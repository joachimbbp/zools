const std = @import("std");

fn numDigitsShort(n: u16) u8 { //LLM: heavily inspired by chatGPT code
    if (n == 0) return 1;
    var count: u8 = 0;
    var value = n;
    while (value > 0) : (value /= 10) {
        count += 1;
    }
    return count;
}

//TODO: Move to testing
const expect = std.testing.expect;
test "num digits" {
    try expect(numDigitsShort(100) == 3);
    try expect(numDigitsShort(1) == 1);
    try expect(numDigitsShort(65535) == 5);
}
