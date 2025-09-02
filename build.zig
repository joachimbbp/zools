const std = @import("std");

// constructs a build graph to be executed by an external runner
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    // No preferred release mode, user can decide optimization
    const optimize = b.standardOptimizeOption(.{});

    const lib_mod = b.addModule("zools", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "zools",
        .root_module = lib_mod,
    });

    b.installArtifact(lib);

    const lib_unit_tests = b.addTest(.{
        .name = "tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/all_tests.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    lib_unit_tests.root_module.addImport("zools", lib.root_module);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}

