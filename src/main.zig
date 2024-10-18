const std = @import("std");
const mem = std.mem;

pub const std_options = .{
    .log_level = .info,
};

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
    _ = ally; // autofix
    var validPasswordCount: u64 = 0;

    var passports = mem.split(u8, input, "\n\n");
    while (passports.next()) |passport| {
        std.log.debug("passport = {s}\n", .{passport});
        var creds = Creds{};

        var fields = mem.splitAny(u8, passport, "\n ");
        while (fields.next()) |field| {
            std.log.debug("field = {s}\n", .{field});

            var it = mem.split(u8, field, ":");
            const field_name = it.next().?;
            const field_value = it.next().?;
            std.log.debug("field: name = {s}, value = {s}\n", .{ field_name, field_value });

            // zig fmt: off
            if (mem.eql(u8, field_name, "byr") and Creds.isValidBirthYear(field_value)) creds.birth_year = true
            else if (mem.eql(u8, field_name, "iyr") and Creds.isValidIssueYear(field_value)) creds.issue_year = true
            else if (mem.eql(u8, field_name, "eyr") and Creds.isValidExpirationYear(field_value)) creds.expiration_year = true
            else if (mem.eql(u8, field_name, "hgt") and Creds.isValidHeight(field_value)) creds.height = true
            else if (mem.eql(u8, field_name, "hcl") and Creds.isValidHairColor(field_value)) creds.hair_color = true
            else if (mem.eql(u8, field_name, "ecl") and Creds.isValidEyeColor(field_value)) creds.eye_color = true
            else if (mem.eql(u8, field_name, "pid") and Creds.isValidPassportId(field_value)) creds.passport_id = true
            else if (mem.eql(u8, field_name, "cid")) {}
            else {
                std.log.debug("invalid field: {s}", .{field});
                break;
            }
            // zig fmt: on
        }

        if (creds.allPresent()) {
            validPasswordCount += 1;
        }
    }

    return validPasswordCount;
}

const Creds = struct {
    birth_year: bool = false,
    issue_year: bool = false,
    expiration_year: bool = false,
    height: bool = false,
    hair_color: bool = false,
    eye_color: bool = false,
    passport_id: bool = false,

    pub fn allPresent(self: *const Creds) bool {
        const fields = comptime blk: {
            const info = @typeInfo(@TypeOf(self.*));
            const fields = info.Struct.fields;
            var names: [fields.len][]const u8 = undefined;
            for (0.., fields) |i, field| {
                names[i] = field.name;
            }

            break :blk names;
        };

        inline for (fields) |field| {
            if (!@field(self, field)) {
                return false;
            }
        }

        return true;
    }

    pub fn isValidBirthYear(value: []const u8) bool {
        return Creds.isValidNumber(value, 4, 1920, 2002);
    }

    pub fn isValidIssueYear(value: []const u8) bool {
        return Creds.isValidNumber(value, 4, 2010, 2020);
    }

    pub fn isValidExpirationYear(value: []const u8) bool {
        return Creds.isValidNumber(value, 4, 2020, 2030);
    }

    pub fn isValidHeight(value: []const u8) bool {
        if (value.len < 3) {
            return false;
        }

        if (std.mem.endsWith(u8, value, "in")) {
            return Creds.isValidNumber(value[0 .. value.len - 2], 2, 59, 76);
        }

        if (std.mem.endsWith(u8, value, "cm")) {
            return Creds.isValidNumber(value[0 .. value.len - 2], 3, 150, 193);
        }

        return false;
    }

    pub fn isValidHairColor(value: []const u8) bool {
        if (value[0] != '#') {
            return false;
        }

        _ = std.fmt.parseInt(u32, value[1..], 16) catch return false;
        return true;
    }

    pub fn isValidEyeColor(value: []const u8) bool {
        return (std.mem.eql(u8, value, "amb") or
            std.mem.eql(u8, value, "blu") or
            std.mem.eql(u8, value, "brn") or
            std.mem.eql(u8, value, "gry") or
            std.mem.eql(u8, value, "grn") or
            std.mem.eql(u8, value, "hzl") or
            std.mem.eql(u8, value, "oth"));
    }

    pub fn isValidPassportId(value: []const u8) bool {
        if (value.len != 9) {
            return false;
        }

        for (value) |char| {
            if (!std.ascii.isDigit(char)) {
                return false;
            }
        }

        return true;
    }

    fn isValidNumber(value: []const u8, char_count: usize, min_value: u32, max_value: u32) bool {
        if (value.len != char_count) {
            return false;
        }

        const num = std.fmt.parseInt(u32, value, 10) catch return false;
        return min_value <= num and num <= max_value;
    }
};
