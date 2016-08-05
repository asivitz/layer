{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE DeriveGeneric #-}

module Control.Layer.Debug where

import Control.Layer
import Control.Lens
import Data.List
import GHC.Generics

data DebugMsg = FlipDebug
              | StepForward
              | JumpForward
              | StepBackward
              | JumpBackward

data DebugState model = DebugState {
             _isDebugging :: Bool,
             _modelStack :: [model],
             _stackIndex :: Int,
             _current :: model
             }
             deriving (Show, Generic)

mkDebugState = DebugState False [] 0

debugInput :: DebugState b -> DebugMsg -> DebugState b
debugInput debugstate@DebugState { _isDebugging, _stackIndex, _modelStack } input = state'
        where state' = case input of
                         FlipDebug -> if _isDebugging
                                          then debugstate { _isDebugging = not _isDebugging, _stackIndex = 0, _modelStack = drop _stackIndex _modelStack }
                                          else debugstate { _isDebugging = not _isDebugging, _stackIndex = 0 }
                         StepForward -> debugstate { _stackIndex = max 0 (_stackIndex - 1) }
                         JumpForward -> debugstate { _stackIndex = max 0 (_stackIndex - 10) }
                         StepBackward -> debugstate { _stackIndex = min (length _modelStack - 1) (max 0 (_stackIndex + 1)) }
                         JumpBackward -> debugstate { _stackIndex = min (length _modelStack - 1) (max 0 (_stackIndex + 10)) }

debugStep :: DebugState b -> DebugState b -> DebugState b
debugStep oldstate debugstate@DebugState { _isDebugging, _modelStack, _stackIndex, _current } =
        if _isDebugging
            then set current (_modelStack !! _stackIndex) debugstate
            else set modelStack (_current : (if length _modelStack > 1500 then take 1500 _modelStack else _modelStack)) debugstate

liftDebug :: Layer b i -> Layer (DebugState b) i
liftDebug layer = resolveDiff debugStep (liftState current layer)

-- GENERATED #################
-- makeLenses ''DebugState
current :: forall model_aI9. Lens' (DebugState model_aI9) model_aI9
current f_a6OS (DebugState x_a6OT x_a6OU x_a6OV x_a6OW)
    = fmap
        (\ y_a6OX -> DebugState x_a6OT x_a6OU x_a6OV y_a6OX)
        (f_a6OS x_a6OW)
{-# INLINE current #-}
isDebugging :: forall model_aI9. Lens' (DebugState model_aI9) Bool
isDebugging f_a6OY (DebugState x_a6OZ x_a6P0 x_a6P1 x_a6P2)
    = fmap
        (\ y_a6P3 -> DebugState y_a6P3 x_a6P0 x_a6P1 x_a6P2)
        (f_a6OY x_a6OZ)
{-# INLINE isDebugging #-}
modelStack ::
    forall model_aI9. Lens' (DebugState model_aI9) [model_aI9]
modelStack f_a6P4 (DebugState x_a6P5 x_a6P6 x_a6P7 x_a6P8)
    = fmap
        (\ y_a6P9 -> DebugState x_a6P5 y_a6P9 x_a6P7 x_a6P8)
        (f_a6P4 x_a6P6)
{-# INLINE modelStack #-}
stackIndex :: forall model_aI9. Lens' (DebugState model_aI9) Int
stackIndex f_a6Pa (DebugState x_a6Pb x_a6Pc x_a6Pd x_a6Pe)
    = fmap
        (\ y_a6Pf -> DebugState x_a6Pb x_a6Pc y_a6Pf x_a6Pe)
        (f_a6Pa x_a6Pd)
{-# INLINE stackIndex #-}
-- ##########################
