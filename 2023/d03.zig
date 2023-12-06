const std = @import("std");

// ---------------------------------------------------

const Symbol = struct {
    x: isize,
    y: isize,
    c: u8,
};

const Range = struct {
    xMin: isize,
    xMax: isize,
    y: isize,

    fn isAdjacent(self: @This(), p: Symbol) bool {
        const isXAdjacent = p.x >= self.xMin - 1 and p.x <= self.xMax + 1;
        const isYAdjacent = p.y >= self.y - 1 and p.y <= self.y + 1;
        return isXAdjacent and isYAdjacent;
    }
};

const Number = struct {
    val: isize,
    pos: Range,
};

fn parseSymbols(symbols: *std.ArrayList(Symbol), sequence: []const u8, y: isize) void {
    for (sequence, 0..) |c, i| {
        if (c != '.' and !std.ascii.isDigit(c)) {
            const i_ = std.math.cast(isize, i) orelse unreachable;
            symbols.append(.{ .x = i_, .y = y, .c = c }) catch unreachable;
        }
    }
}

fn parseNumbers(numbers: *std.ArrayList(Number), sequence: []const u8, y: isize) void {
    var xMin: isize = 0;
    var val: isize = 0;

    var i: isize = 0;
    for (sequence) |c| {
        if (std.ascii.isDigit(c)) {
            if (val == 0) xMin = i;
            val = val * 10 + (c - '0');
        } else if (val != 0) {
            numbers.append(.{ .val = val, .pos = .{ .xMin = xMin, .xMax = i - 1, .y = y } }) catch unreachable;
            val = 0;
        }
        i += 1;
    }

    if (val != 0) {
        numbers.append(.{ .val = val, .pos = .{ .xMin = xMin, .xMax = i - 1, .y = y } }) catch unreachable;
    }
}

fn parseSchematic(symbols: *std.ArrayList(Symbol), numbers: *std.ArrayList(Number), sequence: []const u8) void {
    var it = std.mem.tokenizeSequence(u8, sequence, "\n");
    var i: isize = 0;
    while (it.next()) |line| : (i += 1) {
        parseSymbols(symbols, line, i);
        parseNumbers(numbers, line, i);
    }
}

fn partOne(allocator: std.mem.Allocator, sequence: []const u8) isize {
    var symbols = std.ArrayList(Symbol).init(allocator);
    defer symbols.deinit();

    var numbers = std.ArrayList(Number).init(allocator);
    defer numbers.deinit();

    parseSchematic(&symbols, &numbers, sequence);

    var result: isize = 0;
    for (numbers.items) |number| {
        for (symbols.items) |point| {
            if (number.pos.isAdjacent(point)) {
                result += number.val;
                break;
            }
        }
    }
    return result;
}

fn partTwo(allocator: std.mem.Allocator, sequence: []const u8) isize {
    var symbols = std.ArrayList(Symbol).init(allocator);
    defer symbols.deinit();

    var numbers = std.ArrayList(Number).init(allocator);
    defer numbers.deinit();

    parseSchematic(&symbols, &numbers, sequence);

    var result: isize = 0;
    for (symbols.items) |symbol| {
        if (symbol.c != '*') {
            continue;
        }

        var neighbour: ?Number = null;
        for (numbers.items) |number| {
            if (!number.pos.isAdjacent(symbol)) {
                continue;
            }
            if (neighbour != null) {
                result += number.val * neighbour.?.val;
                break;
            }
            neighbour = number;
        }
    }
    return result;
}

// ---------------------------------------------------

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const data = @embedFile("res/d03.txt");

    var timer = try std.time.Timer.start();
    std.debug.print("one : {d}\ntime : {}\n\n", .{
        partOne(allocator, data),
        std.fmt.fmtDuration(timer.lap()),
    });
    std.debug.print("two : {d}\ntime : {}\n\n", .{
        partTwo(allocator, data),
        std.fmt.fmtDuration(timer.read()),
    });
}

// ---------------------------------------------------

test Range {
    const expect = std.testing.expect;

    const range = Range{ .xMin = 1, .xMax = 3, .y = 1 };
    try expect(range.isAdjacent(.{ .x = 0, .y = 0, .c = 0 }));
    try expect(range.isAdjacent(.{ .x = 0, .y = 1, .c = 0 }));
    try expect(range.isAdjacent(.{ .x = 1, .y = 1, .c = 0 }));
    try expect(range.isAdjacent(.{ .x = 2, .y = 1, .c = 0 }));
    try expect(range.isAdjacent(.{ .x = 3, .y = 2, .c = 0 }));
    try expect(range.isAdjacent(.{ .x = 4, .y = 1, .c = 0 }));
    try expect(range.isAdjacent(.{ .x = 4, .y = 2, .c = 0 }));
    try expect(!range.isAdjacent(.{ .x = 4, .y = 3, .c = 0 }));
    try expect(!range.isAdjacent(.{ .x = 2, .y = 3, .c = 0 }));
    try expect(!range.isAdjacent(.{ .x = 1, .y = 4, .c = 0 }));
    try expect(!range.isAdjacent(.{ .x = 5, .y = 1, .c = 0 }));
}

test partOne {
    const expectEqual = std.testing.expectEqual;

    const data =
        \\467..114..
        \\...*......
        \\..35..633.
        \\......#...
        \\617*......
        \\.....+.58.
        \\..592.....
        \\......755.
        \\...$.*....
        \\.664.598..
        \\........20
        \\........*.
    ;

    try expectEqual(partOne(std.heap.page_allocator, data), 4361 + 20);
}

test partTwo {
    const expectEqual = std.testing.expectEqual;

    const data =
        \\467..114..
        \\...*......
        \\..35..633.
        \\......#...
        \\617*......
        \\.....+.58.
        \\..592.....
        \\......755.
        \\...$.*....
        \\.664.598..
        \\........20
        \\........*.
    ;

    try expectEqual(partTwo(std.heap.page_allocator, data), 467835);
}
