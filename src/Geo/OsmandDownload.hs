module Geo.OsmandDownload where

import Data.Time(UTCTime(utctDay, utctDayTime), TimeOfDay(TimeOfDay), toGregorian, timeToTimeOfDay)
import Sys.Exit(CreateProcess, procIn)
import System.FilePath((</>))

time ::
  UTCTime
  -> String
time t =
  let show2 = let s2 [x] = ['0', x]
                  s2 x = x
              in s2 . show
      (y, m, d) = toGregorian (utctDay t)
      TimeOfDay h n s = timeToTimeOfDay (utctDayTime t)
  in concat [show y, show2 m, show2 d, "-", show2 h, show2 n, show2 (floor s)]

downloadDirectory ::
  FilePath
downloadDirectory =
  "download"

buildDirectory ::
  FilePath
buildDirectory =
  "build"

distDirectory ::
  FilePath
distDirectory =
  "dist"

getObf ::
  FilePath
  -> FilePath
  -> CreateProcess
getObf obf wd =
  let z = obf ++ ".obf.zip"
  in procIn (wd </> downloadDirectory) "wget"
        [
          "-c"
        , "http://download.osmand.net/download.php?standard=yes&file=" ++ z
        , "-O"
        , z
        ]

unzipObf ::
  FilePath
  -> FilePath
  -> CreateProcess
unzipObf obf wd =
  let z = obf ++ ".obf.zip"
  in procIn wd "unzip"
        [
          "-d"
        , wd </> buildDirectory
        , downloadDirectory </> z
        ]

renameObf ::
  FilePath
  -> FilePath
  -> FilePath
  -> CreateProcess
renameObf obf1 obf2 wd =
  procIn (wd </> buildDirectory) "mv"
    [
      "-v"
    , obf1 ++ ".obf"
    , obf2 ++ ".obf"
    ]

distObf ::
  FilePath
  -> FilePath
  -> CreateProcess
distObf obf wd =
  procIn (wd </> distDirectory) "ln"
    [
      "-s"
    , ".." </> buildDirectory </> obf ++ ".obf"
    ]

australiaOceania ::
  FilePath
  -> [CreateProcess]
australiaOceania =
  sequence
    [
      getObf "Australia-oceania_2"
    , unzipObf "Australia-oceania_2"
    , renameObf "Australia-oceania_2" "Australia-oceania"
    , distObf "Australia-oceania"
    ]

indonesiaAsia ::
  FilePath
  -> [CreateProcess]
indonesiaAsia =
  sequence
    [
      getObf "Indonesia_asia_2"
    , unzipObf "Indonesia_asia_2"
    , renameObf "Indonesia_asia_2" "Indonesia_asia"
    , distObf "Indonesia_asia"
    ]

usColoradoNorthAmerica ::
  FilePath
  -> [CreateProcess]
usColoradoNorthAmerica =
  sequence
    [
      getObf "Us_colorado_northamerica_2"
    , unzipObf "Us_colorado_northamerica_2"
    , renameObf "Us_colorado_northamerica_2" "Us_colorado_northamerica"
    , distObf "Us_colorado_northamerica"
    ]

usCaliforniaNorthAmerica ::
  FilePath
  -> [CreateProcess]
usCaliforniaNorthAmerica =
  sequence
    [
      getObf "Us_california_northamerica_2"
    , unzipObf "Us_california_northamerica_2"
    , renameObf "Us_california_northamerica_2" "Us_california_northamerica"
    , distObf "Us_california_northamerica"
    ]

commands ::
  FilePath
  -> [CreateProcess]
commands =
  fmap concat . sequence $
    [
      australiaOceania
    , indonesiaAsia
    , usColoradoNorthAmerica
    , usCaliforniaNorthAmerica
    ]

linkLatest ::
  FilePath
  -> String
  -> CreateProcess
linkLatest d t =
  procIn d "ln"
    [
      "-f"
    , "-s"
    , "-n"
    , t
    , "latest"
    ]
