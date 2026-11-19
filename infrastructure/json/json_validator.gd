extends RefCounted

const REQUIRED := {
	"hero": ["id", "name", "subtitle", "power", "attributes", "abilities", "advantages"],
	"monster": ["id", "name", "monster_type", "monster_level", "power", "attributes", "abilities", "advantages", "evolution_experience"],
	"terrain": ["id", "name", "monster_icons", "treasure_bonus", "effects"],
	"treasure": ["id", "name", "treasure_points", "treasure_type", "equipment_slot", "power_bonus", "attribute_requirement", "abilities", "advantages"],
	"action": ["id", "name", "power_bonus", "attribute_requirement", "target", "effects", "duration"]
}

const STRING_FIELDS := ["id", "name", "subtitle", "monster_type", "treasure_type", "equipment_slot", "target", "duration"]
const ARRAY_FIELDS := ["abilities", "advantages", "effects", "monster_icons"]
const DICTIONARY_FIELDS := ["attributes", "attribute_requirement"]
const NUMBER_FIELDS := ["power", "monster_level", "evolution_experience", "treasure_bonus", "treasure_points", "power_bonus"]

func validate_cards(cards: Variant, card_type: String, source_path: String) -> Dictionary:
	var errors: Array[Dictionary] = []
	if not REQUIRED.has(card_type):
		return {"valid": false, "errors": [{"path": source_path, "field": "card_type", "message": "Tipo de carta desconhecido."}]}
	if not cards is Array:
		return {"valid": false, "errors": [{"path": source_path, "field": "$", "message": "A raiz do JSON deve ser um array."}]}

	var ids := {}
	for index in cards.size():
		var card = cards[index]
		if not card is Dictionary:
			errors.append({"path": source_path, "field": "[%s]" % index, "message": "A carta deve ser um objeto."})
			continue

		for field in REQUIRED[card_type]:
			if not card.has(field):
				errors.append({"path": source_path, "field": "[%s].%s" % [index, field], "message": "Campo obrigatório ausente."})

		for field in STRING_FIELDS:
			if card.has(field) and (not card[field] is String or card[field].strip_edges().is_empty()):
				errors.append({"path": source_path, "field": "[%s].%s" % [index, field], "message": "Deve ser uma string não vazia."})

		for field in ARRAY_FIELDS:
			if card.has(field) and not card[field] is Array:
				errors.append({"path": source_path, "field": "[%s].%s" % [index, field], "message": "Deve ser um array."})

		for field in DICTIONARY_FIELDS:
			if card.has(field) and not card[field] is Dictionary:
				errors.append({"path": source_path, "field": "[%s].%s" % [index, field], "message": "Deve ser um objeto."})
			elif card.has(field):
				for attribute_value in card[field].values():
					if not (attribute_value is int or attribute_value is float):
						errors.append({"path": source_path, "field": "[%s].%s" % [index, field], "message": "Os valores devem ser numéricos."})

		for field in NUMBER_FIELDS:
			if card.has(field) and not (card[field] is int or card[field] is float):
				errors.append({"path": source_path, "field": "[%s].%s" % [index, field], "message": "Deve ser numérico."})

		var card_id_value: Variant = card.get("id", "")
		if not card_id_value is String or card_id_value.strip_edges().is_empty():
			continue
		var card_id: String = card_id_value
		if ids.has(card_id):
			errors.append({"path": source_path, "field": "[%s].id" % index, "message": "ID duplicado '%s'." % card_id})
		else:
			ids[card_id] = true

	return {"valid": errors.is_empty(), "errors": errors}
