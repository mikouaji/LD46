extends KinematicBody2D

const MOTION_SPEED = 800
const MAP_SCALE_MIN = 0.5
const MAP_SCALE_TICK = 0.1
var MAP_SCALE_MAX = 6

const TILE_WIDTH = 94
const TILE_HEIGHT = 82
var MAP_RADIUS;

var map;
var map_scale = 1.0

var mouse_prev = Vector2(0,0)
var mouse_pressed = false

func init(RADIUS:int, g_map:TileMap):
	map = g_map
	MAP_RADIUS = RADIUS
	var computed_max = float(MAP_RADIUS) / 10 * 2.0
	MAP_SCALE_MAX = 1 if computed_max < 1.0 else computed_max
	map_scale = MAP_SCALE_MAX
	adjust_zoom()

func zoom_out():
	if(map_scale + MAP_SCALE_TICK <= MAP_SCALE_MAX):
		map_scale += MAP_SCALE_TICK
		adjust_zoom()
		
func zoom_in():
	if(map_scale - MAP_SCALE_TICK > MAP_SCALE_MIN):
		map_scale -= MAP_SCALE_TICK
		adjust_zoom()
	
func adjust_zoom():
	var vector = Vector2(map_scale, map_scale)
	$Camera.set_zoom(vector)

#made for mouse
func _input(event):
	zoom_camera(event)
	if event is InputEventMouse:
		move_camera_mouse(event)

#made for keyboard
func _physics_process(_delta):
	move_camera_keys(Input)

#left mouse drag around
func move_camera_mouse(input_event:InputEventMouse):
	if input_event.is_action_pressed("rmb"):
		mouse_pressed = true
		mouse_prev.x=input_event.position.x
		mouse_prev.y=input_event.position.y
	if input_event.is_action_released("rmb"):
		mouse_pressed = false
		
	if mouse_pressed:
		var motion = Vector2()
		motion.x = input_event.position.x - mouse_prev.x 
#		motion.x = mouse_prev.x - input_event.position.x
		motion.y = input_event.position.y - mouse_prev.y
#		motion.y = mouse_prev.y - input_event.position.y
		mouse_prev.x = input_event.position.x
		mouse_prev.y = input_event.position.y
		if not (motion.x == 0 and motion.y == 0):
			move_camera(motion, 2)

#wasd/arrows moveing
func move_camera_keys(input_event:Input):
	var motion = Vector2()
	motion.x = input_event.get_action_strength("ui_right") - input_event.get_action_strength("ui_left")
	motion.y = input_event.get_action_strength("ui_down") - input_event.get_action_strength("ui_up")
	if not (motion.x == 0 and motion.y == 0):
		move_camera(motion, 2)

func move_camera(motion:Vector2, speed:int = 1):
	var pre_move_position = self.position;
	motion.y *= 0.5
	motion = motion.normalized() * MOTION_SPEED * map_scale
	motion *= speed
	var _camera_var = move_and_slide(motion)
	var camera_tile = map.world_to_map(self.position)
	var map_tiles = map.get_used_cells()
	if not map_tiles.has(camera_tile):
		self.position = pre_move_position

func zoom_camera(input_event):
	if input_event.is_action_pressed("zoom_in"):
		zoom_in()
	if input_event.is_action_pressed("zoom_out"):
		zoom_out()
