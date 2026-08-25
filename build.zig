const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "vtterm",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),

            .target = target,
            .optimize = optimize,

            .imports = &.{},
        }),
    });

    const vaxis = b.dependency("vaxis", .{
        .target = target,
        .optimize = optimize,
    });
    const lua_dep = b.dependency("zlua", .{
        .target = target,
        .optimize = optimize,
        //.lang = .luajit,
    });
    const xml_dep = b.dependency(
        "xml",
        .{
            .target = target,
            .optimize = optimize,
        },
    );

    // ADD MODULES HERE
    exe.root_module.addImport("zlua", lua_dep.module("zlua"));
    exe.root_module.addImport("vaxis", vaxis.module("vaxis"));
    exe.root_module.addImport(
        "xml",
        xml_dep.module("xml"),
    );

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_exe_tests.step);
}
