extends Creature

var carnivorous = false
var male = false
var mating_break = 10
var break_stage = 0

class_name Animal

func _init():
	pass

func _ready():
	connect("childbirth", get_parent(), "add_newborn")


func decide():
	var position_data = self.look_around()
	var all_tiles_in_sight = position_data.all_tiles_in_sight
	var my_tile = position_data.my_tile
	var empty_tiles_in_sight = position_data.empty_tiles_in_sight
	var creatures_around = position_data.creatures_around
	var possible_tiles = get_possible_tiles(my_tile)
	
	
	var mate = find_mate_in_sight(creatures_around)
	var prey = find_prey_in_sight(creatures_around)
	if self.is_healthy():
		break_stage -=1
		if mate != null and break_stage <= 0:
			search_mate(mate, my_tile, possible_tiles)
		elif prey != null:
			search_food(prey, my_tile, possible_tiles)
		else:
			wander(possible_tiles, my_tile)
	else:
		if prey != null:
			search_food(prey, my_tile, possible_tiles)
		else:
			wander(possible_tiles, my_tile)
		
	self.gain_age()
	pay_turn_price()

func search_mate(mate, my_tile, possible_tiles):
	var mate_tile = get_parent().get_tile_for(mate)
	if mate_tile == my_tile:
		procreate(my_tile, mate)
	elif possible_tiles.has(mate_tile):
		self.move_to(mate_tile)
	else:
		self.move_close_to(mate_tile)

func search_food(prey, my_tile, possible_tiles):
	var prey_tile = get_parent().get_tile_for(prey)
	if prey_tile == my_tile:
		eat(prey)
	elif possible_tiles.has(prey_tile):
		self.move_to(prey_tile)
	else:
		self.move_close_to(prey_tile)

func wander(tiles, my_tile):
	var tile = get_parent().find_free_tile(tiles, type, my_tile)
	if tile != null:
		self.move_to(tile)
	
func find_prey_in_sight(creatures_around):
	for creature in creatures_around:
		if carnivorous:
			if creature.species_name != self.species_name and creature.type == TYPE_ANIMAL:
				return creature
		else:
			if creature.type == TYPE_PLANT:
				return creature
	return null
	
func find_mate_in_sight(creatures_around):
	var gender_needed = !male
	for creature in creatures_around:
		if creature.species_name == self.species_name and gender_needed == creature.male:
			return creature
	return null

func get_possible_tiles(my_tile):
	return get_parent().get_tiles_around(my_tile, speed, type)

signal childbirth
func procreate(my_tile, mate):
	randomize()
	var tiles = get_parent().get_tiles_around(my_tile, 1, type)
	if not tiles.empty() and randi()%100 + 1 < fertility:
		var tile = tiles[randi()%tiles.size()]
		if get_parent().check_if_empty_tile(tile, type):
			$BirthSound.play()
			emit_signal("childbirth", self.specie.give_child(), tile)
			break_stage = mating_break
			mate.break_stage = mate.mating_break
	
func eat(target):
	var damage = strength - target.defense
	if damage < 0:
		damage = 1
	target.get_hit(damage, self.species_name)
	$EatSound.play()
	self.gain_health(round( float(damage)/2.0))
	
func pay_turn_price():
	var price = round( float(max_health) * 2.5 / 100.0)
	self.lose_health(price)
	pass
