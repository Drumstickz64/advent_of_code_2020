const std = @import("std");

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
        const count = std.mem.count(u8, entry.password, &[_]u8{entry.policy.char});
        if (entry.policy.min <= count and count <= entry.policy.max) {
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

        const min = try parser.nextInt(u32);
        try parser.expect('-');
        const max = try parser.nextInt(u32);
        try parser.expect(' ');
        const char = parser.next().?;
        try parser.expect(':');
        try parser.expect(' ');
        const password = parser.remainder();

        return Entry{
            .policy = Policy{
                .min = min,
                .max = max,
                .char = char,
            },
            .password = password,
        };
    }
};

const Policy = struct {
    char: u8,
    min: u32,
    max: u32,
};

const Parser = struct {
    str: []const u8,
    curr: usize = 0,

    pub fn nextInt(self: *Parser, comptime T: type) !T {
        const start = self.curr;

        while (self.peek()) |char| {
            if (!std.ascii.isDigit(char)) {
                break;
            }

            _ = self.next();
        }

        return std.fmt.parseInt(T, self.str[start..self.curr], 10);
    }

    pub fn remainder(self: *Parser) []const u8 {
        return self.str[self.curr..];
    }

    pub fn expect(self: *Parser, expected: u8) !void {
        if (self.next() != expected) {
            return error.ExpectMismatch;
        }
    }

    pub fn next(self: *Parser) ?u8 {
        if (self.curr >= self.str.len) {
            return null;
        }

        self.curr += 1;
        return self.str[self.curr - 1];
    }

    pub fn peek(self: *Parser) ?u8 {
        if (self.curr >= self.str.len) {
            return null;
        }

        return self.str[self.curr];
    }
};
