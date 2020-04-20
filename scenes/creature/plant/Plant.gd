extends Creature

var hunger_percent = 10

class_name Plant

func _init():
	pass

func _ready():
	connect("take_energy_from_planet", get_parent().get_parent(), "take_energy")
	connect("plant_grows", get_parent(), "add_newborn")

func decide():
	var position_data = self.look_around()
	if self.is_healthy():
		procreate(position_data.empty_tiles_in_sight)
	else:
		eat()
	self.gain_age()
	pay_turn_price()

signal plant_grows
func procreate(tiles:Array):
	randomize()
	if not tiles.empty() and randi()%100 + 1 < fertility:
		var tile = tiles[randi()%tiles.size()]
		if get_parent().check_if_empty_tile(tile, type):
			$BirthSound.play()
			emit_signal("plant_grows", self.specie.give_child(), tile)
	
signal take_energy_from_planet
func eat():
	var energy = get_parent().get_parent().energy;
	var energy_needed = round(float(max_health) * float(hunger_percent/2) / 100.0)
	var energy_taken = energy_needed if energy > energy_needed else energy
	health += energy_taken
#	$EatSound.play()
	emit_signal("take_energy_from_planet", energy_taken)
	
func pay_turn_price():
	var price = round( float(max_health) * float(hunger_percent/2) / 100.0)
	self.lose_health(price)
	pass
