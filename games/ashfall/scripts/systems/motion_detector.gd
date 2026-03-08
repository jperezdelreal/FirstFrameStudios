## Scans the input buffer for directional motion sequences.
## Uses numpad notation: 236 = QCF, 623 = DP, 214 = QCB, etc.
## Respects facing direction — motions auto-flip when facing left.
## Priority: more complex motions checked first (DP > QCF).
class_name MotionDetector
extends RefCounted

const MOTION_WINDOW: int = 15  # frames to complete a motion

## Detect the highest-priority motion present in the buffer.
## Returns motion name or "" if none found.
static func detect_motion(buffer: Array, facing_right: bool) -> String:
	# Check most complex motions first for priority
	if _check_sequence(buffer, _get_double_qcf(facing_right)):
		return "double_qcf"
	if _check_sequence(buffer, _get_hcf(facing_right)):
		return "hcf"
	if _check_sequence(buffer, _get_hcb(facing_right)):
		return "hcb"
	if _check_sequence(buffer, _get_dp(facing_right)):
		return "dp"
	if _check_sequence(buffer, _get_qcf(facing_right)):
		return "qcf"
	if _check_sequence(buffer, _get_qcb(facing_right)):
		return "qcb"
	return ""

## Check for a specific motion in the buffer.
static func detect_specific(buffer: Array, motion: String, facing_right: bool) -> bool:
	match motion:
		"qcf":
			return _check_sequence(buffer, _get_qcf(facing_right))
		"qcb":
			return _check_sequence(buffer, _get_qcb(facing_right))
		"dp":
			return _check_sequence(buffer, _get_dp(facing_right))
		"hcf":
			return _check_sequence(buffer, _get_hcf(facing_right))
		"hcb":
			return _check_sequence(buffer, _get_hcb(facing_right))
		"double_qcf":
			return _check_sequence(buffer, _get_double_qcf(facing_right))
		"":
			return true  # No motion required
	return false

## Scan the buffer for a directional sequence within the motion window.
## Each step in the sequence must appear in order (not necessarily consecutive).
static func _check_sequence(buffer: Array, sequence: Array[Dictionary]) -> bool:
	if buffer.is_empty() or sequence.is_empty():
		return false
	var seq_index: int = 0
	var start: int = maxi(0, buffer.size() - MOTION_WINDOW)
	for i in range(start, buffer.size()):
		if _matches_direction(buffer[i], sequence[seq_index]):
			seq_index += 1
			if seq_index >= sequence.size():
				return true
	return false

## Check if an input frame matches a required direction.
## Supports leniency: diagonals satisfy both cardinal components.
static func _matches_direction(input: Dictionary, required: Dictionary) -> bool:
	for key in required:
		if not input.get(key, false):
			return false
	return true

# --- Motion sequences ---
# Each returns an array of directional requirements.
# Facing-aware: "forward" and "back" resolve based on facing_right.

# Quarter-circle forward: ↓ ↘ → (236)
static func _get_qcf(facing_right: bool) -> Array[Dictionary]:
	var fwd: String = "right" if facing_right else "left"
	return [{"down": true}, {"down": true, fwd: true}, {fwd: true}]

# Quarter-circle back: ↓ ↙ ← (214)
static func _get_qcb(facing_right: bool) -> Array[Dictionary]:
	var back: String = "left" if facing_right else "right"
	return [{"down": true}, {"down": true, back: true}, {back: true}]

# Dragon punch: → ↓ ↘ (623)
static func _get_dp(facing_right: bool) -> Array[Dictionary]:
	var fwd: String = "right" if facing_right else "left"
	return [{fwd: true}, {"down": true}, {"down": true, fwd: true}]

# Half-circle forward: ← ↙ ↓ ↘ → (41236)
static func _get_hcf(facing_right: bool) -> Array[Dictionary]:
	var fwd: String = "right" if facing_right else "left"
	var back: String = "left" if facing_right else "right"
	return [{back: true}, {"down": true, back: true}, {"down": true}, {"down": true, fwd: true}, {fwd: true}]

# Half-circle back: → ↘ ↓ ↙ ← (63214)
static func _get_hcb(facing_right: bool) -> Array[Dictionary]:
	var fwd: String = "right" if facing_right else "left"
	var back: String = "left" if facing_right else "right"
	return [{fwd: true}, {"down": true, fwd: true}, {"down": true}, {"down": true, back: true}, {back: true}]

# Double quarter-circle forward: ↓ ↘ → ↓ ↘ → (236236) — super motions
static func _get_double_qcf(facing_right: bool) -> Array[Dictionary]:
	var fwd: String = "right" if facing_right else "left"
	return [
		{"down": true}, {"down": true, fwd: true}, {fwd: true},
		{"down": true}, {"down": true, fwd: true}, {fwd: true}
	]
