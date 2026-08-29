const std = @import("std");
const Pcg = std.Random.Pcg;

pub const Random = struct {
    rng: Pcg,

    // TODO: fix initial seed, using the time function
    pub fn init() Pcg {
        const rng = Pcg.init(0x6969);
        return std.Random.Pcg.random(&rng);
    }

    pub fn getRange(
        rng: *Pcg,
        r1: u32,
        r2: u32,
    ) u32 {
        const r = rng.random();
        return r.intRangeAtMost(
            u32,
            r1,
            r2,
        );
    }
};
