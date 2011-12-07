module Util.ParallelTest where

import Control.Concurrent.MVar
import Control.Concurrent(forkIO, threadDelay)
import Control.Monad
import Util.TestWrapper
import Test.HUnit

delayTest millis = wrapTest $ \test -> threadDelay (millis * 1000) >> test

parallelTests label tests = TestLabel label $ TestCase $ do
    forks <- mapM forkTest tests
    countsAndLogs <- mapM join forks
    forM_ (map snd countsAndLogs) (putStrLn . concat . reverse) -- putStrLn was the best I could come up with..
    let counts = map fst countsAndLogs
    let total = foldr plus (Counts 0 0 0 0) counts
    assertEqual "Errors in parallel tests" 0 (errors total)
    assertEqual "Failures in parallel tests" 0 (failures total) 
  where plus (Counts a1 b1 c1 d1) (Counts a2 b2 c2 d2) = Counts (a1+a2) (b1+b2) (c1+c2) (d1+d2)
        forkTest t = forkAction $ runTestText (PutText logToBuffer []) t
        forkAction a = do var <- newEmptyMVar
                          forkIO $ a >>= putMVar var
                          return var
        join = takeMVar 
        logToBuffer line important lines | important = return (line : lines) 
                                         | otherwise = return lines
