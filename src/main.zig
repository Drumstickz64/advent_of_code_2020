const std = @import("std");
const mem = std.mem;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    defer std.debug.assert(gpa.deinit() == .ok);

    var args = std.process.args();

    _ = args.skip();

    const is_test = if (args.next()) |is_test_str| std.mem.eql(u8, is_test_str, "test") else false;

    const input = if (is_test) try getInput("test_input.txt", ally) else try getInput("input.txt", ally);
    defer ally.free(input);

    const answer = try solve(input, ally);
    const writer = std.io.getStdOut().writer();
    try writer.print("answer: {any}\n", .{answer});
}

fn getInput(path: []const u8, ally: mem.Allocator) ![]u8 {
    return std.fs.cwd().readFileAlloc(ally, path, std.math.maxInt(usize));
}

fn solve(input: []const u8, ally: mem.Allocator) !u64 {
    var forrest = try Forrest.parse(input, ally);
    defer forrest.deinit(ally);

    const paths = [5][2]usize{
        .{ 1, 1 },
        .{ 3, 1 },
        .{ 5, 1 },
        .{ 7, 1 },
        .{ 1, 2 },
    };

    var result: u64 = 1;
    for (paths) |path| {
        var treesHit: u64 = 0;
        var x: usize = 0;
        var y: usize = 0;
        while (!forrest.reachedEnd(y)) {
            if (forrest.hasTree(x, y)) {
                treesHit += 1;
            }

            x += path[0];
            y += path[1];
        }

        result *= treesHit;
    }

    return result;
}

const Forrest = struct {
    trees: []bool,
    width: usize,
    height: usize,

    pub fn parse(str: []const u8, ally: mem.Allocator) !Forrest {
        var trees = std.ArrayList(bool).init(ally);
        var width: usize = 0;
        for (0.., str) |i, char| {
            if (char == '\n') {
                if (width == 0) {
                    width = i;
                }

                continue;
            }

            const tree = char == '#';
            try trees.append(tree);
        }

        return Forrest{
            .width = width,
            .height = trees.items.len / width,
            .trees = try trees.toOwnedSlice(),
        };
    }

    pub fn deinit(self: *Forrest, ally: mem.Allocator) void {
        ally.free(self.trees);
    }

    pub fn hasTree(self: *Forrest, x: usize, y: usize) bool {
        const looped_x = x % self.width;
        return self.trees[looped_x + y * self.width];
    }

    pub fn reachedEnd(self: *Forrest, y: usize) bool {
        return y >= self.height;
    }
};
