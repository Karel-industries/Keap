#!/bin/python3

from pprint import pprint


class Keap:
    csv_file = "../KeapV1.csv"
    _csv_lines = []
    _csv_data = []

    def read_file():
        with open(Keap.csv_file, "r") as f:
            Keap._csv_lines = f.readlines()
            Keap._csv_lines.pop(0)  # remove first line

        for line in Keap._csv_lines:
            Keap._csv_data.append(line.lstrip().rstrip().split(";"))


class Utils:
    def gen_kyte(gid, ins):
        return f"{int(gid)} {int(int(ins)/9)} {int(int(ins)%9)}"

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

    def gen_table(ins_data, gid, direction):
        lines = []
        lines.append("| iid | kyte | registers |")
        lines.append("| ---- | ---- | ---- |")
        for t in ins_data:
            lines.append(
                f"| {t[0]} | {Utils.gen_kyte(gid, t[0])} | {Utils.gen_regs(t[1:], direction)} |")

        return lines


class Docs:
    doc_file = "Keap docs (detailed) - generated.md"

    out = []

    _Keap_instructions = {}

    gid_lines = {"0": "== GID 0 - extended ==", "1": "== GID 1 - memory ==", "2": "== GID 2 - arithmetics ==",
                 "3": "== GID 3 -  ==", "4": "== GID 4 - control part 1 ==", "5": "== GID 5 - control part 2 =="}

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
                if not gid in list(Docs._Keap_instructions.keys()):
                    Docs._Keap_instructions[gid] = {}

                if ins in list(Docs._Keap_instructions[gid].keys()):
                    Docs._Keap_instructions[gid][ins].append([iid, reg0, reg1])
                else:
                    Docs._Keap_instructions[gid][ins] = [[iid, reg0, reg1]]
            else:
                gid, iid, ins, reg0 = data
                if not gid in list(Docs._Keap_instructions.keys()):
                    Docs._Keap_instructions[gid] = {}

                if ins in list(Docs._Keap_instructions[gid].keys()):
                    Docs._Keap_instructions[gid][ins].append([iid, reg0])
                else:
                    Docs._Keap_instructions[gid][ins] = [[iid, reg0]]

        for gid in list(Docs.gid_lines.keys()):
            Docs.out.append(f"")
            Docs.out.append(f"# {Docs.gid_lines[gid]}")
            if not gid in list(Docs._Keap_instructions.keys()):
                continue
            for ins in Docs._Keap_instructions[gid]:
                Docs.out.append(f"## {Docs.ins_lines[ins]}")
                ins_data = Docs._Keap_instructions[gid][ins]
                pprint(Docs._Keap_instructions[gid][ins])
                for line in Utils.gen_table(ins_data, int(gid), Docs._arrow_dirs[ins]):
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
