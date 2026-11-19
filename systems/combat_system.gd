extends RefCounted

const Character = preload("res://core/domain/character_state.gd")

func resolve_initiative(hero_group: Array, monster_group: Array, random_provider: Object) -> String:
	var heroes_have := _has_initiative(hero_group)
	var monsters_have := _has_initiative(monster_group)
	if heroes_have != monsters_have:
		return "heroes" if heroes_have else "monsters"
	while true:
		var hero_roll: int = random_provider.roll_die(6)
		var monster_roll: int = random_provider.roll_die(6)
		if hero_roll != monster_roll:
			return "heroes" if hero_roll > monster_roll else "monsters"
	return ""

func group_power(group: Array, definitions: Dictionary, die_result: int) -> int:
	var total := die_result
	for character in group:
		if character.is_alive():
			total += character.effective_power(definitions.get(character.card_id, {}))
	return total

func compare_power(hero_total: int, monster_total: int) -> String:
	if hero_total == monster_total:
		return "tie"
	return "heroes" if hero_total > monster_total else "monsters"

func apply_wound(group: Array, card_id: String) -> Dictionary:
	for character in group:
		if character.card_id == card_id:
			var previous: String = character.wound_state
			var current: String = character.apply_wound()
			return {"success": previous != Character.DEAD, "previous_state": previous, "current_state": current}
	return {"success": false, "error": "character_not_found"}

func reset_round(groups: Array) -> void:
	for group in groups:
		for character in group:
			character.reset_round()

func _has_initiative(group: Array) -> bool:
	for character in group:
		if character.is_alive() and character.has_initiative:
			return true
	return false
