#!/bin/python3

from pprint import pprint


class Keap:
    csv_file = "../../KeapV1.csv"
    _csv_lines = []
    _csv_data = []

    def read_file():
        with open(Keap.csv_file, "r") as f:
            Keap._csv_lines = f.readlines()
            Keap._csv_lines.pop(0)  # remove first line

        for line in Keap._csv_lines:
            tmp = line.lstrip().rstrip().split(",")
            if tmp[4] == "":
                tmp.pop()
            Keap._csv_data.append(tmp)


class Utils:
    def gen_regs(regs, direction):
        if len(regs) == 1:
            return f"r{regs[0]}"
        else:
            if direction == 0:
                return f"r{regs[0]} <-> r{regs[1]}"
            elif direction == 1:
                return f"r{regs[0]} -> r{regs[1]}"
            elif direction == 2:
                return f"r{regs[0]} <- r{regs[1]}"

    def gen_ins(ins_data):
        if len(ins_data) == 3:
            return f"{ins_data[0]} r{ins_data[1]} r{ins_data[2]}"
        else:
            return f"{ins_data[0]} r{ins_data[1]}"

    def gen_table(ins_data, direction):
        lines = []
        lines.append("| instruction | registers |")
        lines.append("| ---- | ---- |")
        print(ins_data)
        for t in ins_data:
            lines.append(
                f"| {Utils.gen_ins(t)} | {Utils.gen_regs(t[1:], direction)} |")

        return lines


class Docs:
    doc_file = "Keap ASM docs (detailed) - generated.md"

    out = []

    _Keap_instructions = {}

    ins_lines = {"swp": "SWP - fast local-to-local swap (swaps between two regs)", 
                 "wll": "WLL - local to local write (copy from reg to reg2)",
                 "wlr": "WLR - local to remote write (copy data from reg to ram at reg2)", 
                 "wrl": "WRL - remote to local write (copy data from ram at reg2 to reg)",
                 "drl": "DRL - local drain (set local register to zero)",
                 "drr": "DRR - remote drain (set remote address at reg to zero)",
                 "uadd": "UADD - add unsigned value in reg2 to reg",
                 "usub": "USUB - substract unsigned value in reg2 from reg",
                 "umul": "UMUL - multiply register by register2 (TODO/RESERVED)",
                 "udiv": "UDIV - divide register by register2 (TODO/RESERVED)",
                 "uinc": "UINC increment register by 1",
                 "udec": "UDEC decrement register by 1",
                 }

    _arrow_dirs = {"swp": 0, "wll":1, "wlr":1, "wrl":2, "drl":-1, "drr":-1, "uadd":2, "usub":2, "umul":2, "udiv":2, "uinc":-1, "udec":-1}

    def gen_docs():
        for data in Keap._csv_data:
            if len(data) == 5:
                gid, iid, ins, reg0, reg1 = data
                if ins in list(Docs._Keap_instructions.keys()):
                    Docs._Keap_instructions[ins].append([ins, reg0, reg1])
                else:
                    Docs._Keap_instructions[ins] = [[ins, reg0, reg1]]
            else:
                gid, iid, ins, reg0 = data

                if ins in list(Docs._Keap_instructions.keys()):
                    Docs._Keap_instructions[ins].append([ins, reg0])
                else:
                    Docs._Keap_instructions[ins] = [[ins, reg0]]


        for ins in Docs._Keap_instructions:
            Docs.out.append(f"## {Docs.ins_lines[ins]}")
            ins_data = Docs._Keap_instructions[ins]
            pprint(ins_data)
            print("\n\n\n\n\n\n\n")
            for line in Utils.gen_table(ins_data, Docs._arrow_dirs[ins]):
                Docs.out.append(line)
            Docs.out.append(f"")

    def write_docs():
        with open(Docs.doc_file, "w") as f:
            for line in Docs.out:
                f.write(f"{line}\n")


Keap.read_file()
Docs.gen_docs()
Docs.write_docs()

pprint(Docs.out)
