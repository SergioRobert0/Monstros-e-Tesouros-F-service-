extends RefCounted

var game_id := ""
var active_player_id := ""
var current_phase := "TURN_START"
var current_round := 1
var players: Dictionary = {}
var card_piles: Dictionary = {}
var discard_piles: Dictionary = {}
var current_terrain: Variant = null
var revealed_monsters: Array = []
var combat_state: Dictionary = {}
var turn_history: Array[Dictionary] = []
var victory_objective: Dictionary = {"id": "conqueror", "type": "conquer_terrains", "target": 5}
var game_status := "active"
var winner_id := ""
var metadata: Dictionary = {}

func _init(p_game_id := "") -> void:
	game_id = p_game_id

func get_active_player() -> Variant:
	return players.get(active_player_id)

func to_public_dict(observer_player_id := "") -> Dictionary:
	var public_players := {}
	for player_id in players:
		var player = players[player_id]
		var public_heroes: Array = []
		for hero in player.heroes:
			public_heroes.append({
				"card_id": hero.card_id, "owner_id": hero.owner_id,
				"wound_state": hero.wound_state,
				"temporary_modifiers": hero.temporary_modifiers.duplicate(true),
				"equipped_treasures": hero.equipped_treasures.duplicate(),
				"familiar_id": hero.familiar_id,
				"experience_cards": hero.experience_cards.duplicate(),
				"has_acted_this_round": hero.has_acted_this_round,
				"has_initiative": hero.has_initiative
			})
		public_players[player_id] = {
			"is_human": player.is_human, "heroes": public_heroes,
			"hand_count": player.hand.size(), "treasures": player.treasures.duplicate(),
			"conquered_terrains": player.conquered_terrains.duplicate(),
			"is_eliminated": player.is_eliminated
		}
		if player_id == observer_player_id:
			public_players[player_id]["hand"] = player.hand.duplicate(true)
	return {
		"game_id": game_id, "active_player_id": active_player_id,
		"current_phase": current_phase, "current_round": current_round,
		"players": public_players, "current_terrain": _snapshot_value(current_terrain),
		"revealed_monsters": _snapshot_value(revealed_monsters), "combat_state": combat_state.duplicate(true),
		"victory_objective": victory_objective.duplicate(true), "game_status": game_status
	}

func _snapshot_value(value: Variant) -> Variant:
	if value is Dictionary or value is Array:
		return value.duplicate(true)
	if value is Object and value.has_method("to_dictionary"):
		return value.to_dictionary()
	return value
