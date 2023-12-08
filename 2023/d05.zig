const std = @import("std");

const Range = struct { start: isize, end: isize };
const Ranges = std.ArrayList(Range);

const Mapping = struct {
    dest: isize,
    src: isize,
    len: isize,

    fn contains(self: @This(), value: isize) bool {
        return value >= self.src and value <= self.src + self.len;
    }

    fn apply(self: @This(), value: isize) isize {
        return if (self.contains(value)) self.dest + value - self.src else value;
    }
};

const Mappings = std.ArrayList(Mapping);

fn parseInputData(
    sequence: []const u8,
    seeds: *std.ArrayList(isize),
    mappings: *[7](Mappings),
) !void {
    var chunk_it = std.mem.tokenizeSequence(u8, sequence, "\n\n");

    var seed_it = std.mem.tokenizeSequence(u8, chunk_it.next() orelse unreachable, " ");
    _ = seed_it.next() orelse unreachable;
    while (seed_it.next()) |seed| {
        try seeds.append(try std.fmt.parseInt(isize, seed, 10));
    }

    var i: usize = 0;
    while (chunk_it.next()) |chunk| {
        var line_it = std.mem.tokenizeSequence(u8, chunk, "\n");
        _ = line_it.next() orelse unreachable;

        while (line_it.next()) |line| {
            var map_it = std.mem.tokenizeSequence(u8, line, " ");
            try mappings[i].append(.{
                .dest = try std.fmt.parseInt(isize, map_it.next() orelse unreachable, 10),
                .src = try std.fmt.parseInt(isize, map_it.next() orelse unreachable, 10),
                .len = try std.fmt.parseInt(isize, map_it.next() orelse unreachable, 10),
            });
        }

        i += 1;
    }
}

fn partOne(allocator: std.mem.Allocator, sequence: []const u8) !isize {
    var seeds = std.ArrayList(isize).init(allocator);
    defer seeds.deinit();

    var mappings = [_]Mappings{Mappings.init(allocator)} ** 7;
    for (mappings) |map| {
        defer map.deinit();
    }

    try parseInputData(sequence, &seeds, &mappings);

    for (mappings) |map| {
        for (seeds.items) |*seed| {
            for (map.items) |m| {
                if (m.contains(seed.*)) {
                    seed.* = m.apply(seed.*);
                    break;
                }
            }
        }
    }

    return std.mem.min(isize, seeds.items);
}

fn partTwo(allocator: std.mem.Allocator, sequence: []const u8) !isize {
    var seeds = std.ArrayList(isize).init(allocator);
    defer seeds.deinit();

    var mappings = [_]Mappings{Mappings.init(allocator)} ** 7;
    for (mappings) |map| {
        defer map.deinit();
    }

    try parseInputData(sequence, &seeds, &mappings);

    var ranges = Ranges.init(allocator);
    defer ranges.deinit();

    var min: isize = std.math.maxInt(isize);
    var i: usize = 0;
    while (i < seeds.items.len) : (i += 2) {
        ranges.clearRetainingCapacity();
        try ranges.append(.{ .start = seeds.items[i], .end = seeds.items[i] + seeds.items[i + 1] });
        try applyMappingsToRange(allocator, &mappings, &ranges);
        for (ranges.items) |r| min = @min(r.start, min);
    }

    return min;
}

fn applyMappingsToRange(
    allocator: std.mem.Allocator,
    mappings: *const [7]Mappings,
    ranges: *Ranges,
) !void {
    var new_ranges = Ranges.init(allocator);
    defer new_ranges.deinit();

    var mapped_ranges = Ranges.init(allocator);
    defer mapped_ranges.deinit();

    for (mappings) |group| {
        mapped_ranges.clearRetainingCapacity();

        for (group.items) |map| {
            new_ranges.clearRetainingCapacity();

            // consume all seed ranges while mapping them and
            // creating new ranges for the non-intersecting ranges
            while (ranges.popOrNull()) |seed| {
                const mapped = Range{
                    .start = @max(seed.start, map.src),
                    .end = @min(seed.end, map.src + map.len),
                };
                if (mapped.end > mapped.start)
                    try mapped_ranges.append(.{
                        .start = map.apply(mapped.start),
                        .end = map.apply(mapped.end),
                    });

                const low = Range{
                    .start = seed.start,
                    .end = @min(seed.end, map.src),
                };
                if (low.end > low.start)
                    try new_ranges.append(low);

                const high = Range{
                    .start = @max(seed.start, map.src + map.len),
                    .end = seed.end,
                };
                if (high.end > high.start)
                    try new_ranges.append(high);
            }

            ranges.clearRetainingCapacity();
            try ranges.appendSlice(new_ranges.items);
        }

        // only add the mappings once we've finished processing the current group doh!
        try ranges.appendSlice(mapped_ranges.items);
    }
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const data = @embedFile("res/d05.txt");

    var timer = try std.time.Timer.start();
    std.debug.print("one : {d}\ntime : {}\n\n", .{
        try partOne(allocator, data),
        std.fmt.fmtDuration(timer.lap()),
    });
    std.debug.print("two : {d}\ntime : {}\n\n", .{
        try partTwo(allocator, data),
        std.fmt.fmtDuration(timer.read()),
    });
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

test partTwo {
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
    try std.testing.expectEqual(try partTwo(std.heap.page_allocator, data), 46);
}
