const std = @import("std");
const godot_zig = @import("godot_zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // -- bindings
    const bind_step = godot_zig.createBindStep(b, target);
    b.installDirectory(.{
        .source_dir = b.dependency("godot_zig", .{}).path("src/api"),
        .install_dir = .prefix,
        .install_subdir = "api",
    });

    // -- godot module
    const godot_mod = b.addModule("godot", .{
        .root_source_file = .{ .path = b.pathJoin(&.{ b.install_prefix, "api/Godot.zig" }) },
        .link_libc = true,
    });
    godot_mod.addIncludePath(.{ .path = b.pathJoin(&.{ b.install_prefix, "api" }) });

    // -- library
    const lib = b.addSharedLibrary(.{
        .name = "godot-zig-test",
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    lib.root_module.addImport("godot", godot_mod);
    lib.step.dependOn(bind_step);
    b.installArtifact(lib);

    // -- tests
    const lib_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    const run_lib_tests = b.addRunArtifact(lib_tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_lib_tests.step);

    // -- formatting
    const fmt_step = b.step("fmt", "Run formatter");
    const fmt = b.addFmt(.{
        .paths = &.{ "src", "build.zig" },
        .check = true,
    });
    fmt_step.dependOn(&fmt.step);
    b.default_step.dependOn(fmt_step);
}
