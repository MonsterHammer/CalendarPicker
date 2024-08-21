extends Button

signal date_pressed

var global_date_data = {}


enum button_date_type {
	past_type,
	current_type,
	future_type
}

func get_button_type():
	return button_date_type.current_type

func get_global_date_data():
	return global_date_data

func _on_pressed():
	emit_signal("date_pressed", self, button_date_type.current_type, global_date_data)

func set_data(complete_date):
	self.text = str(complete_date.day)
	global_date_data = complete_date
