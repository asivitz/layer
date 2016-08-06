{-# LANGUAGE Rank2Types #-}

module Control.Layer
    (
    Layer,
    (*.*),
    dynamic,
    postProcess,
    resolveDiff,
    when,
    liftState,
    liftInput,
    liftAndConsumeInput
    ) where

import Data.List
import Control.Lens

type Layer s i = s -> i -> s

(*.*) :: Layer s i -> Layer s i -> Layer s i
l1 *.* l2 = \s i -> l1 (l2 s i) i

dynamic :: (s -> Layer s i) -> Layer s i
dynamic layerf s = layerf s s

postProcess :: (s -> s) -> Layer s i -> Layer s i
postProcess f layer s i = f (layer s i)

resolveDiff :: (s -> s -> s) -> Layer s i -> Layer s i
resolveDiff f layer s i = f s (layer s i)

when :: (s -> Bool) -> Layer s i -> Layer s i
when pred layer s i = if pred s then layer s i else s

liftState :: Lens' s s' -> Layer s' i -> Layer s i
liftState l nextLayer s i = over l (`nextLayer` i) s

liftInput :: (i -> [j]) -> Layer s j -> Layer s i
liftInput inputmap layer s i = foldl' layer s (inputmap i)

liftAndConsumeInput :: (i -> [j]) -> Layer s j -> Layer s i -> Layer s i
liftAndConsumeInput inputmap layer nextLayer s i =
        case inputmap i of
            [] -> nextLayer s i
            js -> foldl' layer s js
