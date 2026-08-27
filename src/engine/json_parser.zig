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

pub const TranslationInfo = struct {
    pub fn new(
        allocator: Allocator,
        string: []const u8,
    ) !void {
        var parsed = try std.json.parseFromSlice(
            //std.json.ArrayHashMap([]const u8),
            json.Value,
            allocator,
            string,
            .{},
        );
        defer parsed.deinit();

        const object = parsed.value.object;
        var iterator = object.iterator();

        while (iterator.next()) |e| {
            const key = e.key_ptr.*;
            const value = e.value_ptr.*;

            std.debug.print("{s}: {s}\n", .{
                key,
                value.string,
            });
        }
    }
};
