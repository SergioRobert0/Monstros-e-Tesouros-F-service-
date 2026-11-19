extends RefCounted

func can_equip(character: Object, definition: Dictionary, treasure: Dictionary) -> bool:
	var requirements: Dictionary = treasure.get("attribute_requirement", {})
	for attribute in requirements:
		if character.effective_attribute(definition, str(attribute)) < int(requirements[attribute]):
			return false
	var slot := str(treasure.get("equipment_slot", ""))
	if slot == "weapon" or slot == "shield":
		for equipped_id in character.equipped_treasures:
			if str(equipped_id).begins_with(slot + ":"):
				return false
	return true

func select_within_budget(revealed: Array, selected_ids: Array, budget: int) -> Dictionary:
	var total := 0
	for card in revealed:
		if selected_ids.has(card.get("id")):
			total += int(card.get("treasure_points", 0))
	if total > budget:
		return {"valid": false, "total": total, "remaining": budget}
	return {"valid": true, "total": total, "remaining": budget - total}
