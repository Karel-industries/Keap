#!/bin/python3

from pprint import pprint


class regs:

    def gen_unique(r):
        return [[i, j] for i in range(r) for j in range(i + 1, r)]

    def gen_not_same(r):
        out = []
        for i in range(r):
            for j in range(r):
                if not i == j:
                    out.append([i, j])
        return out

    def gen_same(r):
        out = []
        for i in range(r):
            for j in range(r):
                out.append([i, j])
        return out

    def gen_range(r):
        out = []
        for i in range(r):
            out.append([i])
        return out

    # list of register lines (combinaion of registers)
    lines = {"swp": gen_unique(5), "wll": gen_not_same(5), "wlr": gen_not_same(5), "wrl": gen_not_same(5), "drl": gen_range(5), "drr": gen_range(
        5), "uadd": gen_same(4), "usub": gen_not_same(4), "umul": gen_not_same(4), "udiv": gen_not_same(4), "uinc": gen_range(4), "udec": gen_range(4)}


class Keap:
    file = "KeapV1.csv"
    data = []

    instructions = [[],
                    ["swp", "wll", "wlr", "wrl", "drl", "drr",],
                    ["uadd", "usub", "umul", "udiv", "uinc", "udec",],
                    [],
                    [],
                    []]

    def gen_Keap():
        Keap.data.append(["gid", "iid", "ins", "reg", "reg"])
        for gid in range(6):
            iid = 0
            for ins in Keap.instructions[gid]:
                print(ins)
                for reg in regs.lines[ins]:
                    if len(reg) == 1:
                        Keap.data.append(
                            [str(gid), str(iid), str(ins), str(reg[0])])
                    else:
                        Keap.data.append(
                            [str(gid), str(iid), str(ins), str(reg[0]), str(reg[1])])
                    iid += 1

    def write_file():
        with open(Keap.file, "w") as f:
            for line in Keap.data:
                f.write(f"{';'.join(line)}\n")


Keap.gen_Keap()
Keap.write_file()
