const std = @import("std");

const Mapping = [3]isize;

fn applyMapping(seeds: *std.ArrayList(isize), mappings: *const std.ArrayList(Mapping)) void {
    for (seeds.items) |*seed| {
        for (mappings.items) |mapping| {
            if (seed.* >= mapping[1] and seed.* <= mapping[1] + mapping[2]) {
                seed.* = mapping[0] + (seed.* - mapping[1]);
                break;
            }
        }
    }
}

fn parseSeeds(seeds: *std.ArrayList(isize), sequence: []const u8) !void {
    var it = std.mem.tokenizeSequence(u8, sequence["seeds: ".len..], " ");
    while (it.next()) |token| {
        try seeds.append(try std.fmt.parseInt(isize, token, 10));
    }
}

fn parseMapping(line: []const u8) !Mapping {
    var it = std.mem.tokenizeSequence(u8, line, " ");
    return .{
        try std.fmt.parseInt(isize, it.next() orelse unreachable, 10),
        try std.fmt.parseInt(isize, it.next() orelse unreachable, 10),
        try std.fmt.parseInt(isize, it.next() orelse unreachable, 10),
    };
}

fn smallestSeed(seeds: *const std.ArrayList(isize)) isize {
    var smallest: isize = std.math.maxInt(isize);
    for (seeds.items) |seed| {
        smallest = if (seed < smallest) seed else smallest;
    }
    return smallest;
}

fn partOne(allocator: std.mem.Allocator, sequence: []const u8) !isize {
    var chunkIt = std.mem.tokenizeSequence(u8, sequence, "\n\n");

    var seeds = std.ArrayList(isize).init(allocator);
    defer seeds.deinit();

    try parseSeeds(&seeds, chunkIt.next() orelse unreachable);

    var mappings = std.ArrayList(Mapping).init(allocator);
    defer mappings.deinit();

    while (chunkIt.next()) |chunk| {
        var lineIt = std.mem.tokenizeSequence(u8, chunk, "\n");
        _ = lineIt.next() orelse unreachable;

        mappings.clearRetainingCapacity();
        while (lineIt.next()) |line| {
            try mappings.append(try parseMapping(line));
        }
        applyMapping(&seeds, &mappings);
    }

    return smallestSeed(&seeds);
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const data = @embedFile("res/d05.txt");

    var timer = try std.time.Timer.start();
    std.debug.print("one : {d}\ntime : {}\n\n", .{
        try partOne(allocator, data),
        std.fmt.fmtDuration(timer.lap()),
    });
    // std.debug.print("two : {d}\ntime : {}\n\n", .{
    //     try partTwo(allocator, data),
    //     std.fmt.fmtDuration(timer.read()),
    // });
}

test partOne {
    const data =
        \\seeds: 79 14 55 13
        \\
        \\seed-to-soil map:
        \\50 98 2
        \\52 50 48
        \\
        \\soil-to-fertilizer map:
        \\0 15 37
        \\37 52 2
        \\39 0 15
        \\
        \\fertilizer-to-water map:
        \\49 53 8
        \\0 11 42
        \\42 0 7
        \\57 7 4
        \\
        \\water-to-light map:
        \\88 18 7
        \\18 25 70
        \\
        \\light-to-temperature map:
        \\45 77 23
        \\81 45 19
        \\68 64 13
        \\
        \\temperature-to-humidity map:
        \\0 69 1
        \\1 0 69
        \\
        \\humidity-to-location map:
        \\60 56 37
        \\56 93 4
    ;
    try std.testing.expectEqual(try partOne(std.heap.page_allocator, data), 35);
}
