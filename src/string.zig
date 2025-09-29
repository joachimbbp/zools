const std = @import("std");
const ArrayList = std.array_list.Managed;

pub fn isInteger(chars: []const u8) bool {
    //as per: https://upload.wikimedia.org/wikipedia/commons/1/1b/ASCII-Table-wide.svg
    for (chars) |c| {
        if ((c < 48) or (c > 57)) {
            return false;
        }
    }
    return true;
}

test "strings" {
    std.debug.print("🎻 testing strings\n", .{});
    std.debug.print("module level\n", .{});
    try std.testing.expect(isInteger("42"));
    try std.testing.expect(isInteger("0"));
    try std.testing.expect(!isInteger("ham"));
}
