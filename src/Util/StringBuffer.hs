module Util.StringBuffer(StringBuffer, newSB, appendSB, readSB) where

import Data.IORef
import Control.Monad

data StringBuffer = StringBuffer (IORef [String])
newSB = liftM StringBuffer $ newIORef []
appendSB sb s = modifyIORef sb (s :)
readSB = readIORef >=> return . concat
