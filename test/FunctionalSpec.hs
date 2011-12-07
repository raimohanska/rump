module FunctionalSpec where

import Snap.Http.Server.Config
import Test.HUnit
import RumpServer
import Util.HttpTester
import Util.ParallelTest
import Util.TestWrapper

john = "{\"userId\":\"john\",\"displayName\":\"John Kennedy\",\"location\":{\"latitude\":51,\"longitude\":-0.1}}"
jack = "{\"userId\":\"jack\",\"displayName\":\"Jack Kennedy\",\"location\":{\"latitude\":51,\"longitude\":-0.1}}"
justJohn = "[" ++ john ++ "]"
responseWithTwoGuys = "[" ++ jack ++ "," ++ john ++ "]"

functionalTests = wrapTest withTestServer $ TestList [
  post "New meeting for new dude" url "/testing" john $ Exactly justJohn
  ,parallelTests "Similar requests to common meeting" [
      post "Dude 1" url "/testing" john $ Exactly jackAndJohn
      ,delayTest $ post "Dude 1" url "/testing" jack $ Exactly responseWithTwoGuys
    ]
  ]

port = 8001
url= "http://localhost:" ++ (show port) 

withTestServer = withForkedServer $ RumpServer.serve (setPort port defaultConfig) 
