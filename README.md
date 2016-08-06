This library assists in building update functions for interactive programs. An update function is of the form

    Model -> Input -> Model

where *Model* is your program's entire state and *Input* is the base input provided by your platform (usually clicks and keypresses and frame ticks).
Such a function can be folded over a list of inputs to provide a new program state.

So for example, if Input is...

    data Input = KeyDown Key
               | Click Point
               | Tick Double

then an update function might look like:

    update :: Model -> Input -> Model
    update model input = case input of
        KeyDown SpaceBar -> ...
        Click pt -> ...
        Tick timeDelta -> ...

However, if your application is nontrivial, then there are likely complex interactions between various pieces of your program state, such as using input to update the UI which then generates events for your core logic to consume. This library provides combinators to make this easier.

-- Functions

The basic data type is a Layer.

    -- An update function that uses inputs of type 'i' to produce new states of type 's'
    Layer s i = s -> i -> s

You can run update functions sequentially with the __\*.\*__ operator:

    updateUI :: Layer Model Input
    updateGame :: Layer Model Input
    
    update = updateUI *.* updateGame

Scope them to a specific lens with the __liftState__ function:

    Model :: (UIState, GameState)
    updateGame :: Layer GameState Input
    updateUI :: Layer UIState Input

    update = liftState _1 updateUI *.* liftState _2 updateGame

Change the input type with __liftInput__:

    data GameInput = GameTick Double
                   | PlayerJump

    updateGame :: Layer GameState GameInput

    playerControls :: Input -> GameInput
    playerControls input = case input of
        Tick delta -> [GameTick delta]
        KeyDown SpaceBar -> [PlayerJump]
        _ -> []

    update = liftState _1 updateUI *.* liftState _2 (liftInput playerControls updateGame)

Conditionally run a layer with __when__:

    Model :: (UIState, GameState, Bool)
    paused :: Model -> Bool
    paused (_,_,isPaused) = isPaused

    update = liftState _1 updateUI *.*
             when (not . paused) (liftState gameState (liftInput playerControls updateGame))

Change the layer function depending on the current state with __dynamic__:

    update = liftState _1 updateUI *.*
             when (not . paused) (liftState gameState (liftInput playerControls updateGame))
