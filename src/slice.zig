const std = @import("std");

pub fn reverse(
    comptime T: type,
    input_slice: []const T,
    alloc: std.mem.Allocator,
) !std.array_list.Managed(T) {
    var res = std.array_list.Managed(T).init(alloc);
    var i = input_slice.len;
    while (i > 0) {
        i -= 1;
        try res.append(input_slice[i]);
    }
    return res;
}

test "reversing slices" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa_alloc = gpa.allocator();
    defer _ = gpa.deinit();
    const nums = [_]usize{ 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    const rev_nums = try reverse(usize, &nums, gpa_alloc);
    defer rev_nums.deinit();
    std.debug.print("◀️ Reversed nums: {any}\n", .{rev_nums.items});
}
