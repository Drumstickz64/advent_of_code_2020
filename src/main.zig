const std = @import("std");

pub fn main() !void {
    var args = std.process.args();
    _ = args.skip();
    const part_str = args.next() orelse return error.PartNotProvided;
    const part = try std.fmt.parseInt(u8, part_str, 10);

    const is_test = if (args.next()) |is_test_str| std.mem.eql(u8, is_test_str, "test") else false;

    const input = if (is_test) try getInput("test_input.txt") else try getInput("input.txt");

    switch (part) {
        1 => try part1(input),
        2 => try part2(input),
        else => return error.IncorrectPart,
    }
}

fn getInput(path: []const u8) ![]u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    return std.fs.cwd().readFileAlloc(ally, path, std.math.maxInt(usize));
}

fn part1(input: []const u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();

    var lines = std.mem.splitScalar(u8, input, '\n');

    var numbers = std.ArrayList(i32).init(ally);
    defer numbers.deinit();

    while (lines.next()) |line| {
        const number: i32 = try std.fmt.parseInt(i32, line, 10);
        try numbers.append(number);
    }

    for (0..numbers.items.len - 1) |i| {
        for (i..numbers.items.len) |j| {
            if (numbers.items[i] + numbers.items[j] == 2020) {
                const stdout = std.io.getStdOut().writer();
                try stdout.print("answer: {d}\n", .{numbers.items[i] * numbers.items[j]});
                return;
            }
        }
    }
}

fn part2(input: []const u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();

    var lines = std.mem.splitScalar(u8, input, '\n');

    var numbers = std.ArrayList(i32).init(ally);
    defer numbers.deinit();

    while (lines.next()) |line| {
        const number: i32 = try std.fmt.parseInt(i32, line, 10);
        try numbers.append(number);
    }

    for (0..numbers.items.len - 2) |i| {
        for (i..numbers.items.len - 1) |j| {
            for (j..numbers.items.len) |k| {
                if (numbers.items[i] + numbers.items[j] + numbers.items[k] == 2020) {
                    const stdout = std.io.getStdOut().writer();
                    try stdout.print("answer: {d}\n", .{numbers.items[i] * numbers.items[j] * numbers.items[k]});
                    return;
                }
            }
        }
    }
}
