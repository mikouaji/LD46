extends Node2D

const WEATHER_COLD = "COLD"
const WEATHER_HOT = "HOT"
const WEATHER_NORMAL = "NORMAL"

var RNG = load("res://scripts/RandomNameGenerator.gd")

var planet_name = "Planet Name"
var map = null
var species = []
var energy = 0
var age = 0
var max_age;
#ganerate rivers/lakes
var water = false
#generate desert
var desert = false
#generate bare rock
var bare = false
var weather = WEATHER_NORMAL
	
func init(config:Dictionary):
	connect_events()
	max_age = config.max_age
	set_energy(config.start_energy)
	set_planet_name(RNG.generate("PLANET"))
	
	map = preload("res://scenes/map/Map.tscn").instance()
	self.add_child(map)
	map.init(config.radius)
	
	randomize()
	generate_species(config.max_species)
	add_creatures(config.max_creatures)


func connect_events():
	connect("day_passed", $"../CanvasLayer/GUI/PlanetInfo", "set_age_value")
	connect("energy_set", $"../CanvasLayer/GUI/PlanetInfo", "set_energy_value")
	connect("add_specie", $"../CanvasLayer/GUI/PlanetInfo", "set_species_value")
	connect("set_planet_name", $"../CanvasLayer/GUI/PlanetInfo", "set_planet_name")
	connect("species_done", $"../CanvasLayer/GUI/SpeciesInfo", "set_options")
	
signal day_passed
func day_passed():
	age +=1
	emit_signal("day_passed", age)
	
signal energy_set
func set_energy(value:int):
	energy = value
	emit_signal("energy_set", energy)
func add_energy(value:int):
	set_energy(energy + value)
func take_energy(value:int):
	set_energy(energy - value)

signal set_planet_name
func set_planet_name(name:String):
	planet_name = name
	emit_signal("set_planet_name", planet_name)
	
signal species_done
func generate_species(max_species:int):
	var new = []
	var species_amount = int(rand_range(2, max_species))
	for i in species_amount:
		var new_specie = generate_one_specie()
		new.push_back(new_specie)
	return new

func generate_one_specie():
	var new_specie = null;
	var type = Creature.TYPES[randi()%Creature.TYPES.size()]
	match type:
		Creature.TYPE_PLANT:
			new_specie = PlantSpecie.new()
		Creature.TYPE_ANIMAL:
			new_specie = AnimalSpecie.new()
	new_specie.init()
	add_specie(new_specie)
	emit_signal("species_done",species)
	return new_specie

signal add_specie
func add_specie(specie):
	species.push_back(specie)
	emit_signal("add_specie", species.size())

func add_creatures(max_creatures:int):
	for specie in species:
		add_creatures_for_specie(max_creatures, specie)

func add_creatures_for_specie(max_creatures:int, specie):
	var creature_amount = int(rand_range(2, max_creatures))
	for i in creature_amount:
		var creature = specie.give_child()
		creature.newborn = false
		map.add_creature(creature)
