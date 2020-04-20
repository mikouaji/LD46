extends MarginContainer

var high_score = 0

func _ready():
	connect("play_more", get_tree().get_root().get_child(0), "continue_game")
	pass
	
	
func set_score(value):
	if value > high_score:
		high_score = value
	$BG/Center/Data/Score.set_text("Your score:" + str(value))
	$BG/Center/Data/HighScore.set_text("High score:" + str(high_score))
	
func set_why(string):
	$BG/Center/Data/Why.set_text(string)


func _on_Quit_pressed():
	get_tree().quit()

signal play_more
func _on_More_pressed():
	emit_signal("play_more")
	visible = false


func _on_Restart_pressed():
	visible = false
	$"../Welcome".visible = true
