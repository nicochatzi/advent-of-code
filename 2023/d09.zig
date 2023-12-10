const std = @import("std");

fn all_zero(sequence: []const isize) bool {
    for (sequence) |value| if (value != 0) return false;
    return true;
}

fn build_diff(sequence: []const isize) !std.ArrayList(isize) {
    var result = std.ArrayList(isize).init(std.heap.page_allocator);
    var i: usize = 0;
    while (i < sequence.len - 1) : (i += 1)
        try result.append(sequence[i + 1] - sequence[i]);
    return result;
}

fn build_diffs(sequence: []const isize) !std.ArrayList(std.ArrayList(isize)) {
    var stack = std.ArrayList(std.ArrayList(isize)).init(std.heap.page_allocator);
    var first = std.ArrayList(isize).init(std.heap.page_allocator);
    try first.appendSlice(sequence);
    try stack.append(first);

    while (!all_zero(stack.getLast().items))
        try stack.append(try build_diff(stack.getLast().items));

    try stack.items[stack.items.len - 1].append(0);
    return stack;
}

fn extrapolate1(sequence: []const isize) !isize {
    var diffs = try build_diffs(sequence);

    const len: isize = @intCast(diffs.items.len);
    var i: isize = len - 2;
    while (i >= 0) : (i -= 1) {
        const i_: usize = @intCast(i);
        var list = &diffs.items[i_];
        var next = &diffs.items[i_ + 1];
        const step = list.getLast() + next.getLast();
        try diffs.items[i_].append(step);
    }

    return diffs.items[0].getLast();
}

fn extrapolate2(sequence: []const isize) !isize {
    var diffs = try build_diffs(sequence);

    const len: isize = @intCast(diffs.items.len);
    var i: isize = len - 2;
    while (i >= 0) : (i -= 1) {
        const i_: usize = @intCast(i);
        var curr = &diffs.items[i_];
        var next = &diffs.items[i_ + 1];
        const step = curr.items[0] - next.items[0];
        try curr.insert(0, step);
    }

    return diffs.items[0].items[0];
}

fn parse(sequence: []const u8) !std.ArrayList(std.ArrayList(isize)) {
    var results = std.ArrayList(std.ArrayList(isize)).init(std.heap.page_allocator);
    var it = std.mem.tokenizeSequence(u8, sequence, "\n");
    while (it.next()) |line| {
        var numbers = std.ArrayList(isize).init(std.heap.page_allocator);
        var token_it = std.mem.tokenizeSequence(u8, line, " ");
        while (token_it.next()) |token|
            try numbers.append(try std.fmt.parseInt(isize, token, 10));
        try results.append(numbers);
    }
    return results;
}

fn partOne(sequence: []const u8) !isize {
    const lists = try parse(sequence);
    var result: isize = 0;
    for (lists.items) |list| result += try extrapolate1(list.items);
    return result;
}

fn partTwo(sequence: []const u8) !isize {
    const lists = try parse(sequence);
    var result: isize = 0;
    for (lists.items) |list| result += try extrapolate2(list.items);
    return result;
}

pub fn main() !void {
    const data = @embedFile("res/d09.txt");
    var timer = try std.time.Timer.start();

    std.debug.print("one : {d}\ntime: {}\n\n", .{
        try partOne(data),
        std.fmt.fmtDuration(timer.lap()),
    });
    std.debug.print("two : {d}\ntime: {}\n\n", .{
        try partTwo(data),
        std.fmt.fmtDuration(timer.lap()),
    });
}

test extrapolate1 {
    try std.testing.expectEqual(extrapolate1(&[_]isize{ 0, 3, 6, 9, 12, 15 }), 18);
    try std.testing.expectEqual(extrapolate1(&[_]isize{ 1, 3, 6, 10, 15, 21 }), 28);
    try std.testing.expectEqual(extrapolate1(&[_]isize{ 10, 13, 16, 21, 30, 45 }), 68);
}

test partOne {
    try std.testing.expectEqual(try partOne(
        \\0 3 6 9 12 15
        \\1 3 6 10 15 21
        \\10 13 16 21 30 45
    ), 114);
}

test extrapolate2 {
    try std.testing.expectEqual(extrapolate2(&[_]isize{ 0, 3, 6, 9, 12, 15 }), -3);
    try std.testing.expectEqual(extrapolate2(&[_]isize{ 1, 3, 6, 10, 15, 21 }), 0);
    try std.testing.expectEqual(extrapolate2(&[_]isize{ 10, 13, 16, 21, 30, 45 }), 5);
}

test partTwo {
    try std.testing.expectEqual(try partTwo(
        \\0 3 6 9 12 15
        \\1 3 6 10 15 21
        \\10 13 16 21 30 45
    ), 2);
}
