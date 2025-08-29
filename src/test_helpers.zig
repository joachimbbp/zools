const std = @import("std");
const string = @import("string.zig");
const ArrayList = std.array_list.Managed;

// Outputs valid paths to test against.
pub fn test_paths(dir: []const u8, files_csv: []const u8, alloc: std.mem.Allocator) !ArrayList([]const u8) {
    try std.fs.cwd().makeDir(dir);
    const files = try string.split(
        files_csv,
        ",",
        alloc,
    );

    for (files.items) |file| {
        const output = try std.fmt.allocPrint(alloc, "{s}/{s}", .{ dir, file });
        defer alloc.free(output);
        _ = try std.fs.cwd().createFile(output, .{});
    }
    //    files.append(dir);
    return files;
}

//TODO: delete test files
