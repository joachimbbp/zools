//NOTE: must run from the project root, not src
//should run as: <zig test src/testing.zig>

const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
const sleep = std.Thread.sleep;

const iter = @import("iter.zig");
const path = @import("path.zig");
const dir = @import("dir.zig");
//const file = @import("file.zig");
const string = @import("string.zig");

const one_sec: u64 = 1 * std.time.ns_per_s;

const test_dir = "./test_files_2b31fe56-0219-4e02-84d7-b113a2b19bd8";

//fn clear_test_files(){}

test "path exists" {
    //TODO: build custom folders so this doesn't need to run from the root
    try expect(!path.exists("hd998e9db-f335-4499-91e0-cb941fdeed3/home"));
    try expect(path.exists("./src/testing.zig"));
    try expect(path.exists(test_dir));
}

test "build directory if absent" {
    //Look at the src folder. You should see "./temp" appear for one second only
    const temp_folder = "./temp";
    try dir.buildIfAbsent(temp_folder);
    try expect(path.exists(temp_folder));
    sleep(one_sec);
    try std.fs.cwd().deleteTree(temp_folder);
}

test "splitting" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const csv_string = "0,1,2,3,4,5,6,7,8,9,10";
    const csv_list = try string.split(csv_string, ",", allocator);
    defer csv_list.deinit();
    try std.testing.expectEqual(@as(usize, 11), csv_list.items.len);
    try std.testing.expect(std.mem.eql(u8, csv_list.items[10], "10"));
}
test "is number" {
    try expect(string.isInteger("42"));
    try expect(string.isInteger("0"));
    try expect(!string.isInteger("ham"));
}

test "ls" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const a = arena.allocator();

    const list = try path.ls("/Users/joachimpfefferkorn/repos/zools/test_files", a);
    defer list.deinit();
    for (0..list.items.len) |n| {
        print("item: {s}\n", .{list.items[n]});
    }

    // const item = try path.ls("/Users/joachimpfefferkorn/repos/zools/test_files/ham.txt", a);
    // defer item.deinit();
    // print("item: {s}\n", .{item.items[0]});
}
test "versioning" {
    //NOTE: this test particularly could use a lot of work

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();
    //probably need to run from root, not src

    const version_me = "/Users/joachimpfefferkorn/Desktop/v_10.txt";
    const versioned = try path.addVersion(version_me, alloc);
    defer versioned.deinit();
    print("versioned: {s}\n \n \n", .{versioned.items});

    const first_version = "/Users/joachimpfefferkorn/Desktop/ham.txt";
    const first_versioned = try path.addVersion(first_version, alloc);
    defer first_versioned.deinit();
    print("first versioned: {s}\n \n \n", .{first_versioned.items});

    const version_with_underscore = "/Users/joachimpfefferkorn/Desktop/v_with_under_59.txt";
    const versioned_alt = try path.addVersion(version_with_underscore, alloc);
    defer versioned_alt.deinit();
    print("alt: {s}\n \n \n", .{versioned_alt.items});

    // const ds_store = "/Users/joachimpfefferkorn/Desktop/.Ds_store";
    // const ds_stored = try addVersion(ds_store, alloc);
    // defer ds_stored.deinit();
    // print("ds store test {s}", .{ds_stored.items});
}
//TODO: build test files programatically
