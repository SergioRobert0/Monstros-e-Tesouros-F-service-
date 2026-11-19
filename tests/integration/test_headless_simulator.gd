extends SceneTree

const Simulator = preload("res://ai/headless_simulator.gd")

func _initialize() -> void:
	var artifacts_dir := ProjectSettings.globalize_path("res://artifacts")
	DirAccess.make_dir_recursive_absolute(artifacts_dir)
	var results_path := "res://artifacts/headless_simulator_test_results.json"
	var experiences_path := "res://artifacts/headless_simulator_test_experiences.jsonl"
	var result: Dictionary = Simulator.new().run_batch(7001, 10, 50, results_path, experiences_path)
	assert(result.success, "simulator batch should export its report")
	assert(result.report.games.size() == 10, "simulator should create ten seeded attempts")
	assert(result.report.statistics.blocked == 10, "incomplete engine must block all attempts")
	assert(result.report.statistics.completed == 0, "blocked attempts must not count as completed games")
	assert(result.report.statistics.wins == 0 and result.report.statistics.losses == 0 and result.report.statistics.draws == 0, "blocked attempts must not create match outcomes")
	var seen_seeds := {}
	for game in result.report.games:
		assert(game.status == "blocked", "attempt status should be blocked")
		assert(not game.blockers.is_empty(), "blocked attempt should explain its blockers")
		assert(not seen_seeds.has(game.seed), "each attempt should use a distinct seed")
		seen_seeds[game.seed] = true
	assert(FileAccess.file_exists(results_path), "JSON report should exist")
	assert(FileAccess.file_exists(experiences_path), "experience JSONL should exist")
	var repeated_result: Dictionary = Simulator.new().run_batch(7001, 10, 50, results_path, experiences_path)
	assert(repeated_result.success, "repeated simulator batch should export its report")
	var report_file := FileAccess.open(results_path, FileAccess.READ)
	var parsed := JSON.new()
	assert(parsed.parse(report_file.get_as_text()) == OK, "exported report should contain valid JSON")
	var experience_file := FileAccess.open(experiences_path, FileAccess.READ)
	var experience_lines := experience_file.get_as_text().strip_edges().split("\n")
	assert(experience_lines.size() == 10, "one ML attempt record should be written per seed")
	for line in experience_lines:
		var event := JSON.new()
		assert(event.parse(line) == OK, "each ML attempt record should contain valid JSON")
		assert(event.data.status == "blocked" and event.data.terminal, "blocked attempts must be explicitly marked")
	print("Headless simulator integration tests passed")
	quit(0)
