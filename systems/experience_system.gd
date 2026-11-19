extends RefCounted

func award(hero: Object, defeated_monsters: Array) -> void:
	for monster in defeated_monsters:
		var experience_id := str(monster.get("id", ""))
		if not experience_id.is_empty() and not hero.experience_cards.has(experience_id):
			hero.experience_cards.append(experience_id)

func can_evolve(attribute_value: int, amount: int, maximum := 4) -> bool:
	return amount > 0 and attribute_value + amount <= maximum
