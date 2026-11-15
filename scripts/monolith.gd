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
	MONOLITH_5,
	MONOLITH_5
]
var current_upgrade = 0

var upgrades1 = [
	"Better Robes\nCOST ponderings\nNovice Wizards Ponder twice as much",
	"Pointier Hats\nCOST ponderings\nJournyman Wizards Ponder twice as much",
	"Christmas Bonus\nCOST ponderings\nNovice Wizards Ponder ten times as much",
	"OUT OF STOCK"
]

var upgrades1_costs = [
	100,
	750,
	5000,
	0
]

var upgrades2 = [
	"More Power\n COST ponderings\nAbjuration Wizards can shoot twice as fast",
	"Deeper Thoughts\n COST ponderings\nYou can focus ponder twice as much", #TODO
	"OUT OF STOCK"
]

var upgrades2_costs = [
	2000,
	5000,
	0
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
	if type == 6:
		return upgrades1[current_upgrade].replace("COST", str(upgrades1_costs[current_upgrade]))
	elif type == 7:
		return upgrades2[current_upgrade].replace("COST", str(upgrades2_costs[current_upgrade]))
	return monolith_texts[type].replace("COST", str(main_manager.get_active_cost(type))).replace("PPS", str(main_manager.get_pps(type)))

func attempt_active_monolith():
	if type == 5:
		main_manager.enter_towerpit()
	elif type == 6 and len(upgrades1) != current_upgrade + 1 and main_manager.dec_ponderings(upgrades1_costs[current_upgrade]):
		main_manager.give_upgrade_1(current_upgrade)
		current_upgrade += 1
	elif type == 7 and len(upgrades2) != current_upgrade + 1 and main_manager.dec_ponderings(upgrades2_costs[current_upgrade]):
		main_manager.give_upgrade_2(current_upgrade)
		current_upgrade += 1
		
	if main_manager.dec_ponderings(main_manager.get_active_cost(type)):
		main_manager.spawn_mage(type)
