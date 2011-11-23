{-# LANGUAGE OverloadedStrings, DeriveDataTypeable #-}
module Main where
import           Snap.Http.Server
import           Snap.Http.Server.Config
import           Snap.Core
import           Control.Monad
import           Control.Monad.Trans
import           Data.ByteString (ByteString)
import           Snap.Util.FileServe
import qualified Data.ByteString.Lazy.Char8 as L8
import           Text.JSON.Generic
import           RumpInfo
import           Plaza
import           GeoLocation
import           Util.Http

main :: IO ()
main = serve defaultConfig

serve :: Config Snap a -> IO()
serve config = httpServe config $ route [ 
  ("/:app", rump), 
  ("", serveDirectory "resources/static")
  ] 

rump = do 
    body <- readBody
    appPar <- getPar("app")
    case appPar of
      Nothing -> notFound
      Just(app) -> do 
        liftIO $ putStrLn $ "app=" ++ app ++ " body=" ++ body
        let request = decodeJSON body :: RumpInfo
        reply <- liftIO $ findBuddies app request
        let distances = distancesBetween reply
        liftIO $ putStrLn $ "distances=" ++ (show distances)
        modifyResponse $ setContentType "application/json"
        writeResponse $ encodeJSON $ reply  

data DistanceBetween a = DistanceBetween a a Meters
instance Show a => Show (DistanceBetween a) where
  show (DistanceBetween from to meters) = (show from) ++ "<->" ++ (show to) ++ ": " ++ (show meters) ++ " meters"

distancesBetween :: [RumpInfo] -> [DistanceBetween RumpInfo]
distancesBetween dudes = map (\(a, b) -> DistanceBetween a b $ dist a b) pairs
  where pairs = zip dudes (tail dudes)
        dist a b = distance (location a) (location b)
