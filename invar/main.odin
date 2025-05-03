package invar

import "core:strings"
import rl "vendor:raylib"

init :: proc(w, h: i32, window_name: string = "invar", flags: rl.ConfigFlags = {}, fps: i32 = 60) {
	namec := strings.clone_to_cstring(window_name, context.temp_allocator)
	rl.InitWindow(w, h, namec)
	rl.SetWindowState(flags)
	rl.SetTargetFPS(fps)
}

run :: proc() {
	when #config(SERVER, 0) == 1 {
		main_server()
	} else {
		main_client()
	}
}
