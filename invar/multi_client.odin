package invar

import "core:container/queue"
import "core:mem"
import "core:net"
import "core:sync"
import "core:thread"

mtx := sync.Mutex{}

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
	net.close(client.socket)
	free(client)
}

connect_to_server :: proc(
	client: ^Client,
	address: net.IP4_Address,
	port := DEFAULT_PORT,
) -> bool {
	msg := Message {
		header = {timestamp = Time.time, type = .Connection_Request},
		id = ~u32(0),
	}

	bytes := mem.byte_slice(&msg, size_of(Message))

	numbytes, err := net.send_udp(client.socket, bytes, {address, port})
	if err != nil do return false

	buf := [1024]u8{}
	client.server_remote = {address, port}
	numbytes, _, err = net.recv_udp(client.socket, buf[:])
	if err != nil {
		return false
	}

	resp := (cast(^Message)raw_data(buf[:numbytes]))^
	if resp.header.type == .Connection_Reject {
		return false
	}
	client.id = resp.id
	return true
}

disconnect :: proc(client: ^Client) {
	msg := Message {
		header = {timestamp = Time.time, type = .Disconnect},
		id = client.id,
	}

	net.send_udp(client.socket, mem.byte_slice(&msg, size_of(Message)), client.server_remote)
}

start_client_thread :: proc(client: ^Client) {
	thread.run_with_poly_data(client, client_thread)
}

client_thread :: proc(client: ^Client) {
	for {

	}
}
