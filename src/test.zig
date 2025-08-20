const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;

const iter = @import("iter.zig");
const path = @import("path.zig");
const dir = @import("dir.zig");

test "u8 splitBackwardsIterator counting" {
    const five_parts = std.mem.splitBackwardsScalar(u8, "the_quick_brown_fox_jumped", '_');
    const one_part = std.mem.splitBackwardsScalar(u8, "hamspamland", '_');
    const csv = std.mem.splitBackwardsScalar(u8, "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,", ',');

    try expect(iter.len(five_parts) == 5);
    try expect(iter.len(one_part) == 1);
    try expect(iter.len(csv) == 21);
}
test "path exists" {
    try expect(!path.exists("hd998e9db-f335-4499-91e0-cb941fdeed3/home"));
    try expect(path.exists("./test.zig"));
}

test "build directory if absent" {
    //Look at the src folder. You should see "./temp" appear for one second only
    const dummy_check_time: u64 = 1 * std.time.ns_per_s;
    const temp_folder = "./temp";
    try dir.buildIfAbsent(temp_folder);
    try expect(path.exists(temp_folder));
    std.time.sleep(dummy_check_time);
    try std.fs.cwd().deleteTree(temp_folder);
}
