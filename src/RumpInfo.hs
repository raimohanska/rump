{-# LANGUAGE OverloadedStrings, DeriveDataTypeable #-}

module RumpInfo where

import           Data.Typeable
import           Data.Data
import           GeoLocation

data RumpInfo = RumpInfo { userId :: String, displayName :: String, location :: GeoLoc} deriving (Data, Typeable)

instance Show RumpInfo where
  show (RumpInfo userId _ loc) = userId ++ "@" ++ (show loc)



