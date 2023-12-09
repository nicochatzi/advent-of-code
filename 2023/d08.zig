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

fn walkToZ(network: *const Network, instructions: *const Instructions, start: Node) usize {
    var node = start;
    var step: usize = 0;
    while (node[2] != 'Z') : (step += 1) {
        const map = network.get(node) orelse unreachable;
        switch (instructions.items[step % instructions.items.len]) {
            .l => node = map.l,
            .r => node = map.r,
        }
    }
    return step;
}

fn gcm(a: usize, b: usize) usize {
    var a_ = a;
    var b_ = b;
    while (b_ != 0) {
        const temp = b_;
        b_ = a_ % b_;
        a_ = temp;
    }
    return a_;
}

fn resolvePartTwo(network: *const Network, instructions: *const Instructions) usize {
    var starts = std.ArrayList(Node).init(std.heap.page_allocator);
    defer starts.deinit();

    var it = network.iterator();
    while (it.next()) |entry| {
        if (entry.key_ptr.*[2] == 'A') {
            starts.append(entry.key_ptr.*) catch unreachable;
        }
    }

    var steps = std.ArrayList(usize).init(std.heap.page_allocator);
    defer steps.deinit();

    for (starts.items) |start|
        steps.append(walkToZ(network, instructions, start)) catch unreachable;

    var result: usize = 1;
    for (steps.items) |step| result = result * step / gcm(result, step);
    return result;
}

fn run(comptime solver: fn (*const Network, *const Instructions) usize, sequence: []const u8) !usize {
    var network = Network.init(std.heap.page_allocator);
    defer network.deinit();

    var instructions = Instructions.init(std.heap.page_allocator);
    defer instructions.deinit();

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

    return solver(&network, &instructions);
}

fn partOne(sequence: []const u8) !usize {
    return try run(walkToTerminal, sequence);
}

fn partTwo(sequence: []const u8) !usize {
    return try run(resolvePartTwo, sequence);
}

pub fn main() !void {
    const data = @embedFile("res/d08.txt");
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

test partOne {
    try std.testing.expectEqual(try partOne(
        \\LLR
        \\
        \\AAA = (BBB, BBB)
        \\BBB = (AAA, ZZZ)
        \\ZZZ = (ZZZ, ZZZ)
    ), 6);
}

test partTwo {
    try std.testing.expectEqual(try partTwo(
        \\LR
        \\
        \\11A = (11B, XXX)
        \\11B = (XXX, 11Z)
        \\11Z = (11B, XXX)
        \\22A = (22B, XXX)
        \\22B = (22C, 22C)
        \\22C = (22Z, 22Z)
        \\22Z = (22B, 22B)
        \\XXX = (XXX, XXX)
    ), 6);
}
