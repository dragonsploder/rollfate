extends CanvasLayer

@onready var main_manager = get_tree().current_scene

func _ready() -> void:
	$TextPopup.hide()
	
func _process(delta: float) -> void:
	$buttons.text = main_manager.get_buttons_context()
	
	$VBoxContainer/Ponderings.text = "Ponderings: " + str(main_manager.add_commas(int(main_manager.ponderings)))
	var pps = main_manager.get_total_pps()
	var pondering_pps = main_manager.get_current_focus_base_pps()
	
	$VBoxContainer/PPS.text = "Ponderings Per Second (PPS): " + str(main_manager.add_commas(int(pps+pondering_pps)))
	var n = main_manager.get_num_wizards(0)
	var npps = n * main_manager.get_pps(0)
	var j = main_manager.get_num_wizards(1)
	var jpps = j * main_manager.get_pps(1)
	var e = main_manager.get_num_wizards(2)
	var epps = e * main_manager.get_pps(2)
	var z = main_manager.get_num_wizards(3)
	
	if pondering_pps > 0:
		$VBoxContainer/SelfPonder.show()
		$VBoxContainer/SelfPonder.text = "Currently pondering for " + main_manager.add_commas(pondering_pps) + " PPS"
	else:
		$VBoxContainer/SelfPonder.hide()
	
	if n > 0:
		$VBoxContainer/Nov.show()
		if n == 1:
			$VBoxContainer/Nov.text = main_manager.add_commas(n) + " novice producing " + main_manager.add_commas(npps) + " PPS"
		else:
			$VBoxContainer/Nov.text = main_manager.add_commas(n) + " novices producing " + main_manager.add_commas(npps) + " PPS"
	if j > 0:
		$VBoxContainer/Journy.show()
		if j == 1:
			$VBoxContainer/Journy.text = main_manager.add_commas(j) + " journyman producing " + main_manager.add_commas(jpps) + " PPS"
		else:
			$VBoxContainer/Journy.text = main_manager.add_commas(j) + " journymen producing " + main_manager.add_commas(jpps) + " PPS"
	if z > 0:
		$VBoxContainer/Zap.show()
		if z == 1:
			$VBoxContainer/Zap.text = main_manager.add_commas(z) + " abjuror"
		else:
			$VBoxContainer/Zap.text = main_manager.add_commas(z) + " abjurors"
	if e > 0:
		$VBoxContainer/Elder.show()
		if e == 1:
			$VBoxContainer/Elder.text = main_manager.add_commas(e) + " elder producing " + main_manager.add_commas(epps) + " PPS"
		else:
			$VBoxContainer/Elder.text = main_manager.add_commas(e) + " elders producing " + main_manager.add_commas(epps) + " PPS"

func show_text_popup(text: String):
	$TextPopup.show()
	if text != "":
		$TextPopup/VBoxContainer/Text.text = text
	
func hide_text_popup():
	$TextPopup.hide()

func win():
	$TextPopup.hide()
	$Ponderings.hide()
	$PPS.hide()
	$AnimationPlayer.play("win")
	
