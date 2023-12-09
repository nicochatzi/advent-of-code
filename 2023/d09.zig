const std = @import("std");

fn all_zero(sequence: []const isize) bool {
    for (sequence) |value| if (value != 0) return false;
    return true;
}

fn diff(sequence: []const isize) !std.ArrayList(isize) {
    var result = std.ArrayList(isize).init(std.heap.page_allocator);
    var i: usize = 0;
    while (i < sequence.len - 1) : (i += 1)
        try result.append(sequence[i + 1] - sequence[i]);
    return result;
}

fn extrapolate(sequence: []const isize) !isize {
    var diffs = std.ArrayList(std.ArrayList(isize)).init(std.heap.page_allocator);
    var first = std.ArrayList(isize).init(std.heap.page_allocator);
    for (sequence) |v| try first.append(v);
    try diffs.append(first);
    while (!all_zero(diffs.getLast().items))
        try diffs.append(try diff(diffs.getLast().items));

    try diffs.items[diffs.items.len - 1].append(0);

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
    for (lists.items) |list| result += try extrapolate(list.items);
    return result;
}

pub fn main() !void {
    const data = @embedFile("res/d09.txt");
    var timer = try std.time.Timer.start();

    std.debug.print("one : {d}\ntime: {}\n\n", .{
        try partOne(data),
        std.fmt.fmtDuration(timer.lap()),
    });
}

test extrapolate {
    try std.testing.expectEqual(extrapolate(&[_]isize{ 0, 3, 6, 9, 12, 15 }), 18);
    try std.testing.expectEqual(extrapolate(&[_]isize{ 1, 3, 6, 10, 15, 21 }), 28);
    try std.testing.expectEqual(extrapolate(&[_]isize{ 10, 13, 16, 21, 30, 45 }), 68);
}

test partOne {
    try std.testing.expectEqual(try partOne(
        \\0 3 6 9 12 15
        \\1 3 6 10 15 21
        \\10 13 16 21 30 45
    ), 114);
}
