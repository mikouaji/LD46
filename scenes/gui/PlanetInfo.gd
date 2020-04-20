extends MarginContainer

var paused = true

func _init():
	pass
func _ready():
	connect("play_pause", get_node("/root").get_children()[0], "toggle_play")

func set_age_value(value):
	$Data/Age/Value.set_text(str(value))
func set_time_value(value):
	$Data/Time/Value.set_text(str(value))
func set_energy_value(value):
	$Data/Energy/Value.set_text(str(value))
func set_species_value(value):
	$Data/Species/Value.set_text(str(value))
func set_plants_value(value):
	$Data/Plants/Value.set_text(str(value))
func set_animals_value(value):
	$Data/Animals/Value.set_text(str(value))
func set_planet_name(value):
	$Data/Name.set_text(str(value))
func set_wait(value):
	$Data/Waiting/Value.set_pressed(value)
func set_all_value(done:int, all:int):
	var string = str(done)+"/"+str(all)
	$Data/Moves/Value.set_text(string)


func _on_Quit_pressed():
	_on_Restart_Button_pressed()
	$"../Welcome".visible = true

signal restart_game;
func _on_Restart_Button_pressed():
	change_startPause_button(true)
	var config = $Data/Restart/Option.get_selected_id();
	emit_signal('restart_game', config)

signal play_pause
func _on_StartPause_pressed():
	change_startPause_button(!paused)
	
func change_startPause_button(value:bool):
	paused = value
	$Data/StartPause.set_text("Pause" if not paused else "Start")
	emit_signal("play_pause", paused)
