const std = @import("std");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

const Screen = enum {
    Home,
    Settings,
    Help,
};

const App = struct {
    screen: Screen = .Home,

    // Which item is selected on the Home screen.
    selected: usize = 0,

    // Example application state.
    counter: u32 = 0,

    // Stateful widgets need to persist between frames.
    button: vxfw.Button,

    pub fn widget(self: *App) vxfw.Widget {
        return .{
            .userdata = self,
            .eventHandler = App.eventHandler,
            .drawFn = App.draw,
        };
    }

    // ------------------------------------------------------------
    // Events
    // ------------------------------------------------------------

    fn eventHandler(
        ptr: *anyopaque,
        ctx: *vxfw.EventContext,
        event: vxfw.Event,
    ) anyerror!void {
        const self: *App = @ptrCast(@alignCast(ptr));

        switch (event) {
            .init => {
                // Start with our main button focused.
                return ctx.requestFocus(self.button.widget());
            },

            .key_press => |key| {
                // Ctrl-C always exits.
                if (key.matches('c', .{ .ctrl = true })) {
                    ctx.quit = true;
                    return;
                }

                // q exits.
                if (key.matches('q', .{})) {
                    ctx.quit = true;
                    return;
                }

                // Number keys switch screens.
                if (key.matches('1', .{})) {
                    self.screen = .Home;
                    return ctx.consumeAndRedraw();
                }

                if (key.matches('2', .{})) {
                    self.screen = .Settings;
                    return ctx.consumeAndRedraw();
                }

                if (key.matches('3', .{})) {
                    self.screen = .Help;
                    return ctx.consumeAndRedraw();
                }

                // Escape always returns to Home.
                if (key.matches(vaxis.Key.escape, .{})) {
                    self.screen = .Home;
                    return ctx.consumeAndRedraw();
                }
            },

            else => {},
        }
    }

    // ------------------------------------------------------------
    // Drawing
    // ------------------------------------------------------------

    fn draw(
        ptr: *anyopaque,
        ctx: vxfw.DrawContext,
    ) std.mem.Allocator.Error!vxfw.Surface {
        const self: *App = @ptrCast(@alignCast(ptr));

        const size = ctx.max.size();

        // --------------------------------------------------------
        // Header
        // --------------------------------------------------------

        const header = vxfw.Text{
            .text = "  My Vaxis Application",
        };

        // --------------------------------------------------------
        // Main content
        // --------------------------------------------------------

        const content_text = switch (self.screen) {
            .Home => "HOME\n\n" ++
                "Welcome to your application!\n\n" ++
                "  [1] Home\n" ++
                "  [2] Settings\n" ++
                "  [3] Help\n\n" ++
                "  Press the button below to increment the counter.",

            .Settings => "SETTINGS\n\n" ++
                "This is where application Settings can go.\n\n" ++
                "Nothing is configured yet.",

            .Help => "HELP\n\n" ++
                "Keyboard shortcuts:\n\n" ++
                "  1       Home\n" ++
                "  2       Settings\n" ++
                "  3       Help\n" ++
                "  Escape  Home\n" ++
                "  q       Quit\n" ++
                "  Ctrl-C  Quit",
        };

        const content = vxfw.Text{
            .text = content_text,
        };

        // --------------------------------------------------------
        // Status bar
        // --------------------------------------------------------

        const status = vxfw.Text{
            .text = "  1 Home   2 Settings   3 Help   q Quit",
        };

        // --------------------------------------------------------
        // Button
        // --------------------------------------------------------

        const button = try self.button.draw(ctx.withConstraints(
            ctx.min,
            .{
                .width = 20,
                .height = 3,
            },
        ));

        // --------------------------------------------------------
        // Children
        // --------------------------------------------------------

        const children = try ctx.arena.alloc(vxfw.SubSurface, 4);

        children[0] = .{
            .origin = .{
                .row = 0,
                .col = 0,
            },
            .surface = try header.draw(ctx),
        };

        children[1] = .{
            .origin = .{
                .row = 2,
                .col = 2,
            },
            .surface = try content.draw(ctx),
        };

        children[2] = .{
            .origin = .{
                .row = 12,
                .col = 2,
            },
            .surface = button,
        };

        children[3] = .{
            .origin = .{
                .row = size.height -| 1,
                .col = 0,
            },
            .surface = try status.draw(ctx),
        };

        return .{
            .size = size,
            .widget = self.widget(),

            // The root itself doesn't draw anything.
            .buffer = &.{},

            .children = children,
        };
    }

    // ------------------------------------------------------------
    // Button
    // ------------------------------------------------------------

    fn onButtonClick(
        ptr: ?*anyopaque,
        ctx: *vxfw.EventContext,
    ) anyerror!void {
        const userdata = ptr orelse return;

        const self: *App = @ptrCast(@alignCast(userdata));

        self.counter +|= 1;

        return ctx.consumeAndRedraw();
    }
};

// ------------------------------------------------------------
// Main
// ------------------------------------------------------------

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const alloc = init.gpa;

    var buffer: [1024]u8 = undefined;

    var app_runtime: vxfw.App = try .init(
        io,
        alloc,
        init.environ_map,
        &buffer,
    );
    defer app_runtime.deinit();

    // The model needs a stable address because widgets store
    // pointers to their userdata.
    const app = try alloc.create(App);
    defer alloc.destroy(app);

    app.* = .{
        .screen = .Home,
        .selected = 0,
        .counter = 0,

        .button = .{
            .label = "Increment Counter",
            .onClick = App.onButtonClick,
            .userdata = app,
        },
    };

    try app_runtime.run(app.widget(), .{});
}
