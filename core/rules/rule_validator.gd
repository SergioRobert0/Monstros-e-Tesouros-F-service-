extends RefCounted

func validate_action(state: Object, command: Dictionary) -> Dictionary:
	if state.game_status != "active":
		return _error("game_finished", "A partida já terminou.")
	var player_id: Variant = command.get("player_id", "")
	if not player_id is String or player_id.is_empty():
		return _error("invalid_player", "Identificador do jogador inv\u00e1lido.")
	if player_id != state.active_player_id:
		return _error("inactive_player", "O jogador não está ativo.")
	var phase: Variant = command.get("phase", state.current_phase)
	if not phase is String or phase.is_empty():
		return _error("invalid_phase", "Fase inv\u00e1lida.")
	if phase != state.current_phase:
		return _error("wrong_phase", "A ação não pertence à fase atual.")
	return {"valid": true, "errors": []}

func _error(code: String, message: String) -> Dictionary:
	return {"valid": false, "errors": [{"code": code, "message": message}]}

func meets_attribute_requirement(character: Object, definition: Dictionary, requirements: Dictionary) -> bool:
	for attribute in requirements:
		if character.effective_attribute(definition, str(attribute)) < int(requirements[attribute]):
			return false
	return true
