const std = @import("std");

pub fn main() !void {
    var args = std.process.args();
    _ = args.skip();
    const part_str = args.next() orelse return error.PartNotProvided;
    const part = try std.fmt.parseInt(u8, part_str, 10);

    const is_test = if (args.next()) |is_test_str| std.mem.eql(u8, is_test_str, "test") else false;

    const input = if (is_test) try getInput("test_input.txt") else try getInput("input.txt");

    switch (part) {
        1 => part1(input),
        2 => part2(input),
        else => return error.IncorrectPart,
    }
}

fn getInput(path: []const u8) ![]u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    return std.fs.cwd().readFileAlloc(ally, path, std.math.maxInt(usize));
}

fn part1(input: []const u8) void {
    std.debug.print("part 1, input: {s}\n", .{input});
}

fn part2(input: []const u8) void {
    std.debug.print("part 2, input: {s}\n", .{input});
}
