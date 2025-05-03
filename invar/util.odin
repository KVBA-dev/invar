package invar

import rl "vendor:raylib"

RectLerp :: proc(a, b: rl.Rectangle, t: f32) -> rl.Rectangle {
	return {
		a.x + (b.x - a.x) * t,
		a.y + (b.y - a.y) * t,
		a.width + (b.width - a.width) * t,
		a.height + (b.height - a.height) * t,
	}
}

RectPos :: proc(r: rl.Rectangle) -> [2]f32 {
	return {r.x, r.y}
}

MouseOnRect :: proc(r: rl.Rectangle) -> bool {
	relPos := Input.mousePosition - RectPos(r)
	return relPos.x > 0 && relPos.x < r.width && relPos.y > 0 && relPos.y < r.height
}
