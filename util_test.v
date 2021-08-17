module clip

fn test_append() {
	a := [1, 2, 3]
	b := [4, 5]
	c := append(a, ...b)
	assert [1, 2, 3, 4, 5] == c
}
