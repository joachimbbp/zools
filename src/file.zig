const std = @import("std");
const path = @import("path.zig");
const iter = @import("iter.zig");
const string = @import("string.zig");
const print = std.debug.print;
const expect = std.testing.expect;
const FileError = error{
    ExtensionError,
};

//WARNING: WIP
//Returns path with updated version number, <file_#.ext>, if a file exists at this path
pub fn addVersion(filepath: []const u8) ![]const u8 {
    const vsep = "_";
    const f_pattern = "{s}/{s}_{d}.{s}";

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    if (!path.exists(filepath)) {
        return filepath;
    }

    const folders = try string.split(filepath, "/", allocator);
    defer folders.deinit();
    const directory = try std.mem.join(allocator, "/", folders.items[0 .. folders.items.len - 1]);
    const filename = folders.items[folders.items.len - 1];
    const filename_split = try string.split(filename, ".", allocator);
    defer filename_split.deinit();
    if (filename_split.items.len != 2) {
        return FileError.ExtensionError;
    }
    const basename = filename_split.items[0];
    const extension = filename_split.items[1];

    const v_split = try string.split(basename, vsep, allocator);
    defer v_split.deinit();
    const suffix = v_split.items[v_split.items.len - 1];
    var version: u32 = 1;
    if (!string.isInteger(suffix)) {
        return try std.fmt.allocPrint(allocator, f_pattern, .{ directory, basename, version, extension });
    }
    version = try std.fmt.parseInt(u32, suffix, 10) + 1;
    return try std.fmt.allocPrint(allocator, f_pattern, .{ directory, basename, version, extension });
}

test "as we go" {
    const known = "/Users/joachimpfefferkorn/repos/zools/src/test.zig";
    const version_me = "/Users/joachimpfefferkorn/Desktop/v_10.txt";
    print("version name: {s}\n", .{try addVersion(known)});
    print("updated: {s}\n", .{try addVersion(version_me)});
}

//Returns the next next file's name in versioning sequence
// pub fn versionName(path_string: []u8) FileError![]u8 {
//     if (!path.exists(path_string)) {
//         return path_string;
//     }
//
//     var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//     const allocator = gpa.allocator();
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
//     const output = std.fmt.allocPrint(allocator, "{s}/{s}_{d}.{s}", .{ base_path, basename, version_num, extension }) catch FileError.OutOfMemory;
//     //defer allocator.free(output);
//     return output;
// }
