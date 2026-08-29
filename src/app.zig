const std = @import("std");
const vaxis = @import("vaxis");

pub const App = struct {
    running: bool = true,

    pub fn init(
        io: std.Io,
        allocator: std.mem.Allocator,
        environ_map: *std.process.Environ.Map,
    ) !App {}

    pub fn deinit(self: *App) void {}
};
