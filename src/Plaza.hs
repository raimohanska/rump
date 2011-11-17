module Plaza(findBuddies) where

import RumpDomain
import Control.Concurrent(threadDelay, forkIO, ThreadId)
import Control.Concurrent.MVar
import Data.IORef
import Control.Concurrent.STM.TVar
import Control.Concurrent.STM.TMVar
import Control.Monad.STM
import System.IO.Unsafe

findBuddies :: RumpInfo -> IO [RumpInfo]
findBuddies req = do m <- findMeeting req 
                     atomically $ getParticipants m

data Meeting = Meeting { participants :: (TVar [RumpInfo]), resultHolder :: TMVar [RumpInfo] }

currentMeeting :: TVar (Maybe Meeting)
currentMeeting = unsafePerformIO $ newTVarIO Nothing 

findMeeting :: RumpInfo -> IO Meeting
findMeeting dude = do
  (meeting, initializer) <- atomically $ lookupMeeting dude
  initializer
  return meeting

lookupMeeting :: RumpInfo -> STM (Meeting, IO ())
lookupMeeting dude = do current <- readTVar currentMeeting
                        case current of
                            Nothing -> do 
                              m <- newMeeting dude
                              writeTVar currentMeeting (Just m)
                              return (m, scheduleMeeting m)
                            Just m -> do
                              modifyTVar (dude :) (participants m)
                              return (m, nop)

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
      writeTVar currentMeeting Nothing
 
getParticipants :: Meeting -> STM [RumpInfo]
getParticipants meeting = readTMVar $ resultHolder meeting

toMicros = (*1000000)
nop = return ()
void action = action >> return ()
modifyTVar f var = do
  val <- readTVar var
  writeTVar var (f val)


