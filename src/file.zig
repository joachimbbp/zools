const std = @import("std");
const path = @import("path.zig");
const iter = @import("iter.zig");
const string = @import("string.zig");
const print = std.debug.print;
const expect = std.testing.expect;
const ArrayList = std.ArrayList;

const FileError = error{
    ExtensionError,
};

//Returns path with updated version number, <file_#.ext>, if a file exists at this path
pub fn addVersion(filepath: []const u8, alloc: std.mem.Allocator) !ArrayList(u8) {
    //NOTE: not sure if ArrayList appends and joins are the best way to go about this...
    //Might be nice for this to return a []const u8 if possible?
    const vsep = "_";
    const f_pattern = "{s}/{s}_{d}.{s}";
    var output = ArrayList(u8).init(alloc);

    if (!path.exists(filepath)) {
        for (filepath) |c| {
            try output.append(c);
        }
        return output;
    }
    const folders = try string.split(filepath, "/", alloc);
    defer folders.deinit();
    const directory: []const u8 = try std.mem.join(alloc, "/", folders.items[0 .. folders.items.len - 1]);
    defer alloc.free(directory);
    const filename = folders.items[folders.items.len - 1];
    const filename_split = try string.split(filename, ".", alloc);
    defer filename_split.deinit();
    if (filename_split.items.len != 2) {
        return FileError.ExtensionError;
    }
    const basename = filename_split.items[0];
    const extension = filename_split.items[1];

    const v_split = try string.split(basename, vsep, alloc);
    defer v_split.deinit();
    const suffix = v_split.items[v_split.items.len - 1];
    var version: u32 = 1;

    if (string.isInteger(suffix)) {
        version = try std.fmt.parseInt(u32, suffix, 10) + 1;
    }

    const result = try std.fmt.allocPrint(alloc, f_pattern, .{ directory, basename, version, extension });
    defer alloc.free(result);

    for (result) |c| {
        try output.append(c);
    }

    return output;
}

// test "as we go" {
//     var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//     const alloc = gpa.allocator();
//     defer _ = gpa.deinit();
//
//     var dir = try std.fs.Dir.openDir("../test_files/", .{ .iterate = true });
//     defer dir.close();
//
//     const version_me = "/Users/joachimpfefferkorn/Desktop/v_10.txt";
//     const versioned = try addVersion(version_me, alloc);
//     defer versioned.deinit();
//     print("updated: {s}\n", .{versioned.items});
// }

//Returns the next next file's name in versioning sequence
// pub fn versionName(path_string: []u8) FileError![]u8 {
//     if (!path.exists(path_string)) {
//         return path_string;
//     }
//
//     var gpa = std.heap.GeneralPurposealloc(.{}){};
//     const alloc = gpa.alloc();
//     defer {
//         const deinit_status = gpa.deinit();
//         if (deinit_status == .leak) expect(false) catch @panic("TEST FAIL");
//     }
//     var path_split = std.mem.splitBackwardsScalar(u8, path_string, '/');
//     const filename = path_split.first();
//     const base_path = path_split.rest();
//     var fname_split = std.mem.splitBackwardsScalar(u8, filename, '.');
//     if (iter.len(fname_split) != 2) {
//         return FileError.InvalidExtensionNumber;
//     }
//     const extension = fname_split.first();
//     const basename = fname_split.next().?;
//
//     var version_split = std.mem.splitBackwardsScalar(u8, filename, '_');
//     const version_num_str = version_split.first();
//     var first_version = false;
//     for (version_num_str) |c| {
//         std.debug.print("character: {d}\n", .{c});
//         if ((c < 0) or (c > 9)) {
//             //file is not a version
//             first_version = true;
//             break;
//         }
//     }
//
//     var version_num: u32 = 1;
//     if (!first_version) {
//         std.debug.print("version number string: {s}\n", .{version_num_str});
//         //        version_num = std.fmt.parseInt(u32, version_num_str, 10);
//         version_num += 1;
//     }
//     const output = std.fmt.allocPrint(alloc, "{s}/{s}_{d}.{s}", .{ base_path, basename, version_num, extension }) catch FileError.OutOfMemory;
//     //defer alloc.free(output);
//     return output;
// }
