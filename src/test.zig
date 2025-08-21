const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;

const iter = @import("iter.zig");
const path = @import("path.zig");
const dir = @import("dir.zig");
const file = @import("file.zig");
const string = @import("string.zig");

const one_sec: u64 = 1 * std.time.ns_per_s;

test "u8 splitBackwardsIterator counting" {
    const five_parts = std.mem.splitBackwardsScalar(u8, "the_quick_brown_fox_jumped", '_');
    const one_part = std.mem.splitBackwardsScalar(u8, "hamspamland", '_');
    const csv = std.mem.splitBackwardsScalar(u8, "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,", ',');

    try expect(iter.len(five_parts) == 5);
    try expect(iter.len(one_part) == 1);
    try expect(iter.len(csv) == 21);
}
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
    std.time.sleep(one_sec);
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
