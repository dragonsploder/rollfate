extends Node2D

@onready var main_manager = get_tree().current_scene

@export var type : int = 0

@export var angle_loc : float = 0

@export var min_ponderings : int = 33

var active = false

var monolith_texts = [
	"Hire Novice Mage\n COST ponderings\n(Thinks PPS pondering per second)",
	"Hire Journyman Mage\n COST ponderings\n(Thinks PPS pondering per second)",
	"Hire Elder Mage\n COST ponderings\n(Thinks PPS pondering per second)"
]

func get_monolith_text():
	if type == 50:
		return "Enter tower-pit"
	return monolith_texts[type].replace("COST", str(main_manager.get_active_cost(type))).replace("PPS", str(main_manager.get_pps(type)))

func attempt_active_monolith():
	if type == 50:
		main_manager.enter_towerpit()
	if main_manager.dec_ponderings(main_manager.get_active_cost(type)):
		main_manager.spawn_mage(type)
