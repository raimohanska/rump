module Meeting(newMeeting, addParticipant, notifyParticipant, currentParticipants, finalParticipants, app, Meeting) where 

import RumpInfo
import Control.Concurrent.STM.TVar
import Control.Concurrent.STM.TMVar
import Control.Monad.STM
import GHC.Conc.Sync
import Reactive.Bacon

data Meeting = Meeting { 
  app :: String, 
  participants :: (TVar [RumpInfo]), 
  notifyParticipant :: (RumpInfo -> IO ()),
  resultHolder :: TMVar [RumpInfo] 
  }

instance Eq Meeting where
  m1 == m2 = (participants m1) == (participants m2)

newMeeting :: String -> RumpInfo -> (Meeting -> STM ()) -> STM Meeting
newMeeting a dude removeMeeting = unsafeIOToSTM $ do
  resultHolder <- newEmptyTMVarIO
  participantsRef <- newTVarIO [dude]
  (stream, push) <- newPushStream
  let pushParticipant = \newGuy -> do atomically $ modifyTVar (newGuy :) participantsRef
                                      push $ Next ()
  let m = Meeting a participantsRef pushParticipant resultHolder 
  scheduleMeeting m stream removeMeeting
  return m

scheduleMeeting :: Meeting -> EventStream () -> (Meeting -> STM ()) -> IO ()
scheduleMeeting m join removeMeeting = do
    afterJoin <- delayE (seconds 1) join
    laterE (seconds 3) () >>= mergeE afterJoin >>=! const (atomically $ do
      allDudes <- readTVar (participants m)
      putTMVar (resultHolder m) allDudes
      writeTVar (participants m) []
      removeMeeting m)

currentParticipants :: Meeting -> STM [RumpInfo]
currentParticipants = readTVar . participants

addParticipant m dude = modifyTVar (dude :) $ participants m
 
finalParticipants :: Meeting -> STM [RumpInfo]
finalParticipants meeting = readTMVar $ resultHolder meeting

modifyTVar f var = do
  val <- readTVar var
  writeTVar var (f val)
