#!/bin/python3

import platform, subprocess,os

files = ["main.d", "analyzer.d", "config.d", "expansion.d", "output.d"]

if platform.system() == "Linux":
    if subprocess.run(["which","dmd"], stdout=open(os.devnull, "w"),
                      stderr=subprocess.STDOUT).returncode == 0:
        use = "dmd"

    elif subprocess.run(["which","ldc"], stdout=open(os.devnull, "w"),
                      stderr=subprocess.STDOUT).returncode == 0:
        use = "ldc"

    elif subprocess.run(["which","ldc2"], stdout=open(os.devnull, "w"),
                      stderr=subprocess.STDOUT).returncode == 0:
        use = "ldc2"

    elif subprocess.run(["which","gdc"], stdout=open(os.devnull, "w"),
                      stderr=subprocess.STDOUT).returncode == 0:
        use = "gdc"

    else:
        print("no compiler found")
        exit(1)

    print(f"usind {use}")
    out = subprocess.run([use, "-of=keap"] + files)
    if out.returncode == 0:
        subprocess.run(["rm", "keap.o"])

else:
    print(f"{platform.system()} is not supported yet")
