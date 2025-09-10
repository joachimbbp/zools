const std = @import("std");
const ArrayList = std.array_list.Managed;
const print = std.debug.print;

//prints hello zools to check import
pub fn helloZools() void {
    print("🦎 Hello Zools! 🦎\n", .{});
}
