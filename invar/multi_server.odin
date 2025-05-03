package invar

import "core:fmt"
import "core:mem"
import "core:net"


init_server :: proc(port: u16, numclients: int) -> ^Server {
	socket, err := net.make_bound_udp_socket(net.IP4_Address{127, 0, 0, 1}, int(port))
	if err != nil {
		fmt.println("error on server creation:", err)
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

	fmt.println("server running on port", port)
	return server
}

update_server :: proc(server: ^Server) {
	for {
		bytes, remote, err := net.recv_udp(server.socket, buf[:])
		if err != nil {
			fmt.println("error:", err)
			return
		}

		msg := cast(^Message)raw_data(buf[:bytes])

		#partial switch msg.header.type {
		case .Disconnect:
			handle_disconnect(server, remote)

		case .Connection_Request:
			handle_new_connection(server, remote)

		case .Input:
			body, ok := msg.body.(InputMessage)
			assert(ok, "invalid input message body")
			handle_input(server, remote, body)

		}
	}
}

find_client_by_endpoint :: proc(server: ^Server, remote: net.Endpoint) -> ^ClientInfo {
	for &c in server.clients {
		if c.remote == remote {
			return &c
		}
	}
	return nil
}

destroy_server :: proc(server: ^Server) {
	msg := Message {
		header = MessageHeader{type = .Disconnect, timestamp = Time.time},
		body = nil,
	}
	for &c in server.clients {
		if !c.connected do continue
		msg.id = c.id
		bytes := mem.byte_slice(&msg, size_of(msg))
		net.send_udp(server.socket, bytes, c.remote)
	}
	net.close(server.socket)
	free(server)
	fmt.println("server shut down")
}

get_connected_clients_count :: proc(server: ^Server) -> int {
	i := 0
	for c in server.clients {
		if c.connected do i += 1
	}
	return i
}

handle_disconnect :: proc(server: ^Server, remote: net.Endpoint) {
	client := find_client_by_endpoint(server, remote)
	if client == nil do return

	client.connected = false
	fmt.println("client", client.id, "disconnected")
}

handle_new_connection :: proc(server: ^Server, remote: net.Endpoint) {
	client := find_client_by_endpoint(server, remote)
	if client != nil {
		// client is already connected, just ack
		send_connection_response(server, client, true)
		return
	}
	for &c in server.clients {
		if !c.connected {
			client = &c
			break
		}
	}
	if client == nil {
		// server full
		tempClient := ClientInfo {
			remote = remote,
		}
		send_connection_response(server, &tempClient, false)
		return
	}

	client.remote = remote
	client.connected = true
	// accept connection
	send_connection_response(server, client, true)

	fmt.println("client connected from", remote, "with id", client.id)
}

send_connection_response :: proc(server: ^Server, client: ^ClientInfo, accept: bool) {
	msg := Message {
		header = MessageHeader {
			type = .Connection_Accept if accept else .Connection_Reject,
			timestamp = Time.time,
		},
		body = nil,
		id = client.id if accept else ~u32(0),
	}

	bytes := mem.byte_slice(&msg, size_of(Message))

	numbytes, err := net.send_udp(server.socket, bytes, client.remote)
	if err != nil {
		fmt.println("error on sending connection response to", client.remote, ":", err)
		return
	}
}

handle_input :: proc(server: ^Server, remote: net.Endpoint, input: InputMessage) {
	// TODO: fill your own input handling here
}
