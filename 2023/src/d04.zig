const std = @import("std");
const utils = @import("utils.zig");

fn cardIteratorFromLine(line: []const u8) std.mem.TokenIterator(u8, .sequence) {
    var sectionIt = std.mem.tokenizeSequence(u8, line, ":");
    _ = sectionIt.next() orelse unreachable;
    return std.mem.tokenizeSequence(u8, sectionIt.next() orelse unreachable, "|");
}

fn parseWinningNumbers(numbers: *std.AutoHashMap(usize, usize), sequence: []const u8) !void {
    var it = std.mem.tokenizeSequence(u8, sequence, " ");
    while (it.next()) |n| {
        const num = try std.fmt.parseInt(usize, n, 10);
        try numbers.put(num, 0);
    }
}

fn partOne(allocator: std.mem.Allocator, sequence: []const u8) !usize {
    var lineIt = std.mem.tokenizeSequence(u8, sequence, "\n");

    var winningNumbers = std.AutoHashMap(usize, usize).init(allocator);
    defer winningNumbers.deinit();

    var result: usize = 0;
    while (lineIt.next()) |line| {
        var cardsIt = cardIteratorFromLine(line);

        winningNumbers.clearRetainingCapacity();
        try parseWinningNumbers(&winningNumbers, cardsIt.next() orelse unreachable);

        var lineResult: usize = 0;
        var it = std.mem.tokenizeSequence(u8, cardsIt.next() orelse unreachable, " ");
        while (it.next()) |n| {
            const num = try std.fmt.parseInt(usize, n, 10);
            if (winningNumbers.get(num) != null) {
                lineResult = if (lineResult == 0) 1 else lineResult * 2;
            }
        }

        result += lineResult;
    }
    return result;
}

fn partTwo(allocator: std.mem.Allocator, sequence: []const u8) !usize {
    var lineIt = std.mem.tokenizeSequence(u8, sequence, "\n");

    var cards = std.AutoHashMap(usize, usize).init(allocator);
    defer cards.deinit();

    var winningNumbers = std.AutoHashMap(usize, usize).init(allocator);
    defer winningNumbers.deinit();

    var largestWinningCard: usize = 0;
    var lineNum: usize = 0;
    while (lineIt.next()) |line| {
        var cardsIt = cardIteratorFromLine(line);
        _ = try cards.getOrPutValue(lineNum, 1);

        winningNumbers.clearRetainingCapacity();
        try parseWinningNumbers(&winningNumbers, cardsIt.next() orelse unreachable);

        var matches: usize = 0;
        var it = std.mem.tokenizeSequence(u8, cardsIt.next() orelse unreachable, " ");
        while (it.next()) |n| {
            const num = try std.fmt.parseInt(usize, n, 10);
            if (winningNumbers.get(num) != null) {
                matches += 1;
            }
        }

        if (matches == 0 and lineNum > largestWinningCard) {
            break;
        }

        if (matches != 0) {
            largestWinningCard = lineNum + matches + 1;
        }

        const numInstancesOfCard = cards.get(lineNum) orelse unreachable;
        for (0..numInstancesOfCard) |_| {
            for (0..matches) |n| {
                var card = try cards.getOrPutValue(lineNum + n + 1, 1);
                card.value_ptr.* += 1;
            }
        }

        lineNum += 1;
    }

    var result: usize = 0;
    var it = cards.iterator();
    while (it.next()) |card| {
        result += cards.get(card.key_ptr.*) orelse unreachable;
    }
    return result;
}

pub fn main() !void {
    var allocator = std.heap.page_allocator;
    const data = try utils.readFile(&allocator, "res/d04.txt");
    defer allocator.free(data);

    std.debug.print("part one : {d}\n", .{try partOne(allocator, data)});
    std.debug.print("part two : {d}\n", .{try partTwo(allocator, data)});
}

test partOne {
    const data =
        \\Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        \\Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        \\Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        \\Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        \\Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        \\Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    ;
    try std.testing.expectEqual(partOne(std.heap.page_allocator, data), 13);
}

test partTwo {
    const data =
        \\Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        \\Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        \\Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        \\Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        \\Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        \\Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    ;
    try std.testing.expectEqual(partTwo(std.heap.page_allocator, data), 30);
}
