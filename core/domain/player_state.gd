extends RefCounted

var player_id: String
var is_human := false
var heroes: Array = []
var hand: Array[String] = []
var treasures: Array[String] = []
var conquered_terrains: Array[String] = []
var is_eliminated := false

func _init(p_player_id := "", p_is_human := false) -> void:
	player_id = p_player_id
	is_human = p_is_human

func check_elimination() -> bool:
	var living := 0
	for hero in heroes:
		if hero.is_alive():
			living += 1
	return living == 0

func update_elimination_status() -> bool:
	is_eliminated = check_elimination()
	return is_eliminated
