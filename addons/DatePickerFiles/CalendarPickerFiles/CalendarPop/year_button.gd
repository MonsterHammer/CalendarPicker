extends Button

signal button_selected

func _on_pressed():
	emit_signal("button_selected", self)
