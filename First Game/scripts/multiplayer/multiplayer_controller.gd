extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0

@onready var animated_sprite = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction = 1
var do_jump = false
var _is_on_floor = true
var alive = true

@export var player_id := 1:
	set(id):
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id)

func _ready():
	# run when first entering the scene. good for initialization
	
	# Setup the camera to follow the correct player
	if multiplayer.get_unique_id() == player_id:
		# if the unique id matches the client
		$Camera2D.make_current()
	else:
		$Camera2D.enabled = false

func _apply_animations():
	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations
	if _is_on_floor:
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

func _apply_movement_from_input(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if do_jump and is_on_floor():
		velocity.y = JUMP_VELOCITY
		do_jump = false

	# Get the input direction: -1, 0, 1 from the synchronizer
	direction = %InputSynchronizer.input_direction
	# Commented is how to process the player input directly
	# Input.get_axis("move_left", "move_right")
	
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()

func _physics_process(delta):
	# Only apply the movement as a server so that clients can't cheat
	if multiplayer.is_server():
		# Call set alive here so that there is that delay
		if not alive && is_on_floor():
			_set_alive()

		_is_on_floor = is_on_floor()
		_apply_movement_from_input(delta)
	if not multiplayer.is_server() || MultiplayerManager.host_mode_enabled:
		_apply_animations()
		
func mark_dead():
	print("mark player dead")
	alive = false
	$CollisionShape2D.set_deferred("disabled", true)
	$RespawnTimer.start()

func respawn():
	print("respawning")
	position = MultiplayerManager.respawn_point # respawn at the point
	# There's a bug with set deferred with collisions on existing objects?
	$CollisionShape2D.set_deferred("disabled", false)

# Why this method? So that the engine has a chance to re-establish the collision shape
func _set_alive():
	alive = true
	Engine.time_scale = 1.0
