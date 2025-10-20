const std = @import("std");

// Takes a simple non nested structs and returns a csv
// even indices are the names, odds are the values
// Does not work for nested structs
// Quotes "must have \"propper escape chars\" around the double quotes"
//WARN: possible edge case: you read in a " right from disk into a struct and then yeet it into memory
// That might break this so you'll want to sanitize those after reading!
pub fn fromSimpleStruct(alloc: std.mem.Allocator, s: anytype) ![]u8 { //LLM: This was a full Claude rewrite
    var csv = std.array_list.Managed(u8).init(alloc);
    const T = @TypeOf(s);
    const info = @typeInfo(T).@"struct";
    inline for (info.fields) |field| {
        try csv.appendSlice(field.name);
        try csv.append(',');
        const raw_value = @field(s, field.name);
        const FieldType = @TypeOf(raw_value);
        const type_info = @typeInfo(FieldType);

        // Handle optionals first
        if (type_info == .optional) {
            if (raw_value) |value| {
                const ValueType = @TypeOf(value);
                // Check if the unwrapped optional is a string
                if (comptime std.mem.eql(u8, @typeName(ValueType), "[]const u8")) {
                    const ascii_value = try std.fmt.allocPrint(alloc, "\"{s}\"", .{value});
                    try csv.appendSlice(ascii_value);
                    alloc.free(ascii_value);
                } else {
                    const ascii_value = try std.fmt.allocPrint(alloc, "{any}", .{value});
                    try csv.appendSlice(ascii_value);
                    alloc.free(ascii_value);
                }
            } else {
                try csv.appendSlice("null");
            }
            try csv.append(',');
        }
        // Handle regular strings
        else if (comptime std.mem.eql(u8, @typeName(FieldType), "[]const u8")) {
            const ascii_value = try std.fmt.allocPrint(alloc, "\"{s}\"", .{raw_value});
            try csv.appendSlice(ascii_value);
            alloc.free(ascii_value);
            try csv.append(',');
        }
        // Handle arrays
        else if (type_info == .array) {
            const ArrayInfo = type_info.array;
            // If it's an array of u8, treat it as a string
            if (ArrayInfo.child == u8) {
                // Find null terminator or use full length
                const len = std.mem.indexOfScalar(u8, &raw_value, 0) orelse raw_value.len;
                const ascii_value = try std.fmt.allocPrint(alloc, "\"{s}\"", .{raw_value[0..len]});
                try csv.appendSlice(ascii_value);
                alloc.free(ascii_value);
            } else {
                // For other array types, print as array
                const ascii_value = try std.fmt.allocPrint(alloc, "{any}", .{raw_value});
                try csv.appendSlice(ascii_value);
                alloc.free(ascii_value);
            }
            try csv.append(','); // ADD THIS
        }
        // Handle everything else
        else {
            const ascii_value = try std.fmt.allocPrint(alloc, "{any}", .{raw_value});
            try csv.appendSlice(ascii_value);
            alloc.free(ascii_value);
            try csv.append(',');
        }
    }
    return csv.toOwnedSlice();
}

//TESTING:
pub const SimpleTestStruct = struct {
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
    const big = SimpleTestStruct{
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
