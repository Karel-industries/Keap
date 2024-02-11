#!/bin/python3

import sys

from pprint import pprint

map_size = 20


class Utils:
    def gen_kyte(gid, iid):
        return [int(gid), int(int(iid)/9), int(int(iid)%9)]

class Keap:
    csv_file = ""
    csv_lines = []
    _csv_data = []
    instructions = {}

    conditions = ["eq", "iz", "of", "uf", "nf", "gt", "lt", "ge", "le"]

    def read_file():
        with open(Keap.csv_file, "r") as f:
            for line in f.readlines():
                Keap.csv_lines.append(line.lstrip().rstrip().replace("   ", "").replace("  ", ""))
            Keap.csv_lines.pop(0)  # remove first line

        for line in Keap.csv_lines:
            tmp = line.split(",")
            Keap._csv_data.append(tmp)
        
        for line in Keap._csv_data:
            # gid, iid, ins, reg, reg, cond_index, cond_bit

            if line[3] == "" and line[4] == "": # no reg1 and no reg2 = conditional

                if not line[2] in list(Keap.instructions.keys()):
                    Keap.instructions[line[2]] = {}
                if line[5] == "": # no cond_index
                    Keap.instructions[line[2]][f"{line[6]}"] = Utils.gen_kyte(line[0], line[1])
                else:
                    Keap.instructions[line[2]][f"{Keap.conditions[int(line[5])]} {line[6]}"] = Utils.gen_kyte(line[0], line[1])
            elif line[3] == "" and not line[4] == "": # no reg1 but has reg2
                pass
            elif not line[3] == "" and line[4] == "": # has reg1 but no reg2
                if not line[2] in list(Keap.instructions.keys()):
                    Keap.instructions[line[2]] = {}
                Keap.instructions[line[2]][f"r{line[3]}"] = Utils.gen_kyte(line[0], line[1])
            else: # has reg1 and has reg2
                if not line[2] in list(Keap.instructions.keys()):
                    Keap.instructions[line[2]] = {}
                Keap.instructions[line[2]][f"r{line[3]} r{line[4]}"] = Utils.gen_kyte(line[0], line[1])

        


class ASM:
    file = ""
    lines = []
    program = []

    def run():
        with open(ASM.file, "r", encoding="utf-8") as f:
            for line in f.readlines():
                if not line.rstrip() == "":
                    ASM.lines.append(line.rstrip())

        tmp_lines = []
        for line in ASM.lines:
            if not line == "" and not line.startswith(";"):
                tmp_lines.append(line)

        ASM.lines = tmp_lines

        for line in ASM.lines:
            toks = line.split(" ", 1) # ["uadd", "r0 r0"]
            ASM.program.append(Keap.instructions[toks[0]][toks[1]])



class KPU:
    file = ""
    _start_index = 0
    _lines = []

    _world = [["." for _ in range(map_size)]for _ in range(map_size)]
    world = []

    def prepare_world():
        if len(ASM.program) > 120:
            print(f"Program too long ({len(ASM.program)})")
            exit()
        for i, prg in enumerate(ASM.program):
            x = i%map_size
            y = int(i/map_size)*3 + 4
            #print(prg, x, y)
            for o in range(len(prg)):
                KPU._world[y-o][x] = str(prg[o])
        
        for y in range(map_size):
            KPU.world.append("".join(KPU._world[y]))

    def write():
        with open(KPU.file, "r") as f:
            KPU._lines = f.readlines()
        
        for i, line in enumerate(KPU._lines):
            if line.rstrip().lstrip() == "Definice města:" or line.rstrip().lstrip() == "Map definition:":
                KPU._start_index = i + 1
                break
        

        #print(KPU._start_index)
        
        for _ in range(len(KPU._lines) - KPU._start_index):
            KPU._lines.pop()
        
        with open(KPU.file, "w") as f:
            for line in KPU._lines:
                f.write(line)
            for line in KPU.world:
                f.write(line + "\n")


try:
    Keap.csv_file = sys.argv[1]
    ASM.file = sys.argv[2]
    KPU.file = sys.argv[3]
except:
    print("Usage:")
    print("python3 asembler.py <Keap CSV file> <ASM file> <KPU .K99 file>")
    print("python3 asembler.py ../KeapV1.csv test.asm KPU.K99")
    exit()


print(f"ASM file: {ASM.file}")
print(f"KPU file: {KPU.file}")

Keap.read_file()
ASM.run()
KPU.prepare_world()
#pprint(KPU.world)
KPU.write()
