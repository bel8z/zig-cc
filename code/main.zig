const std = @import("std");

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var allocator = arena.allocator();

    var arg_list = std.ArrayList([]const u8).init(allocator);
    defer arg_list.deinit();

    try arg_list.append("zig"[0..]);
    try arg_list.append("cc"[0..]);

    var args = std.process.args();
    _ = args.skip();
    while (args.next(allocator)) |arg_or_err| {
        const arg = try arg_or_err;
        try arg_list.append(arg);
    }

    // The arguments must be split first (you can use std.mem.split if
    // you have all of your arguments in one string)
    var proc = try std.ChildProcess.init(arg_list.items, allocator);
    defer proc.deinit();

    // By default, standard input is inherited, but to give the child program
    // a specific input, you need to request it to open a pipe with parent program.
    proc.stdin_behavior = .Pipe;

    // Spawn the process
    try proc.spawn();

    // Now wait for the program to end.
    _ = try proc.wait();
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
