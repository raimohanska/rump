module FunctionalSpec where

import Snap.Http.Server.Config
import Test.HUnit
import RumpServer
import Util.HttpTester
import Control.Concurrent.MVar
import Control.Concurrent(forkIO)

exampleRequest = "{ \"userId\" : \"john\", \"displayName\" : \"John Kennedy\", \"location\": { \"latitude\": 51.0, \"longitude\": -0.1}}"
exampleRequest2 = "{ \"userId\" : \"jack\", \"displayName\" : \"Jack Kennedy\", \"location\": { \"latitude\": 51.0, \"longitude\": -0.1}}"
exampleResponse = "[{\"userId\":\"john\",\"displayName\":\"John Kennedy\",\"location\":{\"latitude\":51,\"longitude\":-0.1}}]"
responseWithTwoGuys = "[{\"userId\":\"jack\",\"displayName\":\"Jack Kennedy\",\"location\":{\"latitude\":51,\"longitude\":-0.1}},{\"userId\":\"john\",\"displayName\":\"John Kennedy\",\"location\":{\"latitude\":51,\"longitude\":-0.1}}]"

functionalTests = wrapTest withTestServer $ TestList [
  post "New meeting for new dude" url "/testing" exampleRequest $ Exactly exampleResponse
  ,parallelTests "Similar requests to common meeting" [
      post "Dude 1" url "/testing" exampleRequest $ Exactly responseWithTwoGuys
      ,post "Dude 1" url "/testing" exampleRequest2 $ Exactly responseWithTwoGuys
    ]
  ]

-- TODO: collect output using runTestText http://hackage.haskell.org/packages/archive/HUnit/1.2.4.2/doc/html/Test-HUnit-Text.html#t:PutText
-- 

parallelTests label tests = TestLabel label $ TestCase $ do
    forks <- mapM forkTest tests
    counts <- mapM join forks
    let total = foldr plus (Counts 0 0 0 0) counts
    assertEqual "Errors in parallel tests" 0 (errors total)
    assertEqual "Failures in parallel tests" 0 (failures total) 
  where plus (Counts a1 b1 c1 d1) (Counts a2 b2 c2 d2) = Counts (a1+a2) (b1+b2) (c1+c2) (d1+d2)
        forkTest t = forkAction $ runTestTT t
        forkAction a = do var <- newEmptyMVar
                          forkIO $ a >>= putMVar var
                          return var
        join = takeMVar 

port = 8001
url= "http://localhost:" ++ (show port) 

withTestServer = withForkedServer $ RumpServer.serve (setPort port defaultConfig) 
