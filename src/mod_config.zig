const std = @import("std");

// comptime types
const json = std.json;

const ModConfig = struct {
    name: []const u8,
    version: []const u8,
    display_name: []const u8,
    description: []const u8,
    authors: []const []const u8,

    // versions
    vtt_version: []const u8,

    pub fn loadMod(s: []const u8, allocator: std.mem.Allocator) !ModConfig {
        const parsed =
            try json.parseFromSlice(ModConfig, allocator, s, .{});
        defer parsed.deinit();

        const parsed_values = parsed.value;

        return parsed_values orelse undefined;
    }
};
