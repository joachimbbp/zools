const std = @import("std");
const ArrayList = std.array_list.Managed;

// //WARNING: deprecated and unidiomatic
// //TODO: replace with std.mem.splitSequence
// pub fn split(chars: []const u8, delimiter: []const u8, alloc: std.mem.Allocator) !ArrayList([]const u8) {
//     var splits = ArrayList([]const u8).init(alloc);
//     var split_iter = std.mem.splitSequence(u8, chars, delimiter);
//
//     while (split_iter.next()) |n| {
//         try splits.append(n);
//     }
//     return splits;
// }

pub fn isInteger(chars: []const u8) bool {
    //as per: https://upload.wikimedia.org/wikipedia/commons/1/1b/ASCII-Table-wide.svg
    for (chars) |c| {
        if ((c < 48) or (c > 57)) {
            return false;
        }
    }
    return true;
}
