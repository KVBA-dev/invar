package invar

import "core:math"

linear :: proc "contextless" (t: f32) -> f32 {return t}

quad_in :: proc "contextless" (t: f32) -> f32 {
	return t * t
}

quad_out :: proc "contextless" (t: f32) -> f32 {
	return t * (2 - t)
}

quad_in_out :: proc "contextless" (t: f32) -> f32 {
	if t < 0.5 do return 2 * t * t
	else do return 4 * t - 2 * t * t - 1
}

sine_in :: proc "contextless" (t: f32) -> f32 {
	return 1 - math.cos(t * math.PI)
}

sine_out :: proc "contextless" (t: f32) -> f32 {
	return math.sin(t * math.PI)
}

sine_in_out :: proc "contextless" (t: f32) -> f32 {
	return 0.5 - 0.5 * math.cos(t * math.PI)
}

cube_in :: proc "contextless" (t: f32) -> f32 {
	return math.pow(t, 3)
}

cube_out :: proc "contextless" (t: f32) -> f32 {
	return 1 - math.pow(1 - t, 3)
}

cube_in_out :: proc "contextless" (t: f32) -> f32 {
	return t * t * (3 - 2 * t)
}

elastic_in :: proc "contextless" (t: f32) -> f32 {
	if t == 0 do return 0
	if t == 1 do return 1
	return -math.pow(2, 10 * t - 10) * math.sin((t * 10 - 10.75) * 2 * math.PI / 3)
}

elastic_out :: proc "contextless" (t: f32) -> f32 {
	if t == 0 do return 0
	if t == 1 do return 1
	return math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * 2 * math.PI / 3) + 1
}

elastic_in_out :: proc "contextless" (t: f32) -> f32 {
	if t < 0.5 do return elastic_in(2 * t) / 2
	return elastic_out(2 * t - 1) / 2 + 0.5
}

bounce_in :: proc "contextless" (t: f32) -> f32 {
	return abs(elastic_in(t))
}

bounce_out :: proc "contextless" (t: f32) -> f32 {
	return 1 - bounce_in(1 - t)
}

bounce_in_out :: proc "contextless" (t: f32) -> f32 {
	if t < 0.5 do return bounce_in(2 * t) / 2
	return bounce_out(2 * t - 1) / 2 + 0.5
}

exp_in :: proc "contextless" (t: f32) -> f32 {
	if t == 0 do return 0
	return math.pow(2, 10 * t - 10)
}

exp_out :: proc "contextless" (t: f32) -> f32 {
	if t == 1 do return 1
	return 1 - math.pow(2, -10 * t)
}

exp_in_out :: proc "contextless" (t: f32) -> f32 {
	if t == 0 do return 0
	if t == 1 do return 1
	if t < 0.5 do return math.pow(2, 20 * t - 10) / 2
	return (2 - math.pow(2, -20 * t + 10)) / 2
}
