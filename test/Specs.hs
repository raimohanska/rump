import FunctionalSpec
import System.Exit(exitFailure)

import Test.HUnit

main = failOnError =<< runTestTT functionalTests

failOnError :: Counts -> IO ()
failOnError (Counts _ _ 0 0) = return ()
failOnError _                = exitFailure
