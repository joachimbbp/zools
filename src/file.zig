const std = @import("std");
const path = @import("path.zig");
const iter = @import("iter.zig");
const print = std.debug.print;
const expect = std.testing.expect;
const FileError = error{
    PathDoesNotExist,
    InvalidExtensionNumber,
    OutOfMemory,
    ParseError,
};
pub fn versionName(file_path: []u8) []u8 {
    if (!path.exists(file_path)) {
        return file_path;
    }
    print("filepath: {s}\n", .{file_path});
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
