extends Node2D

@onready var main_manager = get_tree().current_scene

@export var type : int = 0

@export var angle_loc : float = 0

@export var min_ponderings : int = 33

var active = false

const MONOLITH_1 = preload("uid://dfxxmlgeh6bv")
const MONOLITH_2 = preload("uid://bh6huwgqp5dya")
const MONOLITH_3 = preload("uid://cxj7nkd7t6qf1")
const MONOLITH_4 = preload("uid://cboywsbdamwyt")
const MONOLITH_5 = preload("uid://1fe5bk2y20rg")
const MONOLITH_6 = preload("uid://dnx71sf010e81")


var monolith_sprites = [
	MONOLITH_2,
	MONOLITH_3,
	MONOLITH_1,
	MONOLITH_4,
	MONOLITH_4,
	MONOLITH_6,
]

var monolith_texts = [
	"Hire Novice Wizard\n COST ponderings\n(Thinks PPS pondering per second)",
	"Hire Journyman Wizard\n COST ponderings\n(Thinks PPS pondering per second)",
	"Hire Elder Wizard\n COST ponderings\n(Thinks PPS pondering per second)",
	"Hire Abjuration Wizard\n COST ponderings\n (Shoots a bolt of lighting for 1% of your ponderings)",
	"Hire Abjuration Wizard\n COST ponderings\n (Shoots a bolt of lighting for 1% of your ponderings)",
	"Enter tower-pit",
]

func _ready() -> void:
	$Sprite2D.texture = monolith_sprites[type]

func get_monolith_text():
	return monolith_texts[type].replace("COST", str(main_manager.get_active_cost(type))).replace("PPS", str(main_manager.get_pps(type)))

func attempt_active_monolith():
	if type == 5:
		main_manager.enter_towerpit()
	if main_manager.dec_ponderings(main_manager.get_active_cost(type)):
		main_manager.spawn_mage(type)
