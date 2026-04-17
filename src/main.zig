const std = @import("std");
const clap = @import("clap");
const desc = @import("constants.zig").ARGS_DESCREPTIONS;
const process = @import("proccess.zig");
const builtin = @import("builtin");
pub fn main(init: std.process.Init) !void {
    const params = comptime clap.parseParamsComptime(
        \\-h, --help       Displays Help. \\<str>             Inputs file path.
        \\-u, --unicode Adds unicode to the visual queu.
        \\<str>
        \\-s, --string dumps a string instead of a file.
    );
    var res = clap.parse(clap.Help, &params, clap.parsers.default, init.minimal.args, .{
        .allocator = init.gpa,
    }) catch {
        return;
    };
    defer res.deinit();
    var unicode_encoding: bool = false;
    var string_dump: bool = false;
    if (res.args.help != 0) std.debug.print("{s}\n", .{desc.help});
    if (res.args.unicode != 0) unicode_encoding = true;
    if (res.args.string != 0) string_dump = true;

    if (res.positionals[0]) |input| {
        if (!string_dump) try process.processFile(input, &init.io, unicode_encoding);
        try process.processString(&input, unicode_encoding);
    }
}
