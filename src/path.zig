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

pub fn exists(path: []const u8) bool {
    _ = std.fs.cwd().openFile(path, .{}) catch {
        //WARNING: blunt instrument, not fully covered, clean this guy up!
        return false;
    };
    return true;
}

// Returns true only if the path is to a folder
//TODO: isDir function
//Separate basename function would be used many places

// Lists all the files in a directory
pub fn ls(path: []const u8, alloc: std.mem.Allocator) !ArrayList([]u8) {
    if (!exists(path)) {
        return PathError.PathDoesNotExist;
    }
    var dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    defer dir.close();
    var output = ArrayList([]u8).init(alloc);

    var walker = try dir.walk(alloc);
    defer walker.deinit();

    while (try walker.next()) |entry| {
        const abs = try entry.dir.realpathAlloc(alloc, entry.path);

        try output.append(abs);
    }
    return output;
}

pub fn addVersion(filepath: []const u8, alloc: std.mem.Allocator) !ArrayList(u8) {
    const v_sep = "_";
    const f_pattern = "{s}/{s}_{d}.{s}";
    var output = ArrayList(u8).init(alloc);

    if (!exists(filepath)) {
        print("path does not exist: {s}\n \n", .{filepath});
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
        return PathError.ExtensionError;
    }
    const basename = filename_split.items[0];
    const extension = filename_split.items[1];

    //filebasename ... any underscores ... version number
    const v_split = try string.split(basename, v_sep, alloc);
    defer v_split.deinit();

    var prefix_chop: u1 = 0;
    const suffix = v_split.items[v_split.items.len - 1];
    var version: u32 = 1;

    if (string.isInteger(suffix)) {
        version = try std.fmt.parseInt(u32, suffix, 10) + 1;
        prefix_chop = 1;
    } else {}
    const prefix = try std.mem.join(alloc, v_sep, v_split.items[0 .. v_split.items.len - prefix_chop]);
    defer alloc.free(prefix);

    const result = try std.fmt.allocPrint(alloc, f_pattern, .{ directory, prefix, version, extension });
    defer alloc.free(result);

    for (result) |c| {
        try output.append(c);
    }
    return output;
}
