const std = @import("std");

const Allocator = std.mem.Allocator;
const json = std.json;

// TODO: implement all ISO 639 language codes
// (or only the necessary ones.)
pub const lang_codes = std.StaticStringMap(Language).initComptime(.{
    .{ "en", "English (US)" },
    .{ "ja", "Japanese" },
    // TODO: rest of lang codes
});

pub const Language = struct {
    lang_code: []const u8,
    lang_name: []const u8,

    pub fn open(
        allocator: Allocator,
        string: []const u8,
    ) !void {
        var parsed = try std.json.parseFromSlice(
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
