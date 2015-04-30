module Paths_suck (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/Users/nhalford/Dropbox/UChicago/Third year/Spring/CMSC 22311/lab1/suck/.cabal-sandbox/bin"
libdir     = "/Users/nhalford/Dropbox/UChicago/Third year/Spring/CMSC 22311/lab1/suck/.cabal-sandbox/lib/x86_64-osx-ghc-7.10.1/suck_17dYAXb0kvA79xf2aHgA3B"
datadir    = "/Users/nhalford/Dropbox/UChicago/Third year/Spring/CMSC 22311/lab1/suck/.cabal-sandbox/share/x86_64-osx-ghc-7.10.1/suck-0.1.0.0"
libexecdir = "/Users/nhalford/Dropbox/UChicago/Third year/Spring/CMSC 22311/lab1/suck/.cabal-sandbox/libexec"
sysconfdir = "/Users/nhalford/Dropbox/UChicago/Third year/Spring/CMSC 22311/lab1/suck/.cabal-sandbox/etc"

getBinDir, getLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "suck_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "suck_libdir") (\_ -> return libdir)
getDataDir = catchIO (getEnv "suck_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "suck_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "suck_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
