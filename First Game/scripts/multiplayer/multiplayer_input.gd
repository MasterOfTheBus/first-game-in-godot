extends MultiplayerSynchronizer

var input_direction

@onready var player = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	# This disables the server from processing physics_process and process
	# Because it shouldn't be handling any inputs local to the server
	# Not a be all end all for all games
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
	
	input_direction = Input.get_axis("move_left", "move_right")

func _physics_process(delta):
	input_direction = Input.get_axis("move_left", "move_right")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("jump"):
		print(str(multiplayer.get_unique_id()) + ": process jumping " + str(player.player_id))
		jump.rpc()

@rpc("call_local")
func jump():
	print(str(multiplayer.get_unique_id()) + ": jumping " + str(player.player_id))
	# Only process this as the host; ignore as a client
	if multiplayer.is_server():
		player.do_jump = true
