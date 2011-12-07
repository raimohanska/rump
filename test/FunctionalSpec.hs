module FunctionalSpec where

import Snap.Http.Server.Config
import Test.HUnit
import RumpServer
import Util.HttpTester
import Util.ParallelTest
import Util.TestWrapper

exampleRequest = "{ \"userId\" : \"john\", \"displayName\" : \"John Kennedy\", \"location\": { \"latitude\": 51.0, \"longitude\": -0.1}}"
exampleRequest2 = "{ \"userId\" : \"jack\", \"displayName\" : \"Jack Kennedy\", \"location\": { \"latitude\": 51.0, \"longitude\": -0.1}}"
exampleResponse = "[{\"userId\":\"john\",\"displayName\":\"John Kennedy\",\"location\":{\"latitude\":51,\"longitude\":-0.1}}]"
responseWithTwoGuys = "[{\"userId\":\"jack\",\"displayName\":\"Jack Kennedy\",\"location\":{\"latitude\":51,\"longitude\":-0.1}},{\"userId\":\"john\",\"displayName\":\"John Kennedy\",\"location\":{\"latitude\":51,\"longitude\":-0.1}}]"

functionalTests = wrapTest withTestServer $ TestList [
  post "New meeting for new dude" url "/testing" exampleRequest $ Exactly exampleResponse
  ,parallelTests "Similar requests to common meeting" [
      post "Dude 1" url "/testing" exampleRequest $ Exactly responseWithTwoGuys
      ,delayTest $ post "Dude 1" url "/testing" exampleRequest2 $ Exactly responseWithTwoGuys
    ]
  ]

port = 8001
url= "http://localhost:" ++ (show port) 

withTestServer = withForkedServer $ RumpServer.serve (setPort port defaultConfig) 
