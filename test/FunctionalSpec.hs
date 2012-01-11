module FunctionalSpec(functionalTests) where

import Snap.Http.Server.Config
import Test.HUnit
import RumpServer
import Util.HttpTester
import Util.ParallelTest
import Util.TestWrapper

john = "{\"userId\":\"john\",\"displayName\":\"John Kennedy\",\"location\":{\"latitude\":51,\"longitude\":-0.1}}"
jack = "{\"userId\":\"jack\",\"displayName\":\"Jack Kennedy\",\"location\":{\"latitude\":51,\"longitude\":-0.1}}"
saddam = "{\"userId\":\"saddam\",\"displayName\":\"Saddam\",\"location\":{\"latitude\":51,\"longitude\":101}}"
justJohn = "[" ++ john ++ "]"
jackAndJohn = "[" ++ jack ++ "," ++ john ++ "]"
justSaddam = "[" ++ saddam ++ "]"

functionalTests = wrapTest withTestServer $ TestList [
  post "New meeting for new dude" url "/testing" john $ Exactly justJohn
  ,parallelTests "Similar requests to common meeting" [
      post "John" url "/testing" john $ Exactly jackAndJohn
      ,delayTest 1000 $ post "Jack" url "/testing" jack $ Exactly jackAndJohn
      ,post "Distant user to separate meeting" url "/testing" saddam $ Exactly justSaddam
    ]
  ]

port = 8001
url= "http://localhost:" ++ (show port) 

withTestServer = withForkedServer $ RumpServer.serve (setPort port defaultConfig) 

main = runTestTT functionalTests
