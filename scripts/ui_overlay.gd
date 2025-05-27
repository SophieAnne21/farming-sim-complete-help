extends Control

@onready var clock_label        = $ClockLabel
@onready var current_date_label = $DateLabel

var current_season_name : String = "Spring"
var day                 : int    = 1
var month               : int    = 1
var days_in_month       = [28,28,28,28,28,28,28,28,28,28,28,28]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:

	
	Global.global_time_passed += delta
	Global.global_time_of_day = Global.global_time_passed / Global.SECONDS_PER_DAY

	Global.global_display_in_game_time += (Global.CYCLE_HOURS / Global.SECONDS_PER_DAY) * delta

	update_clock()

	# Reset day at 2:00 AM
	var real_in_game = Global.START_HOUR + Global.global_time_of_day * Global.CYCLE_HOURS
	if real_in_game >= 26.0:
		Global.global_time_passed = 0.0
		Global.global_time_of_day = 0.0
		Global.global_display_in_game_time = Global.START_HOUR
		next_day()

# ─── CLOCK DISPLAY ─────────────────────────────────────────────────────────────
func update_clock() -> void:
	if clock_label == null:
		return  # No clock label available yet
	
	var hour = int(Global.global_display_in_game_time) % 24
	var minutes_float = (Global.global_display_in_game_time - int(Global.global_display_in_game_time)) * 60.0

	var minute = int(minutes_float / Global.MINUTE_STEP) * Global.MINUTE_STEP

	var am_pm = "AM"
	if hour >= 12:
		am_pm = "PM"
	if hour > 12:
		hour -= 12
	if hour == 0:
		hour = 12

	clock_label.text = str(hour).pad_zeros(2) + ":" + str(minute).pad_zeros(2) + " " + am_pm

func next_day() -> void:
	day += 1
	if day > days_in_month[month - 1]:
		day = 1
		month = month % 12 + 1
	update_date_label()

func update_date_label() -> void:
	current_date_label.text = "%s %d" % [current_season_name, day]
