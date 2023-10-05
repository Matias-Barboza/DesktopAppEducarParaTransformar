extends Panel

signal replegar_panel

func _on_gui_input(event):
	if event.is_action_pressed("click_izquierdo"):
		emit_signal("replegar_panel")
