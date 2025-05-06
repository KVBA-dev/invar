package invar

import "core:fmt"
import "core:mem"
import "core:net"

init_server :: proc(endpoint: net.Endpoint, numclients: int = 8) -> ^Server {
	socket, err := net.make_bound_udp_socket(endpoint.address, endpoint.port)
	if err != nil {
		fmt.eprintln("error on server creation:", err)
		return nil
	}

	server := new(Server)
	server.clients = make([]ClientInfo, numclients)
	server.socket = socket

	i: u32 = 0
	for &c in server.clients {
		c.id = i
		i += 1
	}

	fmt.println("server running on port", endpoint.port)
	return server
}

update_server :: proc(server: ^Server) {
	buf := [1024]u8{}
	for {
		msg, remote, err := recv_message(server.socket, buf[:])
		if err != nil {
			fmt.eprintln("error on receive data:", err)
			return
		}
		#partial switch msg.type {
		case .ConnectionRequest:
			NetworkManager.server_connection_handler(server, remote, buf[:])
		case .Disconnect:
			NetworkManager.server_disconnect_handler(server, remote)
		case .Data:
			NetworkManager.server_proc(server, remote, msg.data)
		case .ConnectionAccepted:
			fallthrough
		case .ConnectionRejected:
			fmt.eprintln("invalid message type:", msg.type)
		}
	}
}

destroy_server :: proc(server: ^Server) {
	delete(server.clients)
	net.close(server.socket)
	free(server)
}

server_echo :: proc(server: ^Server, remote: net.Endpoint, data: []u8) {
	net.send_udp(server.socket, data, remote)
}

default_connection_handler :: proc(server: ^Server, remote: net.Endpoint, buf: []u8) {
	data := [4]u8{}
	for &ci, i in server.clients {
		if ci.remote == remote || !ci.connected {
			ci.connected = true
			ci.remote = remote
			data[0] = cast(u8)(ci.id & 0xFF)
			data[1] = cast(u8)(ci.id >> 8 & 0xFF)
			data[2] = cast(u8)(ci.id >> 16 & 0xFF)
			data[3] = cast(u8)(ci.id >> 24 & 0xFF)
			send_message(server.socket, remote, .ConnectionAccepted, data[:], buf)
			return
		}
	}

	send_message(server.socket, remote, .ConnectionRejected, EmptyData, buf)
}

default_disconnect_handler :: proc(server: ^Server, remote: net.Endpoint) {
	for &ci, i in server.clients {
		if ci.remote == remote {
			ci.connected = false
			ci.remote = {}
			return
		}
	}
}
