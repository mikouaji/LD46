extends Creature

class_name AnimalSpecie

const NATURE_AGRO = "AGRO"
const NATURE_SHY = "SHY"
const NATURE_LOGIC = "LOGIC"
const NATURE_RAND = "RAND"

const HP = {
	SIZE_S: Vector2(10,30),
	SIZE_M: Vector2(25,90),
	SIZE_L: Vector2(80,200),
}

var RNG = load("res://scripts/RandomNameGenerator.gd")
var carnivorous = false
var male = false
var mating_break = 10

func give_child():
	var child = preload("res://scenes/creature/animal/Animal.tscn").instance()
	child.type = self.type
	child.specie = self
	child.species_name = self.species_name
	child.male = self.male
	child.size = self.size
	child.male = bool(randi()%2)
	child.set_animation(child.size)
	if(child.male):
		child.flip_animation()
	child.luck = self.luck
	child.strength = self.strength
	child.mating_break = self.mating_break
	child.view_distance = self.view_distance
	child.max_age = self.modify_by_luck(self.max_age, self.luck)
	child.max_health = self.modify_by_luck(self.max_health, self.luck)
	child.health = child.max_health
	child.carnivorous = self.carnivorous
	child.defense = self.modify_by_luck(self.defense, self.luck)
	child.fertility = self.modify_by_luck(self.fertility, self.luck)
	child.max_speed = self.modify_by_luck(self.max_speed, self.luck)
	child.speed = child.max_speed
	return child

func init():
	randomize()
	self.type = TYPE_ANIMAL
	self.species_name = RNG.generate(TYPE_ANIMAL)
	self.size = SIZES[randi()%SIZES.size()]
	self.luck = int(rand_range(1,100)) 
	self.max_age = calculate_max_age(self.size)
	self.max_health = calculate_max_health(self.size)
	self.strength = calculate_strength()
	self.defense = calculate_defense(self.size)
	self.fertility = calculate_10_90()
	self.mating_break = calculate_5_50()
	self.carnivorous = calculate_carnivorous()
	self.view_distance = calculate_view_distance(self.size)
	self.max_speed = calculate_max_speed(self.size, self.max_health)
	
func calculate_max_speed(size:String, hp:int):
	var max_percent = float(hp) / float(HP[size].y)
	var speed = 0
	match size:
		SIZE_S: speed = int(rand_range(3,4))
		SIZE_M: speed = int(rand_range(3,8))
		SIZE_L: speed = int(rand_range(5,12))
	speed -= 2 if max_percent > 0.85 else 1 if max_percent > 0.55 else 0
	return speed
		
func calculate_max_age(size:String):
	match size:
		SIZE_S: return int(rand_range(5,10))
		SIZE_M: return int(rand_range(8,18))
		SIZE_L: return int(rand_range(15,30))
	
func calculate_max_health(size:String):
		return int(rand_range(HP[size].x, HP[size].y))

func calculate_strength():
	match size:
		SIZE_S: return int(rand_range(5,20))
		SIZE_M: return int(rand_range(15,50))
		SIZE_L: return int(rand_range(40,90))

func calculate_defense(size:String):
	match size:
		SIZE_S: return int(rand_range(5,20))
		SIZE_M: return int(rand_range(15,40))
		SIZE_L: return int(rand_range(30,120))

func calculate_10_90():
	return int(rand_range(10,90))
	
func calculate_5_50():
	return int(rand_range(10,90))
	
func calculate_carnivorous():
	var chance = int(rand_range(0,100))
	return false if chance < 60 else true

func calculate_view_distance(size:String):
	match size:
		SIZE_S: return int(rand_range(2,3))
		SIZE_M: return int(rand_range(2,4))
		SIZE_L: return int(rand_range(2,5))

