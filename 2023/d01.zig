const std = @import("std");

fn findDigitInChar(char: u8) ?u8 {
    return switch (char) {
        '0'...'9' => char - '0',
        else => null,
    };
}

fn parseDigitsInLine(line: []const u8) u8 {
    var first: ?u8 = null;
    var digit: u8 = 0;

    for (line) |c| {
        digit = findDigitInChar(c) orelse continue;
        if (first == null) {
            first = digit;
        }
    }

    return (first orelse digit) * 10 + digit;
}

fn findDigitInString(string: []const u8) ?u8 {
    const digits = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

    for (digits, 0..) |digit, i| {
        if (std.mem.containsAtLeast(u8, string, 1, digit)) {
            return @intCast(i + 1);
        }
    }

    return null;
}

fn parseWordsInLine(line: []const u8) u8 {
    var first: ?u8 = null;
    var digit: u8 = 0;

    var l: usize = 0;
    for (0..line.len) |r| {
        digit = findDigitInChar(line[r]) orelse findDigitInString(line[l .. r + 1]) orelse continue;
        if (first == null) {
            first = digit;
        }
        l = r;
    }

    return (first orelse digit) * 10 + digit;
}

fn run(comptime processLine: fn ([]const u8) u8, sequence: []const u8) u32 {
    var sum: u32 = 0;
    var it = std.mem.splitSequence(u8, sequence, "\n");
    while (it.next()) |line| {
        sum += processLine(line);
    }
    return sum;
}

fn partOne(seqeuence: []const u8) u32 {
    return run(parseDigitsInLine, seqeuence);
}

fn partTwo(seqeuence: []const u8) u32 {
    return run(parseWordsInLine, seqeuence);
}

pub fn main() !void {
    const data = @embedFile("res/d01.txt");
    var timer = try std.time.Timer.start();
    std.debug.print("one : {d}\ntime : {}\n\n", .{
        partOne(data),
        std.fmt.fmtDuration(timer.lap()),
    });
    std.debug.print("two : {d}\ntime : {}\n\n", .{
        partTwo(data),
        std.fmt.fmtDuration(timer.read()),
    });
}

test parseDigitsInLine {
    try std.testing.expectEqual(parseDigitsInLine("1abc2"), 12);
    try std.testing.expectEqual(parseDigitsInLine("pqr3stu8vwx"), 38);
    try std.testing.expectEqual(parseDigitsInLine("a1b2c3d4e5f"), 15);
    try std.testing.expectEqual(parseDigitsInLine("treb7uchet"), 77);
}

test partOne {
    const data =
        \\1abc2
        \\pqr3stu8vwx
        \\a1b2c3d4e5f
        \\treb7uchet
    ;
    try std.testing.expectEqual(partOne(data), 142);
}

test parseWordsInLine {
    try std.testing.expectEqual(parseWordsInLine("two1nine"), 29);
    try std.testing.expectEqual(parseWordsInLine("eightwothree"), 83);
    try std.testing.expectEqual(parseWordsInLine("abcone2threexyz"), 13);
    try std.testing.expectEqual(parseWordsInLine("xtwone3four"), 24);
    try std.testing.expectEqual(parseWordsInLine("4nineeightseven2"), 42);
    try std.testing.expectEqual(parseWordsInLine("zoneight234"), 14);
    try std.testing.expectEqual(parseWordsInLine("7pqrstsixteen"), 76);
}

test partTwo {
    const data =
        \\two1nine
        \\eightwothree
        \\abcone2threexyz
        \\xtwone3four
        \\4nineeightseven2
        \\zoneight234
        \\7pqrstsixteen
    ;
    try std.testing.expectEqual(partTwo(data), 281);
}
