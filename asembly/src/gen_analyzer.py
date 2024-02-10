#!/bin/python3

############
# GET DATA #
############

with open("analyzer.d", "r") as f:
    analyzer = f.read()
with open("../../KeapV1.csv", "r") as f:
    keap = f.readlines()
    keap.pop(0) # remove header

data = [];
for line in keap:
    tmp = line.lstrip().rstrip().split(",")
    data.append({
        "kyte": f"{tmp[0]}{int(tmp[1])//9}{int(tmp[1])%9}",
        "name": tmp[2],
        "r1": tmp[3],
        "r2": tmp[4],
        })

###########################
# GET THE EVALUATION CODE #
###########################

eval_code = ""

prev_name = ""
prev_reg  = ""
for dat in data:
    # instruction inicialization
    if prev_name != dat["name"]:
        prev_name = dat["name"]
        # close if
        if prev_reg != "":
            prev_reg = ""
            eval_code += "         }\n"

        eval_code += "      break;\n\n" + \
                    f"      case \"{dat['name']}\":\n"

    # instruction #
    # TODO: make it a switch
    # just one
    if dat["r2"] == "":
        eval_code += f"         if (tokens[1] == \"r{dat['r1']}\")\n" + \
                     f"            return \"{dat['kyte']}\";\n"
    # first
    else:
        if dat["r1"] != prev_reg:
            if prev_reg != "":
                eval_code += "         }\n"
            eval_code    += f"         if (tokens.canFind(\"r{dat['r1']}\")) {{\n"
            prev_reg = dat["r1"]

    # second
        eval_code += f"            if (tokens.canFind(\"r{dat['r2']}\"))\n" + \
                     f"               return \"{dat['kyte']}\";\n"

# move first 'break;' to the end
eval_code = eval_code[13:] + "      break;\n"

# replace everything between '// #BEGIN' and '// #END'
new_code = analyzer.split("// #BEGIN")[0] + "// #BEGIN\n" \
                    + eval_code + "// #END" + analyzer.split("// #END")[1]

# write new code
with open("analyzer.d", "w") as f:
    f.write(new_code)

# print(new_code)
