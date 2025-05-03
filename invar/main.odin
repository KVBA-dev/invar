package invar

run :: proc() {
	when #config(SERVER, 0) == 1 {
		main_server()
	} else {
		main_client()
	}
}
