## Autoload signal bus for decoupled inter-system communication.
## All gameplay signals route through here so emitters and listeners
## never need direct references to each other.
extends Node

# --- Combat signals ---
signal hit_landed(attacker, target, move)
signal hit_blocked(attacker, target, move)
signal hit_confirmed(attacker, target, move, combo_count: int)
signal combo_updated(fighter, combo_count: int)
signal combo_ended(fighter, total_hits: int, total_damage: int)

# --- Fighter signals ---
signal fighter_damaged(fighter, amount: int, remaining_hp: int)
signal fighter_ko(fighter)

# --- Round signals ---
signal round_started(round_number: int)
signal round_ended(winner, round_number: int)
signal round_draw(round_number: int)
signal match_ended(winner, scores: Array)
signal match_draw(scores: Array)
signal timer_updated(seconds_remaining: int)
signal announce(text: String)

# --- Ember system signals ---
signal ember_changed(player_id: int, new_value: int)
signal ember_spent(player_id: int, amount: int, action: String)
signal ignition_activated(player_id: int)

# --- Game flow signals ---
signal game_paused()
signal game_resumed()
signal scene_change_requested(scene_path: String)
