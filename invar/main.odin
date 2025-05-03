package invar

import rl "vendor:raylib"


init :: proc(w, h: i32, window_name: string = "invar", flags: rl.ConfigFlags = {}, fps: i32 = 60) {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "invar")
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
