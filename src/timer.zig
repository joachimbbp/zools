const std = @import("std");
const time = std.time;
const print = std.debug.print;

// Records the time in microseconds
pub fn Click() i64 {
    return time.microTimestamp();
}
// Returns and prints the difference between the current and given time
pub fn Stop(start_time: i64) void {
    const now = time.microTimestamp();
    const elapsed = now - start_time;
    const seconds = @divTrunc(elapsed, time.us_per_s);
    print("⏱️ {d} seconds\n", .{seconds});
    print("         exact microseconds: {d}\n", .{elapsed});
}

test "timers" {
    print("timer test:\n", .{});
    const start = Click();
    defer Stop(start);
    std.Thread.sleep(3333000);
}
