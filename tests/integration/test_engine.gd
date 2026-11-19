extends SceneTree

const Controller = preload("res://application/game_controller.gd")
const Phases = preload("res://core/domain/game_phase.gd")
const LegalActions = preload("res://core/rules/legal_actions.gd")
const HeuristicAgent = preload("res://ai/heuristic_agent.gd")

func _initialize() -> void:
	var game = Controller.new(42)
	game.add_player("human", true)
	game.add_player("ai", false)
	game.add_hero("ai", "hero-ai-1")
	assert(game.transition(Phases.HAND_REFRESH).success)
	assert(not game.transition(Phases.REWARDS).success)
	var legal = LegalActions.new().for_character(game.state.players["ai"].heroes[0], {}, [], [])
	var selected: Dictionary = HeuristicAgent.new().select_action({"legal_actions": legal}, legal)
	assert(legal.has(selected) or selected.is_empty())
	print("Integration engine tests passed")
	quit(0)
