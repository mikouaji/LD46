extends MarginContainer

var selected = 0


func _ready():
	$BG/Data/Select.clear()
	connect("get_data", get_tree().get_root().get_child(0), "get_specie_data")
	connect("reroll", get_tree().get_root().get_child(0), "reroll")
	connect("killall", get_tree().get_root().get_child(0), "killall")
	pass

func set_options(arr):
	$BG/Data/Select.clear()
	for i in arr.size():
		$BG/Data/Select.add_item("["+arr[i].type+"]"+arr[i].species_name,i)

func refresh():
	_on_Select_item_selected(selected)

	
func update_data(data):
	$BG/Data/Amount/Value.set_text(data.amount)
	$BG/Data/Name/Value.set_text(data.name)
	$BG/Data/Males/Value.set_text(data.males)
	$BG/Data/Females/Value.set_text(data.females)
	$BG/Data/HP/Value.set_text(data.hp)
	$BG/Data/Lifespan/Value.set_text(data.life)
	$BG/Data/Size/Value.set_text(data.size)
	$BG/Data/Type/Value.set_text(data.type)
	$BG/Data/Eats/Value.set_text(data.eats)
	$BG/Data/Fertility/Value.set_text(data.fertility)


signal get_data
func _on_Select_item_selected(id):
	selected = id
	emit_signal("get_data",id)

signal reroll
func _on_Reroll_pressed():
	if selected >= 0:
		emit_signal("reroll",selected)

signal killall
func _on_KillAll_pressed():
	if selected >= 0:
		emit_signal("killall",selected)
