extends RefCounted

const TYPES := ["hero", "monster", "terrain", "treasure", "action"]
const ATTRIBUTES := ["attack", "defense", "arcane_magic", "divine_magic", "stealth"]
var id := ""
var card_type := ""
var data: Dictionary = {}
var extra_fields: Dictionary = {}

func _init(p_type := "", source: Dictionary = {}) -> void:
	card_type = p_type
	data = source.duplicate(true)
	id = str(data.get("id", ""))
	for key in data:
		if not _known_fields().has(key):
			extra_fields[key] = data[key]

func _known_fields() -> Array:
	var common := ["id", "name", "attributes", "abilities", "advantages"]
	var fields := {
		"hero": common + ["subtitle", "power"],
		"monster": common + ["monster_type", "monster_level", "power", "evolution_experience"],
		"terrain": ["id", "name", "monster_icons", "treasure_bonus", "effects"],
		"treasure": common + ["treasure_points", "treasure_type", "equipment_slot", "power_bonus", "attribute_requirement"],
		"action": ["id", "name", "power_bonus", "attribute_requirement", "target", "effects", "duration"]
	}
	return fields.get(card_type, common)

func to_dictionary() -> Dictionary:
	return data.duplicate(true)
