const std = @import("std");
const Parser = @import("parser.zig").Parser;

pub fn main() !void {
    var args = std.process.args();
    _ = args.skip();

    const is_test = if (args.next()) |is_test_str| std.mem.eql(u8, is_test_str, "test") else false;

    const input = if (is_test) try getInput("test_input.txt") else try getInput("input.txt");

    const answer = try solve(input);
    const writer = std.io.getStdOut().writer();
    try writer.print("answer: {any}\n", .{answer});
}

fn getInput(path: []const u8) ![]u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    return std.fs.cwd().readFileAlloc(ally, path, std.math.maxInt(usize));
}

fn solve(input: []const u8) !u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();

    var lines = std.mem.splitScalar(u8, input, '\n');

    var entries = std.ArrayList(Entry).init(ally);
    defer entries.deinit();

    while (lines.next()) |line| {
        const entry = try Entry.parse(line);
        try entries.append(entry);
    }

    var validEntryCount: u64 = 0;
    for (entries.items) |entry| {
        const pos1Matches = entry.password[entry.policy.positions[0]] == entry.policy.char;
        const pos2Matches = entry.password[entry.policy.positions[1]] == entry.policy.char;
        if ((pos1Matches and !pos2Matches) or (!pos1Matches and pos2Matches)) {
            validEntryCount += 1;
        }
    }

    return validEntryCount;
}

const Entry = struct {
    policy: Policy,
    password: []const u8,

    pub fn parse(entry_str: []const u8) !Entry {
        var parser = Parser{ .str = entry_str };

        const pos1 = try parser.nextInt(usize);
        try parser.expect('-');
        const pos2 = try parser.nextInt(usize);
        try parser.expect(' ');
        const char = parser.next().?;
        try parser.expect(':');
        try parser.expect(' ');
        const password = parser.remainder();

        return Entry{
            .policy = Policy{
                .char = char,
                // turn from 1 based to 0 based
                .positions = .{ pos1 - 1, pos2 - 1 },
            },
            .password = password,
        };
    }
};

const Policy = struct {
    char: u8,
    positions: [2]usize,
};
