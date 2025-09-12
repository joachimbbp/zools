//NOTE: must run from the project root, not src
//should run as: <zig test src/testing.zig>

const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
const sleep = std.Thread.sleep;
const ArrayList = std.array_list.Managed;

const iter = @import("iter.zig");
const path = @import("path.zig");
const save = @import("save.zig");
const string = @import("string.zig");
const debug = @import("debug.zig");
const uuid = @import("uuid.zig");
//this quick switch determines whether or not your temp folders
//stay alive for a second to view them in the finder
const spot_check = false;
const clear_at_end = true;
const one_sec: u64 = 1 * std.time.ns_per_s;

const test_dir_1 = "./test_files_2b31fe56-0219-4e02-84d7-b113a2b19bd8";
const test_dir_2 = "./temp_folder_797ceaa5-ad8d-4085-918f-173b82e9e2ef";
const test_files_csv = "ham.txt,spam.txt,version_me_41.txt,land.txt";

const helpers = @import("test_helpers.zig");

test "hello and debug" {
    debug.helloZools();
}

//PATH STUFF:
test "files and paths" {
    //random UUID path does not exist
    try expect(!try path.exists("hd998e9db-f335-4499-91e0-cb941fdeed3/home"));

    //clear test_dir_1 if its still around
    if (try path.exists(test_dir_1)) {
        try std.fs.cwd().deleteTree(test_dir_1);
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    var arena_alloc = std.heap.ArenaAllocator.init(alloc);
    defer arena_alloc.deinit();
    const arena = arena_alloc.allocator(); //wow that is confusing naming!

    //build test paths, deinit and delete at the end of this test
    try helpers.buildTestPaths(test_dir_1, test_files_csv, alloc);
    //check your test directory exists
    try expect(try path.exists(test_dir_1));
    //Appears that a non-local path works as well (commenting out for other users)
    //    try expect(try path.exists("/Users/joachimpfefferkorn/Desktop/select weirdness.mov"));
    print("\n", .{});

    const list = try path.ls(test_dir_1, arena);
    defer list.deinit();
    var dummy_buffer = ArrayList(u8).init(alloc);
    defer dummy_buffer.deinit();
    for ("lorem ipsum") |c| {
        try dummy_buffer.append(c);
    }
    for (0..list.items.len) |n| {
        const item = list.items[n];
        try expect(try path.exists(item));
        print("🐛 Item {s} exists\n", .{item});
        const versioned = try save.version(list.items[n], dummy_buffer, arena);
        defer versioned.deinit();
        print("🦋 Item {s} versioned as {s}\n", .{ item, versioned.items });
    }
    //try back with some previous versions
    const v1 = try save.version(list.items[0], dummy_buffer, arena);
    defer v1.deinit();
    const v2 = try save.version(list.items[list.items.len - 1], dummy_buffer, arena);
    defer v2.deinit();
    if (spot_check) {
        print("👁️ Look at the project root to see the files created\n", .{});
        sleep(one_sec * 3);
    }
    try expect(!try save.dirIfAbsent(test_dir_1));
    print("🗺️ Test dir exists at {s}\n     no new dir created\n", .{test_dir_1});

    try expect(try save.dirIfAbsent(test_dir_2));
    if (spot_check) {
        print("🫜 Second test dir created at the root. Take a look before it disappears in 3 seconds\n", .{});
        sleep(one_sec * 3);
        try std.fs.cwd().deleteTree(test_dir_2);
    }
    if (clear_at_end) {
        try std.fs.cwd().deleteTree(test_dir_1);
        try std.fs.cwd().deleteTree(test_dir_2);
    }
}
test "strings" {
    print("🎻 testing strings\n", .{});
    const csv_string = "0,1,2,3,4,5,6,7,8,9,10";
    var csv_iter = std.mem.splitSequence(u8, csv_string, ",");
    print("csv iter debug: {d}\n", .{csv_iter.index.?});
    var i: usize = 0;
    while (csv_iter.next()) |value| : (i += 1) {
        print("     🪕value {s} should equal index {d}\n", .{ value, i });
        try std.testing.expectEqual(std.fmt.parseInt(usize, value, 10), i);
    }

    try expect(string.isInteger("42"));
    try expect(string.isInteger("0"));
    try expect(!string.isInteger("ham"));
}

test "parts" {
    const p = try path.Parts.init("/ham/spam/land/hello_5.vdb");

    std.debug.print(
        "directory: {s}\nfilename: {s}\nbasename: {s}\nextension: {s}\n",
        .{ p.directory, p.filename, p.basename, p.extension },
    );
}

test "sequence" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const folder = "./seq_8f3e45ea-824e-47b8-b405-35b1584caa27";
    if (try path.exists(folder)) {
        try std.fs.cwd().deleteTree(folder);
    }
    print("🎥 saving a sequence\n", .{});

    _ = try save.dirIfAbsent(folder);

    var current = ArrayList(u8).init(alloc);
    defer current.deinit();
    const ap = try std.fmt.allocPrint(alloc, "{s}/{s}", .{ folder, "frame.txt" });
    defer alloc.free(ap);
    try current.appendSlice(ap);
    var dummy_buffer = ArrayList(u8).init(alloc);
    defer dummy_buffer.deinit();
    for ("Image Sequence\n") |c| {
        try dummy_buffer.append(c);
    }
    for (0..24) |_| {
        for ("Another Frame\n") |c| {
            try dummy_buffer.append(c);
        }
        const next = try save.version(current.items, dummy_buffer, alloc);
        print("     🎞️ version: {s}\n", .{next.items});
        current.deinit();
        current = next;
    }
    if (spot_check) {
        print("🎬 sequence saved. Test folder will stay for 3 seconds\n", .{});
        sleep(one_sec * 3);
    }
    if (clear_at_end) {
        try std.fs.cwd().deleteTree(folder); //too lazy to not hard code this
    }
}

test "UUID" {
    print("🎲 ten, totally random UUIDs (UUID Version 4):\n", .{});
    for (0..10) |_| {
        std.debug.print("      🪪 {s}\n", .{uuid.v4()});
    }
}
test "end" {
    print("🏁Tests have ended\n", .{});
}

