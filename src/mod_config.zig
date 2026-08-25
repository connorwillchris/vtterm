const std = @import("std");
const json = std.json;

const ModInfo = struct {
    mod_name: []const u8,
    description: []const u8,
    version: []const u8,
    authors: []const []const u8,

    pub fn loadMod(allocator: std.mem.Allocator) !ModInfo {
        // test string
        const s = "{ \"name\": \"Alice\" }";

        const parsed = try json.parseFromSlice(ModInfo, allocator, s, .{});
        defer parsed.deinit();

        const parsed_values = parsed.value;

        return ModInfo{
            .mod_name = parsed_values.mod_name,
            .version = parsed_values.version,
        };
    }
};
