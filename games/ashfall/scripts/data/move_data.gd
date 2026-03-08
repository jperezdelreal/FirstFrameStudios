## Data resource for a single fighting game move.
## Pure data — no logic. Each move is a .tres file with frame data,
## damage, and input requirements. Frame Data Is Law.
class_name MoveData
extends Resource

enum MoveType { LIGHT, MEDIUM, HEAVY, SPECIAL }
enum HitType { HIGH, MID, LOW }

@export var move_name: String = ""
@export var input_motion: String = ""   # "qcf","qcb","dp","hcf","hcb","double_qcf" or "" for normals
@export var input_button: String = ""   # "lp","hp","lk","hk"

# Frame data — integers, not floats. Deterministic.
@export var startup_frames: int = 4
@export var active_frames: int = 2
@export var recovery_frames: int = 6

# Damage & combat properties
@export var damage: int = 30
@export var chip_damage: int = 0
@export var hitstun_frames: int = 12
@export var blockstun_frames: int = 8
@export var knockback: Vector2 = Vector2(100, 0)
@export var launch_force: Vector2 = Vector2.ZERO

@export var move_type: MoveType = MoveType.LIGHT
@export var hit_type: HitType = HitType.MID

# Stance requirements
@export var requires_crouch: bool = false
@export var requires_air: bool = false

# Cancel routes — move names this can cancel into
@export var can_cancel_into: PackedStringArray = []

func total_frames() -> int:
	return startup_frames + active_frames + recovery_frames
