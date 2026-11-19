extends RefCounted

const CardDefinition = preload("res://core/domain/card_definition.gd")
const Validator = preload("res://infrastructure/json/json_validator.gd")
var validator = Validator.new()

func load_file(path: String, card_type: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"success": false, "cards": [], "errors": [{"path": path, "field": "$", "message": "Arquivo não encontrado."}]}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"success": false, "cards": [], "errors": [{"path": path, "field": "$", "message": "Não foi possível abrir o arquivo."}]}
	var parsed = JSON.new()
	var parse_error := parsed.parse(file.get_as_text())
	if parse_error != OK:
		return {"success": false, "cards": [], "errors": [{"path": path, "field": "$", "message": "JSON inválido na linha %s: %s" % [parsed.get_error_line(), parsed.get_error_message()]}]}
	var validation: Dictionary = validator.validate_cards(parsed.data, card_type, path)
	if not validation.valid:
		return {"success": false, "cards": [], "errors": validation.errors}
	var definitions: Array = []
	for card_data in parsed.data:
		definitions.append(CardDefinition.new(card_type, card_data))
	return {"success": true, "cards": definitions, "errors": []}

func load_directory(directory: String, card_type: String) -> Dictionary:
	var cards: Array = []
	var errors: Array = []
	var dir := DirAccess.open(directory)
	if dir == null:
		return {"success": false, "cards": cards, "errors": [{"path": directory, "field": "$", "message": "Diretório não encontrado."}]}
	var filenames := dir.get_files()
	filenames.sort()
	var seen_ids := {}
	var json_file_count := 0
	for filename in filenames:
		if filename.get_extension().to_lower() != "json":
			continue
		json_file_count += 1
		var result: Dictionary = load_file(directory.path_join(filename), card_type)
		if result.success:
			for card in result.cards:
				if seen_ids.has(card.id):
					errors.append({"path": directory.path_join(filename), "field": "id", "message": "ID duplicado '%s' entre arquivos." % card.id})
				else:
					seen_ids[card.id] = true
					cards.append(card)
		else:
			errors.append_array(result.errors)
	if json_file_count == 0:
		errors.append({"path": directory, "field": "$", "message": "Nenhum arquivo JSON encontrado."})
	return {"success": errors.is_empty(), "cards": cards if errors.is_empty() else [], "errors": errors}
