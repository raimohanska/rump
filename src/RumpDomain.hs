{-# LANGUAGE OverloadedStrings, DeriveDataTypeable #-}

module RumpDomain where

import           Data.Typeable
import           Data.Data

data RumpInfo = RumpInfo { userId :: String, displayName :: String, location :: GeoLoc} deriving (Data, Typeable, Show)
data GeoLoc = GeoLoc { latitude :: Double, longitude :: Double } deriving (Data, Typeable, Show)



