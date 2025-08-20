const std = @import("std");
const path = @import("path.zig");
const iter = @import("iter.zig");
const splitBackwardsScalar = std.mem.SplitBackwardsScalar;

const FileError = error{
    PathDoesNotExist,
    InvalidExtensionNumber,
};

pub fn saveVersion(path_string: []const u8) FileError!void {
    const gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer gpa.deini();

    if (!path.exists(path_string)) {
        return FileError.PathDoesNotExist;
    } else {
        var path_split = splitBackwardsScalar(u8, path_string, '/');
        const filename = path_split.first();
        const base_path = path_split.rest();
        var fname_split = splitBackwardsScalar(u8, filename, '.');
        if (iter.len(fname_split) != 2) {
            return FileError.InvalidExtensionNumber;
        }
        const extension = fname_split.first();
        const basename = fname_split.next().?;

        var version_split = splitBackwardsScalar(u8, filename, '_');
        const version_num = version_split.first();

        var first_version = false;
        for (version_num) |c| {
            if ((c < 0) or (c > 9)) {
                //Version does not exist
                first_version = true;
                break;
            }
        }

        if (!first_version) {}
        const version = 10;
        const output = try std.fmt.allocPrint(allocator, "{s}/{s}.{s}_{d}", .{ base_path, basename, extension, version });
        defer allocator.free(output);
    }
}
