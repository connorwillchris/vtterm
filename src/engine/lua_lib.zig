const std = @import("std");
const zlua = @import("zlua");

const Lua = zlua.Lua;
const Allocator = std.mem.Allocator;

pub const LuaLib = struct {
    interface: Lua,

    pub fn open(allocator: Allocator) !Lua {
        var l: LuaLib = undefined;
        l.interface = Lua.init(allocator);
    }

    pub fn deinit(self: *LuaLib) !void {
        self.interface.deinit();
    }
};
