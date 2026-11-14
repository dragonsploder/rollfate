extends Node2D

@onready var main_manager = get_tree().current_scene

@export var type : int = 0

@export var angle_loc : float = 0

@export var min_ponderings : int = 33

var active = false

var monolith_texts = [
	"Hire Novice Mage\n COST ponderings\n(Thinks PPS pondering per second)"
]

func get_active_cost():
	return 10

func get_monolith_text():
	return monolith_texts[type].replace("COST", str(main_manager.get_active_cost(type))).replace("PPS", str(main_manager.get_pps(type)))

func attempt_active_monolith():
	if main_manager.dec_ponderings(main_manager.get_active_cost(type)):
		main_manager.spawn_novice_mage()
