const std = @import("std");

pub fn assert(cond: bool, comptime format: []const u8, args: anytype) void {
    if (!cond) {
        std.debug.panic(format, args);
    }
}
