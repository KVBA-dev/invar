package invar

import "core:net"
import "core:slice"

EmptyData := []u8{}

MessageType :: enum u8 {
	ConnectionRequest,
	ConnectionAccepted,
	ConnectionRejected,
	Disconnect,
	Data,
}

Message :: struct {
	type: MessageType,
	data: []u8,
}

Server :: struct {
	clients: []ClientInfo,
	socket:  net.UDP_Socket,
}

ClientInfo :: struct {
	remote:    net.Endpoint,
	id:        u32,
	connected: bool,
}

Client :: struct {
	socket: net.UDP_Socket,
	id:     u32,
}

_NetworkManager :: struct {
	server_address:            net.Endpoint,
	server_proc:               proc(server: ^Server, remote: net.Endpoint, data: []u8),
	server_disconnect_handler: proc(server: ^Server, remote: net.Endpoint),
	server_connection_handler: proc(server: ^Server, remote: net.Endpoint, buf: []u8),
	client_proc:               proc(client: ^Client, data: []u8),
	curr_client:               ^Client,
	enabled:                   bool,
}

NetworkManager := _NetworkManager {
	enabled                   = false,
	server_disconnect_handler = default_disconnect_handler,
	server_connection_handler = default_connection_handler,
}

enable_udp :: proc(server_endpoint: net.Endpoint) {
	NetworkManager.enabled = true
	NetworkManager.server_address = server_endpoint
}

set_server_proc :: proc(p: proc(server: ^Server, remote: net.Endpoint, data: []u8)) {
	NetworkManager.server_proc = p
}

set_client_proc :: proc(p: proc(_: ^Client, data: []u8)) {
	NetworkManager.client_proc = p
}

get_current_client :: proc() -> ^Client {
	return NetworkManager.curr_client
}

send_message :: proc(
	socket: net.UDP_Socket,
	to: net.Endpoint,
	type: MessageType,
	data: []u8,
	buf: []u8,
) -> (
	numbytes: int,
	err: net.Network_Error,
) {
	to_send := buf[:len(data) + 1]
	for e, i in data {
		to_send[i] = data[i]
	}
	to_send[len(data)] = cast(u8)type
	return net.send_udp(socket, to_send, to)
}

recv_message :: proc(
	socket: net.UDP_Socket,
	buf: []u8,
) -> (
	msg: Message,
	remote: net.Endpoint,
	err: net.Network_Error,
) {
	numbytes: int
	numbytes, _, err = net.recv_udp(socket, buf[:])

	type := cast(MessageType)buf[numbytes - 1]

	msg = {
		type = type,
		data = buf[:numbytes - 1],
	}

	return
}

broadcast_message :: proc(
	server: ^Server,
	type: MessageType,
	data: []u8,
	buf: []u8,
) -> net.Network_Error {
	err: net.Network_Error
	to_send := buf[:len(data) + 1]
	for e, i in data {
		to_send[i] = data[i]
	}
	to_send[len(data)] = cast(u8)type
	for ci in server.clients {
		net.send_udp(server.socket, to_send, ci.remote) or_return
	}
	return nil
}
