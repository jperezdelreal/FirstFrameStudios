## Base class for all fighter states. Extends the generic State with a
## typed reference to the owning Fighter. All concrete fighter states
## (idle, walk, attack, etc.) extend this.
class_name FighterState
extends State

## Set by fighter_base.gd in _ready() before the first physics tick.
var fighter: CharacterBody2D
