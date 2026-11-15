extends CanvasLayer

@onready var main_manager = get_tree().current_scene

func _ready() -> void:
	$TextPopup.hide()
	
func _process(delta: float) -> void:
	$Ponderings.text = "Ponderings: " + str(int(main_manager.ponderings))
	$PPS.text = "PPS: " + str(int(main_manager.get_total_pps()))

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
	
