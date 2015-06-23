module Main(
  run
, main
) where

import Control.Monad.Trans.Class(MonadTrans(lift))
import Data.NotZero(notZeroElse1)
import Data.NotZeroOr(NotZeroOr(IsNotZero))
import Data.Time(getCurrentTime)
import Geo.OsmandDownload(Parameters(Parameters), ReadParameters((~>.)), time, commands, linkLatest, mkgmap, splitter)
import System.Environment(getArgs)
import Sys.Exit(ExitCodeM, createMakeWaitProcesses, createMakeWaitProcessM, exitWith, exit)
import System.FilePath((</>))
import System.Directory
import System.IO(hPutStrLn, stderr)

run ::
  FilePath
  -> ExitCodeM IO
run d =
  do t <- lift getCurrentTime
     c <- lift getCurrentDirectory
     let u = time t
     let p = Parameters
               (d </> u)
               (c </> mkgmap)
               (c </> splitter)
     createMakeWaitProcesses (commands ~>. p)
     createMakeWaitProcessM (linkLatest d u)
     

-- http://download.osmand.net/list.php
-- http://download.osmand.net/download.php?standard=yes&file=Australia-oceania_2.obf.zip
-- http://download.osmand.net/download.php?standard=yes&file=Indonesia_asia_2.obf.zip    
main ::
  IO ()
main =
  do a <- getArgs
     case a of
       [] -> hPutStrLn stderr "Usage: osmand-download <output-dir>" >> exitWith (IsNotZero (notZeroElse1 129))
       (o:_) -> exit (run o)
