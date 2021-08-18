module clip

// Behaves like Go append()
fn append<T>(a []T, b ...T) []T {
	mut m := []T{cap: a.len + b.len}

	for elem in a {
		m << elem
	}

	for elem in b {
		m << elem
	}

	return m
}

fn index_of<T>(array []T, value T) int {
	for index, elem in array {
		if elem == value {
			return index
		}
	}

	return -1
}

// Checks if obj.len is zero
fn is_empty<T>(obj T) bool {
	return obj.len == 0
}
