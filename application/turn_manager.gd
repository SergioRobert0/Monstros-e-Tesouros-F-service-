extends RefCounted

const Phases = preload("res://core/domain/game_phase.gd")

func transition(state: Object, next_phase: String) -> Dictionary:
	if not Phases.can_transition(state.current_phase, next_phase):
		return {"success": false, "error": "invalid_transition", "from": state.current_phase, "to": next_phase}
	state.current_phase = next_phase
	return {"success": true, "phase": next_phase}

func begin_next_turn(state: Object, player_ids: Array[String]) -> bool:
	if player_ids.is_empty() or not player_ids.has(state.active_player_id):
		return false
	var current_index := player_ids.find(state.active_player_id)
	state.active_player_id = player_ids[(current_index + 1) % player_ids.size()]
	state.current_round += 1
	return true
