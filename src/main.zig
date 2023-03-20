const std = @import("std");
const Inst = @import("cpu.zig").Inst;
const CPU = @import("cpu.zig").CPU;

fn Stack(comptime size: u64) type {
    return struct {
        const Self = @This();
        data: [size]u64,
        top: u8,

        pub fn pop(self: Self) u64 {
            self.top -= 1;
            return self.data[self.top];
        }

        pub fn push(self: Self, val: u64) void {
            self.top += 1;
            self.data[self.top] = val;
            return;
        }
    };
}

pub fn main() anyerror!void {}

test "root" {
    _ = @import("cpu.zig");
}
