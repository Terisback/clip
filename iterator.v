module clip

struct StringArrayIterator {
	array []string
mut:
	idx      usize
	peek_idx usize = 1
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
	i.peek_idx = i.idx + 1
}

fn (mut i StringArrayIterator) take_while(predicate fn(string) bool) []string {
	mut taked_arr := []string{}

	if in_bounds(i.idx, i.array) {
		for elem in i.array[i.idx..] {
			if predicate(elem) {
				// TODO: Meh, remove `<<` when there will be .push(elem)
				taked_arr << elem
			} else {
				break
			}
		}
	}

	return taked_arr
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
	return 0 <= idx && idx < arr.len
}
