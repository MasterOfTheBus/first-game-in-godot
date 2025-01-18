extends MultiplayerSynchronizer

@onready var finish_line = %FinishLine

@rpc("call_local")
func set_winner(id):
	# Only process this as the host; ignore as a client
	# Replicate the id back to clients
	print(str(multiplayer.get_unique_id()) + ": finish line rpc setting winner " + str(id))
	finish_line.set_winner(id)
