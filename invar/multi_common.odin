package invar

import "core:container/queue"
import "core:net"

buf := [1024]u8{}

DEFAULT_PORT :: 38124

Payload :: union {
	InputMessage,
	GameStateMessage,
}

// TODO: fill your own input messages there
InputMessage :: struct {}

// TODO: fill your own game state messages there
GameStateMessage :: struct {}

MessageType :: enum u8 {
	Disconnect = 0,
	Connection_Request,
	Connection_Accept,
	Connection_Reject,
	Input,
	GameUpdate,
}

MessageHeader :: struct {
	timestamp: f64,
	type:      MessageType,
}

Message :: struct {
	header: MessageHeader,
	body:   Payload,
	id:     u32,
}

Server :: struct {
	socket:  net.UDP_Socket,
	clients: []ClientInfo,
}

ClientInfo :: struct {
	remote:    net.Endpoint,
	id:        u32,
	connected: bool,
}

Client :: struct {
	server_remote: net.Endpoint,
	socket:        net.UDP_Socket,
	id:            u32,
	incomingQueue: queue.Queue(MessageType),
	outgoingQueue: queue.Queue(MessageType),
}
