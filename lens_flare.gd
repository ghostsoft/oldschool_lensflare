## Add this script to a Node3D positioned where you want the "sun" to be

# Tool functionality is only for randomizing the ghosts in the editor.
# If you don't want this functionality then you can simply remove the @tool line
@tool
extends Node3D

@export var lensflare_sprite : Texture2D
# Default value 2.0
# A value of 1.0 stretches from sun to screen center and 2.0 stretches twice as far
@export var length = 2.0
@export var size = 1.0
# workaround for lack of editor buttons
# clicking this will randomize the ghosts to a pleasant range of values
@export var randomize_ghosts : bool = false :
	set(value): _randomize(value)

@export var ghosts : Array[FlareGhost]

var camera
var ghost_instances : Array[Node3D]

func _ready():
	if Engine.is_editor_hint():
		return
		
	camera = get_viewport().get_camera_3d()
	
	for ghost in ghosts:
		var ghost_instance = Sprite3D.new()
		ghost_instance.billboard = true
		ghost_instance.fixed_size = true
		ghost_instance.pixel_size = (size * 0.005) * ghost.size
		ghost_instance.texture = lensflare_sprite
		ghost_instance.visible = false
		ghost_instance.modulate = ghost.color
		add_child(ghost_instance)
		ghost_instances.append(ghost_instance)

func _process(_delta):
	if Engine.is_editor_hint():
		return
	
	var sun_screen = camera.unproject_position(self.global_position)
	var screen_center = get_viewport().get_visible_rect().get_center()
	var sun_to_center = screen_center - sun_screen

	var bounds = get_viewport().get_visible_rect().grow(150)
	
	# check if sun is within bounds or behind camera
	if not bounds.has_point(sun_screen) || camera.is_position_behind(self.global_position):
		for ghost in ghost_instances:
			ghost.visible = false
		return
	
	for i in range(ghost_instances.size()):
		# get the size of equally spaced offset from 0 to length
		var sprite_offset = remap(1,0,ghost_instances.size(),0,length)
		# offset the sprite along the sun_to_center vector starting from the sun
		# plus one sprite_offset so we don't start *inside* the sun
		ghost_instances[i].global_position = camera.project_position(sun_screen + (sprite_offset+(i*sprite_offset)) * sun_to_center, 1)
		ghost_instances[i].visible = true

# randomizes the ghosts to a pleasant value
func _randomize(_value = false):
	for i in range(ghosts.size()):
		if ghosts[i] == null:
			print_debug("No ghost instantiated in index " + str(i))
			return
		ghosts[i].color.r8 = randi_range(210, 255)
		ghosts[i].color.g8 = randi_range(210,255)
		ghosts[i].color.b8 = randi_range(210,255)
		ghosts[i].color.a8 = randi_range(45,64)
		ghosts[i].size = randf_range(0.3,1.0)
