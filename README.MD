# Invar
A bare-bones game framework based on raylib for Odin

---

**IMPORTANT NOTE:** This project is still very new, a lot of features are untested, incomplete, or straight-up missing. The API might and probably will feature breaking changes.

Please, if you spot a bug, create an issue. Or if want to contribute, you're more than welcome to do it! 

---

Invar aims to simplify game development in Odin by implementing a lot of useful features, including:
- Easy CBOR file support (e.g. for data serialisation)
- Scene system
- Rebindable keybinds
- UDP networking for realtime games w/ separate server-side
- Simple UI elements, such as buttons, sliders, and checkboxes

Invar aims to provide a simple structure to your game while leaving you able to control
everything. Like most frameworks, Invar does dictate some of the code architecture,
however it tries to be as transparent and inobtrusive as possible.

```odin
package main

import "invar"
import rl "vendor:raylib"

main :: proc() {
	iv.init()
	iv.set_scene({new(GameData), game_init, game_update, game_cleanup})
	iv.run()
}

GameData :: struct {
	// game variables here...
}

game_init :: proc(data: rawptr) {
	using data := cast(^GameData)data
	// game init code here...
}

game_update :: proc(data :: rawptr) {
	using data := cast(^GameData)data
	// game update code here...
	rl.BeginDrawing()
	rl.ClearBackground(rl.WHITE)
		// drawing code here...
	rl.EndDrawing()
}

game_cleanup :: proc(data: rawptr) {
	using data := cast(^GameData)data
	defer free(data)
	// cleanup code here...
}
```

Invar also supports building server-side applications. Simply compile with:
```
odin build . -define:SERVER=1
```
