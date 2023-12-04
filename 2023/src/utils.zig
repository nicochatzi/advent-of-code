const std = @import("std");

pub fn readFile(allocator: *std.mem.Allocator, path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_len = try file.getEndPos();
    var buffer = try allocator.alloc(u8, file_len);

    _ = try file.readAll(buffer);
    return buffer;
}
