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
        const dot_i = std.mem.lastIndexOfScalar(u8, file, '.').?; //ROBOT:
        const base = file[0..dot_i];
        const ext = file[dot_i + 1 ..];
        return Parts{
            .directory = dir,
            .filename = file,
            .basename = base,
            .extension = ext,
        };
    }
};

test "parts" {
    const p = try Parts.init("/ham/spam/land/hello_5.vdb");

    std.debug.print(
        "directory: {s}\nfilename: {s}\nbasename: {s}\nextension: {s}\n",
        .{ p.directory, p.filename, p.basename, p.extension },
    );
}

//WARNING: presently this 1 indexes: 0 isn't treated as version number
pub fn versionName(filepath: []const u8, arena: std.mem.Allocator) !ArrayList(u8) {
    const version_delimiter = "_";
    const f_pattern = "{s}/{s}_{d}.{s}";
    var output = ArrayList(u8).init(arena);

    if (!try exists(filepath)) {
        //  print("path does not exist: {s}\n", .{filepath});
        for (filepath) |c| {
            try output.append(c);
        }
        return output;
    }
    const parts = try Parts.init(filepath, arena);

    var version: u32 = 1;
    var prefix: []const u8 = undefined;
    var version_split = std.mem.splitBackwardsSequence(u8, parts.basename, version_delimiter);

    const possible_version_number = version_split.first();
    if (string.isInteger(possible_version_number)) {
        version = try std.fmt.parseInt(u32, possible_version_number, 10) + 1;
        prefix = version_split.rest();
    } else {
        version_split.reset();
        prefix = version_split.rest();
    }

    var result: []const u8 = try std.fmt.allocPrint(arena, f_pattern, .{ parts.directory, prefix, version, parts.extension });

    if (try exists(result)) {
        result = (try versionName(result, arena)).items;
    }

    for (result) |c| {
        try output.append(c);
    }
    arena.deinit();
    return output;
}
