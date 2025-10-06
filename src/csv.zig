const std = @import("std");

//s is a struct
//Does not work for nested structs
pub fn fromSimpleStruct(s: anytype) !void {
    const T = @TypeOf(s);
    const info = @typeInfo(T).@"struct";

    inline for (info.fields) |field| {
        const value = @field(s, field.name);
        if (comptime std.mem.eql(u8, @typeName(@TypeOf(value)), "[]const u8")) {
            std.debug.print("{s} = {s}\n", .{ field.name, value }); //problem here
            std.debug.print("       type of value: {s}\n", .{@typeName(@TypeOf(value))});
        } else {
            std.debug.print("{s} = {any}\n", .{ field.name, value });
            std.debug.print("       type of value: {s}\n", .{@typeName(@TypeOf(value))});
        }
    }
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
        .d = "hello",
        .e = .{ 1, 2, 3, 4, 5 },
        .f = null,
        .g = "optional string",
        .i = .{ 0.1, 0.2, 0.3 },
        .k = 255,
        .l = "zig struct test",
        .m = false,
        .n = .{ 10, 20 },
        .o = 0.5,
    };

    try fromSimpleStruct(big);
}
