const std = @import("std");
const vaxis = @import("vaxis");
const xml = @import("xml");
const zlua = @import("zlua");
const document = @import("document.zig");

// comptime types
const Model = document.Model;
const vxfw = vaxis.vxfw;
const Lua = zlua.Lua;

const Node = union(enum) {
    element: Element,
    text: []const u8,

    const Element = struct {
        name: []const u8,
        attributes: std.StringArrayHashMapUnmanaged([]const u8),
        children: []const Node,
    };
};

const Document = struct {
    root_nodes: []const Node,
};

pub fn main(init: std.process.Init) !void {
    _ = init.io;

    const gpa = init.gpa;

    // lua init here...
    var lua = try Lua.init(gpa);
    defer lua.deinit();

    // and use lua lib here!
    lua.pushInteger(42);
    std.debug.print(
        "{}\n",
        .{
            try lua.toInteger(1),
        },
    );
}
