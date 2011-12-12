{-# LANGUAGE OverloadedStrings, DeriveDataTypeable #-}
module RumpServer where
import           Snap.Http.Server
import           Snap.Core
import           Control.Monad.Trans
import           Snap.Util.FileServe
import           Text.JSON.Generic
import           RumpInfo
import           Plaza
import           GeoLocation
import           Util.HttpUtil

main :: IO ()
main = serve defaultConfig

serve :: Config Snap a -> IO()
serve config = do
    plaza <- newPlaza
    httpServe config $ route [ 
      ("/:app", rump plaza), 
      ("", serveDirectory "resources/static")
      ]

rump :: Plaza -> Snap ()
rump plaza = do 
    body <- readBody
    appPar <- getPar("app")
    case appPar of
      Nothing -> notFound
      Just(app) -> do 
        liftIO $ putStrLn $ "app=" ++ app ++ " body=" ++ body
        let request = decodeJSON body :: RumpInfo
        reply <- liftIO $ findBuddies plaza app request
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

