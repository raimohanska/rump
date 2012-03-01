module Plaza(newPlaza, findBuddies, Plaza) where 

import RumpInfo
import GeoLocation
import Control.Concurrent.STM
import Control.Monad
import Data.Maybe(listToMaybe)
import Meeting

findBuddies :: Plaza -> String -> RumpInfo -> IO [RumpInfo]
findBuddies plaza app req = do m <- findMeeting plaza app req 
                               atomically $ finalParticipants m

newPlaza :: IO Plaza
newPlaza = liftM Plaza $ newTVarIO []

data Plaza = Plaza { currentMeetings :: TVar [Meeting] }

distanceLimit :: Meters
distanceLimit = 1000

findMeeting :: Plaza -> String -> RumpInfo -> IO Meeting
findMeeting plaza app dude = do
  meeting <- atomically $ lookupMeeting plaza app dude
  return meeting

lookupMeeting :: Plaza -> String -> RumpInfo -> STM Meeting
lookupMeeting plaza app dude = 
  do openMeetings <- readTVar $ currentMeetings plaza
     current <- pickMeeting app dude openMeetings
     case current of
        Nothing -> do 
          m <- newMeeting app dude $ removeMeeting plaza
          modifyTVar (m :) $ currentMeetings plaza
          return m
        Just m -> do
          addParticipant m dude
          return m

removeMeeting p m = modifyTVar (filter (/= m)) $ currentMeetings p 

pickMeeting :: String -> RumpInfo -> [Meeting] -> STM (Maybe Meeting)
pickMeeting application dude allMeetings = do
  let meetings = filter ((== application) . app) allMeetings
  distances <- sequence $ map (distanceToMeeting dude) meetings
  return $ listToMaybe $ map fst $ filter ((<= distanceLimit) . snd) $ zip meetings distances
  where distanceToMeeting dude meeting = do dudes <- currentParticipants meeting 
                                            return $ minimum $ map (distance (location dude)) $ map location $ dudes

modifyTVar f var = do
  val <- readTVar var
  writeTVar var (f val)
