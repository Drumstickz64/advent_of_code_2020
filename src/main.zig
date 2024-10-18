const std = @import("std");
const mem = std.mem;
const assert = @import("assert.zig").assert;

pub const std_options = .{
    .log_level = .info,
};

// const TEST_ANSWER = 820;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const ally = arena.allocator();

    var args = std.process.args();

    _ = args.skip();

    const is_test = if (args.next()) |is_test_str| std.mem.eql(u8, is_test_str, "test") else false;

    const input = if (is_test) try getInput("test_input.txt", ally) else try getInput("input.txt", ally);

    const answer = try solve(input, ally);

    const writer = std.io.getStdOut().writer();
    if (is_test) {
        // assert(answer == TEST_ANSWER, "answer is incorrect, expected '{d}', got '{d}'\n", .{ TEST_ANSWER, answer });
        try writer.print("answer = {d}, no way to test correctness\n", .{answer});
    } else {
        try writer.print("answer: {any}\n", .{answer});
    }
}

fn getInput(path: []const u8, ally: mem.Allocator) ![]u8 {
    return std.fs.cwd().readFileAlloc(ally, path, std.math.maxInt(usize));
}

fn solve(input: []const u8, ally: mem.Allocator) !u64 {
    var ids = std.ArrayList(u64).init(ally);

    var passes = std.mem.split(u8, input, "\n");
    while (passes.next()) |pass| {
        var row_start: u64 = 0;
        var row_end: u64 = 127;
        for (pass[0..7]) |char| {
            const len = row_end - row_start;
            if (char == 'F') {
                row_end = row_start + len / 2;
            } else {
                row_start = row_end - len / 2;
            }
        }

        const row = row_start;

        var col_start: u64 = 0;
        var col_end: u64 = 8;
        for (pass[7..]) |char| {
            const len = col_end - col_start;
            if (char == 'L') {
                col_end = col_start + len / 2;
            } else {
                col_start = col_end - len / 2;
            }
        }

        const col = col_start;

        const id = row * 8 + col;

        try ids.append(id);
    }

    std.mem.sort(
        u64,
        ids.items,
        {},
        comptime std.sort.asc(u64),
    );

    for (0..ids.items.len - 1) |i| {
        if (ids.items[i + 1] - ids.items[i] > 1) {
            return ids.items[i] + 1;
        }
    }

    unreachable;
}
