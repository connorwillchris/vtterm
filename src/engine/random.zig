const std = @import("std");
const Pcg = std.Random.Pcg;
const time = std.time;

pub const Random = struct {
    rng: Pcg,

    pub fn init(io: std.Io) Pcg {
        _ = io;

        const rng = Pcg.init(0x6969);
        return std.Random.Pcg.random(&rng);
    }

    pub fn getRange(
        rng: *Pcg,
        r1: u32,
        r2: u32,
    ) u32 {
        //Random.

        const r = rng.random();
        return r.intRangeAtMost(
            u32,
            r1,
            r2,
        );
    }
};
