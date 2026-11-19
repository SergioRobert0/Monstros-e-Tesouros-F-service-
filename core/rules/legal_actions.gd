extends RefCounted

func for_character(character: Object, character_definition: Dictionary, hand: Array, treasures: Array) -> Array[Dictionary]:
	var actions: Array[Dictionary] = []
	if not character.can_act():
		return actions
	for card_id in hand:
		actions.append({"type": "play_action_card", "actor_card_id": character.card_id, "card_id": card_id})
	var abilities: Array = character_definition.get("abilities", [])
	for index in abilities.size():
		actions.append({"type": "use_character_ability", "actor_card_id": character.card_id, "ability_index": index})
	for treasure_id in character.equipped_treasures:
		if treasures.has(treasure_id):
			actions.append({"type": "use_treasure_ability", "actor_card_id": character.card_id, "treasure_id": treasure_id})
	return actions

func for_player(player: Object, definitions: Dictionary) -> Array[Dictionary]:
	var actions: Array[Dictionary] = []
	for hero in player.heroes:
		actions.append_array(for_character(hero, definitions.get(hero.card_id, {}), player.hand, player.treasures))
	return actions
