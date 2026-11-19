extends RefCounted

func build(state: Object, player_id: String, legal_actions: Array) -> Dictionary:
	var observation: Dictionary = state.to_public_dict(player_id)
	observation["legal_actions"] = legal_actions.duplicate(true)
	return observation
