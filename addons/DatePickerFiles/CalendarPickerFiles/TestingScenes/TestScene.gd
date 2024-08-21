extends Control


@onready var date_picker_panel = %DatePickerPanel

func _on_test_button_pressed():
	print(date_picker_panel.get_date_data())
