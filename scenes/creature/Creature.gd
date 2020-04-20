extends KinematicBody2D

class_name Creature

const SIZE_S = "S"
const SIZE_M = "M"
const SIZE_L = "L"
const SIZES = [SIZE_S,SIZE_M,SIZE_L]

const TYPE_PLANT = "PLANT"
const TYPE_ANIMAL = "ANIMAL"
const TYPES = [TYPE_PLANT, TYPE_ANIMAL]

var TARGET_TILE = null
var VELOCITY = Vector2()
const ANIMATION_SPEED = 800
const JITT_VAL = 10
const JITT_MAX = 1
var JITT = 0

var max_age = 0
var age = 0
var size
var type
var health
var max_health
var fertility = 25
var speed = 0
var max_speed = 0
var strength = 0
var defense = 10
var luck = 5
var species_name
var specie
var view_distance = 1
var water = false
var newborn = true

func _ready():
	connect("wait_for_animation", get_parent().get_parent().get_parent(), "start_wait")
	connect("animation_ended", get_parent().get_parent().get_parent(), "stop_waiting")
	connect("death", get_parent(), "creature_died")

func look_around():
	var my_tile = get_parent().get_tile_for(self)
	var all_tiles_in_sight = get_parent().get_tiles_around(my_tile, view_distance, type)
	var creatures_around = get_parent().get_creatures_in_tiles(all_tiles_in_sight)
	var empty_tiles_in_sight = get_parent().get_empty_tiles_in_sight(all_tiles_in_sight)
	creatures_around.erase(self)
	return {
		"my_tile":my_tile,
		"all_tiles_in_sight":all_tiles_in_sight,
		"empty_tiles_in_sight":empty_tiles_in_sight,
		"creatures_around":creatures_around
	}

func set_animation(name):
	$AnimatedSprite.set_animation(name)
func flip_animation():
	$AnimatedSprite.set_flip_h(true)
	
#do one of the following (depending of type)
# procreate, attack, run, eat, hunt, die,
func decide():
	pass

func calculate_current_speed():
	speed = floor(float(max_speed) * float(health) / float(max_health))
	pass

func gain_health(value:int):
	health += value
	if health > max_health:
		health = max_health
	calculate_current_speed()

func lose_health(value:int):
	health -= value
	calculate_current_speed()
	if health <= 0:
		die()

func get_hit(value:int, attacker:String):
	lose_health(value)

func is_healthy():
	return true if float(health) / float(max_health) > 0.9 else false

func gain_age():
	age+=1
	if age >= max_age:
		die()

signal death
func die():
	$DeathSound.play()
	emit_signal("animation_ended")
	emit_signal("death",self,true)
	pass

func modify_by_luck(value:int, given_luck:int):
	var added = float(value) * float(given_luck) / 100.0 +1
	randomize()
	# 0 - bad 1,2 - good (bad modifier chance 33%)
	var bad_luck = randi()%2
	var real_value = randi()%int(added)
	if bad_luck == 0:
		value -= real_value
	else:
		value += real_value
	return 1 if value == 0 else value

signal animation_ended
func _physics_process(delta):
	if TARGET_TILE != null:
		VELOCITY = (TARGET_TILE - position).normalized() * ANIMATION_SPEED
		if is_in_place(TARGET_TILE, position):
			emit_signal("animation_ended");
		else:
			VELOCITY = move_and_slide(VELOCITY)
		# if sprites topdown
		# rotation = velocity.angle()

func is_in_place(target, position):
	var tx = target.x
	var ty = target.y
	var px = float(position.x)
	var py = float(position.y)
	var ax = abs(tx - px)
	var ay = abs(ty - py)
	if(ay < JITT_VAL and ax < JITT_VAL):
		JITT+=1
	return JITT > JITT_MAX

func move_close_to(tile):
	var my_tile = get_parent().get_tile_for(self)
	var close_tile = my_tile
	for i in speed:
		if close_tile.x > tile.x:
			close_tile.x -=1
		elif close_tile.x < tile.x:
			close_tile.x +=1
		elif close_tile.y > tile.y:
			close_tile.y -=1
		elif close_tile.y < tile.y:
			close_tile.y +=1
	move_to(close_tile)

signal wait_for_animation
func move_to(tile):
#	$MoveSound.play()
	emit_signal("wait_for_animation")
	JITT = 0
	TARGET_TILE = get_parent().get_position_for(tile)
