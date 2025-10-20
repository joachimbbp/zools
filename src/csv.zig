const std = @import("std");

// Takes a simple non nested structs and returns a csv
// even indices are the names, odds are the values
// Does not work for nested structs
// Quotes "must have \"propper escape chars\" around the double quotes"
//WARN: possible edge case: you read in a " right from disk into a struct and then yeet it into memory
// That might break this so you'll want to sanitize those after reading!
pub fn fromSimpleStruct(alloc: std.mem.Allocator, s: anytype) ![]u8 {
    var csv = std.array_list.Managed(u8).init(alloc);

    const T = @TypeOf(s);
    const info = @typeInfo(T).@"struct";

    inline for (info.fields) |field| {
        try csv.appendSlice(field.name);
        try csv.append(',');
        const raw_value = @field(s, field.name);
        if (comptime std.mem.eql(u8, @typeName(@TypeOf(raw_value)), "[]const u8")) {
            const ascii_value = try std.fmt.allocPrint(alloc, "\"{s}\"", .{raw_value});
            for (ascii_value) |c| {
                try csv.append(c);
            }
            try csv.append(',');
            alloc.free(ascii_value);
        } else {
            const ascii_value = try std.fmt.allocPrint(alloc, "{any}", .{raw_value});
            for (ascii_value) |c| {
                try csv.append(c);
            }
            try csv.append(',');
            alloc.free(ascii_value);
        }
    }
    return csv.toOwnedSlice();
}

//TESTING:
pub const SimpleStruct = struct {
    a: i32,
    b: bool,
    c: f64,
    d: []const u8,
    e: [5]u8,
    f: ?i16,
    g: ?[]const u8,
    i: [3]f32,
    k: u8,
    l: []const u8,
    m: bool,
    n: [2]i32,
    o: ?f32,
};

test "from struct" {
    const big = SimpleStruct{
        .a = 123,
        .b = true,
        .c = 3.14159,
        .d = "hello world",
        .e = .{ 1, 2, 3, 4, 5 },
        .f = null,
        .g = "MR. Has Commas, MD, oh no!",
        .i = .{ 0.1, 0.2, 0.3 },
        .k = 255,
        .l = "Here, someone decided to \"quote\" something!",
        .m = false,
        .n = .{ 10, 20 },
        .o = 0.5,
    };
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa_alloc = gpa.allocator();
    defer _ = gpa.deinit();

    const test_csv = try fromSimpleStruct(gpa_alloc, big);
    defer gpa_alloc.free(test_csv);
    std.debug.print("test CSV:\n{s}", .{test_csv});
}
