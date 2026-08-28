// standard lib and external modules
const std = @import("std");
const vaxis = @import("vaxis");
const zlua = @import("zlua");
const xml = @import("xml");
const colors = @import("engine/colors.zig");
const root_doc = @import("engine/root_document.zig");
const json_parser = @import("engine/json_parser.zig");
const random = @import("engine/random.zig");

const vxfw = vaxis.vxfw;
const Lua = zlua.Lua;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const alloc = init.gpa;

    var buffer: [1024]u8 = undefined;
    var app: vxfw.App = try .init(io, alloc, init.environ_map, &buffer);
    defer app.deinit();

    // We heap allocate our model because we will require a stable pointer to it in our Button
    // widget
    const model = try alloc.create(root_doc.Model);
    defer alloc.destroy(model);

    // Set the initial state of our button
    model.* = .{
        .count = 0,
        .button = .{
            .label = "Click me!",
            .onClick = root_doc.Model.onClick,
            .userdata = model,
        },
    };

    try app.run(model.widget(), .{});
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

test "testing colors" {
    const code: []const u8 = "aliceblue";
    const hex_code = colors.color_codes.get(code).?;

    const c = try colors.Color.fromHexString(hex_code);

    std.debug.print("HexCode: {s}\nR={} G={} B={}\n", .{
        hex_code,
        c.r,
        c.g,
        c.b,
    });
}
