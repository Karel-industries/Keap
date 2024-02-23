#!/bin/python3

import re

############
# GET DATA #
############

with open("analyzer.d", "r") as f:
    analyzer = f.read()
with open("../../KeapV1.csv", "r") as f:
    keap = f.readlines()
    keap.pop(0) # remove header

conditions = ["eq", "iz", "of", "uf", "nf", "gt", "lt", "ge", "le"]

data = [];
for line in keap:
    tmp = line.lstrip().rstrip().split(",")
    data.append({
        "kyte": f"{tmp[0]}{int(tmp[1])//9}{int(tmp[1])%9}",
        "name": tmp[2],
        "r1": tmp[3],
        "r2": tmp[4],
		"cond_id": "",
		"cond_bit": tmp[6]
        })
    if tmp[5] != "":
        data[-1]["cond_id"] = conditions[int(tmp[5])]

######################
# GET SYNTAX CHECKER #
######################

prev_name = data[0]["name"]
mode = "different"

instrs = {
        "one": [],
        "different": [],
        "non_different": [],
        "nothing": [],
        "condition": [],
        "condition_end": []
        }

# also chesk for this
# will use later
firstRegs = []
positional = False
positionals = []

# sort based on arguments
for i, dat in enumerate(data):
    if prev_name != dat["name"]:
        instrs[mode].append(f"\"{data[i-1]['name']}\"")
        prev_name = dat["name"]
        mode = "different"

        if positional:
            positionals.append(data[i-1]["name"])
        firstRegs = []
        positional = False

    if dat["r1"] != "":
        if dat["r2"] == "":
            mode = "one"

        else:
            if dat["r1"] == dat["r2"]:
                mode = "non_different"

            if not dat["r1"] in firstRegs:
                firstRegs.append(dat["r1"])
            if dat["r2"] in firstRegs:
                positional = True

    elif dat["cond_id"] != "":
        mode = "condition";
    elif dat["cond_bit"] != "":
        mode = "condition_end"
    else:
        mode = "nothing"
      
instrs[mode].append(f"\"{data[-1]['name']}\"")
if positional:
    positionals.append(data[-1]["name"])


###########################
# GET THE EVALUATION CODE #
###########################

eval_code = ""

prev_name = ""
prev_reg = ""
prev_cond_bit = ""
for dat in data:
    # instruction inicialization
    if prev_name != dat["name"]:
        prev_name = dat["name"]
        # close if
        if prev_reg != "" or prev_cond_bit != "":
            prev_reg = ""
            prev_cond_bit = ""
            eval_code += "         }\n"

        eval_code += "         break;\n\n" + \
                    f"      case \"{dat['name']}\":\n"

    # instruction #
    # TODO: make some of this a switch
    instr_name = f"\"{dat['name']}\""

    # NO PARAMS #
    if instr_name in instrs["nothing"]:
        eval_code += f"         return \"{dat['kyte']}\";\n\n"

    # CONDITION END #
    elif instr_name in instrs["condition_end"]:
        eval_code += f"         if (tokens[1] == \"{dat['cond_bit']}\")\n" + \
                     f"            return \"{dat['kyte']}\";\n"

    # CONDITION #
    elif instr_name in instrs["condition"]:
        # positional
        if dat["cond_bit"] != prev_cond_bit:
            if prev_cond_bit != "":
                eval_code +=  "         }\n"
            eval_code     += f"         if (tokens[2] == \"{dat['cond_bit']}\") {{\n" #}} for editor ourpses
            prev_cond_bit = dat["cond_bit"]                                           # also WTF it that escape


        # second
        eval_code += f"            if (tokens[1] == \"{dat['cond_id']}\")\n" + \
                     f"               return \"{dat['kyte']}\";\n"

    # REGISTER BASED #
    else:
        # just one
        if dat["r2"] == "":
            eval_code += f"         if (tokens[1] == \"r{dat['r1']}\")\n" + \
                         f"            return \"{dat['kyte']}\";\n"
        else:
            # positonal
            if dat["name"] in positionals:

                if dat["r1"] != prev_reg:
                    if prev_reg != "":
                        eval_code +=  "         }\n"
                    eval_code     += f"         if (tokens[1] == \"r{dat['r1']}\") {{\n" #}} for editor ourpses
                    prev_reg = dat["r1"]                                                 # also WTF it that escape


                # second
                eval_code += f"            if (tokens[2] == \"r{dat['r2']}\")\n" + \
                             f"               return \"{dat['kyte']}\";\n"
            # non-positional
            else:
                # first
                if dat["r1"] != prev_reg:
                    if prev_reg != "":
                        eval_code +=  "         }\n"
                    eval_code     += f"         if (tokens.canFind(\"r{dat['r1']}\")) {{\n" #}}
                    prev_reg = dat["r1"]


                # second
                eval_code += f"            if (tokens.canFind(\"r{dat['r2']}\"))\n" + \
                             f"               return \"{dat['kyte']}\";\n"

# move first 'break;' to the end
eval_code = eval_code[17:] + "      break;\n"


################
# GET NEW CODE #
################
# replace everything between '// #BEGIN' and '// #END'
new_code = analyzer.split("// #BEGIN")[0] + "// #BEGIN\n" \
                    + eval_code + "// #END" + analyzer.split("// #END")[1]


new_code = re.sub("case .*?: // #ONE",
                  "case " + ", ".join(instrs["one"]) + ": // #ONE",
                  new_code)

new_code = re.sub("case .*?: // #DIFFERENT",
                  "case " + ", ".join(instrs["different"]) + ": // #DIFFERENT",
                  new_code)

new_code = re.sub("case .*?: // #NON_DIFFERENT",
                  "case " + ", ".join(instrs["non_different"]) + ": // #NON_DIFFERENT",
                  new_code)

new_code = re.sub("case .*?: // #NOTHING",
                  "case " + ", ".join(instrs["nothing"]) + ": // #NOTHING",
                  new_code)

new_code = re.sub("case .*?: // #CONDITION",
                  "case " + ", ".join(instrs["condition"]) + ": // #CONDITION",
                  new_code)

new_code = re.sub("case .*?: // #CONDITION_END",
                  "case " + ", ".join(instrs["condition_end"]) + ": // #CONDITION_END",
                  new_code)

# write new code #
with open("analyzer.d", "w") as f:
    f.write(new_code)
