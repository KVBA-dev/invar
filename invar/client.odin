package invar

import "core:fmt"
import t "core:thread"
import rl "vendor:raylib"

main_client :: proc() {
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	client: ^Client

	if NetworkManager.enabled {
		client = init_client()
		NetworkManager.curr_client = client
	}

	for !rl.WindowShouldClose() {
		update_time()
		update_input()
		SceneManager.current.update(SceneManager.current.data)
	}

	SceneManager.current.cleanup(SceneManager.current.data)
	destroy_client(client)
	delete_scene_manager()
	delete_input()
}
