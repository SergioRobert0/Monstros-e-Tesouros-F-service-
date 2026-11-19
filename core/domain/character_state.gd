extends RefCounted

const NORMAL := "normal"
const WOUNDED := "wounded"
const DEAD := "dead"

var card_id: String
var owner_id: String
var wound_state := NORMAL
var temporary_modifiers: Dictionary = {}
var equipped_treasures: Array[String] = []
var familiar_id: Variant = null
var experience_cards: Array[String] = []
var has_acted_this_round := false
var has_initiative := false

func _init(p_card_id := "", p_owner_id := "") -> void:
	card_id = p_card_id
	owner_id = p_owner_id

func is_alive() -> bool:
	return wound_state != DEAD

func can_act() -> bool:
	return wound_state != DEAD and not has_acted_this_round

func effective_power(definition: Dictionary) -> int:
	if wound_state == DEAD:
		return 0
	var value := int(definition.get("power", 0))
	if wound_state == WOUNDED:
		value -= 1
	value += int(temporary_modifiers.get("power", 0))
	return maxi(0, value)

func effective_attribute(definition: Dictionary, attribute: String) -> int:
	if wound_state == DEAD:
		return 0
	var attributes: Dictionary = definition.get("attributes", {})
	return maxi(0, int(attributes.get(attribute, 0)) + int(temporary_modifiers.get(attribute, 0)))

func apply_wound() -> String:
	if wound_state == NORMAL:
		wound_state = WOUNDED
		has_initiative = false
		return WOUNDED
	if wound_state == WOUNDED:
		wound_state = DEAD
		has_initiative = false
		return DEAD
	return DEAD

func heal() -> bool:
	if wound_state != WOUNDED:
		return false
	wound_state = NORMAL
	return true

func resurrect() -> bool:
	if wound_state != DEAD:
		return false
	wound_state = NORMAL
	return true

func reset_round() -> void:
	has_acted_this_round = false
	for key in temporary_modifiers.keys():
		if temporary_modifiers[key] is Dictionary and temporary_modifiers[key].get("duration") == "round_end":
			temporary_modifiers.erase(key)
