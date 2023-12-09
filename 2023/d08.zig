const std = @import("std");

const Instruction = enum { l, r };
const Instructions = std.ArrayList(Instruction);
const Node = [3]u8;
const Map = struct { l: Node, r: Node };
const Entry = struct { node: Node, map: Map };
const Network = std.AutoHashMap(Node, Map);

fn walkToTerminal(network: *const Network, instructions: *const Instructions) usize {
    var node = [1]u8{'A'} ** 3;
    var step: usize = 0;
    while (!std.mem.eql(u8, &node, "ZZZ")) : (step += 1) {
        const map = network.get(node) orelse unreachable;
        switch (instructions.items[step % instructions.items.len]) {
            .l => node = map.l,
            .r => node = map.r,
        }
    }
    return step;
}

fn partOne(sequence: []const u8) !usize {
    var instructions = Instructions.init(std.heap.page_allocator);
    defer instructions.deinit();

    var network = Network.init(std.heap.page_allocator);
    defer network.deinit();

    var it = std.mem.tokenizeSequence(u8, sequence, "\n");
    for (it.next().?) |c| {
        switch (c) {
            'L' => try instructions.append(.l),
            'R' => try instructions.append(.r),
            else => unreachable,
        }
    }

    while (it.next()) |line| {
        var entry: Entry = undefined;
        std.mem.copy(u8, &entry.node, line[0..3]);
        std.mem.copy(u8, &entry.map.l, line[7..10]);
        std.mem.copy(u8, &entry.map.r, line[12..15]);
        try network.put(entry.node, entry.map);
    }

    return walkToTerminal(&network, &instructions);
}

pub fn main() !void {
    const data = @embedFile("res/d08.txt");
    var timer = try std.time.Timer.start();

    std.debug.print("one : {d}\ntime: {}\n\n", .{
        try partOne(data),
        std.fmt.fmtDuration(timer.lap()),
    });
}

test partOne {
    try std.testing.expectEqual(try partOne(
        \\LLR
        \\
        \\AAA = (BBB, BBB)
        \\BBB = (AAA, ZZZ)
        \\ZZZ = (ZZZ, ZZZ)
    ), 6);
}
