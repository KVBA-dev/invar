package invar

import "core:fmt"
import "core:net"
import "core:thread"
import "vendor:raylib"

init_client :: proc() -> ^Client {
	socket, err := net.make_unbound_udp_socket(.IP4)
	if err != nil {
		return nil
	}

	client := new(Client)
	client.socket = socket
	return client
}

destroy_client :: proc(client: ^Client) {
	if client == nil do return
	net.close(client.socket)
	free(client)
}

client_connect :: proc(client: ^Client) -> bool {
	buf := [1024]u8{}
	numbytes, err := send_message(
		client.socket,
		NetworkManager.server_address,
		.ConnectionRequest,
		EmptyData,
	)
	if err != nil do return false

	msg: Message
	msg, _, err = recv_message(client.socket, buf[:])
	if err != nil {
		return false
	}

	data := msg.data
	assert(len(data) == 4, "invalid packet")

	if msg.type == .ConnectionRejected {
		return false
	}
	client.id =
		cast(u32)data[0] | cast(u32)data[1] << 8 | cast(u32)data[2] << 16 | cast(u32)data[3] << 24
	return true
}

disconnect :: proc(client: ^Client) {
	send_message(client.socket, NetworkManager.server_address, .Disconnect, nil)
}

start_client_thread :: proc(client: ^Client) {
	thread.run_with_poly_data(client, client_thread)
}

client_thread :: proc(client: ^Client) {
	buf := [1024]u8{}
	for {
		msg, _, err := recv_message(client.socket, buf[:])
		if err != nil {
			fmt.eprintln("error on receive:", err)
			return
		}
		#partial switch msg.type {
		case .Data:
			NetworkManager.client_proc(client, msg.data)
		case:
			fmt.eprintln("invalid message type:", msg.type)
		}
	}
}
