const std = @import("std");
const ArrayList = std.array_list.Managed;
const print = std.debug.print;

pub fn printItems(list: ArrayList([]const u8)) void {
    for (list.items) |item| {
        print("{s},", .{item});
    }
    print("\n", .{});
}
