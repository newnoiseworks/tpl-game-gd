extends Node

var socket: NakamaSocket


func connect_socket():
	socket = Nakama.create_socket_from(SessionManager.client)
	yield(socket.connect_async(SessionManager.session), "completed")
