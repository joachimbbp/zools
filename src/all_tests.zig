//NOTE: must run from the project root, not src
//should run as: <zig test src/testing.zig>

const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
const sleep = std.Thread.sleep;

const iter = @import("iter.zig");
const path = @import("path.zig");
const dir = @import("dir.zig");
const string = @import("string.zig");

const one_sec: u64 = 1 * std.time.ns_per_s;

const test_dir_1 = "./test_files_2b31fe56-0219-4e02-84d7-b113a2b19bd8";
const test_dir_2 = "./temp_folder_797ceaa5-ad8d-4085-918f-173b82e9e2ef";
const test_files_csv = "ham.txt,spam.txt,version_me_41.txt,land.txt";

const helpers = @import("test_helpers.zig");

//PATH STUFF:
test "files and paths" {
    //random UUID path does not exist
    try expect(!path.exists("hd998e9db-f335-4499-91e0-cb941fdeed3/home"));

    //clear test_dir_1 if its still around
    if (path.exists(test_dir_1)) {
        try std.fs.cwd().deleteTree(test_dir_1);
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    var arena_alloc = std.heap.ArenaAllocator.init(alloc);
    defer arena_alloc.deinit();
    const arena = arena_alloc.allocator(); //wow that is confusing naming!

    //build test paths, deinit and delete at the end of this test
    const test_paths = try helpers.test_paths(test_dir_1, test_files_csv, alloc);
    defer test_paths.deinit();

    const list = try path.ls(test_dir_1, arena);
    defer list.deinit();

    for (0..list.items.len) |n| {
        const item = list.items[n];
        try expect(path.exists(item));
        print("Item {s} exists\n", .{item});
        const versioned = try path.addVersion(list.items[n], alloc);
        defer versioned.deinit(); //alloc.free(versioned);
        print("Item {s} versioned name is {s}\n", .{ item, versioned.items });
        //TODO: [ ] save versions here (function not implemented yet)
    }
    print("Look at the project root to see the files created\n", .{});
    sleep(one_sec * 3);

    try expect(!try dir.buildIfAbsent(test_dir_1));
    print("Test dir exists at {s}\n     no new dir created", .{test_dir_1});

    try expect(try dir.buildIfAbsent(test_dir_2));
    print("Second test dir created at the root. Take a look before it disappears in 3 seconds\n", .{});
    sleep(one_sec * 3);
    try std.fs.cwd().deleteTree(test_dir_2);

    try std.fs.cwd().deleteTree(test_dir_1);
}
// //STRING STUFF
// test "splitting" {
//     var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//     defer _ = gpa.deinit();
//     const allocator = gpa.allocator();
//
//     const csv_string = "0,1,2,3,4,5,6,7,8,9,10";
//     const csv_list = try string.split(csv_string, ",", allocator);
//     defer csv_list.deinit();
//     try std.testing.expectEqual(@as(usize, 11), csv_list.items.len);
//     try std.testing.expect(std.mem.eql(u8, csv_list.items[10], "10"));
// }
// //MISC STUFF
// test "is number" {
//     try expect(string.isInteger("42"));
//     try expect(string.isInteger("0"));
//     try expect(!string.isInteger("ham"));
// }
//
// //TODO: build test files programatically
