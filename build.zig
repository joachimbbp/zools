const std = @import("std");

// constructs a build graph to be executed by an external runner
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    // No preferred release mode, user can decide optimization
    const optimize = b.standardOptimizeOption(.{});

    const lib_mod = b.addModule("zools", .{
        .root_source_file = b.path("src/zools.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "zools",
        .root_module = lib_mod,
    });

    b.installArtifact(lib);

    //TODO: Run tests here
}
