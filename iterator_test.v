module clip

const test_array = ['clip', '-v=4', '--debug', 'some', 'fome', 'arguemnt']

fn test_string_array_iterator_next_and_peek() ? {
    mut iterator := StringArrayIterator {
        array: test_array
    }

    assert iterator.peek()? == test_array[1]
    assert iterator.next()? == test_array[0]
    assert iterator.peek()? == test_array[2]
    assert iterator.peek()? == test_array[3]
    assert iterator.next()? == test_array[1]
    assert iterator.peek()? == test_array[3]
}

fn teest_string_array_iterator_skip() ? {
    mut iterator := StringArrayIterator {
        array: test_array
    }

    iterator.skip(1)
    assert iterator.next()? == test_array[1]
    iterator.skip(2)
    assert iterator.next()? == test_array[3]
}
