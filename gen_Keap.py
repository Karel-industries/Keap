#!/bin/python3

from pprint import pprint

class Params:

    def gen_reg_unique(r):
        return ([[i, j] for i in range(r) for j in range(i + 1, r)], "regs")

    def gen_reg_not_same(r):
        out = []
        for i in range(r):
            for j in range(r):
                if not i == j:
                    out.append([i, j])
        return (out, "regs")

    def gen_reg_same(r):
        out = []
        for i in range(r):
            for j in range(r):
                out.append([i, j])
        return (out, "regs")

    def gen_reg_range(r):
        out = []
        for i in range(r):
            out.append([i])
        return (out, "regs")

    def gen_cond_bits_range(bits):
        out = []
        for bit in range(bits):
            for cond in range(9):
                out.append([bit, cond])
        return (out, "conds_bits")

    def gen_bits_range(bits):
        return ([i for i in range(bits)], "bits")

    # list of register lines (combinaion of registers)
    lines = {"swp": gen_reg_unique(5), "wll": gen_reg_not_same(5), "wlr": gen_reg_not_same(5), "wrl": gen_reg_not_same(5), "drl": gen_reg_range(5), "drr": gen_reg_range(
        5), "uadd": gen_reg_same(4), "usub": gen_reg_not_same(4), "umul": gen_reg_not_same(4), "udiv": gen_reg_not_same(4), "uinc": gen_reg_range(4), "udec": gen_reg_range(4),
        "ce": gen_cond_bits_range(4), "ice": gen_cond_bits_range(4), "re": gen_bits_range(4)}


class Keap:
    file = "KeapV1.csv"
    data = []

    instructions = [[],
                    ["swp", "wll", "wlr", "wrl", "drl", "drr",],
                    ["uadd", "usub", "umul", "udiv", "uinc", "udec",],
                    ["ce", "ice", "re"],
                    [],
                    []]

    def gen_Keap():
        Keap.data.append(["gid", "iid", "ins", "reg", "reg", "cond_index", "cond_bit"])
        for gid in range(6):
            iid = 0
            for ins in Keap.instructions[gid]:
                print(ins)

                ins_line = Params.lines[ins]

                if ins_line[1] == "regs":
                    for params in ins_line[0]:
                        if len(params) == 2:
                            Keap.data.append(
                                [str(gid), str(iid), str(ins), str(params[0]), str(params[1])])
                        elif len(params) == 1:
                            Keap.data.append(
                                [str(gid), str(iid), str(ins), str(params[0])])
                        iid += 1

                elif ins_line[1] == "conds_bits":
                    for cond in ins_line[0]:
                        Keap.data.append(
                            [str(gid), str(iid), str(ins), "", "", str(cond[1]), str(cond[0])])
                        iid += 1

                elif ins_line[1] == "bits":
                    for bit in ins_line[0]:
                        Keap.data.append(
                            [str(gid), str(iid), str(ins), "", "", "", str(bit)])
                        iid += 1

    def write_file():
        with open(Keap.file, "w") as f:
            for line in Keap.data:
                if len(line)==5:
                    f.write(f"{','.join(line)}\n")
                else:
                    f.write(f"{','.join(line)}, \n")


Keap.gen_Keap()
Keap.write_file()
