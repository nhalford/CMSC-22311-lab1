-- Noah Halford, CMSC 22311
-- spew.hs
-- git repo at https://github.com/nhalford/CMSC-22311-lab1

module Main where

import Data.Array
import Control.Monad.State
import System.Random
import System.Environment

type FastModel = Array Int (String,[(Int,Int)])

type RandState = State StdGen

-- load the model
loadModel :: String -> IO FastModel
loadModel file = do
    contents <- readFile file
    let entries = lines $ contents
    return $ listArray (0, (length entries) -1) $ map read entries

-- based on runModel from CS 161 lecture 18
runModel :: Int -> FastModel -> RandState [String]
runModel i m = iter i where
    iter ix = do
        let (word,freqlist) = m ! ix
        let successors = concat $ map (\(a,b) -> replicate a b) freqlist
        ix' <- state $ randomR (0,length successors - 1)
        let nextIx = successors !! ix'
        let withinBounds = inRange (bounds m) nextIx
        case withinBounds of False -> return [word]
                             True -> fmap (word:) $ iter nextIx

spew :: Int -> String -> IO ()
spew n file = do
    model <- loadModel file
    gen <- newStdGen
    let start = evalState (state $ randomR (bounds model)) gen
    let ends = ['.','!','?']
    let initial = evalState (runModel start model) gen
    let dropFirst = tail $ dropWhile (\x -> not $ (last x) `elem` ends) initial
    -- firstN is actually a list of length n-1
    let (firstN, rem) = splitAt (n-1) dropFirst
    let (final, r:rest) = break (\x -> (last x) `elem` ends) rem
    let result = firstN ++ final ++ [r]
    print $ unwords result

main :: IO ()
main = do
    args <- getArgs
    case args of
        [x] -> spew (read x) "sokal.model"
        _ -> fail "usage: spew n"
