extends Node

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

var multiplayer_scene = preload("res://scenes/multiplayer_player.tscn")

var _players_spawn_node

var host_mode_enabled = false
var multiplayer_mode_enabled = false
signal multiplayer_mode_selected(id)

var respawn_point = Vector2(30, 20)

func become_host():
	print("starting game")
	
	# Done this way because the node is regenerated after the player dies
	# Not necessarily the same across all games, depends on use case
	_players_spawn_node = get_tree().get_current_scene().get_node("Players")
	
	# Set host mode to true
	host_mode_enabled = true
	multiplayer_mode_enabled = true
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	
	multiplayer.multiplayer_peer = server_peer
	
	# Callbacks to connect any remote peers
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.disconnect(_del_player)
	
	# Remove the single player
	_remove_single_player()
	# Needed to add the current hosting player for the client-server host
	_add_player_to_game(1)

func join_as_player_2():
	print("joining as player 2")
	
	multiplayer_mode_enabled = true
	
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)
	
	multiplayer.multiplayer_peer = client_peer
	
	_remove_single_player()

func _add_player_to_game(id: int):
	print("Player %s joined the game" % id)
	
	var player_to_add = multiplayer_scene.instantiate()
	player_to_add.player_id = id # Make sure to use the same name
	player_to_add.name = str(id)
	
	_players_spawn_node.add_child(player_to_add, true)
	# Let other nodes know that multiplayer is enabled
	multiplayer_mode_selected.emit(id)

func _del_player(id: int):
	print("Player %s has left the game" % id)
	if not _players_spawn_node.has_node(str(id)):
		return
	_players_spawn_node.get_node(str(id)).queue_free()

func _remove_single_player():
	print("remove single player")
	var player_to_remove = get_tree().get_current_scene().get_node("Player")
	player_to_remove.queue_free()
