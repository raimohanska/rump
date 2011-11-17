{-# LANGUAGE OverloadedStrings, DeriveDataTypeable #-}

{-|

This is where all the routes and handlers are defined for your site. The
'app' function is the initializer that combines everything together and
is exported by this module.

-}

module Site where

import           Control.Monad
import           Control.Monad.Trans
import           Data.ByteString (ByteString)
import           Snap.Core
import           Snap.Snaplet
import           Snap.Util.FileServe
import qualified Data.ByteString.Lazy.Char8 as L8
import           Application
import           Text.JSON.Generic
import           RumpDomain 
import           Plaza

rump = do 
    body <- liftM L8.unpack getRequestBody
    liftIO $ putStrLn $ "body=" ++ body
    let request = decodeJSON body :: RumpInfo
    reply <- liftIO $ findBuddies request
    writeLBS $ L8.pack $ encodeJSON $ reply  
 

routes :: [(ByteString, Handler App App ())]
routes = [ ("/", rump)
         , ("", serveDirectory "resources/static")
         ]

app :: SnapletInit App App
app = makeSnaplet "rump" "Rump server" Nothing $ do
    addRoutes routes
    return $ App
