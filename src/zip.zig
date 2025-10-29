const std = @import("std");

// mirror's python's zip function
pub fn pairs(
    comptime T1: type,
    comptime T2: type,
    a: []const T1,
    b: []const T2,
    alloc: std.mem.Allocator,
) !std.array_list.Managed(struct { T1, T2 }) {
    var res = std.array_list.Managed(struct { T1, T2 }).init(alloc);
    const len = @min(a.len, b.len);
    for (0..len) |i| {
        try res.append(.{ a[i], b[i] });
    }
    return res;
}

test "zip pairs" {
    std.debug.print("👯 zipping pairs test\n", .{});
    const a = [_][*:0]const u8{ "and", "band", "canned", "d", "e" };
    const b = [_]usize{ 2, 4, 6, 8, 10, 11 };
    //NOTE: 11 or anything above the shared min is discarded
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa_alloc = gpa.allocator();
    defer _ = gpa.deinit();

    const res = try pairs(
        [*:0]const u8,
        usize,
        &a,
        &b,
        gpa_alloc,
    );
    defer res.deinit();
    //ROBOT: claude built loop
    for (res.items) |pair| {
        std.debug.print("result: {s}, {d}\n", .{ pair[0], pair[1] });
    }
}
