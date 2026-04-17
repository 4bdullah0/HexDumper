pub fn processFile(file_path: []const u8, io: *const std.Io, unicode: ?bool) anyerror!void {
    const isAbs = std.fs.path.isAbsolute(file_path);
    var file: std.Io.File = undefined;
    file = if (isAbs) try std.Io.Dir.openFileAbsolute(io.*, file_path, .{ .mode = .read_only }) else try std.Io.Dir.cwd().openFile(io.*, file_path, .{ .mode = .read_only });
    defer file.close(io.*);

    var buf: [1024]u8 = undefined;
    var reader: std.Io.File.Reader = file.reader(io.*, &buf);
    var rif = &reader.interface;

    var global_offset: usize = 0;

    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();

    var visual_represent = try std.ArrayList(u8).initCapacity(allocator, 1024);
    defer visual_represent.deinit(allocator);
    while (true) {
        const chunk = rif.takeArray(1024) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };

        for (chunk.*) |item| {
            if (global_offset % 16 == 0) {
                std.debug.print("{x:0>8} |  ", .{global_offset});
            }

            try visual_represent.append(allocator, item);
            std.debug.print("{x:0>2} ", .{item});

            global_offset += 1;

            if (global_offset % 16 == 0) {
                std.debug.print(" | ", .{});

                for (visual_represent.items) |char| {
                    if (char >= 32 and char <= 126) {
                        std.debug.print("{c}", .{char});
                    } else {
                        if (unicode orelse false) {
                            std.debug.print("{u}", .{@as(u21, 0x2400) + char});
                        } else {
                            std.debug.print(".", .{});
                        }
                    }
                }

                visual_represent.clearRetainingCapacity();
                std.debug.print("\n", .{});
            }
        }
    }
}

pub fn processString(string: *const []const u8, unicode: ?bool) anyerror!void {
    var global_offset: usize = 0;

    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();

    var visual_represent = try std.ArrayList(u8).initCapacity(allocator, 16);
    defer visual_represent.deinit(allocator);

    for (string.*) |item| {
        if (global_offset % 16 == 0) {
            std.debug.print("{x:0>8} |  ", .{global_offset});
        }

        try visual_represent.append(allocator, item);
        std.debug.print("{x:0>2} ", .{item});

        global_offset += 1;

        if (global_offset % 16 == 0) {
            printVisualLine(visual_represent.items, unicode);
            visual_represent.clearRetainingCapacity();
        }
    }

    if (visual_represent.items.len > 0) {
        const missing = 16 - visual_represent.items.len;
        for (0..missing) |_| std.debug.print("   ", .{});
        printVisualLine(visual_represent.items, unicode);
    }
}

fn printVisualLine(items: []const u8, unicode: ?bool) void {
    std.debug.print(" | ", .{});
    for (items) |char| {
        if (char >= 32 and char <= 126) {
            std.debug.print("{c}", .{char});
        } else {
            if (unicode orelse false) {
                std.debug.print("{u}", .{@as(u21, 0x2400) + char});
            } else {
                std.debug.print(".", .{});
            }
        }
    }
    std.debug.print("\n", .{});
}
const std = @import("std");
