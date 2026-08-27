// standard lib and external modules
const std = @import("std");
const vaxis = @import("vaxis");
const zlua = @import("zlua");
const xml = @import("xml");

// import zig files
const document = @import("document.zig");
const json_parser = @import("engine/json_parser.zig");

const Model = document.Model;
const vxfw = vaxis.vxfw;
const Lua = zlua.Lua;

pub fn main(init: std.process.Init) !void {
    _ = init;
}

test "json parsing" {
    const allocator = std.heap.page_allocator;

    const mod_info = try json_parser.ModInfo.new(
        allocator,
        \\{
        \\"name": "core",
        \\"version": "1.0",
        \\"description": "Core game. Necessary for Vtterm to work",
        \\"authors": [ "cuck", "Fuyuhiko" ],
        \\"website": "google.com"
        \\}
        ,
    );
    try json_parser.TranslationInfo.new(
        allocator,
        \\{
        \\ "k1": "Fuck",
        \\ "k2": "You"
        \\}
        ,
    );

    std.debug.print("Mod Info Test\nName: {s}\n\n", .{mod_info.name});
}

test "xml parsing" {
    const allocator = std.heap.page_allocator;
    var reader = xml.Reader.Static.init(allocator,
        \\<book>
        \\    <title>My Book</title>
        \\    <author>John</author>
        \\</book>
    , .{});
    defer reader.deinit();

    while (true) {
        const event = try reader.interface.read();

        switch (event) {
            .eof => break,

            .element_start => {
                const element_name = reader.interface.elementNameNs();

                std.debug.print("element_start: \"{f}\"[\"{f}\"]:\"{f}\"\n", .{
                    std.zig.fmtString(element_name.prefix),
                    std.zig.fmtString(element_name.ns),
                    std.zig.fmtString(element_name.local),
                });

                for (0..reader.interface.attributeCount()) |i| {
                    const attribute_name = reader.interface.attributeNameNs(i);
                    std.debug.print("  attribute: \"{f}\"[\"{f}\"]:\"{f}\" = \"{f}\"\n", .{
                        std.zig.fmtString(attribute_name.prefix),
                        std.zig.fmtString(attribute_name.ns),
                        std.zig.fmtString(attribute_name.local),
                        std.zig.fmtString(try reader.interface.attributeValue(i)),
                    });
                }
            },

            .element_end => {
                const element_name = reader.interface.elementNameNs();

                std.debug.print("element_end: \"{f}\"[\"{f}\"]:\"{f}\"\n", .{
                    std.zig.fmtString(element_name.prefix),
                    std.zig.fmtString(element_name.ns),
                    std.zig.fmtString(element_name.local),
                });
            },

            else => {},
        }
    }
}
