extends RefCounted

const Validator = preload("res://core/rules/rule_validator.gd")
var validator = Validator.new()
var events: Object

func _init(dispatcher: Object = null) -> void:
	events = dispatcher

func execute(state: Object, command: Dictionary, mutation: Callable) -> Dictionary:
	var validation: Dictionary = validator.validate_action(state, command)
	if not validation.valid:
		return {"success": false, "errors": validation.errors}
	var result: Dictionary = mutation.call(state, command)
	if not result.get("success", false):
		return result
	if events != null:
		events.publish({"type": "command_executed", "command": command.duplicate(true), "result": result.duplicate(true)})
	return result
