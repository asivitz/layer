{-# LANGUAGE Rank2Types #-}

module Control.Layer
    (
    Layer,
    (*.*),
    dynamic,
    resolveDiff,
    when,
    liftState,
    liftInput,
    liftAndConsumeInput
    ) where

import Data.List
import Data.Functor.Identity

-- Grab a few things from Control.Lens so that we don't incur the dependency
type Lens' s a = forall f. Functor f => (a -> f a) -> s -> f s

over :: Lens' s a -> (a -> a) -> s -> s
over l f = runIdentity . l (Identity . f)

type Layer s i = s -> i -> s

(*.*) :: Layer s i -> Layer s i -> Layer s i
l1 *.* l2 = \s i -> l1 (l2 s i) i

dynamic :: (s -> Layer s i) -> Layer s i
dynamic layerf s = layerf s s

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
