extends RefCounted

func is_monster_level_compatible(monster_level: int, icon: Dictionary) -> bool:
	var level := int(icon.get("level", 0))
	match str(icon.get("operator", "exact")):
		"plus": return monster_level >= level
		"minus": return monster_level <= level
		_: return monster_level == level

func can_reject_terrain(rejections: int, mandatory_exploration: bool) -> bool:
	return not mandatory_exploration and rejections < 3

func calculate_treasure_points(defeated_monsters: Array, terrain: Dictionary) -> int:
	var total := int(terrain.get("treasure_bonus", 0))
	for monster in defeated_monsters:
		total += int(monster.get("monster_level", 0))
	return total

func is_conquerable(combat_occurred: bool, active_player_won: bool) -> bool:
	return combat_occurred and active_player_won
