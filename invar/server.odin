package invar

import "core:fmt"
import "core:os"
import "core:thread"

main_server :: proc() {
	server := init_server(DEFAULT_PORT, 4)
	defer destroy_server(server)
	fmt.printfln("press enter to shut down")

	t := thread.create_and_start_with_poly_data(server, update_server)
	defer thread.destroy(t)

	buf := [1]u8{}

	for {
		n, err := os.read(os.stdin, buf[:])
		fmt.println(n)
		if n > 0 {
			break
		}
	}
	thread.terminate(t, 0)
}
