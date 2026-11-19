extends RefCounted

const GameLogger = preload("res://infrastructure/persistence/game_logger.gd")
var logger = GameLogger.new()

func record(path: String, observation: Dictionary, legal_actions: Array, selected_action: Dictionary, reward: float, next_observation: Dictionary, terminal: bool) -> bool:
	return logger.append_event(path, {
		"observation": observation.duplicate(true), "legal_actions": legal_actions.duplicate(true),
		"selected_action": selected_action.duplicate(true), "reward": reward,
		"next_observation": next_observation.duplicate(true), "terminal": terminal
	})
