const std = @import("std");

pub const Parser = struct {
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
