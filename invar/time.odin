package invar

import "core:time"
import rl "vendor:raylib"

_Time :: struct {
	time:          f64,
	levelLoadTime: f64,
	levelTime:     f64,
	deltaTime:     f32,
}

Time := _Time{}

update_time :: proc() {
	Time.time = rl.GetTime()
	Time.deltaTime = rl.GetFrameTime()
	Time.levelTime = Time.time - Time.levelLoadTime
}

sleep :: proc(seconds: f64) {
	ts := time.now()
	for time.duration_seconds(time.since(ts)) < seconds {}
}

sleep_ms :: proc(ms: f64) {
	ts := time.now()
	for time.duration_milliseconds(time.since(ts)) < ms {}
}
