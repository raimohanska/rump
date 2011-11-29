module PlazaTest where

import Test.HUnit
import Plaza
import Control.Concurrent.STM.TVar
import Control.Concurrent.STM
import Control.Monad
import RumpInfo
import GeoLocation

-- TODO: instead of poking at internals, create a test-helper method:

openMeetingsWithParticipants :: STM [[String]]
openMeetingsWithParticipants = undefined

testApp = "test-app"

plazaTests = TestList [
  TestLabel "New meeting for new dude" $ TestCase $ do
    plaza <- newPlaza
    add plaza dude
    meetingList <- getMeetings plaza
    assertEqual "One meeting in list" 1 (length meetingList) 
  ,
  TestLabel "Second dude to same meeting" $ TestCase $ do
    plaza <- newPlaza
    add plaza dude
    add plaza dude
    meetingList <- getMeetings plaza
    assertEqual "Still one meeting in list" 1 (length meetingList)
    participants <- readTVarIO $ participants $ head meetingList
    assertEqual "Two participants in Meeting" 2 (length participants)
  ,
  TestLabel "Distant dude to different meeting" $ TestCase $ do
    plaza <- newPlaza
    add plaza dude
    add plaza dude
    add plaza distantDude
    meetingList <- getMeetings plaza
    assertEqual "Two meetings in list" 2 (length meetingList)
    participants <- readTVarIO $ participants $ meetingList !! 1
    assertEqual "Two participants in original Meeting" 2 (length participants)
  ]

dude = RumpInfo "user" "The User" $ GeoLoc 0 0
distantDude = RumpInfo "user" "The User" $ GeoLoc 100 100

add plaza dude = void $ atomically $ lookupMeeting plaza testApp dude
getMeetings plaza = readTVarIO $ currentMeetings plaza
