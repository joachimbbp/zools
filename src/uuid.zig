const std = @import("std");
const random = std.crypto.random;
const eql = std.mem.eql;
const ArrayList = std.array_list.Managed;

//entirely random uuid
pub fn v4() [36]u8 {
    var result: [36]u8 = undefined;
    const hex_chars = "0123456789abcdef";

    var i: usize = 0;
    while (i < 36) {
        if ((i == 8) or (i == 13) or (i == 18) or (i == 23)) {
            result[i] = '-';
            i += 1;
        } else {
            result[i] = hex_chars[random.int(u4)];
            i += 1;
        }
    }
    return result;
}
