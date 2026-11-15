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
const SKULL = preload("uid://bi8xyb4f30t6s")
const TREE_1 = preload("uid://smympd4r2qo4")
const MONOLITH_WIN = preload("uid://crite8glwewf7")


var monolith_sprites = [
	MONOLITH_2,
	MONOLITH_3,
	MONOLITH_1,
	MONOLITH_4,
	MONOLITH_4,
	MONOLITH_6,
	MONOLITH_5,
	MONOLITH_5,
	SKULL,
	TREE_1,
	MONOLITH_WIN
]
var current_upgrade = 0

var upgrades1 = [
	"Better Robes\nCOST ponderings\nNovice Wizards Ponder twice as much",
	"Rings of Power\nCOST ponderings\nNovice Wizards Ponder twice as much",
	"Pointier Hats\nCOST ponderings\nJournyman Wizards Ponder twice as much",
	"Christmas Bonus\nCOST ponderings\nNovice Wizards Ponder ten times as much",
	"Nose Hair Trimmers\nCOST ponderings\nJournyman Wizards Ponder five times as much",
	"Beard Combs\nCOST ponderings\nElder Wizards Ponder five times as much",
	"OUT OF STOCK"
]

var upgrades1_costs = [
	772,
	4_500,
	20_000,
	50_000,
	100_000,
	500_000,
	0,
]

var upgrades2 = [
	"Deeper Thoughts\n COST ponderings\nYou can focus ponder four times as much",
	"Deeper Thoughts Level II \n COST ponderings\nYou can focus ponder six times as much",
	"Deeper Thoughts Level III \n COST ponderings\nYou can focus ponder seven times as much",
	"More Power\n COST ponderings\nAbjuration Wizards can shoot twice as fast",
	"Deeper Thoughts Level IV \n COST ponderings\nYou can focus ponder twenty times as much",
	"OUT OF STOCK"
]

var upgrades2_costs = [
	440,
	2_100,
	14_000,
	20_000,
	500_000,
	0
]

var current_skull_text = "Got here fast huh."
var skull_texts = [
	"You suck.",
	"So much pondering, so little thinking.",
	"I once had a body you know.",
	"Tis but a flesh wound.",
	"I thought I would ponder forever, now I’m naught but a skull - it will happen to you too..!",
	"Too many enemies eh? Knock the rest back first - then you can focus on just a few at a time.",
	"Summon your Abjurors on opposite sides of the orb - makes ‘em it quicker to aim at the Archorbs.",
	"If you loose any of your wizards, the hire price goes back down.",
	"Light travels faster than sound, that’s why some people appear bright until you hear them speak.",
	"Change is inevitable, except from a vending machine.",
	"An onion a day keeps your friends away.",
]

var monolith_texts = [
	"Hire Novice Wizard\n COST ponderings\n(Thinks PPS pondering per second)",
	"Hire Journyman Wizard\n COST ponderings\n(Thinks PPS pondering per second)",
	"Hire Elder Wizard\n COST ponderings\n(Thinks PPS pondering per second)",
	"Hire Abjuration Wizard\n COST ponderings\n (Shoots a bolt of lighting for 1% of your ponderings)",
	"Hire Abjuration Wizard\n COST ponderings\n (Shoots a bolt of lighting for 1% of your ponderings)",
	"Enter tower-pit",
]

const TITLE = preload("uid://dkvahcolwkcjq")

var name_stems = [
	"Chudding",
	"Chudders",
	"Chuddington",
	"Chudly",
	"Chad",
	"Chud"
]

var name_endings = [
	" the Third",
	" the Second",
	" the Fourth",
	" the Chudling",
	" the Chudly",
	" the Chud",
]

var name_prefixes = [
	"Sir ",
	"Mr. ",
	"Arch ",
	"High ",
	"Old ",
]

func get_wiz_name(): 
	var wiz_name = name_stems.pick_random()
	
	if randi_range(0,8) == 0:
		wiz_name = name_prefixes.pick_random() + wiz_name
		
	if randi_range(0, 8) == 0:
		wiz_name = wiz_name + name_endings.pick_random()
	
	var endings = [" has appeared...", " falls into existance...", " shows up...", " arrives..."]
	
	return wiz_name + endings.pick_random()
	

func _ready() -> void:
	$Sprite2D.texture = monolith_sprites[type]
	if type == 9:
		$Sprite2D.scale = Vector2(1.5, 1.5)
		$Sprite2D.position += Vector2(0, -75) 

func get_monolith_text():
	if type == 6:
		return upgrades1[current_upgrade].replace("COST", str(upgrades1_costs[current_upgrade]))
	elif type == 7:
		return upgrades2[current_upgrade].replace("COST", str(upgrades2_costs[current_upgrade]))
	elif type == 8:
		return current_skull_text
	elif type == 9:
		return "Plant Tree\n5,000 pondering\nOffers vibes and some protection"
	elif type == 10:
		return "Ascend\n1,000,000 ponderings"
		
	return monolith_texts[type].replace("COST", main_manager.add_commas(str(main_manager.get_active_cost(type)))).replace("PPS", str(main_manager.add_commas(main_manager.get_pps(type))))

func attempt_active_monolith():
	if type == 5:
		main_manager.enter_towerpit()
	elif type == 6 and len(upgrades1) != current_upgrade + 1 and main_manager.dec_ponderings(upgrades1_costs[current_upgrade]):
		main_manager.give_upgrade_1(current_upgrade)
		current_upgrade += 1
	elif type == 7 and len(upgrades2) != current_upgrade + 1 and main_manager.dec_ponderings(upgrades2_costs[current_upgrade]):
		main_manager.give_upgrade_2(current_upgrade)
		current_upgrade += 1
	elif type == 8:
		return
	elif type == 9 and main_manager.dec_ponderings(5000):
		main_manager.spawn_mage(9)
	elif type == 10 and main_manager.dec_ponderings(1000000):
		main_manager.win()
	else:
		if main_manager.dec_ponderings(main_manager.get_active_cost(type)):
			var t = TITLE.instantiate()
			$title_holder.add_child(t)
			t.set_text(get_wiz_name())
			main_manager.spawn_mage(type)


func _on_skull_timer_timeout() -> void:
	if main_manager.ponderings < 1000:
		current_skull_text = "You arn't much good at this pondering stuff."
	elif main_manager.get_num_wizards(0) > 200 and randi_range(0,5) == 0:
		current_skull_text = ["It's like a zoo here!", "Getting a bit crowded on this orb…"].pick_random()
	
	current_skull_text = skull_texts.pick_random()
