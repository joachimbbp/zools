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

// If a file exists at that place, save a new version of it
pub fn version(
    path_string: []const u8,
    buffer: ArrayList(u8),
    alloc: std.mem.Allocator,
) !ArrayList(u8) {
    //TODO: version for directory as well
    const file_name = try path.versionName(path_string, alloc);
    const file = try std.fs.cwd().createFile(file_name.items, .{});
    try file.writeAll(buffer.items);
    defer file.close();
    return file_name;
}
