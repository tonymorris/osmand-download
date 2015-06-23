module Main(
  run
, main
) where

import Control.Monad.Trans.Class(MonadTrans(lift))
import Data.NotZero(notZeroElse1)
import Data.NotZeroOr(NotZeroOr(IsNotZero))
import Data.Time(getCurrentTime)
import Geo.OsmandDownload(time, commands, linkLatest)
import System.Environment(getArgs)
import Sys.Exit(ExitCodeM, createMakeWaitProcesses, createMakeWaitProcessM, exitWith, exit)
import System.FilePath((</>))
import System.IO(hPutStrLn, stderr)

run ::
  FilePath
  -> ExitCodeM IO
run d =
  do t <- lift getCurrentTime
     let u = time t
     let e = d </> u 
     createMakeWaitProcesses (commands e)
     createMakeWaitProcessM (linkLatest d e)
       
main ::
  IO ()
main =
  do a <- getArgs
     case a of
       [] -> hPutStrLn stderr "Usage: osmand-download <output-dir>" >> exitWith (IsNotZero (notZeroElse1 129))
       (o:_) -> exit (run o)
