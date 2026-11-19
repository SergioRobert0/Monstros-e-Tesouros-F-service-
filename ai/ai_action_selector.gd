extends RefCounted

func select(legal_actions: Array, preferred_types: Array[String] = []) -> Dictionary:
	for action_type in preferred_types:
		for action in legal_actions:
			if action.get("type") == action_type:
				return action.duplicate(true)
	if legal_actions.is_empty():
		return {}
	return legal_actions[0].duplicate(true)
