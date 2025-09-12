const std = @import("std");
const iter = @import("iter.zig");
const debug = @import("debug.zig");
const string = @import("string.zig");
const print = std.debug.print;
const ArrayList = std.array_list.Managed;

const PathError = error{
    PathDoesNotExist,
    ExtensionError,
};

pub fn exists(path: []const u8) !bool {
    const local = std.fs.cwd();
    _ = std.fs.Dir.access(local, path, .{}) catch |err| {
        if (err == std.posix.AccessError.FileNotFound) {
            return false;
        } else {
            return err;
        }
    };
    return true;
}

// Lists all the files in a directory
pub fn ls(path: []const u8, alloc: std.mem.Allocator) !ArrayList([]u8) {
    if (!try exists(path)) {
        return PathError.PathDoesNotExist;
    }
    var dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    defer dir.close();
    var output = ArrayList([]u8).init(alloc);

    var walker = try dir.walk(alloc);
    defer walker.deinit();

    while (try walker.next()) |entry| {
        const abs = try std.fmt.allocPrint(alloc, "{s}/{s}", .{ path, entry.basename });
        try output.append(abs);
    }
    return output;
}
pub const Parts = struct {
    directory: []const u8,
    filename: []const u8,
    basename: []const u8,
    extension: []const u8,
    pub fn init(filepath: []const u8) !Parts {
        const dir = std.fs.path.dirname(filepath).?;
        const file = std.fs.path.basenamePosix(filepath);
        const dot_i = std.mem.lastIndexOfScalar(u8, file, '.'); //ROBOT:
        var base: []const u8 = undefined;
        var ext: []const u8 = undefined;
        if (dot_i == null) {
            //No file extension, probably a directory
            ext = "";
            //thus no "basename" either
            base = "";
        } else {
            base = file[0..dot_i.?];
            ext = file[dot_i.? + 1 ..];
        }
        return Parts{
            .directory = dir,
            .filename = file, //WARN: might be weird for dirs
            .basename = base,
            .extension = ext,
        };
    }
};

//WARNING: presently this 1 indexes: 0 isn't treated as version number
pub fn versionName(path_string: []const u8, arena: std.mem.Allocator, is_dir: bool) !ArrayList(u8) {
    const version_delimiter = "_";
    var output = ArrayList(u8).init(arena);

    if (!try exists(path_string)) { //WARN: Not sure if this works for dir
        for (path_string) |c| {
            try output.append(c);
        }
        return output;
    }
    const parts = try Parts.init(path_string);

    var version: u32 = 1;
    var prefix: []const u8 = undefined;

    var version_split = if (is_dir) //ROBOT: suggested pattern
        std.mem.splitBackwardsSequence(u8, path_string, version_delimiter)
    else
        std.mem.splitBackwardsSequence(u8, parts.basename, version_delimiter);
    // var version_split: std.mem.SplitIterator = undefined;
    // if (is_dir) {
    //     version_split = std.mem.splitBackwardsSequence(u8, path_string, version_delimiter, true);
    // } else {
    //     version_split = std.mem.splitBackwardsSequence(u8, parts.basename, version_delimiter, false);
    // }
    const possible_version_number = version_split.first();
    if (string.isInteger(possible_version_number)) {
        version = try std.fmt.parseInt(u32, possible_version_number, 10) + 1;
        prefix = version_split.rest();
    } else {
        version_split.reset();
        prefix = version_split.rest();
    }

    var result: []const u8 = undefined;
    if (is_dir) {
        result = try std.fmt.allocPrint(arena, "{s}_{d}", .{ path_string, version });
    } else {
        result = try std.fmt.allocPrint(arena, "{s}/{s}_{d}.{s}", .{ parts.directory, prefix, version, parts.extension });
    }
    if (try exists(result)) {
        result = (try versionName(result, arena, is_dir)).items;
    }

    for (result) |c| {
        try output.append(c);
    }
    arena.free(result);
    return output;
}
