module Plaza where

import RumpInfo
import GeoLocation
import Control.Concurrent(threadDelay, forkIO, ThreadId)
import Control.Concurrent.MVar
import Data.IORef
import Control.Concurrent.STM.TVar
import Control.Concurrent.STM.TMVar
import Control.Monad.STM
import System.IO.Unsafe
import GHC.Exts(sortWith)
import Data.Maybe(listToMaybe)

findBuddies :: String -> RumpInfo -> IO [RumpInfo]
findBuddies app req = do m <- findMeeting req 
                         atomically $ getParticipants m

data Meeting = Meeting { participants :: (TVar [RumpInfo]), resultHolder :: TMVar [RumpInfo] } deriving (Eq)

distanceLimit :: Meters
distanceLimit = 1000

currentMeetings :: TVar ([Meeting])
currentMeetings = unsafePerformIO $ newTVarIO [] 

findMeeting :: RumpInfo -> IO Meeting
findMeeting dude = do
  (meeting, initializer) <- atomically $ lookupMeeting dude
  initializer
  return meeting

lookupMeeting :: RumpInfo -> STM (Meeting, IO ())
lookupMeeting dude = do openMeetings <- readTVar currentMeetings
                        current <- pickMeeting dude openMeetings
                        case current of
                            Nothing -> do 
                              m <- newMeeting dude
                              modifyTVar (m :) currentMeetings
                              return (m, scheduleMeeting m)
                            Just m -> do
                              modifyTVar (dude :) (participants m)
                              return (m, nop)

pickMeeting :: RumpInfo -> [Meeting] -> STM (Maybe Meeting)
pickMeeting dude meetings = do
  distances <- sequence $ map (distanceToMeeting dude) meetings
  return $ listToMaybe $ map fst $ filter ((<= distanceLimit) . snd) $ zip meetings distances
  where distanceToMeeting dude meeting = do dudes <- readTVar $ participants meeting 
                                            return $ minimum $ map (distance (location dude)) $ map location $ dudes

newMeeting :: RumpInfo -> STM Meeting
newMeeting dude = do
  resultHolder <- newEmptyTMVar
  participantsRef <- newTVar [dude]
  return $ Meeting participantsRef resultHolder 

scheduleMeeting :: Meeting -> IO ()
scheduleMeeting m = void $ forkIO $ do
    threadDelay $ toMicros 3 
    atomically $ do
      allDudes <- readTVar (participants m)
      putTMVar (resultHolder m) allDudes
      modifyTVar (filter (/= m)) currentMeetings
 
getParticipants :: Meeting -> STM [RumpInfo]
getParticipants meeting = readTMVar $ resultHolder meeting

toMicros = (*1000000)
nop = return ()
void action = action >> return ()
modifyTVar f var = do
  val <- readTVar var
  writeTVar var (f val)


