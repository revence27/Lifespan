module Main where

import Control.Concurrent
import System.Environment
import System.Exit
import System.IO
import System.Process

quitAfter :: Int -> (String, [String]) -> IO ExitCode
quitAfter secs (cmd, args) = do
    ans <- newChan
    mst <- forkIO $ do
        pid <- runProcess cmd args Nothing Nothing Nothing Nothing Nothing
        to  <- forkIO $ do
            writeChan ans =<< waitForProcess pid
            killThread =<< myThreadId
        _   <- forkIO $ do
            sequence_ [threadDelay 1000000 | _ <- [1 .. secs]]
            terminateProcess pid
            killThread to
            writeChan ans (ExitFailure 27)
            killThread =<< myThreadId
        return ()
    rez <- readChan ans
    killThread mst
    return rez

main :: IO ()
main = do
    args <- getArgs
    case args of
        (t:c:etc) -> do
            got <- quitAfter (read t) (c, etc)
            exitWith got
        _           -> do
            putStrLn ("Provide the life span in seconds, and the command " ++
                      "to execute.")
            exitFailure
