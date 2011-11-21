{-# LANGUAGE OverloadedStrings, DeriveDataTypeable #-}

module GeoLocation where

import           Data.Typeable
import           Data.Data
import qualified Data.Geo as Geo
import           Data.Geo ((|.|), haversine, earthMean)
data GeoLoc = GeoLoc { latitude :: Double, longitude :: Double } deriving (Data, Typeable)

instance Show GeoLoc where
  show (GeoLoc lat lon) = "(" ++ (show lat) ++ "," ++ (show lon) ++ ")"

type Meters = Double

distance :: GeoLoc -> GeoLoc -> Meters
distance from to = haversine earthMean (toCoord from) (toCoord to)
  where toCoord l = Geo.latitude (latitude l) |.| Geo.longitude (longitude l) 





