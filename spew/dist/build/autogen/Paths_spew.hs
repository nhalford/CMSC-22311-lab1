module Paths_spew (
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

bindir     = "/Users/nhalford/.cabal/bin"
libdir     = "/Users/nhalford/.cabal/lib/x86_64-osx-ghc-7.10.1/spew_DzKDLAMWddBGbA7Buh2oeF"
datadir    = "/Users/nhalford/.cabal/share/x86_64-osx-ghc-7.10.1/spew-0.1.0.0"
libexecdir = "/Users/nhalford/.cabal/libexec"
sysconfdir = "/Users/nhalford/.cabal/etc"

getBinDir, getLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "spew_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "spew_libdir") (\_ -> return libdir)
getDataDir = catchIO (getEnv "spew_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "spew_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "spew_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
