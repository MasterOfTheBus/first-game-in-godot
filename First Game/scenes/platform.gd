extends AnimatableBody2D

# Assign the animation player on the platform to this
@export var animation_player_optional: AnimationPlayer

func _on_player_connected(id):
	if not multiplayer.is_server():
		# Stops the animation player on the client side
		# Let the server's animation player sync the position back to the client
		animation_player_optional.stop()
		animation_player_optional.set_active(false)

# Called when the node enters the scene tree for the first time.
func _ready():
	if animation_player_optional:
		# Disable the animation player on the client
		multiplayer.peer_connected.connect(_on_player_connected)
