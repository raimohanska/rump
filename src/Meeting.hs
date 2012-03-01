module Meeting(newMeeting, addParticipant, currentParticipants, finalParticipants, app, Meeting) where 

import RumpInfo
import Control.Concurrent.STM.TVar
import Control.Concurrent.STM.TMVar
import Control.Monad.STM
import GHC.Conc.Sync
import Reactive.Bacon

data Meeting = Meeting { 
  app :: String, 
  participants :: (TVar [RumpInfo]), 
  addParticipant :: (RumpInfo -> STM ()),
  resultHolder :: TMVar [RumpInfo] 
  }

instance Eq Meeting where
  m1 == m2 = (participants m1) == (participants m2)

newMeeting :: String -> RumpInfo -> (Meeting -> STM ()) -> STM Meeting
newMeeting a dude removeMeeting = unsafeIOToSTM $ do
  resultHolder <- newEmptyTMVarIO
  participantsRef <- newTVarIO [dude]
  let pushParticipant = \newGuy -> modifyTVar (newGuy :) participantsRef
  let m = Meeting a participantsRef pushParticipant resultHolder 
  scheduleMeeting m removeMeeting
  return m

scheduleMeeting :: Meeting -> (Meeting -> STM ()) -> IO ()
scheduleMeeting m removeMeeting = do
    laterE (seconds 3) () >>=! \_ -> atomically $ do
      allDudes <- readTVar (participants m)
      putTMVar (resultHolder m) allDudes
      writeTVar (participants m) []
      removeMeeting m

currentParticipants :: Meeting -> STM [RumpInfo]
currentParticipants = readTVar . participants
 
finalParticipants :: Meeting -> STM [RumpInfo]
finalParticipants meeting = readTMVar $ resultHolder meeting

modifyTVar f var = do
  val <- readTVar var
  writeTVar var (f val)
