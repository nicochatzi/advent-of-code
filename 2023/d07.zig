const std = @import("std");

const Player = struct { cards: []const u8, bid: usize };
const FrequencyMap = std.AutoHashMap(u8, usize);
const Frequency = struct { card: u8, freq: usize };
const Hand = enum(u8) { five = 7, four = 6, full = 5, three = 4, two = 3, pair = 2, high = 1 };

const PartOne = struct {
    fn handStrength(map: *FrequencyMap) Hand {
        var cache: usize = 0;
        var it = map.iterator();
        while (it.next()) |pair| {
            const value = pair.value_ptr.*;
            if (value == 5) return .five;
            if (value == 4) return .four;
            if (value == 3 and cache == 2) return .full;
            if (value == 2 and cache == 3) return .full;
            if (value == 2 and cache == 2) return .pair;
            cache = @max(value, cache);
        }

        return if (cache == 3) .three else @enumFromInt(cache);
    }

    fn cardStrength(card: u8) u8 {
        switch (card) {
            'A' => return 14,
            'K' => return 13,
            'Q' => return 12,
            'J' => return 11,
            'T' => return 10,
            else => return card - '0',
        }
    }

    fn comparePlayers(map: *FrequencyMap, a: Player, b: Player) bool {
        return compare(PartOne.handStrength, PartOne.cardStrength, map, a, b);
    }
};

const PartTwo = struct {
    fn mapHas(map: *FrequencyMap, value: usize, joker: usize) bool {
        var it = map.iterator();
        while (it.next()) |pair| if ((pair.value_ptr.* + joker) == value) return true;
        return false;
    }

    fn handStrength(map: *FrequencyMap) Hand {
        const joker_entry = map.fetchRemove('J');
        const joker = if (joker_entry != null) joker_entry.?.value else 0;
        if (joker == 5) return .five;

        switch (map.count()) {
            1 => return .five,
            2 => if (mapHas(map, 4, joker)) return .four else return .full,
            3 => if (mapHas(map, 3, joker)) return .three else return .two,
            4 => if (mapHas(map, 2, joker)) return .pair else return .high,
            5 => return .high,
            else => unreachable,
        }
    }

    fn cardStrength(card: u8) u8 {
        return if (card == 'J') 1 else PartOne.cardStrength(card);
    }

    fn comparePlayers(map: *FrequencyMap, a: Player, b: Player) bool {
        return compare(PartTwo.handStrength, PartTwo.cardStrength, map, a, b);
    }
};

fn buildFrequencyMap(sequence: []const u8, map: *FrequencyMap) void {
    map.clearRetainingCapacity();
    for (sequence) |c| {
        var entry = map.getOrPutValue(c, 0) catch unreachable;
        entry.value_ptr.* += 1;
    }
}

fn compare(
    comptime handStrength: fn (*FrequencyMap) Hand,
    comptime cardStrength: fn (u8) u8,
    map: *FrequencyMap,
    a: Player,
    b: Player,
) bool {
    buildFrequencyMap(a.cards, map);
    const a_strength = @intFromEnum(handStrength(map));

    buildFrequencyMap(b.cards, map);
    const b_strength = @intFromEnum(handStrength(map));

    if (a_strength > b_strength) return true;
    if (a_strength < b_strength) return false;

    for (a.cards, b.cards) |a_, b_| {
        if (cardStrength(a_) > cardStrength(b_)) return true;
        if (cardStrength(a_) < cardStrength(b_)) return false;
    }

    unreachable;
}

fn run(
    comptime comparator: fn (*FrequencyMap, Player, Player) bool,
    alloc: std.mem.Allocator,
    sequence: []const u8,
) !usize {
    var players = std.ArrayList(Player).init(alloc);
    var it = std.mem.tokenizeSequence(u8, sequence, "\n");
    while (it.next()) |p| {
        var p_it = std.mem.tokenizeSequence(u8, p, " ");
        try players.append(.{
            .cards = p_it.next().?,
            .bid = try std.fmt.parseInt(usize, p_it.next().?, 10),
        });
    }

    var map = FrequencyMap.init(alloc);
    std.sort.insertion(Player, players.items, &map, comparator);

    var result: usize = 0;
    for (players.items, 0..) |p, i| {
        std.debug.print("p: {d}\tb: {d} \tc: {s}\n", .{ i, p.bid, p.cards });
        result += p.bid * (players.items.len - i);
    }
    return result;
}

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    var timer = try std.time.Timer.start();
    const data = @embedFile("res/d07.txt");

    std.debug.print("one: {d}\ntime: {}\n\n", .{
        try run(PartOne.comparePlayers, alloc, data),
        std.fmt.fmtDuration(timer.lap()),
    });
    std.debug.print("two: {d}\ntime: {}\n\n", .{
        try run(PartTwo.comparePlayers, alloc, data),
        std.fmt.fmtDuration(timer.lap()),
    });
}

test "part one comparator" {
    var map = FrequencyMap.init(std.heap.page_allocator);
    defer map.deinit();

    try std.testing.expect(PartOne.comparePlayers(
        &map,
        .{ .cards = "T55J5", .bid = 0 },
        .{ .cards = "32T3K", .bid = 0 },
    ));
    try std.testing.expect(PartOne.comparePlayers(
        &map,
        .{ .cards = "T55J5", .bid = 0 },
        .{ .cards = "KK677", .bid = 0 },
    ));
    try std.testing.expect(PartOne.comparePlayers(
        &map,
        .{ .cards = "KK677", .bid = 0 },
        .{ .cards = "KTJJT", .bid = 0 },
    ));
    try std.testing.expect(PartOne.comparePlayers(
        &map,
        .{ .cards = "55T5T", .bid = 0 },
        .{ .cards = "55Q57", .bid = 0 },
    ));
}

test "part one" {
    try std.testing.expectEqual(try run(PartOne.comparePlayers, std.heap.page_allocator,
        \\32T3K 765
        \\T55J5 684
        \\KK677 28
        \\KTJJT 220
        \\QQQJA 483
    ), 6440);
}

test "part two comparator" {
    var map = FrequencyMap.init(std.heap.page_allocator);
    defer map.deinit();

    try std.testing.expect(PartTwo.comparePlayers(
        &map,
        .{ .cards = "T5KJ5", .bid = 0 },
        .{ .cards = "32T3K", .bid = 0 },
    ));
    try std.testing.expect(PartTwo.comparePlayers(
        &map,
        .{ .cards = "T55J5", .bid = 0 },
        .{ .cards = "KKK77", .bid = 0 },
    ));
    try std.testing.expect(PartTwo.comparePlayers(
        &map,
        .{ .cards = "AAJAA", .bid = 0 },
        .{ .cards = "AAAQA", .bid = 0 },
    ));
}

test "part two" {
    try std.testing.expectEqual(try run(PartTwo.comparePlayers, std.heap.page_allocator,
        \\32T3K 765
        \\T55J5 684
        \\KK677 28
        \\KTJJT 220
        \\QQQJA 483
    ), 5905);

    try std.testing.expectEqual(try run(PartTwo.comparePlayers, std.heap.page_allocator,
        \\JJJJJ 2
        \\AAJAA 3
        \\AAAQA 1
    ), 14);
}
