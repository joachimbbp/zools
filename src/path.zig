const std = @import("std");
const iter = @import("iter.zig");
const string = @import("string.zig");
const debug = @import("debug.zig");
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
        //        print("abs: {s}\n", .{abs});
        try output.append(abs);
    }
    return output;
}

pub fn versionName(filepath: []const u8, alloc: std.mem.Allocator) !ArrayList(u8) {
    const version_delimiter = "_";
    const f_pattern = "{s}/{s}_{d}.{s}";
    var output = ArrayList(u8).init(alloc);

    if (!try exists(filepath)) {
        //  print("path does not exist: {s}\n", .{filepath});
        for (filepath) |c| {
            try output.append(c);
        }
        return output;
    }
    var path_segments = std.mem.splitBackwardsSequence(u8, filepath, "/");
    const filename = path_segments.first();

    var path_segment_list = ArrayList([]const u8).init(alloc);
    while (path_segments.next()) |segment| {
        if (std.mem.eql(u8, segment, ".")) continue;
        try path_segment_list.append(segment);
    }
    const directory = try std.mem.join(alloc, "/", path_segment_list.items);
    path_segment_list.deinit();
    defer alloc.free(directory);

    var filename_segments = std.mem.splitSequence(u8, filename, ".");
    if (iter.len(filename_segments) != 2) {
        return PathError.ExtensionError;
    }

    const basename = filename_segments.first();
    const extension = filename_segments.rest();

    //filebasename ... any underscores ... version number
    var version_split = std.mem.splitBackwardsSequence(u8, basename, version_delimiter);

    var version: u32 = 1;
    var prefix: []const u8 = undefined;

    const possible_version_number = version_split.first();
    if (string.isInteger(possible_version_number)) {
        version = try std.fmt.parseInt(u32, possible_version_number, 10) + 1;
        prefix = version_split.rest();
    } else {
        version_split.reset();
        prefix = version_split.rest();
    }

    //print("directory: {s}\nprefix: {s}\nversion: {d}\nexteionsion: {s}\n", .{ directory, prefix, version, extension });
    const result = try std.fmt.allocPrint(alloc, f_pattern, .{ directory, prefix, version, extension });
    defer alloc.free(result);

    for (result) |c| {
        try output.append(c);
    }
    return output;
}
