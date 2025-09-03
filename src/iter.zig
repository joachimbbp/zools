// Returns the length of an iterator
pub fn len(split: anytype) usize {
    // So far tested on:
    //      - `SplitBackwardsIterator`
    var iter = split;
    var parts: usize = 0;
    while (iter.next() != null) {
        parts += 1;
    }
    return parts;
}
