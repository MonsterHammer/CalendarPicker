extends Control


var current_button = preload("res://addons/DatePickerFiles/CalendarPop/CurrentButton.tscn")
var past_button = preload("res://addons/DatePickerFiles/CalendarPop/PastButton.tscn")
var future_button = preload("res://addons/DatePickerFiles/CalendarPop/FutureButton.tscn")
var year_button = preload("res://addons/DatePickerFiles/CalendarPop/year_button.tscn")

enum button_date_type {
	past_type,
	current_type,
	future_type
}

var scroll_items_times = 0
var scroll_size = 0
var from = 1950
var to = 2050
var anim_speed = float(0.2)
var global_date_data = {}
var final_date_data = {}

var global_time_data = {}

@onready var date_grid = %DateGrid
@onready var current_date_label = %CurrentDateLabel
@onready var current_time_label = %CurrentTimeLabel
@onready var selected_date_label = %SelecteDateLabel
@onready var year_scroll = %YearScroll
@onready var year_con = %YearCon
@onready var choose_month_year = %ChooseMonthYearPanel
@onready var month_grid = %MonthGrid
@onready var date_picker_panel = %DatePickerPanel
@onready var date_picker_button = %DatePickerButton

var year = 2024
var month = 1
var day = 1

func get_date_data():
	var merge_date_and_time = {
		'year' : final_date_data.year,
		'month' : final_date_data.month,
		'day' : final_date_data.day,
		'hour' : global_time_data.hour,
		'minute' : global_time_data.minute,
		'second' : global_time_data.second,
		'period' : global_time_data.period
	}
	
	return merge_date_and_time

func _ready():
	generate_years(from, to)
	
	var current_date_string = Time.get_datetime_dict_from_system(false)
	
	year = current_date_string.year
	month = current_date_string.month
	day = current_date_string.day
	
	select_month(month)
	load_the_date(year, month)
	date_picker_button.text = selected_date_label.text
	final_date_data = global_date_data 
	#select_day(day)

# Function to determine if a year is a leap year
func is_leap_year(year: int) -> bool:
	return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)

# Function to get the number of days in a given month and year
func get_days_in_month(year: int, month: int) -> int:
	match month:
		1, 3, 5, 7, 8, 10, 12:
			return 31
		4, 6, 9, 11:
			return 30
		2:
			return 29 if is_leap_year(year) else 28
		_:
			return 0  # Invalid month

# Function to create an array of dates for the date picker
func create_date_picker(year: int, month: int) -> Dictionary:
	# Get the number of days in the given month
	var days_in_month = get_days_in_month(year, month)
	var total_box = 7 * 6 #42
	
	var past_month = month - 1
	var past_year = year
	
	if past_month <= 0:
		past_month = 12
		past_year -= 1
	
	var days_in_month_past = get_days_in_month(past_year, past_month)
	var date_picker = []
	var date_past = []
	var date_future = []
	var date_data_dict : Dictionary = {}
	
	## Initialize the first day of the month
	var first_day_of_month = {}
	first_day_of_month.year = year
	first_day_of_month.month = month
	first_day_of_month.day = 1
	
	#YYYY-MM-DDTHH:MM:SS
	var the_target_date = str(year)+"-"+str(month)+"-"+str(first_day_of_month.day)+"T00:00:00"
	var start_weekday = Time.get_datetime_dict_from_datetime_string(the_target_date, true)
	
	var current_month_weekday = start_weekday.weekday
	
	var count = 0
	var over_count = 1
	
	for i in total_box:
		#FOR LESS THAN
		if current_month_weekday > i:
			var past_date = (days_in_month_past - (current_month_weekday)) + (i + 1)
			date_past.append(past_date)
		elif days_in_month <= count:
			date_future.append(over_count)
			over_count += 1
		else:
			date_picker.append(count + 1)
			count += 1
	
	date_data_dict = {
		"past_date" : date_past,
		"future_date" : date_future,
		"current_date" : date_picker
	}
	
	return date_data_dict

func update_month_year_label(year, month):
	var month_abbreviations = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
	
	var final_text = str(month_abbreviations[month]) + ", " + str(year)
	current_date_label.text = final_text

func select_day(param_date):
	for i in date_grid.get_child_count():
		var cur_date =  date_grid.get_child(i)
		var cur_date_value = cur_date.text
		var date_to_string = str(param_date)
		if date_to_string == cur_date_value and cur_date.get_button_type() == button_date_type.current_type:
			cur_date.emit_signal("date_pressed", cur_date, cur_date.get_button_type(), cur_date.get_global_date_data())
			
	
	#for i in date_grid.get_child_count():
		#var cur_button = date_grid.get_child(i)
		#cur_button.button_pressed = false
	#button_node.button_pressed = true
	#
	#global_date_data = button_data
	#var new_selected_date = str(get_weekday_name(button_data.weekday)) + ", " + str(get_month_name(button_data.month)) + " " + str(button_data.day) + ", " + str(button_data.year)
	#selected_date_label.text = new_selected_date

func load_the_date(param_year, param_month):
	update_month_year_label(param_year, param_month)
	var calendar_dict : Dictionary = create_date_picker(param_year, param_month)
	
	for i in date_grid.get_child_count():
		date_grid.get_child(i).call_deferred("queue_free")
	
	var past_data = calendar_dict.past_date
	generate_past_dates(past_data, param_month, param_year)
	
	var current_data = calendar_dict.current_date
	generate_current_dates(current_data, param_month, param_year)
	
	var future_data = calendar_dict.future_date
	generate_future_dates(future_data, param_month, param_year)
	
	select_day(day)
	

func generate_past_dates(date_data, param_month, param_year):
	var new_month = param_month - 1
	var new_year = param_year
	
	if new_month <= 0:
		new_month = 12
		new_year -= 1
	
	for i in date_data.size():
		var cur_data = date_data[i]
		var target_button = past_button.instantiate().duplicate()
		date_grid.add_child(target_button)
		target_button.date_pressed.connect(self.update_date_pressed)
		var the_target_date = str(new_year)+"-"+str(new_month)+"-"+str(cur_data)+"T00:00:00"
		var start_weekday = Time.get_datetime_dict_from_datetime_string(the_target_date, true)
		target_button.set_data(start_weekday)
		#target_button.text = str(cur_data)

func generate_current_dates(date_data, param_month, param_year):
	for i in date_data.size():
		var cur_data = date_data[i]
		var target_button = current_button.instantiate().duplicate()
		date_grid.add_child(target_button)
		target_button.date_pressed.connect(self.update_date_pressed)
		var the_target_date = str(param_year)+"-"+str(param_month)+"-"+str(cur_data)+"T00:00:00"
		var start_weekday = Time.get_datetime_dict_from_datetime_string(the_target_date, true)
		target_button.set_data(start_weekday)

func generate_future_dates(date_data, param_month, param_year):
	var new_month = param_month + 1
	var new_year = param_year
	
	if new_month > 12:
		new_month = 1
		new_year += 1
	
	for i in date_data.size():
		var cur_data = date_data[i]
		var target_button = future_button.instantiate().duplicate()
		date_grid.add_child(target_button)
		target_button.date_pressed.connect(self.update_date_pressed)
		var the_target_date = str(new_year)+"-"+str(new_month)+"-"+str(cur_data)+"T00:00:00"
		var start_weekday = Time.get_datetime_dict_from_datetime_string(the_target_date, true)
		target_button.set_data(start_weekday)

func _on_button_pressed():
	#load_the_date(year, month)
	#CONFIGURE THE ANIMATION OF THE BUTTON
	
	if date_picker_panel.visible:
		date_picker_panel.visible = false
	else:
		date_picker_panel.visible = true
		
		var new_pos = Vector2(self.global_position.x, self.global_position.y + date_picker_button.size.y + 10)
		date_picker_panel.position = new_pos
		choose_month_year.position = new_pos

func _on_left_month_pressed():
	month = month - 1
	
	if month <= 0:
		month = 12
		year -= 1
	
	load_the_date(year, month)

func _on_right_month_pressed():
	month = month + 1
	
	if month > 12:
		month = 1
		year += 1
	
	load_the_date(year, month)

#THIS IS WHERE WE SET DATA.
func update_date_pressed(button_node, button_type, button_data):
	for i in date_grid.get_child_count():
		var cur_button = date_grid.get_child(i)
		cur_button.button_pressed = false
	button_node.button_pressed = true
	
	global_date_data = button_data
	var new_selected_date = str(get_weekday_name(button_data.weekday)) + ", " + str(get_month_name(button_data.month)) + " " + str(button_data.day) + ", " + str(button_data.year)
	selected_date_label.text = new_selected_date

func get_month_name(month: int) -> String:
	var month_names = ["", "January", "February", "March", "April", "May", "June", 
					   "July", "August", "September", "October", "November", "December"]
					   
	if month >= 1 and month <= 12:
		return month_names[month]
	else:
		return "Invalid month"

func get_weekday_name(weekday: int) -> String:
	match weekday:
		0:
			return "Sunday"
		1:
			return "Monday"
		2:
			return "Tuesday"
		3:
			return "Wednesday"
		4:
			return "Thursday"
		5:
			return "Friday"
		6:
			return "Saturday"
		_:
			return "Invalid day"

func _on_refresh_time_timer_timeout():
	var current_time = Time.get_time_dict_from_system()
	
	var hour = int(current_time.hour)
	var minute = current_time["minute"]
	var second = current_time["second"]
	
	var period = "AM"
	
	# Convert to 12-hour format
	if hour >= 12:
		period = "PM"
		if hour > 12:
			hour -= 12
	elif hour == 0:
		hour = 12

	var time_string = "%02d:%02d:%02d %s" % [hour, minute, second, period]
	
	var current_time_replace_global = {
		'hour' : hour,
		'minute' : minute,
		'second' : second,
		'period' : period,
	}
	global_time_data = current_time_replace_global
	
	current_time_label.text = time_string

func _on_select_month_pressed():
	choose_month_year.visible = true
	
	var new_value = scroll_items_times * 27
	var tween = get_tree().create_tween()
	tween.tween_property(year_scroll, "scroll_vertical", new_value, anim_speed)
	fade_animation(scroll_items_times)

func _on_test_button_pressed():
	pass

func _on_year_scroll_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var tween = get_tree().create_tween()
			scroll_items_times -= 1
			if scroll_items_times < 0:
				scroll_items_times = 0
			var new_value = scroll_items_times * 27
			tween.tween_property(year_scroll, "scroll_vertical", new_value, anim_speed)
			fade_animation(scroll_items_times)
		
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var tween = get_tree().create_tween()
			scroll_items_times += 1
			if scroll_items_times >= scroll_size:
				scroll_items_times = scroll_size - 1
				
			var new_value = scroll_items_times * 27
			tween.tween_property(year_scroll, "scroll_vertical", new_value, anim_speed)
			fade_animation(scroll_items_times)

func generate_years(from, to):
	while from <= to:
		var new_year_button = year_button.instantiate().duplicate()
		year_con.add_child(new_year_button)
		new_year_button.text = str(from)
		new_year_button.button_selected.connect(self.manual_select_button)
		
		from += 1
		scroll_size += 1
	
	#SELECT THE CURRENT MONTH AND YEAR
	for i in year_con.get_child_count():
		var cur_button = year_con.get_child(i)
		if cur_button.text == str(year):
			scroll_items_times = i
			var new_value = scroll_items_times * 27
			var tween = get_tree().create_tween()
			tween.tween_property(year_scroll, "scroll_vertical", new_value, anim_speed)
			fade_animation(scroll_items_times)

func select_month(our_month):
	month_grid.get_child(our_month).button_pressed = true

func manual_select_button(button_node):
	var get_node_index = -1
	
	for i in year_con.get_child_count():
		if button_node == year_con.get_child(i):
			get_node_index = i
			break
	
	if get_node_index != -1:
		
		scroll_items_times = get_node_index
		var new_value = scroll_items_times * 27
		var tween = get_tree().create_tween()
		tween.tween_property(year_scroll, "scroll_vertical", new_value, anim_speed)
		fade_animation(scroll_items_times)

func fade_animation(cur_index):
	var scroll_prev = cur_index - 1
	var temp_next = cur_index + 1
	var final_next = temp_next if temp_next <= scroll_size else scroll_size
	
	for i in year_con.get_child_count():
		var cur_con = year_con.get_child(i)
		if i == cur_index or i == scroll_prev or i == final_next:
			var tween = get_tree().create_tween()
			tween.tween_property(cur_con, "modulate:a", 1, anim_speed)
		else:
			if cur_con.modulate.a != 0:
				var tween = get_tree().create_tween()
				tween.tween_property(cur_con, "modulate:a", 0, anim_speed)
	

func _on_month_year_confirm_pressed():
	year = int(year_con.get_child(scroll_items_times).text)
	var temp_selected = -1
	
	for i in month_grid.get_child_count():
		var cur_month = month_grid.get_child(i)
		if cur_month.button_pressed == true:
			temp_selected = i
			break
	
	month = temp_selected + 1
	load_the_date(year, month)
	choose_month_year.visible = false

func _on_month_year_cancel_pressed():
	choose_month_year.visible = false

func _on_cancel_pressed():
	date_picker_panel.visible = false

func _on_confirm_pressed():
	final_date_data = global_date_data
	date_picker_button.text = selected_date_label.text
	date_picker_panel.visible = false













