const std = @import("std");

const FrequencyMap = std.AutoHashMap(u8, usize);

fn strength(sequence: []const u8, map: *FrequencyMap) usize {
    map.clearRetainingCapacity();
    for (sequence) |c| {
        var entry = map.getOrPutValue(c, 0) catch unreachable;
        entry.value_ptr.* += 1;
    }

    var cache: usize = 0;
    var it = map.iterator();
    while (it.next()) |pair| {
        const value = pair.value_ptr.*;
        if (value == 5) return 7;
        if (value == 4) return 6;
        if (value == 3 and cache == 2) return 5;
        if (value == 2 and cache == 3) return 5;
        if (value == 2 and cache == 2) return 3;
        cache = @max(value, cache);
    }

    return if (cache == 3) 4 else cache;
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

const Player = struct {
    cards: []const u8,
    bid: usize,
};

fn comparePlayers(map: *FrequencyMap, a: Player, b: Player) bool {
    const a_strength = strength(a.cards, map);
    const b_strength = strength(b.cards, map);

    if (a_strength > b_strength) return true;
    if (a_strength < b_strength) return false;

    for (a.cards, b.cards) |a_, b_| {
        if (cardStrength(a_) > cardStrength(b_)) return true;
        if (cardStrength(a_) < cardStrength(b_)) return false;
    }

    unreachable;
}

fn partOne(alloc: std.mem.Allocator, sequence: []const u8) !usize {
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

    std.sort.insertion(Player, players.items, &map, comparePlayers);

    var result: usize = 0;
    for (players.items, 0..) |p, i| {
        std.debug.print("{s}\t{d}\t{d}\n", .{ p.cards, p.bid, players.items.len - i });
        result += p.bid * (players.items.len - i);
    }
    return result;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var timer = try std.time.Timer.start();
    const data = @embedFile("res/d07.txt");

    std.debug.print("one: {d}\ntime: {}\n\n", .{
        try partOne(alloc, data),
        std.fmt.fmtDuration(timer.lap()),
    });
}

test "is higher than" {
    var map = FrequencyMap.init(std.heap.page_allocator);
    defer map.deinit();

    try std.testing.expect(comparePlayers(
        &map,
        .{ .cards = "T55J5", .bid = 0 },
        .{ .cards = "32T3K", .bid = 0 },
    ));
    try std.testing.expect(comparePlayers(
        &map,
        .{ .cards = "T55J5", .bid = 0 },
        .{ .cards = "KK677", .bid = 0 },
    ));
    try std.testing.expect(comparePlayers(
        &map,
        .{ .cards = "KK677", .bid = 0 },
        .{ .cards = "KTJJT", .bid = 0 },
    ));
    try std.testing.expect(comparePlayers(
        &map,
        .{ .cards = "55T5T", .bid = 0 },
        .{ .cards = "55Q57", .bid = 0 },
    ));
}

// test partOne {
//     const data =
//         \\32T3K 765
//         \\T55J5 684
//         \\KK677 28
//         \\KTJJT 220
//         \\QQQJA 483
//     ;
//     try std.testing.expectEqual(try partOne(std.heap.page_allocator, data), 6440);
// }
