const std = @import("std");
const utils = @import("utils.zig");

// ---------------------------------------------------

const Symbol = struct {
    x: usize,
    y: usize,
    c: u8,
};

const Range = struct {
    xMin: usize,
    xMax: usize,
    y: usize,

    fn isAdjacent(self: @This(), p: Symbol) bool {
        const px = std.math.cast(isize, p.x) orelse unreachable;
        const py = std.math.cast(isize, p.y) orelse unreachable;
        const xMin = (std.math.cast(isize, self.xMin) orelse unreachable);
        const xMax = (std.math.cast(isize, self.xMax) orelse unreachable);
        const y_ = std.math.cast(isize, self.y) orelse unreachable;

        const isXAdjacent = px >= xMin - 1 and px <= xMax + 1;
        const isYAdjacent = py >= y_ - 1 and py <= y_ + 1;
        return isXAdjacent and isYAdjacent;
    }
};

const Number = struct {
    val: usize,
    pos: Range,
};

fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

fn parseSymbols(symbols: *std.ArrayList(Symbol), sequence: []const u8, y: usize) void {
    for (sequence, 0..) |c, i| {
        if (c != '.' and !isDigit(c)) {
            symbols.append(.{ .x = i, .y = y, .c = c }) catch unreachable;
        }
    }
}

fn parseNumbers(numbers: *std.ArrayList(Number), sequence: []const u8, y: usize) void {
    var xMin: usize = 0;
    var val: usize = 0;

    var i: usize = 0;
    for (sequence) |c| {
        if (isDigit(c)) {
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
    var i: usize = 0;
    while (it.next()) |line| {
        parseSymbols(symbols, line, i);
        parseNumbers(numbers, line, i);
        i += 1;
    }
}

fn partOne(allocator: std.mem.Allocator, sequence: []const u8) usize {
    var symbols = std.ArrayList(Symbol).init(allocator);
    defer symbols.deinit();

    var numbers = std.ArrayList(Number).init(allocator);
    defer numbers.deinit();

    parseSchematic(&symbols, &numbers, sequence);

    var result: usize = 0;
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

fn partTwo(allocator: std.mem.Allocator, sequence: []const u8) usize {
    var symbols = std.ArrayList(Symbol).init(allocator);
    defer symbols.deinit();

    var numbers = std.ArrayList(Number).init(allocator);
    defer numbers.deinit();

    parseSchematic(&symbols, &numbers, sequence);

    var result: usize = 0;
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
    var allocator = std.heap.page_allocator;
    const data = try utils.readFile(&allocator, "res/d03.txt");
    defer allocator.free(data);

    std.debug.print("part one : {d}\n", .{partOne(allocator, data)});
    std.debug.print("part two : {d}\n", .{partTwo(allocator, data)});
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
