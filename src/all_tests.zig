//NOTE: must run from the project root, not src
//should run as: <zig test src/testing.zig>

const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
const sleep = std.Thread.sleep;

const iter = @import("iter.zig");
const path = @import("path.zig");
const save = @import("save.zig");
const string = @import("string.zig");
const debug = @import("debug.zig");
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
    print("\n", .{});

    const list = try path.ls(test_dir_1, arena);
    defer list.deinit();

    for (0..list.items.len) |n| {
        const item = list.items[n];
        try expect(try path.exists(item));
        print("🐛 Item {s} exists\n", .{item});
        const versioned = try path.versionName(list.items[n], alloc);
        defer versioned.deinit(); //alloc.free(versioned);
        print("🦋 Item {s} versioned name is {s}\n", .{ item, versioned.items });
        //TODO: [ ] save versions here (function not implemented yet)
    }
    print("👁️ Look at the project root to see the files created\n", .{});
    sleep(one_sec * 3);

    try expect(!try save.dirIfAbsent(test_dir_1));
    print("🗺️ Test dir exists at {s}\n     no new dir created\n", .{test_dir_1});

    try expect(try save.dirIfAbsent(test_dir_2));
    print("🫜 Second test dir created at the root. Take a look before it disappears in 3 seconds\n", .{});
    sleep(one_sec * 3);
    try std.fs.cwd().deleteTree(test_dir_2);

    try std.fs.cwd().deleteTree(test_dir_1);
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
