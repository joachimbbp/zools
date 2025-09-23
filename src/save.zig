const std = @import("std");
const Io = std.Io;

const path = @import("path.zig");
const ArrayList = std.array_list.Managed;

// Builds a directory if one is not present at that filepath
// Returns true for absent paths
pub fn dirIfAbsent(path_string: []const u8) !bool {
    if (!try path.exists(path_string)) {
        try std.fs.cwd().makeDir(path_string);
        return true;
    }
    return false;
}

pub fn version(
    path_string: []const u8,
    leading_zeros: u8,
    buffer: ArrayList(u8),
    alloc: std.mem.Allocator,
) !ArrayList(u8) {
    const file_name = try path.versionName(path_string, leading_zeros, alloc);
    const file = try std.fs.cwd().createFile(file_name.items, .{});
    try file.writeAll(buffer.items);
    defer file.close();
    return file_name;
}

pub fn versionFolder(path_string: []const u8, arena: std.mem.Allocator) !ArrayList(u8) {
    const folder_name = try path.folderVersionName(path_string, arena);
    try std.fs.cwd().makeDir(folder_name.items);
    return folder_name;
}
test "folder version" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    var arena_alloc = std.heap.ArenaAllocator.init(alloc);
    defer arena_alloc.deinit();
    const arena = arena_alloc.allocator(); //wow that is confusing naming!
    const new_name = try versionFolder("/Users/joachimpfefferkorn/Desktop/lib_test", arena);
    std.debug.print("folder versioned at: {s}\n", .{new_name.items});
}
