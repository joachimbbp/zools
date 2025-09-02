// Returns the length of an iterator
// So far tested on:
//      - `SplitBackwardsIterator`

pub fn len(split: anytype) usize {
    var iter = split;
    var parts: usize = 0;
    while (iter.next() != null) {
        parts += 1;
    }
    return parts;
}
