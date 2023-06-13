module Main where
import System.Process (readProcess, runCommand, CreateProcess (std_out), StdStream (CreatePipe), createProcess, shell)
import GHC.IO.Handle (hGetLine)
import Control.Monad (when, void)
import Data.List (isInfixOf)

processCommand :: String -> IO ()
processCommand line = do
  -- Process the line or perform any desired actions
  -- putStrLn $ "Received event: " ++ line
  when ("switch tablet-mode state 1" `isInfixOf` line) $ do
      void $ runCommand "xmonadctl layout-tablet"
  when ("switch tablet-mode state 0" `isInfixOf` line) $ do
      void $ runCommand "xmonadctl layout-normal"

main :: IO ()
main = do
  -- use libinput to find the device id of `Asus WMI hotkeys`
  deviceID <- readProcess "sh" ["-c", "libinput list-devices | grep 'Asus WMI hotkeys' -A 2 | grep -o '/dev/input/event[0-9]*'"] ""
  -- use `libinput debug-events --device deviceID` to listen for events
  -- specifically, call the above command and whenever a new line is printed, run the function `processCommand` with the line as an argument
  (_, Just stdoutHandle, _, processHandle) <- createProcess (shell $ "libinput debug-events --device " ++ deviceID) { std_out = CreatePipe }
  -- Continuously read and process lines from the command output
  let loop = do
        line <- hGetLine stdoutHandle
        processCommand line
        loop 
  loop
