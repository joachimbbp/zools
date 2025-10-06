const std = @import("std");

//s is a struct
//Does not work for nested structs
pub fn fromSimpleStruct(s: anytype) void {
    //reutnr will be: ![]const u8
    const T = @TypeOf(s);
    const info = @typeInfo(T).@"struct";

    //    var csv: std.array_list.Managed(u8) = undefined;
    inline for (info.fields) |field| {
        const value = @field(s, field.name);
        //debug print for now
        //TODO: Char8s format as letters if given the option
        std.debug.print("{s} = {any}\n", .{ field.name, value });
        //TODO: actually append this to a csv: even is key and odd is value
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

    fromSimpleStruct(big);
}
