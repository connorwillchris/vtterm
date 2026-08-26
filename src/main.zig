const std = @import("std");
const vaxis = @import("vaxis");
const zlua = @import("zlua");
const document = @import("document.zig");
const zxml = @import("zxml");

const Model = document.Model;
const vxfw = vaxis.vxfw;
const Lua = zlua.Lua;

pub fn main(init: std.process.Init) !void {
    _ = init;
}
