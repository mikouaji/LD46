extends Creature

class_name PlantSpecie

var hunger_percent = 10
var RNG = load("res://scripts/RandomNameGenerator.gd")

func give_child():
	var child = preload("res://scenes/creature/plant/Plant.tscn").instance()
	child.specie = self
	child.type = self.type
	child.species_name = self.species_name
	child.size = self.size
	child.set_animation(child.size)
	child.luck = self.luck
	child.strength = self.strength
	child.view_distance = self.view_distance
	child.max_age = self.modify_by_luck(self.max_age, self.luck)
	child.max_health = self.modify_by_luck(self.max_health, self.luck)
	child.health = child.max_health
	child.defense = self.modify_by_luck(self.defense, self.luck)
	child.fertility = self.modify_by_luck(self.fertility, self.luck)
	child.hunger_percent = self.modify_by_luck(self.hunger_percent, self.luck)
	return child

func init():
	randomize()
	self.type = TYPE_PLANT
	self.species_name = RNG.generate(TYPE_ANIMAL)
	self.size = SIZES[randi()%SIZES.size()]
	self.luck = int(rand_range(1,100)) 
	self.max_age = calculate_max_age(self.size)
	self.max_health = calculate_max_health(self.size)
	self.strength = calculate_strength()
	self.defense = calculate_defense(self.size)
	self.fertility = calculate_10_50()
	self.view_distance = calculate_view_distance(self.size)
	self.hunger_percent = calculate_10_90()
	
func calculate_max_age(size:String):
	match size:
		SIZE_S: return int(rand_range(1,20))
		SIZE_M: return int(rand_range(5,50))
		SIZE_L: return int(rand_range(10,120))
	
func calculate_max_health(size:String):
	match size:
		SIZE_S: return int(rand_range(3,15))
		SIZE_M: return int(rand_range(10,30))
		SIZE_L: return int(rand_range(25,90))

func calculate_strength():
	var chance = int(rand_range(0,100))
	return 2 if chance > 90 else 1 if chance > 75 else 0

func calculate_defense(size:String):
	match size:
		SIZE_S: return int(rand_range(1,8))
		SIZE_M: return int(rand_range(5,20))
		SIZE_L: return int(rand_range(12,60))

func calculate_10_50():
	return int(rand_range(10,50))
func calculate_10_90():
	return int(rand_range(10,90))

func calculate_view_distance(size:String):
	match size:
		SIZE_S: return int(rand_range(1,2))
		SIZE_M: return int(rand_range(1,3))
		SIZE_L: return int(rand_range(2,4))

