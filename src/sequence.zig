// SECTION: Explanation:
// A self-contained way to save out sequences of files (such as a .png sequence for VFX purposes)
// Originally this was going to grow out of `save` and `path`'s version functions
// However, this proved to be unweildy and I thought it was best to pull the best
// parts of these and bring them in here

//SECTION: CODE:

const std = @import("std");
const path = @import("path.zig");
const string = @import("string.zig");

pub fn elementName(dir: []const u8, basename: []const u8, extension: []const u8, version: usize, leading_zeros: u8, alloc: std.mem.Allocator) ![]const u8 {
    //    var output = ArrayList(u8).init(arena);
    var result: []const u8 = undefined;
    result = try std.fmt.allocPrint(
        alloc,
        "{[dir]s}/{[bn]s}_{[n]d:0>[w]}.{[ext]s}",
        .{ .dir = dir, .bn = basename, .n = version, .w = leading_zeros, .ext = extension },
    );
    return result;
}

test "iterate" {
    //NOTE:
    //patern should be:
    //      Test directory exists
    //      write new element name
    //      make sure you're not overwriting an existing file (panic for now)
    //      write sequence element
    std.debug.print("🎥 Testing sequence iteration: \n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    for (0..24) |i| {
        const name = try elementName("ham/spam", "land", "png", i, 3, alloc);
        std.debug.print("   name: {s}\n", .{name});
        alloc.free(name);
    }
}
