const std = @import("std");
const ArrayList = std.ArrayList;

pub fn split(chars: []const u8, delimiter: []const u8, allocator: std.mem.Allocator) !ArrayList([]const u8) {
    var splits = ArrayList([]const u8).init(allocator);
    var split_iter = std.mem.splitSequence(u8, chars, delimiter);

    while (split_iter.next()) |n| {
        try splits.append(n);
    }
    return splits;
}
