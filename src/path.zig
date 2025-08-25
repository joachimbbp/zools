const std = @import("std");
const iter = @import("iter.zig");
const print = std.debug.print;
const ArrayList = std.array_list.Managed;

const PathError = error{
    PathDoesNotExist,
};

pub fn exists(path: []const u8) bool {
    _ = std.fs.cwd().openFile(path, .{}) catch {
        return false;
    };
    return true;
}

//TODO:
//Separate basename function would be used many places

// Lists all the files in a directory
// If input is not a directory, it simply returns the input (like the unix ls command)
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

        //        print("path: {s} from original {s}\n", .{ abs, path });
        try output.append(abs);
    }
    return output;
}
