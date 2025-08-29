const std = @import("std");
const path = @import("path.zig");
const ArrayList = std.array_list.Managed;

// Builds a directory if one is not present at that filepath
// Returns true for absent paths
//WARNING: not sure if this will save outside of currnet directory
pub fn dirIfAbsent(path_string: []const u8) !bool {
    if (!path.exists(path_string)) {
        try std.fs.cwd().makeDir(path_string);
        return true;
    }
    return false;
}

// Saves file as a version, returns the filename of the newly saved version
// pub fn saveVersion(path_string: []const u8, alloc: std.mem.Allocator) !ArrayList() {
//     const version_name = path.versionName(path_string, alloc);
//
//NOTE: need basepath here! so you don't have to do cwd()
// }
//
