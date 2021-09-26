module clip

struct StringArrayIterator {
	array []string
mut:
	idx      int = 0
	peek_idx int = 1
}

fn (mut i StringArrayIterator) next() ?string {
	defer {
		i.idx += 1
		i.peek_idx = i.idx + 1
	}
	return get(i.array, i.idx)
}

fn (mut i StringArrayIterator) peek() ?string {
	defer {
		i.peek_idx++
	}
	return get(i.array, i.peek_idx)
}

fn (mut i StringArrayIterator) skip(n usize) {
	i.idx += n
}
[direct_array_access]
fn get(array []string, index usize) ?string {
	if in_bounds(index, array) {
		return array[index]
	} else {
		return none
	}
}

fn in_bounds(idx usize, arr []string) bool {
	return 0 <= idx && idx < array.len;
}
