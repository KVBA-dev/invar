package invar

Stack :: struct($T: typeid) {
	data: []T,
	top:  int,
}

make_stack :: proc($T: typeid, capacity: int = 10) -> ^Stack(T) {
	stack := new(Stack(T))
	stack.data = make([]T, capacity)
	stack.top = -1
	return stack
}

delete_stack :: proc(stack: ^Stack($T)) {
	delete(stack.data)
	free(stack)
}

stack_push :: proc(stack: ^Stack($T), el: T) {
	if stack.top + 1 == len(stack.data) {
		newData := make([]T, len(stack.data) * 2)
		for e, idx in stack.data {
			newData[idx] = stack.data[idx]
		}
		delete(stack.data)
		stack.data = newData
	}

	stack.top += 1
	stack.data[stack.top] = el
}

stack_pop :: proc(stack: ^Stack($T)) -> T {
	if stack.top == -1 {
		panic("stack underflow - tried popping from empty stack")
	}
	el := stack.data[stack.top]
	stack.top -= 1
	return el
}

stack_peek :: proc(stack: ^Stack($T)) -> T {
	if stack.top == -1 {
		panic("stack underflow - tried peeking into empty stack")
	}
	return stack.data[stack.top]
}
