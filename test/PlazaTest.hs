module PlazaTest where

import Test.HUnit
import Plaza
import Control.Concurrent.STM.TVar
import Control.Concurrent.STM
import RumpInfo
import GeoLocation


-- TODO: instead of poking at internals, create a test-helper method:

openMeetingsWithParticipants :: STM [[String]]
openMeetingsWithParticipants = undefined

plazaTests = TestList [
  TestLabel "New meeting for new dude" $ TestCase $ do
    (m, _) <- atomically $ lookupMeeting dude
    meetingList <- readTVarIO currentMeetings
    assertEqual "One meeting in list" 1 (length meetingList) 
  ,
  TestLabel "Second dude to same meeting" $ TestCase $ do
    (m, _) <- atomically $ lookupMeeting dude
    meetingList <- readTVarIO currentMeetings
    assertEqual "Still one meeting in list" 1 (length meetingList)
    participants <- readTVarIO $ participants $ head meetingList
    assertEqual "Two participants in Meeting" 2 (length participants)
  ,
  TestLabel "Distant dude to different meeting" $ TestCase $ do
    (m, _) <- atomically $ lookupMeeting distantDude
    meetingList <- readTVarIO currentMeetings
    assertEqual "Two meetings in list" 2 (length meetingList)
    participants <- readTVarIO $ participants $ meetingList !! 1
    assertEqual "Two participants in original Meeting" 2 (length participants)
  ]

dude = RumpInfo "user" "The User" $ GeoLoc 0 0
distantDude = RumpInfo "user" "The User" $ GeoLoc 100 100
