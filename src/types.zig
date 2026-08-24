const std = @import("std");
const json = std.json;

const Mod = struct {
    name: []const u8,
    age: u8,

    pub fn loadMod() !Mod {
        const s = "{ \"name\": \"Alice\" }";

        const parsed = try json.parseFromSlice(Mod, allocator, s, .{});
        defer parsed.deinit();

        //return 0;
    }
};

//pub fn main(!void) {
//var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
//defer arena.deinit();
//const allocator = arena.allocator();

// const json_string = "{\"name\":\"Alice\",\"age\":30}";

//  const parsed = try std.json.parseFromSlice(Person, allocator, json_string, .{});
//  defer parsed.deinit();

//  const person = parsed.value;
//  std.debug.print("Name: {s}, Age: {}\n", .{ person.name, person.age });
//}
