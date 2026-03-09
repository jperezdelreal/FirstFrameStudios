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
#  CROUCH — Low defensive stance. Kael drops centre of gravity, hands guard.
# =========================================================================
func _draw_crouch() -> void:
	var p := pal
	var ol := p.outline
	var crouch_off := 12.0  # how much the body drops

	# Legs — deeply bent, wide base
	draw_limb(Vector2(-6, HIP_Y + crouch_off), Vector2(-12, KNEE_Y + crouch_off + 4), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-12, KNEE_Y + crouch_off + 4), Vector2(-10, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-10, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(5, HIP_Y + crouch_off), Vector2(10, KNEE_Y + crouch_off + 4), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(10, KNEE_Y + crouch_off + 4), Vector2(9, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(9, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — compressed, lowered
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W, TORSO_TOP + crouch_off), Vector2(TORSO_W, TORSO_TOP + crouch_off),
		Vector2(TORSO_W * 0.9, TORSO_BOT + crouch_off), Vector2(-TORSO_W * 0.9, TORSO_BOT + crouch_off)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y + crouch_off - 2, TORSO_W * 1.8, 4), p.belt)
	draw_line(Vector2(-TORSO_W * 0.9, WAIST_Y + crouch_off), Vector2(TORSO_W * 0.9, WAIST_Y + crouch_off), p.accent, 1.0)

	# Arms — guard up near lowered head
	draw_limb(Vector2(-SHOULDER_W, SHOULDER_Y + crouch_off), Vector2(-14, SHOULDER_Y + crouch_off + 6), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(-14, SHOULDER_Y + crouch_off + 6), Vector2(-8, SHOULDER_Y + crouch_off), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(-8, SHOULDER_Y + crouch_off), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y + crouch_off), Vector2(14, SHOULDER_Y + crouch_off + 4), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(14, SHOULDER_Y + crouch_off + 4), Vector2(8, SHOULDER_Y + crouch_off - 2), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(8, SHOULDER_Y + crouch_off - 2), FIST_R, p.skin, ol)

	_draw_head_calm(Vector2(0, HEAD_Y + crouch_off))


# =========================================================================
#  JUMP UP — Ascending. Body extended upward, legs tucked slightly.
# =========================================================================
func _draw_jump_up() -> void:
	var p := pal
	var ol := p.outline
	var lift := -8.0

	# Legs — tucked under body
	draw_limb(Vector2(-4, HIP_Y + lift), Vector2(-8, KNEE_Y + lift - 4), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-8, KNEE_Y + lift - 4), Vector2(-6, FOOT_Y + lift - 8), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-6, FOOT_Y + lift - 8), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(4, HIP_Y + lift), Vector2(6, KNEE_Y + lift - 4), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(6, KNEE_Y + lift - 4), Vector2(4, FOOT_Y + lift - 8), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(4, FOOT_Y + lift - 8), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — stretched upward
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W, TORSO_TOP + lift), Vector2(TORSO_W, TORSO_TOP + lift),
		Vector2(TORSO_W * 0.9, TORSO_BOT + lift), Vector2(-TORSO_W * 0.9, TORSO_BOT + lift)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y + lift - 2, TORSO_W * 1.8, 4), p.belt)

	# Arms — reaching up
	draw_limb(Vector2(-SHOULDER_W, SHOULDER_Y + lift), Vector2(-12, SHOULDER_Y + lift - 8), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(-12, SHOULDER_Y + lift - 8), Vector2(-6, SHOULDER_Y + lift - 4), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(-6, SHOULDER_Y + lift - 4), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y + lift), Vector2(12, SHOULDER_Y + lift - 8), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(12, SHOULDER_Y + lift - 8), Vector2(6, SHOULDER_Y + lift - 4), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(6, SHOULDER_Y + lift - 4), FIST_R, p.skin, ol)

	_draw_head_calm(Vector2(0, HEAD_Y + lift))


# =========================================================================
#  JUMP PEAK — Apex. Weightless, legs spread, arms relaxed outward.
# =========================================================================
func _draw_jump_peak() -> void:
	var p := pal
	var ol := p.outline
	var lift := -6.0

	# Legs — spread apart in air
	draw_limb(Vector2(-5, HIP_Y + lift), Vector2(-10, KNEE_Y + lift), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-10, KNEE_Y + lift), Vector2(-12, FOOT_Y + lift - 4), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-12, FOOT_Y + lift - 4), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(5, HIP_Y + lift), Vector2(8, KNEE_Y + lift), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(8, KNEE_Y + lift), Vector2(10, FOOT_Y + lift - 4), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(10, FOOT_Y + lift - 4), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W, TORSO_TOP + lift), Vector2(TORSO_W, TORSO_TOP + lift),
		Vector2(TORSO_W * 0.9, TORSO_BOT + lift), Vector2(-TORSO_W * 0.9, TORSO_BOT + lift)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y + lift - 2, TORSO_W * 1.8, 4), p.belt)

	# Arms — spread outward for balance
	draw_limb(Vector2(-SHOULDER_W, SHOULDER_Y + lift), Vector2(-18, SHOULDER_Y + lift + 2), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(-18, SHOULDER_Y + lift + 2), Vector2(-14, SHOULDER_Y + lift - 2), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(-14, SHOULDER_Y + lift - 2), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y + lift), Vector2(18, SHOULDER_Y + lift + 2), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(18, SHOULDER_Y + lift + 2), Vector2(14, SHOULDER_Y + lift - 2), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(14, SHOULDER_Y + lift - 2), FIST_R, p.skin, ol)

	_draw_head_calm(Vector2(0, HEAD_Y + lift))


# =========================================================================
#  JUMP FALL — Descending. Legs extending downward, arms guard position.
# =========================================================================
func _draw_jump_fall() -> void:
	var p := pal
	var ol := p.outline
	var lift := -4.0

	# Legs — extending down to land
	draw_limb(Vector2(-5, HIP_Y + lift), Vector2(-8, KNEE_Y + lift + 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-8, KNEE_Y + lift + 2), Vector2(-7, FOOT_Y + lift), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-7, FOOT_Y + lift), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(4, HIP_Y + lift), Vector2(7, KNEE_Y + lift + 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(7, KNEE_Y + lift + 2), Vector2(6, FOOT_Y + lift), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(6, FOOT_Y + lift), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — slight forward tilt for landing
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 1, TORSO_TOP + lift), Vector2(TORSO_W + 1, TORSO_TOP + lift),
		Vector2(TORSO_W * 0.9, TORSO_BOT + lift), Vector2(-TORSO_W * 0.9, TORSO_BOT + lift)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y + lift - 2, TORSO_W * 1.8, 4), p.belt)

	# Arms — guard position while falling
	draw_limb(Vector2(-SHOULDER_W, SHOULDER_Y + lift), Vector2(-14, SHOULDER_Y + lift + 6), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(-14, SHOULDER_Y + lift + 6), Vector2(-8, SHOULDER_Y + lift + 2), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(-8, SHOULDER_Y + lift + 2), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y + lift), Vector2(14, SHOULDER_Y + lift + 4), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(14, SHOULDER_Y + lift + 4), Vector2(8, SHOULDER_Y + lift), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(8, SHOULDER_Y + lift), FIST_R, p.skin, ol)

	_draw_head_focused(Vector2(1, HEAD_Y + lift))


# =========================================================================
#  DASH — Quick forward burst. Body leaned forward, one foot pushing off.
# =========================================================================
func _draw_dash() -> void:
	var p := pal
	var ol := p.outline

	# Legs — back leg pushing, front leg leading
	draw_limb(Vector2(-6, HIP_Y), Vector2(-14, KNEE_Y + 4), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-14, KNEE_Y + 4), Vector2(-18, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-18, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(5, HIP_Y), Vector2(12, KNEE_Y - 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(12, KNEE_Y - 2), Vector2(16, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(16, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — aggressive lean forward
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 3, TORSO_TOP - 1), Vector2(TORSO_W + 3, TORSO_TOP - 3),
		Vector2(TORSO_W * 0.9 + 2, TORSO_BOT), Vector2(-TORSO_W * 0.9 + 2, TORSO_BOT)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9 + 1, WAIST_Y - 2, TORSO_W * 1.8, 4), p.belt)

	# Arms — streamlined back
	draw_limb(Vector2(-SHOULDER_W + 3, SHOULDER_Y), Vector2(-12, SHOULDER_Y + 8), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-12, SHOULDER_Y + 8), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W + 3, SHOULDER_Y - 3), Vector2(18, SHOULDER_Y), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(18, SHOULDER_Y), Vector2(14, SHOULDER_Y - 4), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(14, SHOULDER_Y - 4), FIST_R, p.skin, ol)

	_draw_head_focused(Vector2(4, HEAD_Y - 2))


# =========================================================================
#  BACKDASH — Retreating hop. Body arched backward, defensive.
# =========================================================================
func _draw_backdash() -> void:
	var p := pal
	var ol := p.outline

	# Legs — both off ground slightly, arched back
	draw_limb(Vector2(-4, HIP_Y), Vector2(-8, KNEE_Y - 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-8, KNEE_Y - 2), Vector2(-12, FOOT_Y - 4), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-12, FOOT_Y - 4), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(4, HIP_Y), Vector2(2, KNEE_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(2, KNEE_Y), Vector2(-2, FOOT_Y - 4), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-2, FOOT_Y - 4), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — leaning back
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W - 2, TORSO_TOP + 1), Vector2(TORSO_W - 3, TORSO_TOP + 2),
		Vector2(TORSO_W * 0.9 - 2, TORSO_BOT), Vector2(-TORSO_W * 0.9 - 1, TORSO_BOT)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9 - 1, WAIST_Y - 2, TORSO_W * 1.8, 4), p.belt)

	# Arms — guard held up
	draw_limb(Vector2(-SHOULDER_W - 2, SHOULDER_Y + 1), Vector2(-16, SHOULDER_Y + 4), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(-16, SHOULDER_Y + 4), Vector2(-10, SHOULDER_Y), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(-10, SHOULDER_Y), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W - 3, SHOULDER_Y + 2), Vector2(10, SHOULDER_Y + 6), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(10, SHOULDER_Y + 6), Vector2(4, SHOULDER_Y + 2), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(4, SHOULDER_Y + 2), FIST_R, p.skin, ol)

	_draw_head_calm(Vector2(-2, HEAD_Y + 1))


# =========================================================================
#  ATTACK LK — Quick snap kick. Low, fast, clean technique.
# =========================================================================
func _draw_attack_lk() -> void:
	var p := pal
	var ol := p.outline

	# Back leg planted
	draw_limb(Vector2(-5, HIP_Y), Vector2(-8, KNEE_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-8, KNEE_Y), Vector2(-7, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-7, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	# Kicking leg — extended forward, low
	draw_limb(Vector2(4, HIP_Y), Vector2(12, KNEE_Y + 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(12, KNEE_Y + 2), Vector2(24, KNEE_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(24, KNEE_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_circle(Vector2(24, KNEE_Y), FIST_R + 1.5, p.accent_glow)

	# Torso — slight rotation
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 1, TORSO_TOP), Vector2(TORSO_W, TORSO_TOP),
		Vector2(TORSO_W * 0.9, TORSO_BOT), Vector2(-TORSO_W * 0.9, TORSO_BOT)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y - 2, TORSO_W * 1.8, 4), p.belt)

	# Arms — guard position
	draw_limb(Vector2(-SHOULDER_W, SHOULDER_Y), Vector2(-14, SHOULDER_Y + 6), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(-14, SHOULDER_Y + 6), Vector2(-8, SHOULDER_Y + 2), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(-8, SHOULDER_Y + 2), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y), Vector2(14, SHOULDER_Y + 4), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(14, SHOULDER_Y + 4), Vector2(8, SHOULDER_Y), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(8, SHOULDER_Y), FIST_R, p.skin, ol)

	_draw_head_focused(Vector2(1, HEAD_Y))


# =========================================================================
#  ATTACK MK — Side kick. Body turned, more commitment than LK.
# =========================================================================
func _draw_attack_mk() -> void:
	var p := pal
	var ol := p.outline

	# Back leg — planted wide
	draw_limb(Vector2(-6, HIP_Y), Vector2(-12, KNEE_Y + 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-12, KNEE_Y + 2), Vector2(-12, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-12, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	# Kicking leg — mid-level side kick
	draw_limb(Vector2(5, HIP_Y), Vector2(14, KNEE_Y - 4), LEG_THICK + 0.5, p.outfit_secondary, ol)
	draw_limb(Vector2(14, KNEE_Y - 4), Vector2(28, SHOULDER_Y + 10), LEG_THICK + 0.5, p.outfit_secondary, ol)
	draw_boot(Vector2(28, SHOULDER_Y + 10), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_circle(Vector2(28, SHOULDER_Y + 10), FIST_R + 2.5, p.accent_glow)

	# Torso — turned sideways for side kick
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 3, TORSO_TOP + 1), Vector2(TORSO_W - 2, TORSO_TOP),
		Vector2(TORSO_W * 0.9 - 2, TORSO_BOT), Vector2(-TORSO_W * 0.9 + 2, TORSO_BOT)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9 + 1, WAIST_Y - 2, TORSO_W * 1.7, 4), p.belt)

	# Arms — tucked guard
	draw_limb(Vector2(-SHOULDER_W + 3, SHOULDER_Y), Vector2(-10, SHOULDER_Y + 6), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-10, SHOULDER_Y + 6), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W - 2, SHOULDER_Y), Vector2(10, SHOULDER_Y + 4), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(10, SHOULDER_Y + 4), FIST_R, p.skin, ol)

	_draw_head_focused(Vector2(1, HEAD_Y + 1))


# =========================================================================
#  ATTACK HK — Spinning heel kick / roundhouse. Full body rotation.
# =========================================================================
func _draw_attack_hk() -> void:
	var p := pal
	var ol := p.outline

	# Pivot leg — bent, supporting weight
	draw_limb(Vector2(-4, HIP_Y), Vector2(-8, KNEE_Y + 2), LEG_THICK + 0.5, p.outfit_secondary, ol)
	draw_limb(Vector2(-8, KNEE_Y + 2), Vector2(-6, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-6, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	# Kicking leg — high roundhouse, full extension
	draw_limb(Vector2(4, HIP_Y), Vector2(16, HIP_Y - 8), LEG_THICK + 1.0, p.outfit_secondary, ol)
	draw_limb(Vector2(16, HIP_Y - 8), Vector2(34, SHOULDER_Y), LEG_THICK + 1.0, p.outfit_secondary, ol)
	draw_boot(Vector2(34, SHOULDER_Y), BOOT_W + 1, BOOT_H, p.boots, p.sole, ol)
	draw_circle(Vector2(34, SHOULDER_Y), FIST_R + 4.0, p.accent_glow)
	draw_circle(Vector2(34, SHOULDER_Y), FIST_R + 2.0, Color(p.accent, 0.4))

	# Torso — deep rotation for roundhouse
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 5, TORSO_TOP + 2), Vector2(TORSO_W - 3, TORSO_TOP - 1),
		Vector2(TORSO_W * 0.8, TORSO_BOT), Vector2(-TORSO_W * 0.8 + 4, TORSO_BOT)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.8 + 2, WAIST_Y - 2, TORSO_W * 1.5, 4), p.belt)

	# Arms — counterbalance
	draw_limb(Vector2(-SHOULDER_W + 5, SHOULDER_Y + 2), Vector2(-14, SHOULDER_Y + 8), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-14, SHOULDER_Y + 8), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W - 3, SHOULDER_Y - 1), Vector2(8, SHOULDER_Y - 6), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(8, SHOULDER_Y - 6), FIST_R, p.skin, ol)

	_draw_head_focused(Vector2(2, HEAD_Y + 2))


# =========================================================================
#  CROUCH LP — Low jab from crouching position.
# =========================================================================
func _draw_crouch_lp() -> void:
	var p := pal
	var ol := p.outline
	var co := 12.0

	draw_limb(Vector2(-6, HIP_Y + co), Vector2(-12, KNEE_Y + co + 4), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-12, KNEE_Y + co + 4), Vector2(-10, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-10, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(5, HIP_Y + co), Vector2(10, KNEE_Y + co + 4), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(10, KNEE_Y + co + 4), Vector2(9, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(9, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 1, TORSO_TOP + co), Vector2(TORSO_W, TORSO_TOP + co),
		Vector2(TORSO_W * 0.9, TORSO_BOT + co), Vector2(-TORSO_W * 0.9, TORSO_BOT + co)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y + co - 2, TORSO_W * 1.8, 4), p.belt)

	# Guard arm
	draw_limb(Vector2(-SHOULDER_W, SHOULDER_Y + co), Vector2(-12, SHOULDER_Y + co + 4), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-12, SHOULDER_Y + co + 4), FIST_R, p.skin, ol)
	# Jabbing arm — forward
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y + co), Vector2(20, SHOULDER_Y + co), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(20, SHOULDER_Y + co), Vector2(26, SHOULDER_Y + co - 2), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(26, SHOULDER_Y + co - 2), FIST_R + 0.5, p.skin, ol)
	draw_circle(Vector2(26, SHOULDER_Y + co - 2), FIST_R + 1.5, p.accent_glow)

	_draw_head_focused(Vector2(1, HEAD_Y + co))


# =========================================================================
#  CROUCH MP — Low cross from crouch. More body commitment.
# =========================================================================
func _draw_crouch_mp() -> void:
	var p := pal
	var ol := p.outline
	var co := 12.0

	draw_limb(Vector2(-6, HIP_Y + co), Vector2(-12, KNEE_Y + co + 4), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-12, KNEE_Y + co + 4), Vector2(-10, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-10, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(5, HIP_Y + co), Vector2(10, KNEE_Y + co + 4), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(10, KNEE_Y + co + 4), Vector2(9, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(9, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 3, TORSO_TOP + co + 1), Vector2(TORSO_W, TORSO_TOP + co),
		Vector2(TORSO_W * 0.9 - 1, TORSO_BOT + co), Vector2(-TORSO_W * 0.9 + 2, TORSO_BOT + co)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9 + 1, WAIST_Y + co - 2, TORSO_W * 1.7, 4), p.belt)

	draw_limb(Vector2(-SHOULDER_W + 2, SHOULDER_Y + co), Vector2(-8, SHOULDER_Y + co + 6), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-8, SHOULDER_Y + co + 6), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y + co), Vector2(22, SHOULDER_Y + co - 4), ARM_THICK + 0.5, p.skin, ol)
	draw_limb(Vector2(22, SHOULDER_Y + co - 4), Vector2(30, SHOULDER_Y + co - 6), ARM_THICK + 0.5, p.wrap, ol)
	draw_fist(Vector2(30, SHOULDER_Y + co - 6), FIST_R + 0.5, p.skin, ol)
	draw_circle(Vector2(30, SHOULDER_Y + co - 6), FIST_R + 2.5, p.accent_glow)

	_draw_head_focused(Vector2(2, HEAD_Y + co + 1))


# =========================================================================
#  CROUCH HP — Low uppercut from crouch. Rising motion, powerful.
# =========================================================================
func _draw_crouch_hp() -> void:
	var p := pal
	var ol := p.outline
	var co := 8.0  # less crouch since rising

	draw_limb(Vector2(-6, HIP_Y + co), Vector2(-12, KNEE_Y + co + 4), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-12, KNEE_Y + co + 4), Vector2(-10, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-10, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(5, HIP_Y + co), Vector2(10, KNEE_Y + co + 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(10, KNEE_Y + co + 2), Vector2(10, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(10, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 2, TORSO_TOP + co - 2), Vector2(TORSO_W, TORSO_TOP + co - 3),
		Vector2(TORSO_W * 0.9, TORSO_BOT + co), Vector2(-TORSO_W * 0.9, TORSO_BOT + co)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y + co - 2, TORSO_W * 1.8, 4), p.belt)

	# Guard arm
	draw_limb(Vector2(-SHOULDER_W, SHOULDER_Y + co - 2), Vector2(-10, SHOULDER_Y + co + 4), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-10, SHOULDER_Y + co + 4), FIST_R, p.skin, ol)
	# Uppercut arm — punching straight up
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y + co - 3), Vector2(10, SHOULDER_Y + co - 14), ARM_THICK + 1.0, p.skin, ol)
	draw_limb(Vector2(10, SHOULDER_Y + co - 14), Vector2(8, SHOULDER_Y + co - 24), ARM_THICK + 1.0, p.wrap, ol)
	draw_fist(Vector2(8, SHOULDER_Y + co - 24), FIST_R + 1.0, p.skin, ol)
	draw_circle(Vector2(8, SHOULDER_Y + co - 24), FIST_R + 4.0, p.accent_glow)
	draw_circle(Vector2(8, SHOULDER_Y + co - 24), FIST_R + 2.0, Color(p.accent, 0.4))

	_draw_head_focused(Vector2(1, HEAD_Y + co - 2))


# =========================================================================
#  CROUCH LK — Quick low shin kick from crouching.
# =========================================================================
func _draw_crouch_lk() -> void:
	var p := pal
	var ol := p.outline
	var co := 12.0

	# Back leg — support
	draw_limb(Vector2(-6, HIP_Y + co), Vector2(-12, KNEE_Y + co + 4), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-12, KNEE_Y + co + 4), Vector2(-10, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-10, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	# Kicking leg — low kick forward
	draw_limb(Vector2(5, HIP_Y + co), Vector2(10, KNEE_Y + co + 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(10, KNEE_Y + co + 2), Vector2(22, FOOT_Y - 2), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(22, FOOT_Y - 2), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_circle(Vector2(22, FOOT_Y - 2), FIST_R + 1.0, p.accent_glow)

	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W, TORSO_TOP + co), Vector2(TORSO_W, TORSO_TOP + co),
		Vector2(TORSO_W * 0.9, TORSO_BOT + co), Vector2(-TORSO_W * 0.9, TORSO_BOT + co)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y + co - 2, TORSO_W * 1.8, 4), p.belt)

	draw_limb(Vector2(-SHOULDER_W, SHOULDER_Y + co), Vector2(-12, SHOULDER_Y + co + 4), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-12, SHOULDER_Y + co + 4), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y + co), Vector2(12, SHOULDER_Y + co + 2), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(12, SHOULDER_Y + co + 2), FIST_R, p.skin, ol)

	_draw_head_focused(Vector2(0, HEAD_Y + co))


# =========================================================================
#  CROUCH MK — Sweeping side kick from crouch. More range.
# =========================================================================
func _draw_crouch_mk() -> void:
	var p := pal
	var ol := p.outline
	var co := 12.0

	draw_limb(Vector2(-6, HIP_Y + co), Vector2(-12, KNEE_Y + co + 4), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-12, KNEE_Y + co + 4), Vector2(-10, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-10, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	# Sweeping kick — extended forward along ground
	draw_limb(Vector2(5, HIP_Y + co), Vector2(14, KNEE_Y + co), LEG_THICK + 0.5, p.outfit_secondary, ol)
	draw_limb(Vector2(14, KNEE_Y + co), Vector2(28, FOOT_Y - 2), LEG_THICK + 0.5, p.outfit_secondary, ol)
	draw_boot(Vector2(28, FOOT_Y - 2), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_circle(Vector2(28, FOOT_Y - 2), FIST_R + 2.0, p.accent_glow)

	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 2, TORSO_TOP + co), Vector2(TORSO_W, TORSO_TOP + co),
		Vector2(TORSO_W * 0.9, TORSO_BOT + co), Vector2(-TORSO_W * 0.9 + 1, TORSO_BOT + co)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y + co - 2, TORSO_W * 1.8, 4), p.belt)

	draw_limb(Vector2(-SHOULDER_W + 2, SHOULDER_Y + co), Vector2(-10, SHOULDER_Y + co + 6), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-10, SHOULDER_Y + co + 6), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y + co), Vector2(10, SHOULDER_Y + co + 4), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(10, SHOULDER_Y + co + 4), FIST_R, p.skin, ol)

	_draw_head_focused(Vector2(1, HEAD_Y + co))


# =========================================================================
#  CROUCH HK — Leg sweep. Full extension along the ground, launcher.
# =========================================================================
func _draw_crouch_hk() -> void:
	var p := pal
	var ol := p.outline
	var co := 14.0  # lower than other crouches for sweep

	# Support leg — deeply bent
	draw_limb(Vector2(-5, HIP_Y + co), Vector2(-10, KNEE_Y + co + 6), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-10, KNEE_Y + co + 6), Vector2(-8, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-8, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	# Sweep leg — fully extended along ground
	draw_limb(Vector2(4, HIP_Y + co), Vector2(16, KNEE_Y + co + 4), LEG_THICK + 1.0, p.outfit_secondary, ol)
	draw_limb(Vector2(16, KNEE_Y + co + 4), Vector2(34, FOOT_Y), LEG_THICK + 1.0, p.outfit_secondary, ol)
	draw_boot(Vector2(34, FOOT_Y), BOOT_W + 1, BOOT_H, p.boots, p.sole, ol)
	draw_circle(Vector2(34, FOOT_Y), FIST_R + 3.0, p.accent_glow)

	# Torso — very low
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 3, TORSO_TOP + co), Vector2(TORSO_W - 1, TORSO_TOP + co),
		Vector2(TORSO_W * 0.85, TORSO_BOT + co), Vector2(-TORSO_W * 0.85 + 2, TORSO_BOT + co)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.85 + 1, WAIST_Y + co - 2, TORSO_W * 1.6, 4), p.belt)

	# Arms — one on ground for support, one guarding
	draw_limb(Vector2(-SHOULDER_W + 3, SHOULDER_Y + co), Vector2(-16, SHOULDER_Y + co + 8), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-16, SHOULDER_Y + co + 8), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W - 1, SHOULDER_Y + co), Vector2(8, SHOULDER_Y + co + 4), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(8, SHOULDER_Y + co + 4), FIST_R, p.skin, ol)

	_draw_head_focused(Vector2(1, HEAD_Y + co))


# =========================================================================
#  BLOCK STANDING — Defensive stance, arms crossed in front.
# =========================================================================
func _draw_block_standing() -> void:
	var p := pal
	var ol := p.outline

	# Legs — stable, weight back slightly
	draw_limb(Vector2(-5, HIP_Y), Vector2(-8, KNEE_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-8, KNEE_Y), Vector2(-7, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-7, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(4, HIP_Y), Vector2(6, KNEE_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(6, KNEE_Y), Vector2(5, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(5, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W, TORSO_TOP), Vector2(TORSO_W, TORSO_TOP),
		Vector2(TORSO_W * 0.9, TORSO_BOT), Vector2(-TORSO_W * 0.9, TORSO_BOT)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y - 2, TORSO_W * 1.8, 4), p.belt)
	draw_line(Vector2(-TORSO_W * 0.9, WAIST_Y), Vector2(TORSO_W * 0.9, WAIST_Y), p.accent, 1.0)

	# Arms — crossed in front, blocking
	draw_limb(Vector2(-SHOULDER_W, SHOULDER_Y), Vector2(-4, SHOULDER_Y + 4), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(-4, SHOULDER_Y + 4), Vector2(6, SHOULDER_Y - 4), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(6, SHOULDER_Y - 4), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y), Vector2(4, SHOULDER_Y + 2), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(4, SHOULDER_Y + 2), Vector2(-4, SHOULDER_Y - 6), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(-4, SHOULDER_Y - 6), FIST_R, p.skin, ol)

	_draw_head_calm(Vector2(-1, HEAD_Y))


# =========================================================================
#  BLOCK CROUCHING — Low block, arms shielding midsection.
# =========================================================================
func _draw_block_crouching() -> void:
	var p := pal
	var ol := p.outline
	var co := 12.0

	draw_limb(Vector2(-6, HIP_Y + co), Vector2(-12, KNEE_Y + co + 4), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-12, KNEE_Y + co + 4), Vector2(-10, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-10, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(5, HIP_Y + co), Vector2(10, KNEE_Y + co + 4), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(10, KNEE_Y + co + 4), Vector2(9, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(9, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W, TORSO_TOP + co), Vector2(TORSO_W, TORSO_TOP + co),
		Vector2(TORSO_W * 0.9, TORSO_BOT + co), Vector2(-TORSO_W * 0.9, TORSO_BOT + co)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y + co - 2, TORSO_W * 1.8, 4), p.belt)
	draw_line(Vector2(-TORSO_W * 0.9, WAIST_Y + co), Vector2(TORSO_W * 0.9, WAIST_Y + co), p.accent, 1.0)

	# Arms — crossed low block
	draw_limb(Vector2(-SHOULDER_W, SHOULDER_Y + co), Vector2(-2, SHOULDER_Y + co + 4), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(-2, SHOULDER_Y + co + 4), Vector2(8, SHOULDER_Y + co - 2), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(8, SHOULDER_Y + co - 2), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y + co), Vector2(2, SHOULDER_Y + co + 2), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(2, SHOULDER_Y + co + 2), Vector2(-6, SHOULDER_Y + co - 4), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(-6, SHOULDER_Y + co - 4), FIST_R, p.skin, ol)

	_draw_head_calm(Vector2(-1, HEAD_Y + co))


# =========================================================================
#  JUMP ATTACKS — Air normals. Legs tucked, attacking limb extended.
# =========================================================================
func _draw_jump_lp() -> void:
	var p := pal
	var ol := p.outline
	var lift := -6.0

	draw_limb(Vector2(-4, HIP_Y + lift), Vector2(-8, KNEE_Y + lift - 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-8, KNEE_Y + lift - 2), Vector2(-6, FOOT_Y + lift - 6), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-6, FOOT_Y + lift - 6), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(4, HIP_Y + lift), Vector2(6, KNEE_Y + lift - 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(6, KNEE_Y + lift - 2), Vector2(4, FOOT_Y + lift - 6), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(4, FOOT_Y + lift - 6), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W, TORSO_TOP + lift), Vector2(TORSO_W, TORSO_TOP + lift),
		Vector2(TORSO_W * 0.9, TORSO_BOT + lift), Vector2(-TORSO_W * 0.9, TORSO_BOT + lift)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y + lift - 2, TORSO_W * 1.8, 4), p.belt)

	draw_limb(Vector2(-SHOULDER_W, SHOULDER_Y + lift), Vector2(-12, SHOULDER_Y + lift + 6), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-12, SHOULDER_Y + lift + 6), FIST_R, p.skin, ol)
	# Jab forward-down
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y + lift), Vector2(18, SHOULDER_Y + lift + 4), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(18, SHOULDER_Y + lift + 4), Vector2(24, SHOULDER_Y + lift + 2), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(24, SHOULDER_Y + lift + 2), FIST_R + 0.5, p.skin, ol)
	draw_circle(Vector2(24, SHOULDER_Y + lift + 2), FIST_R + 1.5, p.accent_glow)

	_draw_head_focused(Vector2(1, HEAD_Y + lift))


func _draw_jump_mp() -> void:
	var p := pal
	var ol := p.outline
	var lift := -6.0

	draw_limb(Vector2(-4, HIP_Y + lift), Vector2(-8, KNEE_Y + lift - 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-8, KNEE_Y + lift - 2), Vector2(-6, FOOT_Y + lift - 6), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-6, FOOT_Y + lift - 6), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(4, HIP_Y + lift), Vector2(6, KNEE_Y + lift - 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(6, KNEE_Y + lift - 2), Vector2(4, FOOT_Y + lift - 6), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(4, FOOT_Y + lift - 6), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 2, TORSO_TOP + lift + 1), Vector2(TORSO_W, TORSO_TOP + lift),
		Vector2(TORSO_W * 0.9, TORSO_BOT + lift), Vector2(-TORSO_W * 0.9 + 1, TORSO_BOT + lift)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y + lift - 2, TORSO_W * 1.8, 4), p.belt)

	draw_limb(Vector2(-SHOULDER_W + 2, SHOULDER_Y + lift), Vector2(-8, SHOULDER_Y + lift + 6), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-8, SHOULDER_Y + lift + 6), FIST_R, p.skin, ol)
	# Downward angled cross
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y + lift), Vector2(22, SHOULDER_Y + lift + 6), ARM_THICK + 0.5, p.skin, ol)
	draw_limb(Vector2(22, SHOULDER_Y + lift + 6), Vector2(30, SHOULDER_Y + lift + 8), ARM_THICK + 0.5, p.wrap, ol)
	draw_fist(Vector2(30, SHOULDER_Y + lift + 8), FIST_R + 0.5, p.skin, ol)
	draw_circle(Vector2(30, SHOULDER_Y + lift + 8), FIST_R + 2.5, p.accent_glow)

	_draw_head_focused(Vector2(2, HEAD_Y + lift + 1))


func _draw_jump_hp() -> void:
	var p := pal
	var ol := p.outline
	var lift := -6.0

	draw_limb(Vector2(-4, HIP_Y + lift), Vector2(-8, KNEE_Y + lift - 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-8, KNEE_Y + lift - 2), Vector2(-6, FOOT_Y + lift - 6), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-6, FOOT_Y + lift - 6), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(4, HIP_Y + lift), Vector2(6, KNEE_Y + lift - 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(6, KNEE_Y + lift - 2), Vector2(4, FOOT_Y + lift - 6), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(4, FOOT_Y + lift - 6), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 4, TORSO_TOP + lift + 2), Vector2(TORSO_W - 1, TORSO_TOP + lift - 1),
		Vector2(TORSO_W * 0.85, TORSO_BOT + lift), Vector2(-TORSO_W * 0.85 + 3, TORSO_BOT + lift)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)

	draw_limb(Vector2(-SHOULDER_W + 4, SHOULDER_Y + lift + 2), Vector2(-6, SHOULDER_Y + lift + 8), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-6, SHOULDER_Y + lift + 8), FIST_R, p.skin, ol)
	# Hammer fist — arcing downward
	draw_limb(Vector2(SHOULDER_W - 1, SHOULDER_Y + lift - 1), Vector2(18, SHOULDER_Y + lift - 6), ARM_THICK + 1.0, p.skin, ol)
	draw_limb(Vector2(18, SHOULDER_Y + lift - 6), Vector2(28, SHOULDER_Y + lift + 10), ARM_THICK + 1.0, p.wrap, ol)
	draw_fist(Vector2(28, SHOULDER_Y + lift + 10), FIST_R + 1.5, p.skin, ol)
	draw_circle(Vector2(28, SHOULDER_Y + lift + 10), FIST_R + 5.0, p.accent_glow)
	draw_circle(Vector2(28, SHOULDER_Y + lift + 10), FIST_R + 3.0, Color(p.accent, 0.4))

	_draw_head_focused(Vector2(3, HEAD_Y + lift + 2))


func _draw_jump_lk() -> void:
	var p := pal
	var ol := p.outline
	var lift := -6.0

	# Kicking leg extended, other tucked
	draw_limb(Vector2(-4, HIP_Y + lift), Vector2(-8, KNEE_Y + lift - 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-8, KNEE_Y + lift - 2), Vector2(-6, FOOT_Y + lift - 6), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-6, FOOT_Y + lift - 6), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(4, HIP_Y + lift), Vector2(12, KNEE_Y + lift + 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(12, KNEE_Y + lift + 2), Vector2(20, KNEE_Y + lift), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(20, KNEE_Y + lift), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_circle(Vector2(20, KNEE_Y + lift), FIST_R + 1.0, p.accent_glow)

	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W, TORSO_TOP + lift), Vector2(TORSO_W, TORSO_TOP + lift),
		Vector2(TORSO_W * 0.9, TORSO_BOT + lift), Vector2(-TORSO_W * 0.9, TORSO_BOT + lift)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y + lift - 2, TORSO_W * 1.8, 4), p.belt)

	draw_limb(Vector2(-SHOULDER_W, SHOULDER_Y + lift), Vector2(-12, SHOULDER_Y + lift + 4), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-12, SHOULDER_Y + lift + 4), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y + lift), Vector2(12, SHOULDER_Y + lift + 2), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(12, SHOULDER_Y + lift + 2), FIST_R, p.skin, ol)

	_draw_head_focused(Vector2(0, HEAD_Y + lift))


func _draw_jump_mk() -> void:
	var p := pal
	var ol := p.outline
	var lift := -6.0

	draw_limb(Vector2(-4, HIP_Y + lift), Vector2(-8, KNEE_Y + lift - 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-8, KNEE_Y + lift - 2), Vector2(-6, FOOT_Y + lift - 6), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-6, FOOT_Y + lift - 6), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	# Mid-air side kick — angled down
	draw_limb(Vector2(5, HIP_Y + lift), Vector2(14, HIP_Y + lift + 2), LEG_THICK + 0.5, p.outfit_secondary, ol)
	draw_limb(Vector2(14, HIP_Y + lift + 2), Vector2(26, KNEE_Y + lift + 4), LEG_THICK + 0.5, p.outfit_secondary, ol)
	draw_boot(Vector2(26, KNEE_Y + lift + 4), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_circle(Vector2(26, KNEE_Y + lift + 4), FIST_R + 2.0, p.accent_glow)

	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 1, TORSO_TOP + lift), Vector2(TORSO_W, TORSO_TOP + lift),
		Vector2(TORSO_W * 0.9, TORSO_BOT + lift), Vector2(-TORSO_W * 0.9, TORSO_BOT + lift)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y + lift - 2, TORSO_W * 1.8, 4), p.belt)

	draw_limb(Vector2(-SHOULDER_W, SHOULDER_Y + lift), Vector2(-12, SHOULDER_Y + lift + 4), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-12, SHOULDER_Y + lift + 4), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y + lift), Vector2(10, SHOULDER_Y + lift + 2), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(10, SHOULDER_Y + lift + 2), FIST_R, p.skin, ol)

	_draw_head_focused(Vector2(1, HEAD_Y + lift))


func _draw_jump_hk() -> void:
	var p := pal
	var ol := p.outline
	var lift := -6.0

	draw_limb(Vector2(-4, HIP_Y + lift), Vector2(-8, KNEE_Y + lift - 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-8, KNEE_Y + lift - 2), Vector2(-6, FOOT_Y + lift - 6), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-6, FOOT_Y + lift - 6), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	# Diving heavy kick
	draw_limb(Vector2(5, HIP_Y + lift), Vector2(16, HIP_Y + lift - 4), LEG_THICK + 1.0, p.outfit_secondary, ol)
	draw_limb(Vector2(16, HIP_Y + lift - 4), Vector2(32, KNEE_Y + lift + 6), LEG_THICK + 1.0, p.outfit_secondary, ol)
	draw_boot(Vector2(32, KNEE_Y + lift + 6), BOOT_W + 1, BOOT_H, p.boots, p.sole, ol)
	draw_circle(Vector2(32, KNEE_Y + lift + 6), FIST_R + 4.0, p.accent_glow)
	draw_circle(Vector2(32, KNEE_Y + lift + 6), FIST_R + 2.0, Color(p.accent, 0.4))

	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 3, TORSO_TOP + lift + 1), Vector2(TORSO_W, TORSO_TOP + lift),
		Vector2(TORSO_W * 0.85, TORSO_BOT + lift), Vector2(-TORSO_W * 0.85 + 2, TORSO_BOT + lift)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)

	draw_limb(Vector2(-SHOULDER_W + 3, SHOULDER_Y + lift), Vector2(-10, SHOULDER_Y + lift + 6), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-10, SHOULDER_Y + lift + 6), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y + lift), Vector2(8, SHOULDER_Y + lift + 2), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(8, SHOULDER_Y + lift + 2), FIST_R, p.skin, ol)

	_draw_head_focused(Vector2(2, HEAD_Y + lift + 1))


# =========================================================================
#  THROW EXECUTE — Kael grabs & tosses. Controlled, judo-style.
# =========================================================================
func _draw_throw_execute() -> void:
	var p := pal
	var ol := p.outline

	# Legs — wide, braced for throw
	draw_limb(Vector2(-6, HIP_Y), Vector2(-12, KNEE_Y + 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-12, KNEE_Y + 2), Vector2(-12, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-12, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(5, HIP_Y), Vector2(10, KNEE_Y - 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(10, KNEE_Y - 2), Vector2(12, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(12, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — rotated for hip throw
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 4, TORSO_TOP + 2), Vector2(TORSO_W - 2, TORSO_TOP),
		Vector2(TORSO_W * 0.85, TORSO_BOT), Vector2(-TORSO_W * 0.85 + 3, TORSO_BOT)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.85 + 2, WAIST_Y - 2, TORSO_W * 1.6, 4), p.belt)

	# Arms — grabbing motion, both arms reaching forward
	draw_limb(Vector2(-SHOULDER_W + 4, SHOULDER_Y + 2), Vector2(4, SHOULDER_Y - 2), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(4, SHOULDER_Y - 2), Vector2(16, SHOULDER_Y - 8), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(16, SHOULDER_Y - 8), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W - 2, SHOULDER_Y), Vector2(18, SHOULDER_Y + 2), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(18, SHOULDER_Y + 2), Vector2(20, SHOULDER_Y - 4), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(20, SHOULDER_Y - 4), FIST_R, p.skin, ol)
	draw_circle(Vector2(18, SHOULDER_Y - 1), FIST_R + 3.0, p.accent_glow)

	_draw_head_focused(Vector2(3, HEAD_Y + 1))


# =========================================================================
#  THROW VICTIM — Being thrown. Off-balance, inverted upper body.
# =========================================================================
func _draw_throw_victim() -> void:
	var p := pal
	var ol := p.outline

	# Body tilted at ~60°, being flipped
	draw_limb(Vector2(-4, HIP_Y + 4), Vector2(-10, KNEE_Y + 10), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-10, KNEE_Y + 10), Vector2(-16, FOOT_Y + 4), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-16, FOOT_Y + 4), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(4, HIP_Y + 4), Vector2(0, KNEE_Y + 12), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(0, KNEE_Y + 12), Vector2(-6, FOOT_Y + 6), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-6, FOOT_Y + 6), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso tilted
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W - 4, TORSO_TOP + 8), Vector2(TORSO_W - 6, TORSO_TOP + 6),
		Vector2(TORSO_W * 0.9 - 4, TORSO_BOT + 4), Vector2(-TORSO_W * 0.9 - 2, TORSO_BOT + 4)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)

	# Arms — flailing
	draw_limb(Vector2(-SHOULDER_W - 4, SHOULDER_Y + 8), Vector2(-18, SHOULDER_Y + 4), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-18, SHOULDER_Y + 4), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W - 6, SHOULDER_Y + 6), Vector2(10, SHOULDER_Y + 16), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(10, SHOULDER_Y + 16), FIST_R, p.skin, ol)

	# Head — surprised expression
	var hc := Vector2(-4, HEAD_Y + 8)
	draw_circle_outlined(hc, HEAD_R, p.skin, ol, 1.0)
	draw_arc(hc, HEAD_R, deg_to_rad(200), deg_to_rad(430), 16, p.hair, 3.0, true)
	draw_line(hc + Vector2(0, -2), hc + Vector2(-8, 2), p.hair, 2.0, true)
	# Wide shocked eyes
	draw_circle(hc + Vector2(-2, -1), 1.5, p.eye)
	draw_circle(hc + Vector2(2, -1), 1.5, p.eye)
	# Open mouth
	draw_ellipse(hc + Vector2(0, 3), Vector2(2, 1.5), p.eye)


# =========================================================================
#  WAKEUP — Rising from knockdown. One knee up, pushing off ground.
# =========================================================================
func _draw_wakeup() -> void:
	var p := pal
	var ol := p.outline
	var co := 8.0

	# One knee down, other leg pushing up
	draw_limb(Vector2(-6, HIP_Y + co), Vector2(-10, KNEE_Y + co + 6), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-10, KNEE_Y + co + 6), Vector2(-8, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-8, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(4, HIP_Y + co), Vector2(8, KNEE_Y + co + 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(8, KNEE_Y + co + 2), Vector2(8, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(8, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — rising
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W, TORSO_TOP + co - 2), Vector2(TORSO_W, TORSO_TOP + co - 3),
		Vector2(TORSO_W * 0.9, TORSO_BOT + co), Vector2(-TORSO_W * 0.9, TORSO_BOT + co)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y + co - 2, TORSO_W * 1.8, 4), p.belt)

	# One arm pushing off ground, other guarding
	draw_limb(Vector2(-SHOULDER_W, SHOULDER_Y + co - 2), Vector2(-14, SHOULDER_Y + co + 8), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-14, SHOULDER_Y + co + 8), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y + co - 3), Vector2(12, SHOULDER_Y + co), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(12, SHOULDER_Y + co), Vector2(6, SHOULDER_Y + co - 4), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(6, SHOULDER_Y + co - 4), FIST_R, p.skin, ol)

	_draw_head_focused(Vector2(0, HEAD_Y + co - 2))


# =========================================================================
#  SPECIAL 1 — Ember Shot (QCF+P). Kael thrusts palm forward, ember energy.
# =========================================================================
func _draw_special_1() -> void:
	var p := pal
	var ol := p.outline

	# Legs — deep forward stance
	draw_limb(Vector2(-6, HIP_Y), Vector2(-14, KNEE_Y + 3), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-14, KNEE_Y + 3), Vector2(-16, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-16, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(5, HIP_Y), Vector2(10, KNEE_Y - 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(10, KNEE_Y - 2), Vector2(14, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(14, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — rotated, palm thrust
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 4, TORSO_TOP + 1), Vector2(TORSO_W - 1, TORSO_TOP - 1),
		Vector2(TORSO_W * 0.85, TORSO_BOT), Vector2(-TORSO_W * 0.85 + 3, TORSO_BOT)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.85 + 2, WAIST_Y - 2, TORSO_W * 1.6, 4), p.belt)

	# Back arm — pulled to hip (chambered)
	draw_limb(Vector2(-SHOULDER_W + 4, SHOULDER_Y + 1), Vector2(-8, SHOULDER_Y + 8), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-8, SHOULDER_Y + 8), FIST_R, p.skin, ol)
	# Palm thrust arm — open palm (represented as flat fist + glow)
	draw_limb(Vector2(SHOULDER_W - 1, SHOULDER_Y - 1), Vector2(24, SHOULDER_Y - 4), ARM_THICK + 0.5, p.skin, ol)
	draw_limb(Vector2(24, SHOULDER_Y - 4), Vector2(34, SHOULDER_Y - 2), ARM_THICK + 0.5, p.wrap, ol)
	draw_fist(Vector2(34, SHOULDER_Y - 2), FIST_R + 1.0, p.skin, ol)
	# Ember projectile energy
	draw_circle(Vector2(34, SHOULDER_Y - 2), FIST_R + 6.0, p.accent_glow)
	draw_circle(Vector2(34, SHOULDER_Y - 2), FIST_R + 4.0, Color(p.accent, 0.5))
	draw_circle(Vector2(34, SHOULDER_Y - 2), FIST_R + 2.0, Color(1.0, 0.9, 0.7, 0.4))
	# Trailing ember particles
	draw_circle(Vector2(28, SHOULDER_Y), 2.0, p.accent_glow)
	draw_circle(Vector2(24, SHOULDER_Y + 2), 1.5, Color(p.accent, 0.3))

	_draw_head_focused(Vector2(3, HEAD_Y + 1))


# =========================================================================
#  SPECIAL 2 — Rising Cinder (DP+P). Anti-air uppercut, rising with flame.
# =========================================================================
func _draw_special_2() -> void:
	var p := pal
	var ol := p.outline
	var rise := -10.0  # character lifts off ground

	# Legs — extended below, pushing off
	draw_limb(Vector2(-4, HIP_Y + rise), Vector2(-8, KNEE_Y + rise + 6), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-8, KNEE_Y + rise + 6), Vector2(-6, FOOT_Y + rise + 8), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-6, FOOT_Y + rise + 8), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(4, HIP_Y + rise), Vector2(2, KNEE_Y + rise + 6), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(2, KNEE_Y + rise + 6), Vector2(0, FOOT_Y + rise + 8), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(0, FOOT_Y + rise + 8), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — angled upward
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 2, TORSO_TOP + rise - 2), Vector2(TORSO_W, TORSO_TOP + rise - 3),
		Vector2(TORSO_W * 0.9, TORSO_BOT + rise), Vector2(-TORSO_W * 0.9, TORSO_BOT + rise)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y + rise - 2, TORSO_W * 1.8, 4), p.belt)

	# Back arm — trailing down
	draw_limb(Vector2(-SHOULDER_W + 2, SHOULDER_Y + rise - 2), Vector2(-12, SHOULDER_Y + rise + 6), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-12, SHOULDER_Y + rise + 6), FIST_R, p.skin, ol)
	# Rising uppercut fist — straight up with flame trail
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y + rise - 3), Vector2(6, SHOULDER_Y + rise - 16), ARM_THICK + 1.0, p.skin, ol)
	draw_limb(Vector2(6, SHOULDER_Y + rise - 16), Vector2(4, SHOULDER_Y + rise - 28), ARM_THICK + 1.0, p.wrap, ol)
	draw_fist(Vector2(4, SHOULDER_Y + rise - 28), FIST_R + 1.5, p.skin, ol)
	# Rising flame trail
	draw_circle(Vector2(4, SHOULDER_Y + rise - 28), FIST_R + 6.0, p.accent_glow)
	draw_circle(Vector2(4, SHOULDER_Y + rise - 24), FIST_R + 4.0, Color(p.accent, 0.4))
	draw_circle(Vector2(4, SHOULDER_Y + rise - 20), FIST_R + 2.0, Color(p.accent, 0.2))
	draw_circle(Vector2(4, SHOULDER_Y + rise - 16), FIST_R + 1.0, Color(p.accent, 0.1))

	_draw_head_focused(Vector2(1, HEAD_Y + rise - 2))


# =========================================================================
#  SPECIAL 3 — Cinder Step (QCB+K). Quick advancing palm strike.
# =========================================================================
func _draw_special_3() -> void:
	var p := pal
	var ol := p.outline

	# Similar to dash + attack — lunging palm
	draw_limb(Vector2(-6, HIP_Y), Vector2(-16, KNEE_Y + 4), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-16, KNEE_Y + 4), Vector2(-20, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-20, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(5, HIP_Y), Vector2(14, KNEE_Y - 4), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(14, KNEE_Y - 4), Vector2(18, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(18, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 5, TORSO_TOP + 2), Vector2(TORSO_W, TORSO_TOP - 2),
		Vector2(TORSO_W * 0.85, TORSO_BOT), Vector2(-TORSO_W * 0.85 + 4, TORSO_BOT)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.85 + 2, WAIST_Y - 2, TORSO_W * 1.6, 4), p.belt)

	draw_limb(Vector2(-SHOULDER_W + 5, SHOULDER_Y + 2), Vector2(-6, SHOULDER_Y + 10), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-6, SHOULDER_Y + 10), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y - 2), Vector2(26, SHOULDER_Y - 6), ARM_THICK + 0.5, p.skin, ol)
	draw_limb(Vector2(26, SHOULDER_Y - 6), Vector2(36, SHOULDER_Y - 4), ARM_THICK + 0.5, p.wrap, ol)
	draw_fist(Vector2(36, SHOULDER_Y - 4), FIST_R + 1.0, p.skin, ol)
	draw_circle(Vector2(36, SHOULDER_Y - 4), FIST_R + 4.0, p.accent_glow)
	draw_circle(Vector2(36, SHOULDER_Y - 4), FIST_R + 2.0, Color(p.accent, 0.4))

	_draw_head_focused(Vector2(4, HEAD_Y))


# =========================================================================
#  SPECIAL 4 — Flame Guard (HCB+P). Counter-stance, ember shield.
# =========================================================================
func _draw_special_4() -> void:
	var p := pal
	var ol := p.outline

	# Legs — stable, wide stance
	draw_limb(Vector2(-6, HIP_Y), Vector2(-10, KNEE_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-10, KNEE_Y), Vector2(-8, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-8, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(5, HIP_Y), Vector2(8, KNEE_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(8, KNEE_Y), Vector2(7, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(7, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W, TORSO_TOP), Vector2(TORSO_W, TORSO_TOP),
		Vector2(TORSO_W * 0.9, TORSO_BOT), Vector2(-TORSO_W * 0.9, TORSO_BOT)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y - 2, TORSO_W * 1.8, 4), p.belt)
	draw_line(Vector2(-TORSO_W * 0.9, WAIST_Y), Vector2(TORSO_W * 0.9, WAIST_Y), p.accent, 1.0)

	# Arms — both palms forward, creating ember barrier
	draw_limb(Vector2(-SHOULDER_W, SHOULDER_Y), Vector2(-2, SHOULDER_Y - 4), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(-2, SHOULDER_Y - 4), Vector2(10, SHOULDER_Y - 8), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(10, SHOULDER_Y - 8), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y), Vector2(6, SHOULDER_Y - 2), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(6, SHOULDER_Y - 2), Vector2(14, SHOULDER_Y - 6), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(14, SHOULDER_Y - 6), FIST_R, p.skin, ol)
	# Ember shield effect
	draw_arc(Vector2(12, SHOULDER_Y - 4), 12.0, deg_to_rad(-60), deg_to_rad(60), 16, p.accent_glow, 3.0, true)
	draw_arc(Vector2(12, SHOULDER_Y - 4), 10.0, deg_to_rad(-45), deg_to_rad(45), 12, Color(p.accent, 0.4), 2.0, true)

	_draw_head_calm(Vector2(0, HEAD_Y))


# =========================================================================
#  IGNITION — Super move. Maximum ember energy. Both fists blazing.
# =========================================================================
func _draw_ignition() -> void:
	var p := pal
	var ol := p.outline

	# Legs — power stance, deep and wide
	draw_limb(Vector2(-7, HIP_Y), Vector2(-14, KNEE_Y + 2), LEG_THICK + 0.5, p.outfit_secondary, ol)
	draw_limb(Vector2(-14, KNEE_Y + 2), Vector2(-14, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-14, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(6, HIP_Y), Vector2(12, KNEE_Y + 2), LEG_THICK + 0.5, p.outfit_secondary, ol)
	draw_limb(Vector2(12, KNEE_Y + 2), Vector2(14, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(14, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W - 1, TORSO_TOP - 2), Vector2(TORSO_W + 1, TORSO_TOP - 2),
		Vector2(TORSO_W * 0.95, TORSO_BOT), Vector2(-TORSO_W * 0.95, TORSO_BOT)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.95, WAIST_Y - 2, TORSO_W * 1.9, 4), p.belt)
	draw_line(Vector2(-TORSO_W * 0.95, WAIST_Y), Vector2(TORSO_W * 0.95, WAIST_Y), p.accent, 2.0)

	# Arms — both thrust forward, maximum ember
	draw_limb(Vector2(-SHOULDER_W - 1, SHOULDER_Y - 2), Vector2(-4, SHOULDER_Y - 8), ARM_THICK + 0.5, p.skin, ol)
	draw_limb(Vector2(-4, SHOULDER_Y - 8), Vector2(10, SHOULDER_Y - 12), ARM_THICK + 0.5, p.wrap, ol)
	draw_fist(Vector2(10, SHOULDER_Y - 12), FIST_R + 1.0, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W + 1, SHOULDER_Y - 2), Vector2(8, SHOULDER_Y - 6), ARM_THICK + 0.5, p.skin, ol)
	draw_limb(Vector2(8, SHOULDER_Y - 6), Vector2(18, SHOULDER_Y - 10), ARM_THICK + 0.5, p.wrap, ol)
	draw_fist(Vector2(18, SHOULDER_Y - 10), FIST_R + 1.0, p.skin, ol)
	# Massive ember explosion
	draw_circle(Vector2(14, SHOULDER_Y - 11), FIST_R + 10.0, Color(p.accent_glow, 0.3))
	draw_circle(Vector2(14, SHOULDER_Y - 11), FIST_R + 7.0, p.accent_glow)
	draw_circle(Vector2(14, SHOULDER_Y - 11), FIST_R + 4.0, Color(p.accent, 0.5))
	draw_circle(Vector2(14, SHOULDER_Y - 11), FIST_R + 2.0, Color(1.0, 0.95, 0.8, 0.6))

	_draw_head_focused(Vector2(2, HEAD_Y - 2))


# =========================================================================
#  WIN — Victory pose. Calm, arms folded, confident. Monk-like composure.
# =========================================================================
func _draw_win() -> void:
	var p := pal
	var ol := p.outline

	# Legs — relaxed, standing upright
	draw_limb(Vector2(-5, HIP_Y), Vector2(-6, KNEE_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-6, KNEE_Y), Vector2(-5, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-5, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(4, HIP_Y), Vector2(5, KNEE_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(5, KNEE_Y), Vector2(4, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(4, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — upright, proud
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W, TORSO_TOP), Vector2(TORSO_W, TORSO_TOP),
		Vector2(TORSO_W * 0.9, TORSO_BOT), Vector2(-TORSO_W * 0.9, TORSO_BOT)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y - 2, TORSO_W * 1.8, 4), p.belt)
	draw_line(Vector2(-TORSO_W * 0.9, WAIST_Y), Vector2(TORSO_W * 0.9, WAIST_Y), p.accent, 1.0)

	# Arms — folded across chest
	draw_limb(Vector2(-SHOULDER_W, SHOULDER_Y), Vector2(-4, SHOULDER_Y + 6), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(-4, SHOULDER_Y + 6), Vector2(8, SHOULDER_Y + 4), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(8, SHOULDER_Y + 4), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y), Vector2(4, SHOULDER_Y + 4), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(4, SHOULDER_Y + 4), Vector2(-6, SHOULDER_Y + 2), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(-6, SHOULDER_Y + 2), FIST_R, p.skin, ol)

	# Soft ember glow
	draw_circle(Vector2(0, SHOULDER_Y + 4), 8.0, Color(p.accent_glow, 0.2))

	# Head — calm, slight smile
	var hc := Vector2(0, HEAD_Y)
	draw_circle_outlined(hc, HEAD_R, p.skin, ol, 1.0)
	draw_arc(hc, HEAD_R, deg_to_rad(200), deg_to_rad(430), 16, p.hair, 3.0, true)
	draw_line(hc + Vector2(0, -2), hc + Vector2(-8, 2), p.hair, 2.0, true)
	draw_line(hc + Vector2(-3, -1), hc + Vector2(-1, -1), p.eye, 1.5)
	draw_line(hc + Vector2(1, -1), hc + Vector2(3, -1), p.eye, 1.5)
	# Slight smile
	draw_arc(hc + Vector2(0, 2), 2.5, deg_to_rad(10), deg_to_rad(170), 8, p.eye, 1.0, true)


# =========================================================================
#  LOSE — Defeated pose. On one knee, head bowed. Dignified in defeat.
# =========================================================================
func _draw_lose() -> void:
	var p := pal
	var ol := p.outline
	var co := 10.0

	# One knee down
	draw_limb(Vector2(-6, HIP_Y + co), Vector2(-10, KNEE_Y + co + 8), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-10, KNEE_Y + co + 8), Vector2(-8, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-8, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(4, HIP_Y + co), Vector2(6, KNEE_Y + co + 4), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(6, KNEE_Y + co + 4), Vector2(6, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(6, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — slumped forward
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 1, TORSO_TOP + co + 2), Vector2(TORSO_W, TORSO_TOP + co + 1),
		Vector2(TORSO_W * 0.9, TORSO_BOT + co), Vector2(-TORSO_W * 0.9, TORSO_BOT + co)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y + co - 2, TORSO_W * 1.8, 4), p.belt)

	# Arms — hanging limp
	draw_limb(Vector2(-SHOULDER_W, SHOULDER_Y + co + 2), Vector2(-14, SHOULDER_Y + co + 12), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-14, SHOULDER_Y + co + 12), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y + co + 1), Vector2(10, SHOULDER_Y + co + 10), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(10, SHOULDER_Y + co + 10), FIST_R, p.skin, ol)

	# Head — bowed, eyes closed
	var hc := Vector2(0, HEAD_Y + co + 4)
	draw_circle_outlined(hc, HEAD_R, p.skin, ol, 1.0)
	draw_arc(hc, HEAD_R, deg_to_rad(200), deg_to_rad(430), 16, p.hair, 3.0, true)
	draw_line(hc + Vector2(0, -2), hc + Vector2(-8, 2), p.hair, 2.0, true)
	# Closed eyes
	draw_line(hc + Vector2(-3, 0), hc + Vector2(-1, 0), p.eye, 1.0)
	draw_line(hc + Vector2(1, 0), hc + Vector2(3, 0), p.eye, 1.0)
	draw_line(hc + Vector2(-2, 3), hc + Vector2(2, 3), p.eye, 1.0)


# =========================================================================
#  THROW STARTUP -- Reaching forward to grab. Controlled lunge.
# =========================================================================
func _draw_throw_startup() -> void:
	var p := pal
	var ol := p.outline

	# Legs -- forward-weighted lunge
	draw_limb(Vector2(-6, HIP_Y), Vector2(-12, KNEE_Y + 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-12, KNEE_Y + 2), Vector2(-14, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-14, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(5, HIP_Y), Vector2(8, KNEE_Y - 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(8, KNEE_Y - 2), Vector2(10, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(10, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso -- leaning forward
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 3, TORSO_TOP + 1), Vector2(TORSO_W, TORSO_TOP - 1),
		Vector2(TORSO_W * 0.85, TORSO_BOT), Vector2(-TORSO_W * 0.85 + 2, TORSO_BOT)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.85 + 1, WAIST_Y - 2, TORSO_W * 1.65, 4), p.belt)

	# Lead arm -- reaching forward, open hand
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y - 1), Vector2(16, SHOULDER_Y - 6), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(16, SHOULDER_Y - 6), Vector2(22, SHOULDER_Y - 10), ARM_THICK, p.wrap, ol)
	draw_circle_outlined(Vector2(22, SHOULDER_Y - 10), FIST_R + 0.5, p.skin, ol)
	# Rear arm -- pulled back
	draw_limb(Vector2(-SHOULDER_W + 3, SHOULDER_Y + 1), Vector2(-8, SHOULDER_Y + 6), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(-8, SHOULDER_Y + 6), Vector2(-4, SHOULDER_Y + 2), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(-4, SHOULDER_Y + 2), FIST_R, p.skin, ol)

	_draw_head_focused(Vector2(3, HEAD_Y))


# =========================================================================
#  THROW WHIFF -- Missed throw. Stumbling forward, recovering composure.
# =========================================================================
func _draw_throw_whiff() -> void:
	var p := pal
	var ol := p.outline

	# Legs -- overextended forward
	draw_limb(Vector2(-6, HIP_Y), Vector2(-14, KNEE_Y + 4), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-14, KNEE_Y + 4), Vector2(-16, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-16, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(5, HIP_Y), Vector2(12, KNEE_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(12, KNEE_Y), Vector2(14, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(14, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso -- tilted forward off-balance
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W + 5, TORSO_TOP + 4), Vector2(TORSO_W + 2, TORSO_TOP + 2),
		Vector2(TORSO_W * 0.85 + 1, TORSO_BOT + 2), Vector2(-TORSO_W * 0.85 + 4, TORSO_BOT + 2)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.85 + 3, WAIST_Y, TORSO_W * 1.6, 4), p.belt)

	# Arms -- grasping at air
	draw_limb(Vector2(SHOULDER_W + 2, SHOULDER_Y + 2), Vector2(20, SHOULDER_Y - 2), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(20, SHOULDER_Y - 2), Vector2(24, SHOULDER_Y + 2), ARM_THICK, p.wrap, ol)
	draw_circle_outlined(Vector2(24, SHOULDER_Y + 2), FIST_R, p.skin, ol)
	draw_limb(Vector2(-SHOULDER_W + 5, SHOULDER_Y + 4), Vector2(8, SHOULDER_Y + 6), ARM_THICK, p.skin, ol)
	draw_circle_outlined(Vector2(8, SHOULDER_Y + 6), FIST_R, p.skin, ol)

	# Head -- surprised, composure broken
	var hc := Vector2(5, HEAD_Y + 3)
	draw_circle_outlined(hc, HEAD_R, p.skin, ol, 1.0)
	draw_arc(hc, HEAD_R, deg_to_rad(200), deg_to_rad(430), 16, p.hair, 3.0, true)
	draw_line(hc + Vector2(0, -2), hc + Vector2(-8, 2), p.hair, 2.0, true)
	draw_circle(hc + Vector2(-2, -1), 1.2, p.eye)
	draw_circle(hc + Vector2(2, -1), 1.2, p.eye)
	draw_ellipse(hc + Vector2(0, 3), Vector2(1.5, 1.0), p.eye)


# =========================================================================
#  HIT HEAVY -- Heavy attack recoil. Spine arched back, guard shattered.
# =========================================================================
func _draw_hit_heavy() -> void:
	var p := pal
	var ol := p.outline

	# Legs -- buckling backward
	draw_limb(Vector2(-4, HIP_Y), Vector2(-10, KNEE_Y + 4), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-10, KNEE_Y + 4), Vector2(-14, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-14, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(5, HIP_Y), Vector2(0, KNEE_Y + 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(0, KNEE_Y + 2), Vector2(-4, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-4, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso -- arched backward dramatically
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W - 4, TORSO_TOP + 6), Vector2(TORSO_W - 5, TORSO_TOP + 4),
		Vector2(TORSO_W * 0.9 - 3, TORSO_BOT + 2), Vector2(-TORSO_W * 0.9 - 2, TORSO_BOT + 2)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9 - 1, WAIST_Y, TORSO_W * 1.8, 4), p.belt)

	# Arms -- flung wide from impact
	draw_limb(Vector2(-SHOULDER_W - 4, SHOULDER_Y + 6), Vector2(-22, SHOULDER_Y + 4), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(-22, SHOULDER_Y + 4), Vector2(-24, SHOULDER_Y + 10), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(-24, SHOULDER_Y + 10), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W - 5, SHOULDER_Y + 4), Vector2(12, SHOULDER_Y + 16), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(12, SHOULDER_Y + 16), FIST_R, p.skin, ol)

	# Head -- snapping back, eyes clenched
	var hc := Vector2(-4, HEAD_Y + 6)
	draw_circle_outlined(hc, HEAD_R, p.skin, ol, 1.0)
	draw_arc(hc, HEAD_R, deg_to_rad(200), deg_to_rad(430), 16, p.hair, 3.0, true)
	draw_line(hc + Vector2(0, -2), hc + Vector2(-8, 4), p.hair, 2.0, true)
	draw_line(hc + Vector2(-4, 0), hc + Vector2(-2, 1), p.eye, 2.0)
	draw_line(hc + Vector2(0, 0), hc + Vector2(2, 1), p.eye, 2.0)
	draw_line(hc + Vector2(-3, 4), hc + Vector2(1, 5), p.eye, 1.5)


# =========================================================================
#  HIT CROUCHING -- Hit while crouching. Body compressed, rocking back.
# =========================================================================
func _draw_hit_crouching() -> void:
	var p := pal
	var ol := p.outline
	var co := 12.0

	# Legs -- deeply bent, sliding back
	draw_limb(Vector2(-5, HIP_Y + co), Vector2(-12, KNEE_Y + co + 4), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-12, KNEE_Y + co + 4), Vector2(-10, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-10, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(4, HIP_Y + co), Vector2(0, KNEE_Y + co + 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(0, KNEE_Y + co + 2), Vector2(-2, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-2, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso -- compressed and leaning back
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W - 2, TORSO_TOP + co + 3), Vector2(TORSO_W - 3, TORSO_TOP + co + 2),
		Vector2(TORSO_W * 0.9 - 2, TORSO_BOT + co), Vector2(-TORSO_W * 0.9 - 1, TORSO_BOT + co)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9 - 1, WAIST_Y + co - 2, TORSO_W * 1.8, 4), p.belt)

	# Arms -- guard broken low
	draw_limb(Vector2(-SHOULDER_W - 2, SHOULDER_Y + co + 3), Vector2(-14, SHOULDER_Y + co + 10), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-14, SHOULDER_Y + co + 10), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W - 3, SHOULDER_Y + co + 2), Vector2(8, SHOULDER_Y + co + 12), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(8, SHOULDER_Y + co + 12), FIST_R, p.skin, ol)

	# Head -- grimacing low
	var hc := Vector2(-2, HEAD_Y + co + 3)
	draw_circle_outlined(hc, HEAD_R, p.skin, ol, 1.0)
	draw_arc(hc, HEAD_R, deg_to_rad(200), deg_to_rad(430), 16, p.hair, 3.0, true)
	draw_line(hc + Vector2(0, -2), hc + Vector2(-8, 3), p.hair, 2.0, true)
	draw_line(hc + Vector2(-4, 0), hc + Vector2(-2, 1), p.eye, 1.5)
	draw_line(hc + Vector2(0, 0), hc + Vector2(2, 1), p.eye, 1.5)
	draw_line(hc + Vector2(-3, 4), hc + Vector2(1, 4), p.eye, 1.5)


# =========================================================================
#  HIT AIR -- Hit while airborne. Body curling from impact mid-air.
# =========================================================================
func _draw_hit_air() -> void:
	var p := pal
	var ol := p.outline
	var lift := -14.0

	# Legs -- curling upward from impact
	draw_limb(Vector2(-3, HIP_Y + lift), Vector2(-8, KNEE_Y + lift - 4), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-8, KNEE_Y + lift - 4), Vector2(-6, FOOT_Y + lift - 10), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-6, FOOT_Y + lift - 10), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(4, HIP_Y + lift), Vector2(2, KNEE_Y + lift - 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(2, KNEE_Y + lift - 2), Vector2(0, FOOT_Y + lift - 8), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(0, FOOT_Y + lift - 8), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso -- leaning back in air
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W - 2, TORSO_TOP + lift + 2), Vector2(TORSO_W - 3, TORSO_TOP + lift),
		Vector2(TORSO_W * 0.9 - 2, TORSO_BOT + lift), Vector2(-TORSO_W * 0.9 - 1, TORSO_BOT + lift)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)

	# Arms -- flung outward
	draw_limb(Vector2(-SHOULDER_W - 2, SHOULDER_Y + lift + 2), Vector2(-18, SHOULDER_Y + lift - 4), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-18, SHOULDER_Y + lift - 4), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W - 3, SHOULDER_Y + lift), Vector2(14, SHOULDER_Y + lift + 8), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(14, SHOULDER_Y + lift + 8), FIST_R, p.skin, ol)

	# Head -- grimacing in air
	var hc := Vector2(-2, HEAD_Y + lift + 2)
	draw_circle_outlined(hc, HEAD_R, p.skin, ol, 1.0)
	draw_arc(hc, HEAD_R, deg_to_rad(200), deg_to_rad(430), 16, p.hair, 3.0, true)
	draw_line(hc + Vector2(0, -2), hc + Vector2(-8, 4), p.hair, 2.0, true)
	draw_line(hc + Vector2(-4, 0), hc + Vector2(-2, 1), p.eye, 1.5)
	draw_line(hc + Vector2(0, 0), hc + Vector2(2, 1), p.eye, 1.5)
	draw_ellipse(hc + Vector2(0, 4), Vector2(2, 1.2), p.eye)


# =========================================================================
#  KNOCKDOWN FALL -- Mid-air fall after knockdown. Controlled arc.
# =========================================================================
func _draw_knockdown_fall() -> void:
	var p := pal
	var ol := p.outline

	# Legs -- trailing behind during fall
	draw_limb(Vector2(-2, HIP_Y + 4), Vector2(-6, KNEE_Y + 8), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-6, KNEE_Y + 8), Vector2(-10, FOOT_Y + 2), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-10, FOOT_Y + 2), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(4, HIP_Y + 4), Vector2(2, KNEE_Y + 10), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(2, KNEE_Y + 10), Vector2(-2, FOOT_Y + 4), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-2, FOOT_Y + 4), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso -- tilting backward mid-fall
	var gi_pts := PackedVector2Array([
		Vector2(-TORSO_W - 3, TORSO_TOP + 6), Vector2(TORSO_W - 4, TORSO_TOP + 4),
		Vector2(TORSO_W * 0.9 - 3, TORSO_BOT + 4), Vector2(-TORSO_W * 0.9 - 2, TORSO_BOT + 4)
	])
	draw_colored_polygon(gi_pts, p.outfit_primary)
	draw_polyline(gi_pts, ol, 1.0, true)

	# Arms -- reaching out instinctively
	draw_limb(Vector2(-SHOULDER_W - 3, SHOULDER_Y + 6), Vector2(-16, SHOULDER_Y + 2), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(-16, SHOULDER_Y + 2), Vector2(-18, SHOULDER_Y + 8), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(-18, SHOULDER_Y + 8), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W - 4, SHOULDER_Y + 4), Vector2(10, SHOULDER_Y + 12), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(10, SHOULDER_Y + 12), FIST_R, p.skin, ol)

	# Head -- dazed, eyes half-shut
	var hc := Vector2(-4, HEAD_Y + 6)
	draw_circle_outlined(hc, HEAD_R, p.skin, ol, 1.0)
	draw_arc(hc, HEAD_R, deg_to_rad(200), deg_to_rad(430), 16, p.hair, 3.0, true)
	draw_line(hc + Vector2(0, -2), hc + Vector2(-8, 4), p.hair, 2.0, true)
	draw_line(hc + Vector2(-4, 0), hc + Vector2(-2, 0), p.eye, 1.0)
	draw_line(hc + Vector2(0, 0), hc + Vector2(2, 0), p.eye, 1.0)
	draw_ellipse(hc + Vector2(0, 3), Vector2(1.5, 1.0), p.eye)


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
