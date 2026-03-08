## Knockout / knockdown state. Terminal state for the round.
## Fighter falls, plays KO animation, and emits round_over after
## the KO pause. 180-frame safety timeout prevents stuck rounds.
## Exit path: None (round manager resets fighters for next round).
class_name KOState
extends FighterState

const KO_PAUSE_FRAMES: int = 120
const SAFETY_TIMEOUT: int = 180

var _ko_announced: bool = false


func enter(args: Dictionary) -> void:
	super.enter(args)
	_ko_announced = false
	if fighter:
		fighter.velocity.x = 0


func physics_update() -> void:
	super.physics_update()
	if not fighter:
		return

	# Let the fighter fall if airborne
	if not fighter.is_on_floor():
		fighter.velocity.y += fighter.gravity / 60.0
	else:
		fighter.velocity.y = 0
		fighter.velocity.x = move_toward(fighter.velocity.x, 0.0, 20.0)

	fighter.move_and_slide()

	# Announce KO via EventBus after the pause
	if not _ko_announced and frames_in_state >= KO_PAUSE_FRAMES:
		_ko_announced = true
		EventBus.announce.emit("K.O.!")

	# Safety: if stuck longer than timeout, force round-over signal
	if frames_in_state >= SAFETY_TIMEOUT and not _ko_announced:
		_ko_announced = true
		EventBus.announce.emit("K.O.!")
