## Rhena — The Wildfire. Muscular, compact build. Dark red/black attire
## with orange-ember accents. Wild short hair. Burn scars on arms.
## Every pose reads as "ready to explode" — wide, aggressive, messy.
class_name RhenaSprite
extends CharacterSprite

# Body proportions — stockier than Kael, wider shoulders, shorter
const HEAD_R := 7.0
const HEAD_Y := -50.0        # slightly lower head (stockier build)
const NECK_Y := -43.0
const SHOULDER_Y := -40.0
const SHOULDER_W := 14.0     # wider than Kael
const TORSO_TOP := -40.0
const TORSO_BOT := -16.0
const TORSO_W := 13.0        # wider torso
const WAIST_Y := -16.0
const HIP_Y := -14.0
const KNEE_Y := -6.0
const FOOT_Y := 0.0
const ARM_THICK := 4.5       # thicker arms (muscular)
const LEG_THICK := 5.0       # thicker legs
const FIST_R := 3.5          # bigger fists
const BOOT_W := 7.0          # combat boots wider
const BOOT_H := 6.0          # combat boots taller


func _init_palettes() -> void:
	# P1: Hot intensity — dark red/black attire, orange-ember accents, warm skin
	palettes.append({
		"skin": Color(0.75, 0.55, 0.40),
		"hair": Color(0.65, 0.20, 0.10),           # dark red-brown wild hair
		"outfit_primary": Color(0.20, 0.12, 0.10),  # near-black tank top
		"outfit_secondary": Color(0.45, 0.15, 0.10), # dark red pants
		"accent": Color(0.95, 0.55, 0.10),           # orange-ember
		"accent_glow": Color(1.0, 0.6, 0.15, 0.6),
		"eye": Color(0.15, 0.10, 0.08),
		"outline": Color(0.10, 0.06, 0.04),
		"wrap": Color(0.55, 0.35, 0.25),             # hand wraps
		"scar": Color(0.60, 0.35, 0.30, 0.7),        # burn scars
		"belt": Color(0.30, 0.18, 0.12),
		"boots": Color(0.22, 0.15, 0.10),            # dark combat boots
		"sole": Color(0.12, 0.08, 0.05),
		"torn_edge": Color(0.35, 0.20, 0.15),        # torn sleeve edges
	})
	# P2: Cool shift — blue-black attire, cyan-frost accents
	palettes.append({
		"skin": Color(0.72, 0.58, 0.45),
		"hair": Color(0.15, 0.20, 0.45),
		"outfit_primary": Color(0.10, 0.12, 0.22),
		"outfit_secondary": Color(0.12, 0.18, 0.40),
		"accent": Color(0.20, 0.70, 0.95),
		"accent_glow": Color(0.3, 0.8, 1.0, 0.6),
		"eye": Color(0.10, 0.10, 0.15),
		"outline": Color(0.05, 0.05, 0.10),
		"wrap": Color(0.30, 0.35, 0.50),
		"scar": Color(0.40, 0.35, 0.50, 0.7),
		"belt": Color(0.15, 0.18, 0.28),
		"boots": Color(0.12, 0.14, 0.22),
		"sole": Color(0.06, 0.07, 0.12),
		"torn_edge": Color(0.18, 0.22, 0.35),
	})


# =========================================================================
#  IDLE — Aggressive ready stance. Low centre of gravity, fists wide,
#  weight on balls of feet. Reads as "about to explode".
# =========================================================================
func _draw_idle() -> void:
	var p := pal
	var ol := p.outline

	# --- Legs — wide, bent, springy ---
	draw_limb(Vector2(-7, HIP_Y), Vector2(-12, KNEE_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-12, KNEE_Y), Vector2(-10, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-10, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(6, HIP_Y), Vector2(10, KNEE_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(10, KNEE_Y), Vector2(9, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(9, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# --- Torso (tank top — wider, muscular) ---
	var top_pts := PackedVector2Array([
		Vector2(-TORSO_W, TORSO_TOP), Vector2(TORSO_W, TORSO_TOP),
		Vector2(TORSO_W * 0.95, TORSO_BOT), Vector2(-TORSO_W * 0.95, TORSO_BOT)
	])
	draw_colored_polygon(top_pts, p.outfit_primary)
	draw_polyline(top_pts, ol, 1.0, true)
	# Torn sleeveless edges
	draw_line(Vector2(-TORSO_W, TORSO_TOP), Vector2(-TORSO_W - 2, TORSO_TOP + 4), p.torn_edge, 2.0)
	draw_line(Vector2(TORSO_W, TORSO_TOP), Vector2(TORSO_W + 2, TORSO_TOP + 4), p.torn_edge, 2.0)
	# Belt
	draw_rect(Rect2(-TORSO_W * 0.95, WAIST_Y - 2, TORSO_W * 1.9, 4), p.belt)
	draw_line(Vector2(-TORSO_W * 0.95, WAIST_Y), Vector2(TORSO_W * 0.95, WAIST_Y), p.accent, 1.5)

	# --- Arms — wide guard, fists out to sides (brawler stance) ---
	# Left arm
	var l_shoulder := Vector2(-SHOULDER_W, SHOULDER_Y)
	var l_elbow := Vector2(-18, SHOULDER_Y + 6)
	var l_hand := Vector2(-14, SHOULDER_Y)
	draw_limb(l_shoulder, l_elbow, ARM_THICK, p.skin, ol)
	_draw_burn_scars(l_shoulder, l_elbow)
	draw_limb(l_elbow, l_hand, ARM_THICK, p.wrap, ol)
	draw_fist(l_hand, FIST_R, p.skin, ol)

	# Right arm
	var r_shoulder := Vector2(SHOULDER_W, SHOULDER_Y)
	var r_elbow := Vector2(18, SHOULDER_Y + 4)
	var r_hand := Vector2(12, SHOULDER_Y - 2)
	draw_limb(r_shoulder, r_elbow, ARM_THICK, p.skin, ol)
	_draw_burn_scars(r_shoulder, r_elbow)
	draw_limb(r_elbow, r_hand, ARM_THICK, p.wrap, ol)
	draw_fist(r_hand, FIST_R, p.skin, ol)

	# --- Head ---
	_draw_head_fierce(Vector2(0, HEAD_Y))

	# Accent ember glow on fists
	draw_circle(l_hand, FIST_R + 1.5, p.accent_glow)
	draw_circle(r_hand, FIST_R + 1.5, p.accent_glow)


# =========================================================================
#  WALK — Prowling forward. Predatory lean, fists ready. Not graceful.
# =========================================================================
func _draw_walk() -> void:
	var p := pal
	var ol := p.outline

	# Legs — aggressive stride, bent knees
	draw_limb(Vector2(-6, HIP_Y), Vector2(-14, KNEE_Y + 3), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-14, KNEE_Y + 3), Vector2(-14, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-14, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(6, HIP_Y), Vector2(10, KNEE_Y - 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(10, KNEE_Y - 2), Vector2(14, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(14, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — leaning forward aggressively
	var top_pts := PackedVector2Array([
		Vector2(-TORSO_W + 2, TORSO_TOP - 1), Vector2(TORSO_W + 2, TORSO_TOP - 2),
		Vector2(TORSO_W * 0.95 + 1, TORSO_BOT), Vector2(-TORSO_W * 0.95 + 1, TORSO_BOT)
	])
	draw_colored_polygon(top_pts, p.outfit_primary)
	draw_polyline(top_pts, ol, 1.0, true)
	draw_line(Vector2(-TORSO_W + 2, TORSO_TOP), Vector2(-TORSO_W, TORSO_TOP + 4), p.torn_edge, 2.0)
	draw_line(Vector2(TORSO_W + 2, TORSO_TOP), Vector2(TORSO_W + 4, TORSO_TOP + 4), p.torn_edge, 2.0)
	draw_rect(Rect2(-TORSO_W * 0.95, WAIST_Y - 2, TORSO_W * 1.9, 4), p.belt)

	# Arms — swinging with stride
	draw_limb(Vector2(-SHOULDER_W + 2, SHOULDER_Y), Vector2(-18, SHOULDER_Y + 10), ARM_THICK, p.skin, ol)
	_draw_burn_scars(Vector2(-SHOULDER_W + 2, SHOULDER_Y), Vector2(-18, SHOULDER_Y + 10))
	draw_fist(Vector2(-18, SHOULDER_Y + 10), FIST_R, p.skin, ol)

	draw_limb(Vector2(SHOULDER_W + 2, SHOULDER_Y), Vector2(20, SHOULDER_Y + 2), ARM_THICK, p.skin, ol)
	_draw_burn_scars(Vector2(SHOULDER_W + 2, SHOULDER_Y), Vector2(20, SHOULDER_Y + 2))
	draw_limb(Vector2(20, SHOULDER_Y + 2), Vector2(16, SHOULDER_Y - 2), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(16, SHOULDER_Y - 2), FIST_R, p.skin, ol)

	_draw_head_fierce(Vector2(2, HEAD_Y - 1))


func _draw_walk_2() -> void:
	var p := pal
	var ol := p.outline

	# Legs — opposite stride
	draw_limb(Vector2(-6, HIP_Y), Vector2(-8, KNEE_Y - 2), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-8, KNEE_Y - 2), Vector2(-6, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-6, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(6, HIP_Y), Vector2(14, KNEE_Y + 3), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(14, KNEE_Y + 3), Vector2(12, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(12, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso
	var top_pts := PackedVector2Array([
		Vector2(-TORSO_W + 2, TORSO_TOP - 1), Vector2(TORSO_W + 2, TORSO_TOP - 2),
		Vector2(TORSO_W * 0.95 + 1, TORSO_BOT), Vector2(-TORSO_W * 0.95 + 1, TORSO_BOT)
	])
	draw_colored_polygon(top_pts, p.outfit_primary)
	draw_polyline(top_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.95, WAIST_Y - 2, TORSO_W * 1.9, 4), p.belt)

	# Arms — swapped
	draw_limb(Vector2(-SHOULDER_W + 2, SHOULDER_Y), Vector2(-16, SHOULDER_Y + 2), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(-16, SHOULDER_Y + 2), Vector2(-12, SHOULDER_Y - 2), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(-12, SHOULDER_Y - 2), FIST_R, p.skin, ol)

	draw_limb(Vector2(SHOULDER_W + 2, SHOULDER_Y), Vector2(20, SHOULDER_Y + 10), ARM_THICK, p.skin, ol)
	_draw_burn_scars(Vector2(SHOULDER_W + 2, SHOULDER_Y), Vector2(20, SHOULDER_Y + 10))
	draw_fist(Vector2(20, SHOULDER_Y + 10), FIST_R, p.skin, ol)

	_draw_head_fierce(Vector2(2, HEAD_Y - 1))


# =========================================================================
#  ATTACK LP — Wild hook. Less clean than Kael's jab. Momentum.
# =========================================================================
func _draw_attack_lp() -> void:
	var p := pal
	var ol := p.outline

	# Legs — aggressive base
	draw_limb(Vector2(-7, HIP_Y), Vector2(-12, KNEE_Y + 1), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-12, KNEE_Y + 1), Vector2(-10, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-10, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(6, HIP_Y), Vector2(10, KNEE_Y - 1), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(10, KNEE_Y - 1), Vector2(12, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(12, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — rotated into hook
	var top_pts := PackedVector2Array([
		Vector2(-TORSO_W + 3, TORSO_TOP + 1), Vector2(TORSO_W - 1, TORSO_TOP),
		Vector2(TORSO_W * 0.9, TORSO_BOT), Vector2(-TORSO_W * 0.9 + 2, TORSO_BOT)
	])
	draw_colored_polygon(top_pts, p.outfit_primary)
	draw_polyline(top_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.9, WAIST_Y - 2, TORSO_W * 1.8, 4), p.belt)

	# Back arm — pulled back aggressively
	draw_limb(Vector2(-SHOULDER_W + 3, SHOULDER_Y), Vector2(-16, SHOULDER_Y + 8), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-16, SHOULDER_Y + 8), FIST_R, p.skin, ol)

	# Punching arm — wild hook (curved trajectory)
	draw_limb(Vector2(SHOULDER_W - 1, SHOULDER_Y), Vector2(22, SHOULDER_Y - 4), ARM_THICK + 0.5, p.skin, ol)
	_draw_burn_scars(Vector2(SHOULDER_W, SHOULDER_Y), Vector2(22, SHOULDER_Y - 4))
	draw_limb(Vector2(22, SHOULDER_Y - 4), Vector2(30, SHOULDER_Y + 2), ARM_THICK + 0.5, p.wrap, ol)
	draw_fist(Vector2(30, SHOULDER_Y + 2), FIST_R + 0.5, p.skin, ol)
	draw_circle(Vector2(30, SHOULDER_Y + 2), FIST_R + 2.5, p.accent_glow)

	_draw_head_attacking(Vector2(2, HEAD_Y + 1))


# =========================================================================
#  ATTACK MP — Lunging straight. Rhena throws her whole body into it.
# =========================================================================
func _draw_attack_mp() -> void:
	var p := pal
	var ol := p.outline

	# Legs — pushing off back foot, lunging
	draw_limb(Vector2(-7, HIP_Y), Vector2(-14, KNEE_Y + 3), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-14, KNEE_Y + 3), Vector2(-16, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-16, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(6, HIP_Y), Vector2(12, KNEE_Y - 2), LEG_THICK + 0.5, p.outfit_secondary, ol)
	draw_limb(Vector2(12, KNEE_Y - 2), Vector2(16, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(16, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — deep forward lean, momentum overshoot
	var top_pts := PackedVector2Array([
		Vector2(-TORSO_W + 5, TORSO_TOP + 3), Vector2(TORSO_W, TORSO_TOP - 2),
		Vector2(TORSO_W * 0.9, TORSO_BOT), Vector2(-TORSO_W * 0.85 + 4, TORSO_BOT)
	])
	draw_colored_polygon(top_pts, p.outfit_primary)
	draw_polyline(top_pts, ol, 1.0, true)
	draw_rect(Rect2(-TORSO_W * 0.85 + 2, WAIST_Y - 2, TORSO_W * 1.7, 4), p.belt)

	# Back arm — trailing behind from momentum
	draw_limb(Vector2(-SHOULDER_W + 5, SHOULDER_Y + 3), Vector2(-14, SHOULDER_Y + 14), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-14, SHOULDER_Y + 14), FIST_R, p.skin, ol)

	# Punching arm — full body straight, maximum reach
	draw_limb(Vector2(SHOULDER_W, SHOULDER_Y - 2), Vector2(26, SHOULDER_Y - 8), ARM_THICK + 1.0, p.skin, ol)
	_draw_burn_scars(Vector2(SHOULDER_W, SHOULDER_Y), Vector2(26, SHOULDER_Y - 8))
	draw_limb(Vector2(26, SHOULDER_Y - 8), Vector2(36, SHOULDER_Y - 6), ARM_THICK + 1.0, p.wrap, ol)
	draw_fist(Vector2(36, SHOULDER_Y - 6), FIST_R + 1.0, p.skin, ol)
	draw_circle(Vector2(36, SHOULDER_Y - 6), FIST_R + 4.0, p.accent_glow)

	_draw_head_attacking(Vector2(4, HEAD_Y + 2))


# =========================================================================
#  ATTACK HP — Haymaker. Maximum wind-up, full-body explosion.
#  Overshoot, messy, devastating. Reads completely different from Kael's HP.
# =========================================================================
func _draw_attack_hp() -> void:
	var p := pal
	var ol := p.outline

	# Legs — explosive lunge, back leg fully extended
	draw_limb(Vector2(-7, HIP_Y), Vector2(-18, KNEE_Y + 4), LEG_THICK + 0.5, p.outfit_secondary, ol)
	draw_limb(Vector2(-18, KNEE_Y + 4), Vector2(-22, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-22, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(7, HIP_Y), Vector2(14, KNEE_Y - 4), LEG_THICK + 1.0, p.outfit_secondary, ol)
	draw_limb(Vector2(14, KNEE_Y - 4), Vector2(20, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(20, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — massive forward lean, overcommitted
	var top_pts := PackedVector2Array([
		Vector2(-TORSO_W + 7, TORSO_TOP + 5), Vector2(TORSO_W + 2, TORSO_TOP - 4),
		Vector2(TORSO_W * 0.9 + 1, TORSO_BOT), Vector2(-TORSO_W * 0.8 + 6, TORSO_BOT)
	])
	draw_colored_polygon(top_pts, p.outfit_primary)
	draw_polyline(top_pts, ol, 1.0, true)
	# Torn sleeve edge extra tattered
	draw_line(Vector2(TORSO_W + 2, TORSO_TOP - 4), Vector2(TORSO_W + 5, TORSO_TOP), p.torn_edge, 2.5)
	draw_line(Vector2(TORSO_W + 2, TORSO_TOP - 3), Vector2(TORSO_W + 6, TORSO_TOP + 2), p.torn_edge, 1.5)

	# Back arm — fully wound back behind body
	draw_limb(Vector2(-SHOULDER_W + 7, SHOULDER_Y + 5), Vector2(-10, SHOULDER_Y + 16), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(-10, SHOULDER_Y + 16), FIST_R, p.skin, ol)

	# Haymaker arm — MASSIVE extension, fist oversized for impact
	draw_limb(Vector2(SHOULDER_W + 2, SHOULDER_Y - 4), Vector2(30, SHOULDER_Y - 12), ARM_THICK + 1.5, p.skin, ol)
	_draw_burn_scars(Vector2(SHOULDER_W + 2, SHOULDER_Y - 4), Vector2(30, SHOULDER_Y - 12))
	draw_limb(Vector2(30, SHOULDER_Y - 12), Vector2(42, SHOULDER_Y - 8), ARM_THICK + 1.5, p.wrap, ol)
	draw_fist(Vector2(42, SHOULDER_Y - 8), FIST_R + 2.0, p.skin, ol)
	# Massive ember burst
	draw_circle(Vector2(42, SHOULDER_Y - 8), FIST_R + 7.0, p.accent_glow)
	draw_circle(Vector2(42, SHOULDER_Y - 8), FIST_R + 4.0, Color(p.accent, 0.5))
	draw_circle(Vector2(42, SHOULDER_Y - 8), FIST_R + 2.0, Color(1.0, 0.9, 0.7, 0.3))

	_draw_head_screaming(Vector2(6, HEAD_Y + 3))


# =========================================================================
#  HIT — Rhena recoils hard but angrily. She doesn't absorb — she flinches
#  then looks furious. More dramatic reaction than Kael.
# =========================================================================
func _draw_hit() -> void:
	var p := pal
	var ol := p.outline

	# Legs — thrown off balance
	draw_limb(Vector2(-5, HIP_Y), Vector2(-10, KNEE_Y + 3), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-10, KNEE_Y + 3), Vector2(-14, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-14, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(5, HIP_Y), Vector2(2, KNEE_Y + 1), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(2, KNEE_Y + 1), Vector2(-2, FOOT_Y), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-2, FOOT_Y), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — snapping backward from impact
	var top_pts := PackedVector2Array([
		Vector2(-TORSO_W - 3, TORSO_TOP + 5), Vector2(TORSO_W - 4, TORSO_TOP + 3),
		Vector2(TORSO_W * 0.9 - 3, TORSO_BOT), Vector2(-TORSO_W * 0.9 - 2, TORSO_BOT)
	])
	draw_colored_polygon(top_pts, p.outfit_primary)
	draw_polyline(top_pts, ol, 1.0, true)

	# Arms — flailing outward (dramatic, messy)
	draw_limb(Vector2(-SHOULDER_W - 3, SHOULDER_Y + 5), Vector2(-22, SHOULDER_Y + 2), ARM_THICK, p.skin, ol)
	_draw_burn_scars(Vector2(-SHOULDER_W, SHOULDER_Y + 5), Vector2(-22, SHOULDER_Y + 2))
	draw_limb(Vector2(-22, SHOULDER_Y + 2), Vector2(-24, SHOULDER_Y + 8), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(-24, SHOULDER_Y + 8), FIST_R, p.skin, ol)

	draw_limb(Vector2(SHOULDER_W - 4, SHOULDER_Y + 3), Vector2(14, SHOULDER_Y + 14), ARM_THICK, p.skin, ol)
	draw_limb(Vector2(14, SHOULDER_Y + 14), Vector2(10, SHOULDER_Y + 18), ARM_THICK, p.wrap, ol)
	draw_fist(Vector2(10, SHOULDER_Y + 18), FIST_R, p.skin, ol)

	# Head — angry pain grimace
	var hc := Vector2(-3, HEAD_Y + 4)
	draw_circle_outlined(hc, HEAD_R, p.skin, ol, 1.0)
	_draw_wild_hair(hc)
	# Angry squint
	draw_line(hc + Vector2(-4, -2), hc + Vector2(-2, 0), p.eye, 2.0)
	draw_line(hc + Vector2(0, -2), hc + Vector2(2, 0), p.eye, 2.0)
	# Snarling mouth
	draw_line(hc + Vector2(-3, 3), hc + Vector2(0, 4), p.eye, 1.5)
	draw_line(hc + Vector2(0, 4), hc + Vector2(3, 3), p.eye, 1.5)


# =========================================================================
#  KO — Ragdoll collapse. Wild, undignified. Opposite of Kael's composure.
# =========================================================================
func _draw_ko() -> void:
	var p := pal
	var ol := p.outline

	# Legs — sprawled
	draw_limb(Vector2(-2, HIP_Y + 10), Vector2(-12, KNEE_Y + 14), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(-12, KNEE_Y + 14), Vector2(-18, FOOT_Y + 8), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(-18, FOOT_Y + 8), BOOT_W, BOOT_H, p.boots, p.sole, ol)
	draw_limb(Vector2(5, HIP_Y + 10), Vector2(8, KNEE_Y + 16), LEG_THICK, p.outfit_secondary, ol)
	draw_limb(Vector2(8, KNEE_Y + 16), Vector2(2, FOOT_Y + 10), LEG_THICK, p.outfit_secondary, ol)
	draw_boot(Vector2(2, FOOT_Y + 10), BOOT_W, BOOT_H, p.boots, p.sole, ol)

	# Torso — crumpled
	var top_pts := PackedVector2Array([
		Vector2(-TORSO_W - 6, TORSO_TOP + 14), Vector2(TORSO_W - 8, TORSO_TOP + 12),
		Vector2(TORSO_W * 0.9 - 6, TORSO_BOT + 10), Vector2(-TORSO_W * 0.9 - 4, TORSO_BOT + 10)
	])
	draw_colored_polygon(top_pts, p.outfit_primary)
	draw_polyline(top_pts, ol, 1.0, true)

	# Arms — flopped out
	draw_limb(Vector2(-SHOULDER_W - 6, SHOULDER_Y + 14), Vector2(-24, SHOULDER_Y + 20), ARM_THICK, p.skin, ol)
	_draw_burn_scars(Vector2(-SHOULDER_W - 4, SHOULDER_Y + 14), Vector2(-24, SHOULDER_Y + 20))
	draw_fist(Vector2(-24, SHOULDER_Y + 20), FIST_R, p.skin, ol)
	draw_limb(Vector2(SHOULDER_W - 8, SHOULDER_Y + 12), Vector2(10, SHOULDER_Y + 24), ARM_THICK, p.skin, ol)
	draw_fist(Vector2(10, SHOULDER_Y + 24), FIST_R, p.skin, ol)

	# Head — X eyes, tongue out (more dramatic KO than Kael)
	var hc := Vector2(-7, HEAD_Y + 14)
	draw_circle_outlined(hc, HEAD_R, p.skin, ol, 1.0)
	_draw_wild_hair(hc)
	# X eyes
	draw_line(hc + Vector2(-5, -2), hc + Vector2(-3, 0), p.eye, 2.0)
	draw_line(hc + Vector2(-5, 0), hc + Vector2(-3, -2), p.eye, 2.0)
	draw_line(hc + Vector2(1, -2), hc + Vector2(3, 0), p.eye, 2.0)
	draw_line(hc + Vector2(1, 0), hc + Vector2(3, -2), p.eye, 2.0)
	# Open mouth with tongue
	draw_ellipse(hc + Vector2(0, 4), Vector2(3, 2), Color(0.3, 0.1, 0.1))
	draw_ellipse(hc + Vector2(1, 5), Vector2(2, 1.2), Color(0.8, 0.3, 0.3))


# =========================================================================
#  Rhena-specific drawing helpers
# =========================================================================

## Wild spiky short hair — Rhena's defining feature
func _draw_wild_hair(center: Vector2) -> void:
	var p := pal
	# Base hair cap
	draw_arc(center, HEAD_R, deg_to_rad(180), deg_to_rad(420), 16, p.hair, 3.5, true)
	# Spiky tufts (what makes her silhouette distinct from Kael)
	var spikes := [
		Vector2(-5, -6), Vector2(-7, -10),
		Vector2(-2, -7), Vector2(-1, -12),
		Vector2(2, -7), Vector2(4, -11),
		Vector2(5, -5), Vector2(8, -8),
		Vector2(6, -3), Vector2(10, -5),
	]
	for i in range(0, spikes.size(), 2):
		draw_line(center + spikes[i], center + spikes[i + 1], p.hair, 2.5, true)


## Burn scars — jagged lines on upper arms
func _draw_burn_scars(from: Vector2, to: Vector2) -> void:
	var p := pal
	var mid := (from + to) * 0.5
	var perp := (to - from).normalized().rotated(PI * 0.5)
	# 3-4 jagged scar marks
	for i in 3:
		var offset := (float(i) - 1.0) * 3.0
		var scar_center := mid + (to - from).normalized() * offset
		draw_line(
			scar_center + perp * 2.5,
			scar_center - perp * 2.5,
			p.scar, 1.5, true
		)


## Fierce/ready expression
func _draw_head_fierce(center: Vector2) -> void:
	var p := pal
	draw_circle_outlined(center, HEAD_R, p.skin, p.outline, 1.0)
	_draw_wild_hair(center)
	# Intense eyes (angled brows via line direction)
	draw_line(center + Vector2(-4, -2), center + Vector2(-2, -1), p.eye, 2.0)
	draw_line(center + Vector2(1, -2), center + Vector2(3, -1), p.eye, 2.0)
	# Slight snarl
	draw_line(center + Vector2(-2, 3), center + Vector2(0, 3.5), p.eye, 1.0)
	draw_line(center + Vector2(0, 3.5), center + Vector2(2, 3), p.eye, 1.0)


## Attacking expression — teeth bared
func _draw_head_attacking(center: Vector2) -> void:
	var p := pal
	draw_circle_outlined(center, HEAD_R, p.skin, p.outline, 1.0)
	_draw_wild_hair(center)
	# Wide angry eyes
	draw_line(center + Vector2(-4, -3), center + Vector2(-1, -1), p.eye, 2.0)
	draw_line(center + Vector2(1, -3), center + Vector2(4, -1), p.eye, 2.0)
	# Open screaming mouth
	draw_ellipse(center + Vector2(0, 4), Vector2(3, 2), Color(0.3, 0.1, 0.1))
	# Teeth line
	draw_line(center + Vector2(-2, 3.5), center + Vector2(2, 3.5), Color(0.9, 0.9, 0.85), 1.0)


## Full scream — for heavy attacks
func _draw_head_screaming(center: Vector2) -> void:
	var p := pal
	draw_circle_outlined(center, HEAD_R, p.skin, p.outline, 1.0)
	_draw_wild_hair(center)
	# Wide furious eyes
	draw_circle(center + Vector2(-3, -1), 2.0, p.eye)
	draw_circle(center + Vector2(2, -1), 2.0, p.eye)
	# Highlight dots in eyes
	draw_circle(center + Vector2(-2.5, -1.5), 0.8, Color.WHITE)
	draw_circle(center + Vector2(2.5, -1.5), 0.8, Color.WHITE)
	# Huge open mouth
	draw_ellipse(center + Vector2(0, 4), Vector2(4, 3), Color(0.3, 0.1, 0.1))
	draw_line(center + Vector2(-3, 3), center + Vector2(3, 3), Color(0.9, 0.9, 0.85), 1.0)
