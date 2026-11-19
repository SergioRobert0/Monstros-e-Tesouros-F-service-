extends RefCounted

const State = preload("res://core/domain/game_state.gd")
const Player = preload("res://core/domain/player_state.gd")
const Character = preload("res://core/domain/character_state.gd")
const Dispatcher = preload("res://application/event_dispatcher.gd")
const TurnManager = preload("res://application/turn_manager.gd")
const CommandHandler = preload("res://application/command_handler.gd")
var state: Object
var events: Object
var turns: Object
var commands: Object

func _init(seed_value := 1) -> void:
	state = State.new("game-%s" % seed_value)
	state.metadata["seed"] = seed_value
	events = Dispatcher.new()
	turns = TurnManager.new()
	commands = CommandHandler.new(events)

func add_player(player_id: String, is_human: bool) -> void:
	state.players[player_id] = Player.new(player_id, is_human)
	if state.active_player_id.is_empty():
		state.active_player_id = player_id

func add_hero(player_id: String, card_id: String) -> void:
	if state.players.has(player_id):
		state.players[player_id].heroes.append(Character.new(card_id, player_id))

func transition(next_phase: String) -> Dictionary:
	var result: Dictionary = turns.transition(state, next_phase)
	if result.success:
		events.publish({"type": "phase_changed", "phase": next_phase})
	return result
