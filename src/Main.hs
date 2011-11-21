{-# LANGUAGE OverloadedStrings, DeriveDataTypeable #-}
module Main where
import           Snap.Http.Server
import           Snap.Http.Server.Config
import           Snap.Core
import           Control.Monad
import           Control.Monad.Trans
import           Data.ByteString (ByteString)
import           Snap.Util.FileServe
import qualified Data.ByteString.Lazy.Char8 as L8
import           Text.JSON.Generic
import           RumpInfo
import           Plaza

main :: IO ()
main = serve defaultConfig

serve :: Config Snap a -> IO()
serve config = httpServe config $ route [ 
  ("/", rump), 
  ("", serveDirectory "resources/static")
  ] 

rump = do 
    body <- liftM L8.unpack getRequestBody
    liftIO $ putStrLn $ "body=" ++ body
    let request = decodeJSON body :: RumpInfo
    reply <- liftIO $ findBuddies request
    modifyResponse $ setContentType "application/json"
    writeLBS $ L8.pack $ encodeJSON $ reply  
