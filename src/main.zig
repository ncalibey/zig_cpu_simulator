const std = @import("std");
const Inst = @import("cpu.zig").Inst;
const CPU = @import("cpu.zig").CPU;

fn Memory(comptime stack_size: u8, comptime heap_size: u8) type {
    return struct {
        stack: Stack(stack_size),
        heap: [heap_size]u8,
    };
}

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

pub fn main() anyerror!void {
    var insts = [_]Inst{
        Inst.Set(0, 10),
        Inst.Set(1, 10),
        Inst.Add(1, 0, 1),
        Inst.Set(3, 3),
        Inst.Pow(2, 0, 3),
        Inst.Sub(4, 2, 2),
    };
    Inst.display(&insts);
    var cpu = CPU.init();
    try cpu.run(&insts);
    cpu.registers_state();
}

test "should set value in register" {
    var insts = [_]Inst{
        Inst.Set(0, 10),
    };
    var cpu = CPU.init();
    try cpu.run(&insts);

    try std.testing.expectEqual(@as(u64, 10), cpu.registers[0]);
}

test "should add values in registers" {
    var insts = [_]Inst{
        Inst.Set(0, 10),
        Inst.Set(1, 10),
        Inst.Add(2, 0, 1),
    };
    var cpu = CPU.init();
    try cpu.run(&insts);

    try std.testing.expectEqual(@as(u64, 20), cpu.registers[2]);
}

test "should subtract values in registers" {
    var insts = [_]Inst{
        Inst.Set(0, 20),
        Inst.Set(1, 10),
        Inst.Sub(2, 0, 1),
    };
    var cpu = CPU.init();
    try cpu.run(&insts);

    try std.testing.expectEqual(@as(u64, 10), cpu.registers[2]);
}

test "should multiply values in registers" {
    var insts = [_]Inst{
        Inst.Set(0, 20),
        Inst.Set(1, 10),
        Inst.Mul(2, 0, 1),
    };
    var cpu = CPU.init();
    try cpu.run(&insts);

    try std.testing.expectEqual(@as(u64, 200), cpu.registers[2]);
}

test "should divide values in registers" {
    var insts = [_]Inst{
        Inst.Set(0, 20),
        Inst.Set(1, 10),
        Inst.Div(2, 0, 1),
    };
    var cpu = CPU.init();
    try cpu.run(&insts);

    try std.testing.expectEqual(@as(u64, 2), cpu.registers[2]);
}

test "should raise value in register 1 by value in register 2" {
    var insts = [_]Inst{
        Inst.Set(0, 2),
        Inst.Set(1, 5),
        Inst.Pow(2, 0, 1),
    };
    var cpu = CPU.init();
    try cpu.run(&insts);

    try std.testing.expectEqual(@as(u64, 32), cpu.registers[2]);
}
