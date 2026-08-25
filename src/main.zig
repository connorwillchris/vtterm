const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const zlua = @import("zlua");
const Lua = zlua.Lua;

/// Our main application state
const Model = struct {
    /// State of the counter
    count: u32 = 0,
    /// The button. This widget is stateful and must live between frames
    button: vxfw.Button,

    pub fn widget(self: *Model) vxfw.Widget {
        return .{
            .userdata = self,
            .eventHandler = Model.typeErasedEventHandler,
            .drawFn = Model.typeErasedDrawFn,
        };
    }

    /// This function will be called from the vxfw runtime.
    fn typeErasedEventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
        const self: *Model = @ptrCast(@alignCast(ptr));
        switch (event) {
            .init => return ctx.requestFocus(self.button.widget()),
            .key_press => |key| {
                if (key.matches('c', .{ .ctrl = true })) {
                    ctx.quit = true;
                    return;
                }
            },

            .focus_in => return ctx.requestFocus(self.button.widget()),
            else => {},
        }
    }

    fn typeErasedDrawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
        const self: *Model = @ptrCast(@alignCast(ptr));
        const max_size = ctx.max.size();
        const count_text = try std.fmt.allocPrint(ctx.arena, "{d}", .{self.count});
        const text: vxfw.Text = .{ .text = count_text };

        const text_child: vxfw.SubSurface = .{
            .origin = .{ .row = 0, .col = 0 },
            .surface = try text.draw(ctx),
        };

        const button_child: vxfw.SubSurface = .{
            .origin = .{ .row = 2, .col = 0 },
            .surface = try self.button.draw(ctx.withConstraints(
                ctx.min,
                .{ .width = 16, .height = 3 },
            )),
        };

        const children = try ctx.arena.alloc(vxfw.SubSurface, 2);
        children[0] = text_child;
        children[1] = button_child;

        return .{
            .size = max_size,
            .widget = self.widget(),
            .buffer = &.{},
            .children = children,
        };
    }

    fn onClick(maybe_ptr: ?*anyopaque, ctx: *vxfw.EventContext) anyerror!void {
        const ptr = maybe_ptr orelse return;
        const self: *Model = @ptrCast(@alignCast(ptr));
        self.count +|= 1;
        return ctx.consumeAndRedraw();
    }
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const alloc = init.gpa;

    // lua init here...
    var lua = try Lua.init(alloc);
    defer lua.deinit();

    // and use lua lib here!
    lua.pushInteger(42);
    std.debug.print(
        "{}\n",
        .{
            try lua.toInteger(1),
        },
    );

    var buffer: [1024]u8 = undefined;
    var app: vxfw.App = try .init(io, alloc, init.environ_map, &buffer);
    defer app.deinit();

    const model = try alloc.create(Model);
    defer alloc.destroy(model);

    // Set the initial state of our button
    model.* = .{
        .count = 0,
        .button = .{
            .label = "Click me!",
            .onClick = Model.onClick,
            .userdata = model,
        },
    };

    try app.run(model.widget(), .{});
}
