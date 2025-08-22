//Last successful run was zig version 0.14.1

const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
const sleep = std.Thread.sleep;

const iter = @import("iter.zig");
const path = @import("path.zig");
const dir = @import("dir.zig");
const file = @import("file.zig");
const string = @import("string.zig");

const one_sec: u64 = 1 * std.time.ns_per_s;

test "path exists" {
    //TODO: build custom folders so this doesn't need to run from the root
    try expect(!path.exists("hd998e9db-f335-4499-91e0-cb941fdeed3/home"));
    try expect(path.exists("./test.zig"));
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
