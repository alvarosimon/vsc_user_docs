#!/usr/bin/env runhaskell

import Text.Pandoc.JSON
import Text.Pandoc

import Debug.Trace
import System.Environment


inline :: Block -> IO [Block]
inline h@(Header n attr text) = do
  case lookup "basename" variables of
    Just v -> include v
    Nothing -> return [h]
  where
    (identifiers, classes, variables) = attr
    include f = do
      siteDir <- getEnv "VSC_SITE"
      string <- readFile (siteDir ++ "/" ++ f)
      (Pandoc meta blocks) <- return $ readMarkdown def string
      return blocks

inline cb@(CodeBlock (id, classes, namevals) contents) = do
  case lookup "basename" namevals of
      Just f     -> return . return . (CodeBlock (id, classes, namevals)) =<< readFile f
      Nothing    -> return [cb]

inline x = return [x]

main = toJSONFilter inline

