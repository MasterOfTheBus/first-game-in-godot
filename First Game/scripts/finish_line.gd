extends Area2D

@onready var synchronizer = %FinishLineSynchronizer
@onready var winner_label = $Message

var winner = 0

func _ready():
	winner_label.hide()
	print("MultiplayerManager.multiplayer_mode_enabled %s " % MultiplayerManager.multiplayer_mode_enabled)
	MultiplayerManager.multiplayer_mode_selected.connect(_on_multiplayer_selected)

func _on_multiplayer_selected(id):
	# Need to let the remote clients call into the server to inform the winner
	print("setting multiplayer auth for finish line for %s" % id)
	synchronizer.set_multiplayer_authority(id)

func set_winner(id):
	print(str(multiplayer.get_unique_id()) + ": game manager setting winner " + str(id))
	winner = id
	if not winner == 0:
		winner_label.text = "Player %s won" % winner
		winner_label.show()

# Set the winner on the game manager to save the state
func _on_body_entered(body):
	if MultiplayerManager.multiplayer_mode_enabled && multiplayer.get_unique_id() == body.player_id:
		print("player %s won" % body.player_id)
		synchronizer.set_winner.rpc(body.player_id)
	elif not MultiplayerManager.multiplayer_mode_enabled:
		print("winner!")
		synchronizer.set_winner(1)
