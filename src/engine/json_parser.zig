const std = @import("std");

const Allocator = std.mem.Allocator;
const json = std.json;

pub const ModInfo = struct {
    name: []const u8,
    version: []const u8,
    description: []const u8,
    authors: []const []const u8,
    website: []const u8,

    pub fn new(
        allocator: Allocator,
        string: []const u8,
    ) !ModInfo {
        const mod_info = try json.parseFromSlice(
            ModInfo,
            allocator,
            string,
            .{},
        );
        defer mod_info.deinit();

        return mod_info.value;
    }
};
