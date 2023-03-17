const std = @import("std");

const Inst = struct {
    const Ref = union(enum) {
        Value: u64,
        Register: u8,
    };

    op_code: CPU.OpCodes,
    out: u8, // Is always a register number.
    arg1: Ref = undefined,
    arg2: Ref = undefined,

    pub fn Set(out_reg: u8, in_ref: Ref) Inst {
        return .{
            .op_code = .Set,
            .out = out_reg,
            .arg1 = in_ref,
        };
    }

    pub fn Add(out_reg: u8, arg1: Ref, arg2: Ref) Inst {
        return .{
            .op_code = .Add,
            .out = out_reg,
            .arg1 = arg1,
            .arg2 = arg2,
        };
    }

    pub fn Sub(out_reg: u8, arg1: Ref, arg2: Ref) Inst {
        return .{
            .op_code = .Sub,
            .out = out_reg,
            .arg1 = arg1,
            .arg2 = arg2,
        };
    }

    pub fn Div(out_reg: u8, arg1: Ref, arg2: Ref) Inst {
        return .{
            .op_code = .Div,
            .out = out_reg,
            .arg1 = arg1,
            .arg2 = arg2,
        };
    }

    pub fn Mul(out_reg: u8, arg1: Ref, arg2: Ref) Inst {
        return .{
            .op_code = .Mul,
            .out = out_reg,
            .arg1 = arg1,
            .arg2 = arg2,
        };
    }

    pub fn Pow(out_reg: u8, arg1: Ref, arg2: Ref) Inst {
        return .{
            .op_code = .Pow,
            .out = out_reg,
            .arg1 = arg1,
            .arg2 = arg2,
        };
    }

    pub fn display(insts: []Inst) void {
        for (insts) |inst, idx| {
            std.debug.print("{}: OP_CODE={} OUT={} ARG1={} ARG2={}\n", .{ idx, inst.op_code, inst.out, inst.arg1, inst.arg2 });
        }
    }
};

const CPU = struct {
    const Self = @This();
    pub const OpCodes = enum {
        Set,
        Add,
        Sub,
        Div,
        Mul,
        Pow,
    };

    const Register = union(enum) {
        // Reference: u64, // Heap.
        Value: u64, // Value in register (e.g. an int).
        // CodeReference: u64, // Data part of binary.
    };

    registers: [16]Register = undefined,

    pub fn init() CPU {
        return .{};
    }

    pub fn registers_state(self: Self) void {
        for (self.registers) |reg, idx| {
            std.debug.print("{}: {}\n", .{ idx, reg.Value });
        }
    }

    pub fn run(self: *Self, insts: []Inst) !void {
        for (insts) |inst| {
            switch (inst.op_code) {
                .Set => {
                    self.registers[inst.out] = switch (inst.arg1) {
                        Inst.Ref.Register => |reg| self.registers[reg],
                        Inst.Ref.Value => |val| .{ .Value = val },
                    };
                },
                .Add => {
                    const arg1 = switch (inst.arg1) {
                        Inst.Ref.Register => |reg| self.registers[reg].Value,
                        Inst.Ref.Value => |val| val,
                    };
                    const arg2 = switch (inst.arg2) {
                        Inst.Ref.Register => |reg| self.registers[reg].Value,
                        Inst.Ref.Value => |val| val,
                    };
                    self.registers[inst.out] = .{ .Value = arg1 + arg2 };
                },
                .Sub => {
                    const arg1 = switch (inst.arg1) {
                        Inst.Ref.Register => |reg| self.registers[reg].Value,
                        Inst.Ref.Value => |val| val,
                    };
                    const arg2 = switch (inst.arg2) {
                        Inst.Ref.Register => |reg| self.registers[reg].Value,
                        Inst.Ref.Value => |val| val,
                    };
                    self.registers[inst.out] = .{ .Value = arg1 - arg2 };
                },
                .Div => {
                    const arg1 = switch (inst.arg1) {
                        Inst.Ref.Register => |reg| self.registers[reg].Value,
                        Inst.Ref.Value => |val| val,
                    };
                    const arg2 = switch (inst.arg2) {
                        Inst.Ref.Register => |reg| self.registers[reg].Value,
                        Inst.Ref.Value => |val| val,
                    };
                    self.registers[inst.out] = .{ .Value = arg1 / arg2 };
                },
                .Mul => {
                    const arg1 = switch (inst.arg1) {
                        Inst.Ref.Register => |reg| self.registers[reg].Value,
                        Inst.Ref.Value => |val| val,
                    };
                    const arg2 = switch (inst.arg2) {
                        Inst.Ref.Register => |reg| self.registers[reg].Value,
                        Inst.Ref.Value => |val| val,
                    };
                    self.registers[inst.out] = .{ .Value = arg1 * arg2 };
                },
                .Pow => {
                    const arg1 = switch (inst.arg1) {
                        Inst.Ref.Register => |reg| self.registers[reg].Value,
                        Inst.Ref.Value => |val| val,
                    };
                    const arg2 = switch (inst.arg2) {
                        Inst.Ref.Register => |reg| self.registers[reg].Value,
                        Inst.Ref.Value => |val| val,
                    };
                    self.registers[inst.out] = .{ .Value = std.math.pow(u64, arg1, arg2) };
                },
            }
        }
    }
};

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
        Inst.Set(
            0,
            .{ .Value = 10 },
        ),
        Inst.Set(
            1,
            .{ .Value = 10 },
        ),
        Inst.Add(
            2,
            .{ .Register = 0 },
            .{ .Register = 1 },
        ),
        Inst.Sub(
            1,
            .{ .Register = 1 },
            .{ .Register = 0 },
        ),
        Inst.Div(
            2,
            .{ .Register = 2 },
            .{ .Register = 0 },
        ),
        Inst.Mul(
            3,
            .{ .Register = 0 },
            .{ .Register = 2 },
        ),
        Inst.Pow(
            4,
            .{ .Register = 0 },
            .{ .Value = 3 },
        ),
    };
    Inst.display(&insts);
    var cpu = CPU.init();
    try cpu.run(&insts);
    cpu.registers_state();
}

test "simple test" {
    try std.testing.expectEqual(10, 3 + 7);
}
