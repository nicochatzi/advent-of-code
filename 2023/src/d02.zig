const std = @import("std");
const utils = @import("utils.zig");

const Dice = struct {
    r: usize,
    g: usize,
    b: usize,

    fn fromSingle(sequence: []const u8) Dice {
        var dice = Dice{ .r = 0, .g = 0, .b = 0 };

        var it = std.mem.tokenizeSequence(u8, sequence, ",");
        while (it.next()) |token| {
            const trimmed = std.mem.trim(u8, token, " ");
            var colorIt = std.mem.tokenizeSequence(u8, trimmed, " ");
            const num = colorIt.next() orelse unreachable;
            const color = colorIt.next() orelse unreachable;
            const count = std.fmt.parseInt(usize, num, 10) catch unreachable;

            if (std.mem.eql(u8, color, "red")) {
                dice.r = count;
            } else if (std.mem.eql(u8, color, "green")) {
                dice.g = count;
            } else if (std.mem.eql(u8, color, "blue")) {
                dice.b = count;
            }
        }

        return dice;
    }

    fn fromLine(sequence: []const u8) Dice {
        var it = std.mem.tokenizeSequence(u8, sequence, ";");
        var result: Dice = .{ .r = 0, .g = 0, .b = 0 };
        while (it.next()) |line| {
            result = Dice.fromSingle(line).max(result);
        }
        return result;
    }

    fn contains(self: @This(), other: Dice) bool {
        return self.r >= other.r and self.g >= other.g and self.b >= other.b;
    }

    fn max(self: @This(), other: Dice) Dice {
        return .{ .r = @max(self.r, other.r), .g = @max(self.g, other.g), .b = @max(self.b, other.b) };
    }

    fn power(self: @This()) usize {
        return self.r * self.g * self.b;
    }
};

fn parseId(sequence: []const u8) usize {
    var it = std.mem.tokenizeSequence(u8, sequence, " ");
    while (it.next()) |word| {
        return std.fmt.parseInt(usize, word, 10) catch continue;
    }
    unreachable;
}

const Result = struct {
    id: usize,
    dice: Dice,

    fn fromLine(sequence: []const u8) Result {
        var it = std.mem.tokenizeSequence(u8, sequence, ":");
        const id = parseId(it.next() orelse unreachable);
        const dice = Dice.fromLine(it.next() orelse unreachable);
        return .{ .id = id, .dice = dice };
    }
};

fn partOne(sequence: []const u8, max: Dice) usize {
    var sum: usize = 0;
    var it = std.mem.tokenizeSequence(u8, sequence, "\n");
    while (it.next()) |line| {
        const result = Result.fromLine(line);
        if (max.contains(result.dice)) {
            sum += result.id;
        }
    }
    return sum;
}

fn partTwo(sequence: []const u8) usize {
    var sum: usize = 0;
    var it = std.mem.tokenizeSequence(u8, sequence, "\n");
    while (it.next()) |line| {
        const result = Result.fromLine(line);
        sum += result.dice.power();
    }
    return sum;
}

pub fn main() !void {
    var allocator = std.heap.page_allocator;
    const data = try utils.readFile(&allocator, "res/d02.txt");
    defer allocator.free(data);

    const max = Dice{ .r = 12, .g = 13, .b = 14 };
    std.debug.print("part one : {d}\n", .{partOne(data, max)});
    std.debug.print("part two : {d}\n", .{partTwo(data)});
}

test Dice {
    try std.testing.expectEqual(Dice.fromSingle(" 3 blue, 4 red"), .{ .r = 4, .g = 0, .b = 3 });
    try std.testing.expectEqual(Dice.fromSingle(" 2 green, 6 blue, 30 red"), .{ .r = 30, .g = 2, .b = 6 });

    {
        const dice = Dice.fromLine("3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green");
        try std.testing.expectEqual(dice, .{ .r = 4, .g = 2, .b = 6 });
        try std.testing.expectEqual(dice.power(), 48);
    }
    {
        const dice = Dice.fromLine("1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue");
        try std.testing.expectEqual(dice, .{ .r = 1, .g = 3, .b = 4 });
        try std.testing.expectEqual(dice.power(), 12);
    }
    {
        const dice = Dice.fromLine("8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red");
        try std.testing.expectEqual(dice, .{ .r = 20, .g = 13, .b = 6 });
        try std.testing.expectEqual(dice.power(), 1560);
    }
}

test Result {
    try std.testing.expectEqual(
        Result.fromLine("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"),
        .{ .id = 1, .dice = .{ .r = 4, .g = 2, .b = 6 } },
    );
}

test partOne {
    const data =
        \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    ;
    const max: Dice = .{ .r = 12, .g = 13, .b = 14 };
    try std.testing.expectEqual(partOne(data, max), 8);
}

test partTwo {
    const data =
        \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    ;
    try std.testing.expectEqual(partTwo(data), 2286);
}
