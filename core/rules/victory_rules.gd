extends RefCounted

func evaluate(state: Object) -> Dictionary:
	var living_players: Array[String] = []
	for player_id in state.players:
		var player = state.players[player_id]
		if not player.check_elimination():
			living_players.append(str(player_id))
	if living_players.size() == 1:
		return {"finished": true, "winner_id": living_players[0], "reason": "last_player_with_living_heroes"}
	for player_id in living_players:
		var player = state.players[player_id]
		var objective: Dictionary = state.victory_objective
		if objective.get("type") == "conquer_terrains" and player.conquered_terrains.size() >= int(objective.get("target", 5)):
			return {"finished": true, "winner_id": player_id, "reason": "objective_completed"}
	return {"finished": false, "winner_id": "", "reason": ""}
