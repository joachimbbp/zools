const std = @import("std");
const iter = @import("iter.zig");

pub fn exists(path_string: []const u8) bool {
    _ = std.fs.cwd().openFile(path_string, .{}) catch {
        return false;
    };
    return true;
}
