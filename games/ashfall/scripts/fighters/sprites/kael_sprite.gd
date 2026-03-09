## Kael — The Cinder Monk. Lean, athletic build. Grey-white gi with
## blue-ember accents. Hair tied back. Calm, composed posture.
## Every pose reads as "focused fighter" — clean lines, precise motion.
class_name KaelSprite
extends CharacterSprite

# Body proportions (relative to 30×60 collision box centered at origin)
const HEAD_R := 7.0          # head radius
const HEAD_Y := -52.0        # head center Y
const NECK_Y := -45.0
const SHOULDER_Y := -42.0
const SHOULDER_W := 12.0     # half-width shoulder span
const TORSO_TOP := -42.0
const TORSO_BOT := -18.0
const TORSO_W := 11.0        # half-width
const WAIST_Y := -18.0
const HIP_Y := -16.0
const KNEE_Y := -8.0
const FOOT_Y := 0.0
const ARM_THICK := 3.5
const LEG_THICK := 4.0
const FIST_R := 3.0
const BOOT_W := 6.0
const BOOT_H := 5.0


func _init_palettes() -> void:
	# P1: Cool discipline — grey-white gi, blue-ember accents, tan skin
	palettes.append({
		"skin": Color(0.85, 0.70, 0.55),
		"hair": Color(0.15, 0.12, 0.10),
		"outfit_primary": Color(0.88, 0.86, 0.82),    # grey-white gi
		"outfit_secondary": Color(0.70, 0.68, 0.64),  # gi shadows
		"accent": Color(0.25, 0.45, 0.85),             # blue-ember
		"accent_glow": Color(0.4, 0.6, 1.0, 0.6),     # ember highlight
		"eye": Color(0.2, 0.2, 0.2),
		"outline": Color(0.12, 0.10, 0.08),
		"wrap": Color(0.65, 0.60, 0.50),               # forearm wraps
		"belt": Color(0.20, 0.18, 0.15),
		"boots": Color(0.30, 0.25, 0.20),
		"sole": Color(0.18, 0.15, 0.12),
	})
	# P2: Warm shift — ochre gi, red-ember accents
	palettes.append({
		"skin": Color(0.80, 0.65, 0.48),
		"hair": Color(0.25, 0.15, 0.08),
		"outfit_primary": Color(0.82, 0.75, 0.58),
		"outfit_secondary": Color(0.68, 0.60, 0.45),
		"accent": Color(0.85, 0.35, 0.15),
		"accent_glow": Color(1.0, 0.5, 0.2, 0.6),
		"eye": Color(0.2, 0.15, 0.1),
		"outline": Color(0.15, 0.10, 0.05),
		"wrap": Color(0.55, 0.45, 0.30),
		"belt": Color(0.25, 0.15, 0.08),
		"boots": Color(0.35, 0.22, 0.12),
		"sole": Color(0.22, 0.14, 0.08),
	})


# =========================================================================
#  IDLE — Calm, centred fighting stance. Weight evenly distributed.
#  Hands up near chin, feet shoulder-width. Reads as "ready & composed".
# =========================================================================
func _draw_idle() -> void:
	var p := pal
	var ol := p.outline

	# --- Legs ---
	# Left leg (slightly back)
	draw_limb(Vector2(-5, HIP_Y), Vector2(-7, KNEE_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-7, KNEE_Y), Vector2(-6, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-6, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	# Right leg (slightly forward)
	draw_limb(Vector2(4, HIP_Y), Vector2(6, KNEE_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(6, KNEE_Y), Vector2(5, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(5, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# --- Torso (gi) ---
	var gi_points := PackedVector2Array([
		Vector2(-TORSO_W, TORSO_TOP), Vector2(TORSO_W, TORSO_TOP),
		Vector2(TORSO_W * 0.9, TORSO_BOT), Vector2(-TORSO_W * 0.9, TORSO_BOT)
	])
	draw_colored_polygon(gi_points, p.outfit_primary)
	draw_polyline(gi_points, ol, 1.0, true)
	# Gi opening (V-neck)
	draw_line(Vector2(0, TORSO_TOP), Vector2(-3, TORSO_TOP + 10), p.outfit_secondary, 1.5)
	draw_line(Vector2(0, TORSO_TOP), Vector2(3, TORSO_TOP + 10), p.outfit_secondary, 1.5)
	# Belt / sash
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y - 2, TORSO_W * 1.8, 4), p.belt)
	# Accent trim on belt
	draw_line(Vector2(-TORSO_W * 0.9, WAIST_Y), Vector2(TORSO_W * 0.9, WAIST_Y), p.accent, 1.0)

	# --- Arms (guard position — hands near chin) ---
	# Back arm (left)
	var l_shoulder := Vector2(-SHOULDER_W, SHOULDER_Y)
	var l_elbow := Vector2(-14, SHOULDER_Y + 8)
	var l_hand := Vector2(-8, SHOULDER_Y + 2)
	draw_limb(l_shoulder, l_elbow, ARM_THICK, p.skin, ol)
	draw_limb(l_elbow, l_hand, ARM_THICK, p.wrap, ol)
	draw_forearm_wraps(l_elbow + (l_hand - l_elbow) * 0.5, 8, 5, p.accent, 2)
	draw_fist(l_hand, FIST_R, p.skin, ol)

	# Front arm (right)
	var r_shoulder := Vector2(SHOULDER_W, SHOULDER_Y)
	var r_elbow := Vector2(14, SHOULDER_Y + 6)
	var r_hand := Vector2(6, SHOULDER_Y + 1)
	draw_limb(r_shoulder, r_elbow, ARM_THICK, p.skin, ol)
	draw_limb(r_elbow, r_hand, ARM_THICK, p.wrap, ol)
	draw_forearm_wraps(r_elbow + (r_hand - r_elbow) * 0.5, 8, 5, p.accent, 2)
	draw_fist(r_hand, FIST_R, p.skin, ol)

	# --- Head ---
	draw_circle_outlined(Vector2(0, HEAD_Y), HEAD_R, p.skin, ol, 1.0)
	# Hair (tied back — dark cap + ponytail line)
	draw_arc(Vector2(0, HEAD_Y), HEAD_R, deg_to_rad(200), deg_to_rad(430), 16, p.hair, 3.0, true)
	draw_line(Vector2(0, HEAD_Y - 2), Vector2(-8, HEAD_Y + 2), p.hair, 2.0, true)
	# Eyes (calm, focused)
	draw_line(Vector2(-3, HEAD_Y - 1), Vector2(-1, HEAD_Y - 1), p.eye, 1.5)
	draw_line(Vector2(1, HEAD_Y - 1), Vector2(3, HEAD_Y - 1), p.eye, 1.5)
	# Mouth (neutral)
	draw_line(Vector2(-2, HEAD_Y + 3), Vector2(2, HEAD_Y + 3), p.eye, 1.0)

	# --- Accent glow on fists (ember energy) ---
	draw_circle(l_hand, FIST_R + 1.5, p.accent_glow)
	draw_circle(r_hand, FIST_R + 1.5, p.accent_glow)


# =========================================================================
#  WALK — Mid-stride. One leg forward, opposite arm forward. Disciplined.
# =========================================================================
func _draw_walk() -> void:
	var p := pal
	var ol := p.outline

	# Legs — stride pose
	draw_limb(Vector2(-4, HIP_Y), Vector2(-10, KNEE_Y + 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-10, KNEE_Y + 2), Vector2(-10, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-10, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(4, HIP_Y), Vector2(8, KNEE_Y - 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(8, KNEE_Y - 2), Vector2(10, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(10, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso (slight forward lean)
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 1, TORSO_TOP), Vector2(TORSO_W + 1, TORSO_TOP),
		Vector2(TORSO_W * 0.9, TORSO_BOT), Vector2(-TORSO_W * 0.9 + 1, TORSO_BOT)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y - 2, TORSO_W * 1.8, 4), p.belt)
	draw_line(Vector2(-TORSO_W * 0.9, WAIST_Y), Vector2(TORSO_W * 0.9, WAIST_Y), p.accent, 1.0)

	# Arms — opposite arm forward (right arm forward, left back)
	draw_limb(Vector2(-SHOULDER_W, SHOULDER_Y), Vector2(-16, SHOULDER_Y + 10), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(-16, SHOULDER_Y + 10), Vector2(-12, SHOULDER_Y + 6), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(-12, SHOULDER_Y + 6), FIST_R, p.skin, ol)

	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y), Vector2(16, SHOULDER_Y + 4), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(16, SHOULDER_Y + 4), Vector2(12, SHOULDER_Y), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(12, SHOULDER_Y), FIST_R, p.skin, ol)

	# Head
	_draw_head_calm(Vector2(1, HEAD_Y))


func _draw_walk_2() -> void:
	var p := pal
	var ol := p.outline

	# Legs — opposite stride
	draw_limb(Vector2(-4, HIP_Y), Vector2(-6, KNEE_Y - 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-6, KNEE_Y - 2), Vector2(-4, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-4, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(4, HIP_Y), Vector2(10, KNEE_Y + 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(10, KNEE_Y + 2), Vector2(8, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(8, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 1, TORSO_TOP), Vector2(TORSO_W + 1, TORSO_TOP),
		Vector2(TORSO_W * 0.9, TORSO_BOT), Vector2(-TORSO_W * 0.9 + 1, TORSO_BOT)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y - 2, TORSO_W * 1.8, 4), p.belt)
	draw_line(Vector2(-TORSO_W * 0.9, WAIST_Y), Vector2(TORSO_W * 0.9, WAIST_Y), p.accent, 1.0)

	# Arms — swapped from walk
	draw_limb(Vector2(-SHOULDER_W, SHOULDER_Y), Vector2(-14, SHOULDER_Y + 4), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(-14, SHOULDER_Y + 4), Vector2(-10, SHOULDER_Y), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(-10, SHOULDER_Y), FIST_R, p.skin, ol)

	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y), Vector2(16, SHOULDER_Y + 10), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(16, SHOULDER_Y + 10), Vector2(12, SHOULDER_Y + 6), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(12, SHOULDER_Y + 6), FIST_R, p.skin, ol)

	_draw_head_calm(Vector2(1, HEAD_Y))


# =========================================================================
#  ATTACK — Light Punch: Quick, precise jab. Small wind-up, clean line.
# =========================================================================
func _draw_attack_lp() -> void:
	var p := pal
	var ol := p.outline

	# Legs — planted, stable
	draw_limb(Vector2(-5, HIP_Y), Vector2(-8, KNEE_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-8, KNEE_Y), Vector2(-7, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-7, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(4, HIP_Y), Vector2(6, KNEE_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(6, KNEE_Y), Vector2(6, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(6, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — slight rotation toward punch
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 2, TORSO_TOP), Vector2(TORSO_W, TORSO_TOP),
		Vector2(TORSO_W * 0.9 - 1, TORSO_BOT), Vector2(-TORSO_W * 0.9 + 2, TORSO_BOT)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y - 2, TORSO_W * 1.8, 4), p.belt)

	# Back arm (guard)
	draw_limb(Vector2(-SHOULDER_W + 2, SHOULDER_Y), Vector2(-10, SHOULDER_Y + 6), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(-10, SHOULDER_Y + 6), Vector2(-6, SHOULDER_Y + 2), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(-6, SHOULDER_Y + 2), FIST_R, p.skin, ol)

	# Punching arm — extended forward, clean jab
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y), Vector2(20, SHOULDER_Y + 2), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(20, SHOULDER_Y + 2), Vector2(28, SHOULDER_Y - 1), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(28, SHOULDER_Y - 1), FIST_R + 0.5, p.skin, ol)
	draw_circle(Vector2(28, SHOULDER_Y - 1), FIST_R + 2.0, p.accent_glow)

	_draw_head_focused(Vector2(1, HEAD_Y))


# =========================================================================
#  ATTACK — Medium Punch: Rotated body, deeper commitment.
# =========================================================================
func _draw_attack_mp() -> void:
	var p := pal
	var ol := p.outline

	# Legs — wider base, weight shifting forward
	draw_limb(Vector2(-6, HIP_Y), Vector2(-10, KNEE_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-10, KNEE_Y), Vector2(-9, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-9, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(5, HIP_Y), Vector2(8, KNEE_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(8, KNEE_Y), Vector2(10, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(10, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — more rotated, shoulder driving forward
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 3, TORSO_TOP + 1), Vector2(TORSO_W - 1, TORSO_TOP),
		Vector2(TORSO_W * 0.9 - 2, TORSO_BOT), Vector2(-TORSO_W * 0.9 + 3, TORSO_BOT)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9 + 1, WAIST_Y - 2, TORSO_W * 1.7, 4), p.belt)

	# Back arm tucked
	draw_limb(Vector2(-SHOULDER_W + 3, SHOULDER_Y), Vector2(-8, SHOULDER_Y + 8), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-8, SHOULDER_Y + 8), FIST_R, p.skin, ol)

	# Punching arm — full cross, body rotation committed
	draw_limb(Vector2(SHOULDER_W - 1, SHOULDER_Y), Vector2(22, SHOULDER_Y - 2), ARM_THICK + 0.5, p.skin, ol)
	draw_limb(Vector2(22, SHOULDER_Y - 2), Vector2(32, SHOULDER_Y - 4), ARM_THICK + 0.5, p.wrap, ol)
	draw_fist(Vector2(32, SHOULDER_Y - 4), FIST_R + 1.0, p.skin, ol)
	draw_circle(Vector2(32, SHOULDER_Y - 4), FIST_R + 3.0, p.accent_glow)

	_draw_head_focused(Vector2(2, HEAD_Y + 1))


# =========================================================================
#  ATTACK — Heavy Punch: Big wind-up, full extension. Maximum commitment.
# =========================================================================
func _draw_attack_hp() -> void:
	var p := pal
	var ol := p.outline

	# Legs — deep lunge, back leg extended
	draw_limb(Vector2(-6, HIP_Y), Vector2(-14, KNEE_Y + 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-14, KNEE_Y + 2), Vector2(-16, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-16, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(5, HIP_Y), Vector2(10, KNEE_Y - 3), LEG_THICK + 0.5, p.outfit_secondary, ol)
	draw_limb(Vector2(10, KNEE_Y - 3), Vector2(14, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(14, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — deep rotation, driving from hips
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 4, TORSO_TOP + 2), Vector2(TORSO_W - 2, TORSO_TOP - 1),
		Vector2(TORSO_W * 0.8, TORSO_BOT), Vector2(-TORSO_W * 0.8 + 4, TORSO_BOT)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.8 + 2, WAIST_Y - 2, TORSO_W * 1.5, 4), p.belt)

	# Back arm — pulled way back
	draw_limb(Vector2(-SHOULDER_W + 4, SHOULDER_Y + 1), Vector2(-12, SHOULDER_Y + 4), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-12, SHOULDER_Y + 4), FIST_R, p.skin, ol)

	# Punching arm — FULL extension, exaggerated reach
	draw_limb(Vector2(SHOULDER_W - 2, SHOULDER_Y - 1), Vector2(24, SHOULDER_Y - 6), ARM_THICK + 1.0, p.skin, ol)
	draw_limb(Vector2(24, SHOULDER_Y - 6), Vector2(38, SHOULDER_Y - 8), ARM_THICK + 1.0, p.wrap, ol)
	draw_fist(Vector2(38, SHOULDER_Y - 8), FIST_R + 1.5, p.skin, ol)
	# Ember burst on heavy hit
	draw_circle(Vector2(38, SHOULDER_Y - 8), FIST_R + 5.0, p.accent_glow)
	draw_circle(Vector2(38, SHOULDER_Y - 8), FIST_R + 3.0, Color(p.accent, 0.4))

	_draw_head_focused(Vector2(3, HEAD_Y + 2))


# =========================================================================
#  HIT — Recoiling backward. Pain but still composed (Kael doesn't flail).
# =========================================================================
func _draw_hit() -> void:
	var p := pal
	var ol := p.outline

	# Legs — stumbling back
	draw_limb(Vector2(-3, HIP_Y), Vector2(-6, KNEE_Y + 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-6, KNEE_Y + 2), Vector2(-8, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-8, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(4, HIP_Y), Vector2(2, KNEE_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(2, KNEE_Y), Vector2(0, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(0, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — leaning back from impact
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W - 2, TORSO_TOP + 3), Vector2(TORSO_W - 3, TORSO_TOP + 2),
		Vector2(TORSO_W * 0.9 - 2, TORSO_BOT), Vector2(-TORSO_W * 0.9 - 1, TORSO_BOT)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9 - 1, WAIST_Y - 2, TORSO_W * 1.8, 4), p.belt)

	# Arms — recoiling, guard broken
	draw_limb(Vector2(-SHOULDER_W - 2, SHOULDER_Y + 3), Vector2(-16, SHOULDER_Y + 12), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(-16, SHOULDER_Y + 12), Vector2(-18, SHOULDER_Y + 8), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(-18, SHOULDER_Y + 8), FIST_R, p.skin, ol)

	draw_limb(Vector2(SHOULDER_W - 3, SHOULDER_Y + 2), Vector2(10, SHOULDER_Y + 10), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(10, SHOULDER_Y + 10), Vector2(6, SHOULDER_Y + 14), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(6, SHOULDER_Y + 14), FIST_R, p.skin, ol)

	# Head — grimacing, eyes shut
	draw_circle_outlined(Vector2(-2, HEAD_Y + 3), HEAD_R, p.skin, ol, 1.0)
	draw_arc(Vector2(-2, HEAD_Y + 3), HEAD_R, deg_to_rad(200), deg_to_rad(430), 16, p.hair, 3.0, true)
	draw_line(Vector2(-2, HEAD_Y + 1), Vector2(-8, HEAD_Y + 5), p.hair, 2.0, true)
	# Squinted eyes
	draw_line(Vector2(-5, HEAD_Y + 2), Vector2(-3, HEAD_Y + 3), p.eye, 1.5)
	draw_line(Vector2(-1, HEAD_Y + 2), Vector2(1, HEAD_Y + 3), p.eye, 1.5)
	# Clenched mouth
	draw_line(Vector2(-4, HEAD_Y + 6), Vector2(0, HEAD_Y + 6), p.eye, 1.5)


# =========================================================================
#  KO — Falling/fallen. Even in defeat Kael has composure — controlled fall.
# =========================================================================
func _draw_ko() -> void:
	var p := pal
	var ol := p.outline

	# Entire body rotated — falling backward at ~45°
	# Legs — crumpling
	draw_limb(Vector2(-2, HIP_Y + 8), Vector2(-8, KNEE_Y + 12), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-8, KNEE_Y + 12), Vector2(-14, FOOT_Y + 6), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-14, FOOT_Y + 6), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(4, HIP_Y + 8), Vector2(0, KNEE_Y + 14), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(0, KNEE_Y + 14), Vector2(-4, FOOT_Y + 8), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-4, FOOT_Y + 8), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — tilted back dramatically
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W - 4, TORSO_TOP + 10), Vector2(TORSO_W - 6, TORSO_TOP + 8),
		Vector2(TORSO_W * 0.9 - 4, TORSO_BOT + 8), Vector2(-TORSO_W * 0.9 - 2, TORSO_BOT + 8)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)

	# Arms — limp
	draw_limb(Vector2(-SHOULDER_W - 4, SHOULDER_Y + 10), Vector2(-20, SHOULDER_Y + 18), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-20, SHOULDER_Y + 18), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W - 6, SHOULDER_Y + 8), Vector2(8, SHOULDER_Y + 20), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(8, SHOULDER_Y + 20), FIST_R, p.skin, ol)

	# Head — X eyes (KO'd)
	draw_circle_outlined(Vector2(-5, HEAD_Y + 10), HEAD_R, p.skin, ol, 1.0)
	draw_arc(Vector2(-5, HEAD_Y + 10), HEAD_R, deg_to_rad(200), deg_to_rad(430), 16, p.hair, 3.0, true)
	# X eyes
	draw_line(Vector2(-8, HEAD_Y + 8), Vector2(-6, HEAD_Y + 10), p.eye, 1.5)
	draw_line(Vector2(-8, HEAD_Y + 10), Vector2(-6, HEAD_Y + 8), p.eye, 1.5)
	draw_line(Vector2(-4, HEAD_Y + 8), Vector2(-2, HEAD_Y + 10), p.eye, 1.5)
	draw_line(Vector2(-4, HEAD_Y + 10), Vector2(-2, HEAD_Y + 8), p.eye, 1.5)
	# Open mouth
	draw_ellipse(Vector2(-5, HEAD_Y + 13), Vector2(2, 1.5), p.eye)


# =========================================================================
#  Head helpers — reused across poses
# =========================================================================
func _draw_head_calm(center: Vector2) -> void:
	var p := pal
	draw_circle_outlined(center, HEAD_R, p.skin, p.outline, 1.0)
	draw_arc(center, HEAD_R, deg_to_rad(200), deg_to_rad(430), 16, p.hair, 3.0, true)
	draw_line(center + Vector2(0, -2), center + Vector2(-8, 2), p.hair, 2.0, true)
	draw_line(center + Vector2(-3, -1), center + Vector2(-1, -1), p.eye, 1.5)
	draw_line(center + Vector2(1, -1), center + Vector2(3, -1), p.eye, 1.5)
	draw_line(center + Vector2(-2, 3), center + Vector2(2, 3), p.eye, 1.0)

func _draw_head_focused(center: Vector2) -> void:
	var p := pal
	draw_circle_outlined(center, HEAD_R, p.skin, p.outline, 1.0)
	draw_arc(center, HEAD_R, deg_to_rad(200), deg_to_rad(430), 16, p.hair, 3.0, true)
	draw_line(center + Vector2(0, -2), center + Vector2(-8, 2), p.hair, 2.0, true)
	# Narrowed determined eyes
	draw_line(center + Vector2(-3, -2), center + Vector2(-1, -1), p.eye, 1.5)
	draw_line(center + Vector2(1, -2), center + Vector2(3, -1), p.eye, 1.5)
	# Tight mouth
	draw_line(center + Vector2(-1, 3), center + Vector2(1, 3), p.eye, 1.0)
