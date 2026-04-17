const std = @import("std");
const clap = @import("clap");
const desc = @import("constants.zig").ARGS_DESCREPTIONS;
const process = @import("proccess-file.zig");
const builtin = @import("builtin");
pub fn main(init: std.process.Init) !void {
    const params = comptime clap.parseParamsComptime(
        \\-h, --help       Displays Help. \\<str>             Inputs file path.
        \\-u, --unicode Adds unicode to the visual queu.
        \\<str>
    );
    var res = clap.parse(clap.Help, &params, clap.parsers.default, init.minimal.args, .{
        .allocator = init.gpa,
    }) catch {
        return;
    };
    defer res.deinit();
    var unicode_encoding: bool = false;
    if (res.args.help != 0) std.debug.print("{s}\n", .{desc.help});
    if (res.args.unicode != 0) unicode_encoding = true;

    if (res.positionals[0]) |file_path| {
        try process.processFile(file_path, &init.io, unicode_encoding);
    }
}
