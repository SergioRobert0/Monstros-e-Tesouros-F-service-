extends SceneTree

const Character = preload("res://core/domain/character_state.gd")
const Phases = preload("res://core/domain/game_phase.gd")
const Combat = preload("res://systems/combat_system.gd")
const RandomProvider = preload("res://infrastructure/random/random_provider.gd")
const JsonValidator = preload("res://infrastructure/json/json_validator.gd")
const GameState = preload("res://core/domain/game_state.gd")
const PlayerState = preload("res://core/domain/player_state.gd")
const TurnManager = preload("res://application/turn_manager.gd")
const RuleValidator = preload("res://core/rules/rule_validator.gd")
const VictoryRules = preload("res://core/rules/victory_rules.gd")
var failures := 0

func _initialize() -> void:
	_test_character_lifecycle()
	_test_phase_transitions()
	_test_combat_tie()
	_test_seed_reproducibility()
	_test_json_validation()
	_test_public_snapshot_isolated_and_private()
	_test_elimination_check_is_pure()
	_test_invalid_turn_rotation_is_unchanged()
	_test_action_identity_types()
	_test_victory_reflects_resurrection()
	print("Unit tests: %s failures" % failures)
	quit(1 if failures > 0 else 0)

func _assert(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		push_error("FAIL: " + label)
	else:
		print("PASS: " + label)

func _test_character_lifecycle() -> void:
	var character = Character.new("hero-1", "player-1")
	_assert(character.apply_wound() == Character.WOUNDED, "first wound")
	_assert(character.heal(), "heal wounded character")
	_assert(character.apply_wound() == Character.WOUNDED and character.apply_wound() == Character.DEAD, "second wound kills")
	_assert(character.resurrect(), "resurrect dead character")

func _test_phase_transitions() -> void:
	_assert(Phases.can_transition(Phases.TURN_START, Phases.HAND_REFRESH), "valid phase transition")
	_assert(not Phases.can_transition(Phases.TURN_START, Phases.REWARDS), "invalid phase transition")

func _test_combat_tie() -> void:
	_assert(Combat.new().compare_power(8, 8) == "tie", "combat tie")

func _test_seed_reproducibility() -> void:
	var first = RandomProvider.new(1234)
	var second = RandomProvider.new(1234)
	_assert(first.roll_die() == second.roll_die(), "seeded random reproducibility")

func _test_json_validation() -> void:
	var result: Dictionary = JsonValidator.new().validate_cards([{"id": "a", "name": "A"}, {"id": "a", "name": "B"}], "hero", "fixture.json")
	_assert(not result.valid and result.errors.size() > 0, "card validation catches missing fields and duplicate IDs")
	var malformed := {"id": "b", "name": "B", "subtitle": "", "power": "high", "attributes": [], "abilities": {}, "advantages": []}
	result = JsonValidator.new().validate_cards([malformed], "hero", "fixture.json")
	_assert(not result.valid and result.errors.size() >= 4, "card validation rejects malformed field types")

func _test_public_snapshot_isolated_and_private() -> void:
	var state = GameState.new("game-1")
	var owner = PlayerState.new("owner")
	var observer = PlayerState.new("observer")
	var hero = Character.new("hero-1", "owner")
	hero.temporary_modifiers["power"] = 2
	owner.heroes.append(hero)
	owner.hand.append("secret-card")
	observer.hand.append("observer-card")
	state.players["owner"] = owner
	state.players["observer"] = observer
	state.current_terrain = {"id": "terrain-1"}
	var snapshot: Dictionary = state.to_public_dict("observer")
	snapshot["players"]["owner"]["heroes"][0]["temporary_modifiers"]["power"] = 99
	snapshot["players"]["observer"]["hand"].append("extra-card")
	snapshot["current_terrain"]["id"] = "changed"
	_assert(hero.temporary_modifiers["power"] == 2, "public snapshot does not expose mutable hero state")
	_assert(observer.hand.size() == 1, "public snapshot does not expose mutable observer hand")
	_assert(snapshot["players"]["owner"]["hand_count"] == 1 and not snapshot["players"]["owner"].has("hand"), "public snapshot hides other players hands")
	_assert(state.current_terrain["id"] == "terrain-1", "public snapshot does not expose mutable terrain")

func _test_elimination_check_is_pure() -> void:
	var player = PlayerState.new("player-1")
	var hero = Character.new("hero-1", "player-1")
	hero.wound_state = Character.DEAD
	player.heroes.append(hero)
	_assert(player.check_elimination() and not player.is_eliminated, "elimination query does not mutate player state")
	_assert(player.update_elimination_status() and player.is_eliminated, "elimination status updates explicitly")

func _test_invalid_turn_rotation_is_unchanged() -> void:
	var state = GameState.new("game-1")
	state.active_player_id = "missing"
	state.current_round = 4
	var advanced: bool = TurnManager.new().begin_next_turn(state, ["player-1", "player-2"])
	_assert(not advanced and state.active_player_id == "missing" and state.current_round == 4, "invalid turn rotation leaves state unchanged")

func _test_action_identity_types() -> void:
	var state = GameState.new("game-1")
	state.active_player_id = "player-1"
	var validator = RuleValidator.new()
	var result: Dictionary = validator.validate_action(state, {"player_id": 123})
	_assert(not result.valid and result.errors[0].code == "invalid_player", "action validation rejects non-string player IDs")
	result = validator.validate_action(state, {"player_id": "player-1", "phase": 123})
	_assert(not result.valid and result.errors[0].code == "invalid_phase", "action validation rejects non-string phases")

func _test_victory_reflects_resurrection() -> void:
	var state = GameState.new("game-1")
	var player = PlayerState.new("player-1")
	var hero = Character.new("hero-1", "player-1")
	hero.wound_state = Character.DEAD
	player.heroes.append(hero)
	player.is_eliminated = true
	state.players["player-1"] = player
	var result: Dictionary = VictoryRules.new().evaluate(state)
	_assert(not result["finished"], "no winner while all heroes are eliminated")
	hero.resurrect()
	result = VictoryRules.new().evaluate(state)
	_assert(result["finished"] and result["winner_id"] == "player-1", "victory evaluation recognizes resurrection despite stale elimination flag")
