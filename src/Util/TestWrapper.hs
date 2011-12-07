module Util.TestWrapper where

import Test.HUnit

wrapTest :: Wrapper -> Test -> Test
wrapTest wrapper (TestCase a) = TestCase $ wrapper a
wrapTest wrapper (TestList tests) = TestList $ map (wrapTest wrapper) tests
wrapTest wrapper (TestLabel label test) = TestLabel label $ wrapTest wrapper test

type Wrapper = IO () -> IO ()
