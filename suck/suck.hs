-- Noah Halford, CMSC 22311
-- suck.hs
-- git repo at https://github.com/nhalford/CMSC-22311-lab1

module Main where

import qualified Data.Map.Strict as M
import Data.Array
import Data.List
import Data.Maybe
import Data.Char
import Network.HTTP
import Text.HTML.TagSoup
import Control.Monad.State
import System.Environment

type PrimitiveModel = M.Map (String,String) [String]
type ProcessedModel = [(String,[(Int,Int)])]

-- make a frequency list from a PrimitiveModel
modelToFreqList :: PrimitiveModel -> (String, String) -> [(Int,String)]
modelToFreqList m k = case M.lookup k m of Nothing -> []
                                           Just xs -> reverse $ sort $ freq xs 
    where freq [] = []
          freq y@(x:xs) = (length $ elemIndices x y, x) :
                (freq $ filter (/= x) xs)

-- extract all (x,y) pairs from the model and serialize
modelToIDs :: PrimitiveModel -> M.Map (String,String) Int
modelToIDs m = M.fromList $ zip (map fst $ M.toList m) [0..]

-- create a ProcessedModel from a PrimitiveModel
processModel :: PrimitiveModel -> ProcessedModel
processModel m = map (\(_,k) -> (snd k, freqInd k)) ids 
    where idMap = modelToIDs m
          ids = sort $ map (\(k,v) -> (v,k)) $ M.toList idMap
          ind pair = fromJust $ M.lookup pair idMap
          freqs k = modelToFreqList m k
          freqInd (x,y) = map (\(f,z) -> (f, result y z)) (freqs (x,y)) where
                result y z = case M.lookup (y,z) idMap of Nothing -> -1
                                                          Just n -> n

-- export a ProcessedModel to a file
exportToFile :: String -> ProcessedModel -> IO ()
exportToFile path = writeFile path . unlines . map show 

-- update a PrimitiveModel from three consecutive words
updateModel :: PrimitiveModel -> String -> String -> String -> PrimitiveModel
updateModel m x y z
    | M.lookup (x,y) m == Nothing = M.insert (x,y) [z] m
    | otherwise = M.adjust (\zs -> z:zs) (x,y) m

-- get contents of a URL
getURLContents :: String -> IO String
getURLContents url = simpleHTTP (getRequest url) >>= getResponseBody

-- make list of associations from (correctly ordered) list of strings
makeAssocs :: [String] -> [((String, String),String)]
makeAssocs l
    | length l < 3 = []
    | otherwise = zip (zip l xs) (tail xs)
    where (x:xs) = l

-- make model from list of associations
makeModel :: [((String, String),String)] -> PrimitiveModel
makeModel [] = M.empty
makeModel (x:xs) = updateModel (makeModel xs) a b c
    where ((a,b),c) = x

-- helper function for reading all URLs and writing to files
urlToFile :: Int -> [String] -> IO ()
urlToFile n urls = do
    let url = urls !! n
    let contents = getURLContents url
    tags <- liftM parseTags contents
    let result = map (filter isTagText) $ sections (~== "<p>") $ tags
    let filename = "output/out" ++ (show $ n + 1) ++ ".txt"
    writeFile filename $ unlines $ map fromTagText $ concat result

-- bool tells us if we are in the process of removing a script
harvest :: Bool -> [String] -> [String]
harvest _ [] = []
harvest b ("":ls) = harvest b ls
harvest False (x:xs)
    | all isSpace x = harvest False xs
    | head (dropWhile isSpace x) == '-' = harvest False xs
    | "});" `isPrefixOf` (dropWhile isSpace x) = harvest False xs
    | "$(" `isPrefixOf` (dropWhile isSpace x) = harvest True xs
    | otherwise = [x] ++ harvest False xs
harvest True (x:xs)
    | all isSpace x = harvest True xs
    | (== "});") $ head $ words x = harvest False xs
    | otherwise = harvest True xs

main :: IO ()
main = do
    args <- getArgs
    case args of 
        [arg] -> do
            let fname = arg
            let fname = head args
            urls <- readFile fname
            wordList <- forM (lines urls) $ \u -> do
                let contents = getURLContents u
                tags <- liftM parseTags contents
                let initial = map (filter isTagText) $ sections (~== "<p>") tags
                let result = harvest False $ map fromTagText $ concat initial
                return result
            let allwords = concat $ concat $ map (map words) wordList
            let assocs = makeAssocs allwords
            let primModel = makeModel assocs
            let processedModel = processModel primModel
            exportToFile "sokal.model" processedModel
        _ -> fail "usage: suck filename"
