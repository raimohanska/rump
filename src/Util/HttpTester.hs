module Util.HttpTester where

import Snap.Http.Server.Config
import Test.HUnit
import Control.Concurrent(forkIO, threadDelay, killThread)
import qualified Util.HttpClient as HTTP
import Text.Regex.XMLSchema.String(match)
import Control.Exception(finally)
import Util.RegexEscape(escape)
import Util.TestWrapper

data ExpectedResult = Matching String | Exactly String | ReturnCode Int | All [ExpectedResult]

post desc root path request expected = 
  httpTest desc (HTTP.post (root ++ path) request) expected

get desc root path expected = 
  httpTest desc (HTTP.get (root ++ path)) expected

httpTest :: String -> IO (Int, String) -> ExpectedResult -> Test
httpTest desc request expected = TestLabel desc $ TestCase $ do
    (code, body) <- request
    verify (code, body) expected
  where
      verify (code, body) expected = case expected of
        Matching pattern -> assertBool desc (match pattern (body))
        Exactly str -> assertEqual desc str body
        ReturnCode c -> assertEqual desc c code
        All checks -> mapM_ (verify (code, body)) checks

withForkedServer :: IO() -> Wrapper
withForkedServer server task = do
    serverThread <- forkIO server
    threadDelay $ toMicros 1000
    task `finally` (killThread serverThread)

toMicros = (*1000)

