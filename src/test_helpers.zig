const std = @import("std");
const string = @import("string.zig");
const ArrayList = std.array_list.Managed;

// Outputs valid paths to test against.
// file_csv MUST be comma separated
pub fn buildTestPaths(dir: []const u8, files_csv: []const u8, alloc: std.mem.Allocator) !void {
    //TODO:
    //You could write in a buffer here if you felt like it!
    try std.fs.cwd().makeDir(dir);
    var file_paths = std.mem.splitSequence(u8, files_csv, ",");

    var files = ArrayList([]u8).init(alloc);
    defer files.deinit();
    while (file_paths.next()) |file| {
        const output = try std.fmt.allocPrint(alloc, "{s}/{s}", .{ dir, file });
        _ = try std.fs.cwd().createFile(output, .{});
        try files.append(output);
        alloc.free(output);
    }
}
