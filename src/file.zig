const std = @import("std");
const path = @import("path.zig");
const iter = @import("iter.zig");
const string = @import("string.zig");
const print = std.debug.print;
const expect = std.testing.expect;
const ArrayList = std.array_list.Managed;

const FileError = error{
    ExtensionError,
};

//Returns path with updated version number, <file_#.ext>, if a file exists at this path
pub fn addVersion(filepath: []const u8, alloc: std.mem.Allocator) !ArrayList(u8) {
    //NOTE: not sure if ArrayList appends and joins are the best way to go about this...
    //Might be nice for this to return a []const u8 if possible?
    const v_sep = "_";
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

    const v_split = try string.split(basename, v_sep, alloc);
    defer v_split.deinit();
    const prefix = try std.mem.join(alloc, v_sep, v_split.items[0 .. v_split.items.len - 1]);
    defer alloc.free(prefix);
    const suffix = v_split.items[v_split.items.len - 1];
    var version: u32 = 1;

    if (string.isInteger(suffix)) {
        version = try std.fmt.parseInt(u32, suffix, 10) + 1;
    }

    const result = try std.fmt.allocPrint(alloc, f_pattern, .{ directory, prefix, version, extension });
    defer alloc.free(result);

    for (result) |c| {
        try output.append(c);
    }

    return output;
}

test "as we go" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();

    var dir = try std.fs.cwd().openDir("../test_files/", .{ .iterate = true });
    defer dir.close();

    var walker = try dir.walk(alloc);
    defer walker.deinit();

    while (try walker.next()) |entry| {
        const filepath = try std.fmt.allocPrint(alloc, "/{s}/{s}", .{ entry.path, entry.basename });
        //TODO:
        //Okay this is a cwd() issue! this will require some fixing
        //MAIN: you are *adding* the numbers, not replacing them!
        defer alloc.free(filepath);
        print("filepath: {s}\n", .{filepath});
        const versioned = try addVersion(filepath, alloc);
        print("updated: {s}\n \n", .{versioned.items});
        defer versioned.deinit();
    }

    const version_me = "/Users/joachimpfefferkorn/Desktop/v_10.txt";
    const versioned = try addVersion(version_me, alloc);
    defer versioned.deinit();
    print("updated: {s}\n", .{versioned.items});
}
