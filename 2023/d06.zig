const std = @import("std");

const Stat = struct {
    time: isize,
    distance: isize,
};

const Stats = std.ArrayList(Stat);

fn partOne(alloc: std.mem.Allocator, sequence: []const u8) !isize {
    var stats = Stats.init(alloc);
    defer stats.deinit();

    var it = std.mem.tokenizeScalar(u8, sequence, '\n');

    var timeIt = std.mem.tokenizeSequence(u8, it.next().?, " ");
    _ = timeIt.next() orelse unreachable;
    while (timeIt.next()) |time|
        try stats.append(.{ .time = try std.fmt.parseInt(isize, time, 10), .distance = 0 });

    var distanceIt = std.mem.tokenizeSequence(u8, it.next().?, " ");
    _ = distanceIt.next() orelse unreachable;
    var i: usize = 0;
    while (distanceIt.next()) |distance| {
        stats.items[i].distance = try std.fmt.parseInt(isize, distance, 10);
        i += 1;
    }

    var result: isize = 1;
    for (stats.items) |stat| {
        var num: isize = 0;
        for (1..@intCast(stat.distance)) |hold_time| {
            const speed: isize = @intCast(hold_time);
            const distance = (stat.time - speed) * speed;
            if (distance > stat.distance) num += 1;
        }

        result *= num;
    }

    return result;
}

fn partTwo(sequence: []const u8) !isize {
    var stat = Stat{ .time = 0, .distance = 0 };

    var it = std.mem.tokenizeScalar(u8, sequence, '\n');

    var timeIt = std.mem.tokenizeSequence(u8, it.next().?, " ");
    _ = timeIt.next() orelse unreachable;
    var v: isize = 0;
    while (timeIt.next()) |time| {
        for (time) |c| {
            if (std.ascii.isDigit(c))
                v = v * 10 + (c - '0');
        }
    }
    stat.time = v;

    var distanceIt = std.mem.tokenizeSequence(u8, it.next().?, " ");
    _ = distanceIt.next() orelse unreachable;
    v = 0;
    while (distanceIt.next()) |distance| {
        for (distance) |c| {
            if (std.ascii.isDigit(c))
                v = v * 10 + (c - '0');
        }
    }
    stat.distance = v;

    var least_hold_time: isize = 0;
    for (1..@intCast(stat.distance)) |hold_time| {
        const speed: isize = @intCast(hold_time);
        const distance = (stat.time - speed) * speed;
        if (distance > stat.distance) {
            least_hold_time = speed;
            break;
        }
    }

    var most_hold_time: isize = 0;
    var hold_time: usize = @intCast(stat.time);
    while (hold_time > 1) : (hold_time -= 1) {
        const speed: isize = @intCast(hold_time);
        const distance = (stat.time - speed) * speed;
        if (distance > stat.distance) {
            most_hold_time = speed;
            break;
        }
    }

    return most_hold_time - least_hold_time + 1;
}

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    const data = @embedFile("res/d06.txt");
    var timer = try std.time.Timer.start();

    std.debug.print("one: {d}\ttime: {}\n", .{
        try partOne(alloc, data),
        std.fmt.fmtDuration(timer.lap()),
    });

    std.debug.print("two: {d}\ttime: {}\n", .{
        try partTwo(data),
        std.fmt.fmtDuration(timer.lap()),
    });
}

test partOne {
    const data =
        \\Time:      7  15   30
        \\Distance:  9  40  200
    ;
    try std.testing.expectEqual(partOne(std.heap.page_allocator, data), 288);
}

test partTwo {
    const data =
        \\Time:      7  15   30
        \\Distance:  9  40  200
    ;
    try std.testing.expectEqual(partTwo(data), 71503);
}
