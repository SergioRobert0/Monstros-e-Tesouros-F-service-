extends RefCounted

var generator := RandomNumberGenerator.new()

func _init(seed_value := 1) -> void:
	set_seed(seed_value)

func set_seed(seed_value: int) -> void:
	generator.seed = seed_value

func roll_die(sides := 6) -> int:
	return generator.randi_range(1, maxi(1, sides))

func shuffled(values: Array) -> Array:
	var result := values.duplicate(true)
	for index in range(result.size() - 1, 0, -1):
		var swap_index := generator.randi_range(0, index)
		var temporary = result[index]
		result[index] = result[swap_index]
		result[swap_index] = temporary
	return result
