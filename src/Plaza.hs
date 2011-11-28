module Plaza where

import RumpInfo
import GeoLocation
import Control.Concurrent(threadDelay, forkIO)
import Control.Concurrent.STM.TVar
import Control.Concurrent.STM.TMVar
import Control.Monad.STM
import System.IO.Unsafe
import Data.Maybe(listToMaybe)

findBuddies :: String -> RumpInfo -> IO [RumpInfo]
findBuddies app req = do m <- findMeeting app req 
                         atomically $ getParticipants m

data Meeting = Meeting { app :: String, participants :: (TVar [RumpInfo]), resultHolder :: TMVar [RumpInfo] } deriving (Eq)

distanceLimit :: Meters
distanceLimit = 1000

currentMeetings :: TVar ([Meeting])
currentMeetings = unsafePerformIO $ newTVarIO [] 

findMeeting :: String -> RumpInfo -> IO Meeting
findMeeting app dude = do
  (meeting, initializer) <- atomically $ lookupMeeting app dude
  initializer
  return meeting

lookupMeeting :: String -> RumpInfo -> STM (Meeting, IO ())
lookupMeeting app dude = 
  do openMeetings <- readTVar currentMeetings
     current <- pickMeeting app dude openMeetings
     case current of
        Nothing -> do 
          m <- newMeeting app dude
          modifyTVar (m :) currentMeetings
          return (m, scheduleMeeting m)
        Just m -> do
          modifyTVar (dude :) (participants m)
          return (m, nop)

pickMeeting :: String -> RumpInfo -> [Meeting] -> STM (Maybe Meeting)
pickMeeting application dude allMeetings = do
  let meetings = filter ((== application) . app) allMeetings
  distances <- sequence $ map (distanceToMeeting dude) meetings
  return $ listToMaybe $ map fst $ filter ((<= distanceLimit) . snd) $ zip meetings distances
  where distanceToMeeting dude meeting = do dudes <- readTVar $ participants meeting 
                                            return $ minimum $ map (distance (location dude)) $ map location $ dudes

newMeeting :: String -> RumpInfo -> STM Meeting
newMeeting app dude = do
  resultHolder <- newEmptyTMVar
  participantsRef <- newTVar [dude]
  return $ Meeting app participantsRef resultHolder 

scheduleMeeting :: Meeting -> IO ()
scheduleMeeting m = void $ forkIO $ do
    threadDelay $ toMicros 3 
    atomically $ do
      allDudes <- readTVar (participants m)
      putTMVar (resultHolder m) allDudes
      writeTVar (participants m) []
      modifyTVar (filter (/= m)) currentMeetings
 
getParticipants :: Meeting -> STM [RumpInfo]
getParticipants meeting = readTMVar $ resultHolder meeting

toMicros = (*1000000)
nop = return ()
void action = action >> return ()
modifyTVar f var = do
  val <- readTVar var
  writeTVar var (f val)


