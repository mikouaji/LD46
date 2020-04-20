extends MarginContainer

func _ready():
	connect("start_game",get_tree().get_root().get_child(0), "restart_with_id")
	pass


func _on_Quit_pressed():
	get_tree().quit()


func _on_Large_pressed():
	start_new_game(3)


func _on_Medium_pressed():
	start_new_game(2)


func _on_Small_pressed():
	start_new_game(1)


func _on_Tiny_pressed():
	start_new_game(0)
	
signal start_game
func start_new_game(id:int):
	emit_signal("start_game",id)
	visible = false
