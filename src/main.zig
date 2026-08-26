const std = @import("std");
const vaxis = @import("vaxis");
const zlua = @import("zlua");
const document = @import("document.zig");
const xml = @import("xml");

const Model = document.Model;
const vxfw = vaxis.vxfw;
const Lua = zlua.Lua;

pub fn main(init: std.process.Init) !void {
    _ = init;
    std.debug.print("Hello, world!\n", .{});

    const allocator = std.heap.page_allocator;
    var reader = xml.Reader.Static.init(allocator,
        \\<book>
        \\    <title>My Book</title>
        \\    <author>John</author>
        \\</book>
    , .{});
    defer reader.deinit();

    var text: ?[]const u8 = null;
    while (true) {
        const event = try reader.interface.read();

        switch (event) {
            .text => |value| {
                text = value;
            },

            .element_end => {
                if (text) |value| {
                    std.debug.print("{s}\n", .{value});
                }

                text = null;
            },

            .eof => break,

            else => {},
        }
    }
}

const Character = struct {};
