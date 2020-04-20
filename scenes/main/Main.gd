extends Node2D

const TINY={
	"radius": 3,
	"max_species": 4,
	"max_creatures": 6,
	"start_energy": 1000,
	"max_age": 5,
}
const SMALL={
	"radius": 7,
	"max_species": 8,
	"max_creatures": 10,
	"start_energy": 2500,
	"max_age": 10,
}
const MEDIUM={
	"radius": 15,
	"max_species": 12,
	"max_creatures": 20,
	"start_energy": 5000,
	"max_age": 20,
}
const LARGE={
	"radius": 25,
	"max_species": 20,
	"max_creatures": 40,
	"start_energy": 7000,
	"max_age": 25,
}

const CONFIGS = [TINY,SMALL,MEDIUM,LARGE]

var planet = null
var time = 1
#more like month in year
const TIME_IN_DAY = 12
const MINIMUM_MOVE_TIME = 0.1
var paused = true
var wait = false
var CREATURE_INDEX = 0
var config = {}

signal moves_done
func game_loop():
	var creatures_amount = planet.map.creatures
	var why_lost = check_win_lose_conditions()
	if why_lost != null:
		toggle_play(true)
		var score = calculate_score()
		$CanvasLayer/GUI.game_over(score, why_lost);
	else:
		
		if CREATURE_INDEX > creatures_amount or CREATURE_INDEX > planet.map.get_children().size():
			CREATURE_INDEX = 0
			add_time()
		var creature = planet.map.get_child(CREATURE_INDEX)
		if creature is Creature and !creature.newborn:
			
			#shader on tile later
			var creatureTile = planet.map.get_tile_for(creature)
#			planet.map.set_cell(creatureTile.x ,creatureTile.y, 2)
			
			creature.decide()
			$CanvasLayer/GUI/SpeciesInfo.refresh()
			emit_signal("moves_done",CREATURE_INDEX, creatures_amount)
			#shader end
#			planet.map.set_cell(creatureTile.x ,creatureTile.y, 1)
		CREATURE_INDEX +=1

func calculate_score():
	var score = 0
	score += planet.energy
	score += planet.age * 100
	score += planet.map.creatures_max
	return score

func continue_game():
	if planet.map.creatures == 0:
		planet.add_creatures(config.max_creatures)
	elif planet.energy == 0:
		planet.energy = config.start_energy
	else:
		planet.max_age = config.max_age * 2
	time=1
	$CanvasLayer/GUI/PlanetInfo.change_startPause_button(true)
	stop_waiting()

func check_win_lose_conditions():
	if planet.map.creatures == 0:
		return "All creatures on "+planet.planet_name+" died"
	elif planet.energy == 0:
		return "The great "+planet.planet_name+" ran out of energy"
	elif planet.age >= planet.max_age:
		return "Great Job! "+planet.planet_name+" is realy old! You are the best!"
	return null

signal wait_state
func stop_waiting():
	wait = false
	emit_signal("wait_state", wait)
func start_wait():
	wait = true
	emit_signal("wait_state", wait)

func _physics_process(delta):
	if not paused and not wait:
		game_loop()

func _ready():
	connect_events()
	restart(TINY)
	
func connect_events():
	connect("time_passed", $CanvasLayer/GUI/PlanetInfo, "set_time_value")
	connect("moves_done", $CanvasLayer/GUI/PlanetInfo, "set_all_value")
	connect("wait_state", $CanvasLayer/GUI/PlanetInfo, "set_wait")
	connect("update_gui", $CanvasLayer/GUI/SpeciesInfo, "update_data")
	connect("species_del", $CanvasLayer/GUI/SpeciesInfo, "set_options")
	
	
func toggle_play(signal_value):
	paused = signal_value
	
signal time_passed
func add_time():
	time +=1
	add_mewborns()
	if time > TIME_IN_DAY:
		planet.day_passed()
		time = 1
	emit_signal("time_passed", time)

func add_mewborns():
	for dict in planet.map.newborns:
		dict.child.newborn = false
		planet.map.add_creature(dict.child, dict.tile)
	planet.map.newborns = []

func reroll(id):
	start_wait()
	var sp = planet.species[id]
	var _amo =remove_specie_and_creatures(sp)
	planet.take_energy(200)
	var specie = planet.generate_one_specie()
	planet.add_creatures_for_specie(config.max_creatures, specie)
	stop_waiting()
	get_specie_data(planet.species.size() -1)

func killall(id):
	start_wait()
	var sp = planet.species[id]
	var amo = remove_specie_and_creatures(sp)
	planet.take_energy(amo * 50)
	stop_waiting()

signal species_del
func remove_specie_and_creatures(specie):
	var amo = 0
	for child in planet.map.get_children():
		if child is Creature:
			if child.species_name == specie.species_name:
				amo+=1
				planet.map.creatures -=1
				child.queue_free()
	planet.species.erase(specie)
	specie.queue_free()
	emit_signal("species_del", planet.species)
	return amo

signal update_gui
func get_specie_data(id):
	var iii = id if id < planet.species.size() else 0
	var sp = planet.species[iii]
	var amo = 0
	var fm=0
	var m=0
	for child in planet.map.get_children():
		if child is Creature:
			if child.species_name == sp.species_name:
				amo+=1
				if sp.type == Creature.TYPE_ANIMAL:
					if child.male:
						m+=1
					else:
						fm+=1
	var data = {
		"name":sp.species_name,
		"type":sp.type,
		"amount":str(amo),
		"males":str(fm),
		"females":str(m),
		"hp":str(sp.max_health),
		"life":str(sp.max_age),
		"size":sp.size,
		"eats": "planet energy" if sp.type == Creature.TYPE_PLANT else "animals" if sp.carnivorous else "plants",
		"fertility":str(sp.fertility),
	}
	emit_signal("update_gui", data)

func restart(cfg):
	if cfg != null:
		self.config = cfg
	if planet != null:
		planet.free()
		planet = null
	time=1
	$CanvasLayer/GUI/PlanetInfo.change_startPause_button(true)
	$CanvasLayer/GUI/PlanetInfo.visible =true
	stop_waiting()
	
	planet = preload("res://scenes/planet/Planet.tscn").instance()
	self.add_child(planet)
	planet.init(config)
	add_mewborns()
	$CanvasLayer/GUI/SpeciesInfo.refresh()

func restart_with_id(id:int):
	restart(CONFIGS[id])
func _on_GUI_restart_game(config_id):
	restart_with_id(config_id)
