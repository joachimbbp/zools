const std = @import("std");
const path = @import("path.zig");

//Builds a directory if one is not present at that filepath
// Returns true for absent paths
pub fn buildIfAbsent(path_string: []const u8) !bool {
    if (!path.exists(path_string)) {
        try std.fs.cwd().makeDir(path_string);
        return true;
    }
    return false;
}
