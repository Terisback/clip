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

// Checks if obj.len is zero
fn isempty<T>(obj T) bool {
	return obj.len == 0
}
