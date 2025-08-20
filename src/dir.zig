const std = @import("std");
const path = @import("path.zig");

//Builds a directory if one is not present at that filepath
pub fn buildIfAbsent(path_string: []const u8) !void {
    if (!path.exists(path_string)) {
        try std.fs.cwd().makeDir(path_string);
    }
}

//TODO:
//- [ ] saveVersion
