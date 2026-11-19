extends RefCounted

const Controller = preload("res://application/game_controller.gd")
const HeuristicAgent = preload("res://ai/heuristic_agent.gd")
const Observation = preload("res://ai/ai_observation.gd")
const ExperienceRecorder = preload("res://ai/experience_recorder.gd")
const GameLogger = preload("res://infrastructure/persistence/game_logger.gd")
const LegalActions = preload("res://core/rules/legal_actions.gd")
const VictoryRules = preload("res://core/rules/victory_rules.gd")

var experience_recorder = ExperienceRecorder.new()
var logger = GameLogger.new()
var observation_builder = Observation.new()
var legal_actions_builder = LegalActions.new()
var victory_rules = VictoryRules.new()

func run_batch(first_seed: int, game_count: int, max_turns: int, results_path: String, experiences_path: String) -> Dictionary:
	if game_count < 1 or max_turns < 1:
		return {"success": false, "error": "game_count e max_turns devem ser positivos."}
	var experiences_file := FileAccess.open(experiences_path, FileAccess.WRITE)
	if experiences_file == null:
		return {"success": false, "error": "Could not initialize experience JSONL at %s (error %s)." % [experiences_path, FileAccess.get_open_error()]}
	experiences_file.close()
	var batch_started := Time.get_ticks_msec()
	var games: Array[Dictionary] = []
	var totals := {"completed": 0, "blocked": 0, "wins": 0, "losses": 0, "draws": 0, "turns": 0, "duration_ms": 0}
	for game_index in game_count:
		var seed_value := first_seed + game_index
		var game_result: Dictionary = _run_attempt(seed_value, max_turns, experiences_path)
		games.append(game_result)
		totals["completed"] += int(game_result.status == "completed")
		totals["blocked"] += int(game_result.status == "blocked")
		totals["wins"] += int(game_result.winner_id == "agent_1")
		totals["losses"] += int(game_result.winner_id == "agent_2")
		totals["draws"] += int(game_result.status == "completed" and game_result.winner_id.is_empty())
		totals["turns"] += game_result.turns
		totals["duration_ms"] += game_result.duration_ms
	var report := {
		"schema_version": 1,
		"seed_start": first_seed,
		"seed_end": first_seed + game_count - 1,
		"game_count": game_count,
		"max_turns": max_turns,
		"batch_duration_ms": Time.get_ticks_msec() - batch_started,
		"statistics": totals,
		"games": games
	}
	var save_error := _write_json(results_path, report)
	if not save_error.is_empty():
		return {"success": false, "error": save_error, "report": report}
	return {"success": true, "report": report}

func _run_attempt(seed_value: int, max_turns: int, experiences_path: String) -> Dictionary:
	var started := Time.get_ticks_msec()
	var controller = Controller.new(seed_value)
	controller.add_player("agent_1", false)
	controller.add_player("agent_2", false)
	var agents := {"agent_1": HeuristicAgent.new(), "agent_2": HeuristicAgent.new()}
	var blockers: Array[String] = []
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path("res://data/cards")):
		blockers.append("Card definition directory res://data/cards is missing.")
	if controller.state.players["agent_1"].heroes.is_empty() or controller.state.players["agent_2"].heroes.is_empty():
		blockers.append("No validated hero card definitions are available to create the required player teams.")
	if not controller.has_method("run_turn") and not controller.has_method("run_game"):
		blockers.append("GameController has no complete turn or game lifecycle entry point.")
	var legal_actions: Array = []
	var observations := {}
	for player_id in ["agent_1", "agent_2"]:
		observations[player_id] = observation_builder.build(controller.state, player_id, legal_actions)
		var selected: Dictionary = agents[player_id].select_action(observations[player_id], legal_actions)
		if not selected.is_empty():
			blockers.append("The current engine does not expose a validated mutation path for the selected action.")
	if legal_actions.is_empty():
		blockers.append("LegalActions currently exposes no mandatory turn, terrain, monster, combat, escape, or reward decisions.")
	var unique_blockers: Array[String] = []
	for blocker in blockers:
		if not unique_blockers.has(blocker):
			unique_blockers.append(blocker)
	var experience_event := {
		"record_type": "simulation_attempt",
		"schema_version": 1,
		"seed": seed_value,
		"status": "blocked",
		"observations": observations,
		"legal_actions": legal_actions,
		"selected_actions": {},
		"turns": [],
		"actions": [],
		"combats": [],
		"blockers": unique_blockers,
		"terminal": true
	}
	var experience_saved := logger.append_event(experiences_path, experience_event)
	if not experience_saved:
		unique_blockers.append("Could not write the simulation-attempt experience record to %s." % experiences_path)
	return {
		"seed": seed_value,
		"status": "blocked",
		"winner_id": "",
		"turns": 0,
		"max_turns": max_turns,
		"duration_ms": Time.get_ticks_msec() - started,
		"turn_log": [],
		"action_log": [],
		"combat_log": [],
		"blockers": unique_blockers,
		"experience_recorded": experience_saved,
		"final_game_status": controller.state.game_status,
		"victory_evaluation": victory_rules.evaluate(controller.state)
	}

func _write_json(path: String, value: Dictionary) -> String:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return "Could not write JSON report to %s (error %s)." % [path, FileAccess.get_open_error()]
	file.store_string(JSON.stringify(value, "\t"))
	return ""
