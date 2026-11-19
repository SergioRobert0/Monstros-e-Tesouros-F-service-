extends RefCounted

const Selector = preload("res://ai/ai_action_selector.gd")
var selector = Selector.new()

func select_action(observation: Dictionary, legal_actions: Array) -> Dictionary:
	var observed_legal: Array = observation.get("legal_actions", legal_actions)
	var allowed: Array = []
	for action in legal_actions:
		if observed_legal.has(action):
			allowed.append(action)
	return selector.select(allowed, ["play_action_card", "use_character_ability", "use_treasure_ability"])
