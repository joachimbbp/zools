const std = @import("std");
const string = @import("string.zig");
const test_dir = "./test_files_2b31fe56-0219-4e02-84d7-b113a2b19bd8";

fn build_test_files() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    try std.fs.cwd().makeDir(test_dir);
    //try std.fmt.allocPrint(alloc, "{s}/{s}", .{ path, entry.basename });
    const files_csv = "ham.txt,spam.txt,version_me_41.txt,land.txt";
    const files = try string.split(files_csv, ",", alloc);
    defer files.deinit();

    for (files.items) |file| {
        const output = try std.fmt.allocPrint(alloc, "{s}/{s}", .{ test_dir, file });
        defer alloc.free(output);
        _ = try std.fs.cwd().createFile(output, .{});
    }
}

test "helpers" {
    try build_test_files();
}
