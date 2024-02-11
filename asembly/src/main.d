import std.stdio;
import std.string;
import std.uni;
import std.file;
import std.utf;
import std.regex;
import std.algorithm;
import std.conv;

import expansion;
import output;
import analyzer;
import config;

bool showNumbers = false;
bool fromZero = false;
bool showExpanded = false;
bool showLabels = false;

string ver = "kasm 0.0.1";

string inputFile = "";
string outputFile = "";
bool showNonary = false;
bool showMap = false;

string kpuFile = "KPU.K99";

string help = "Keap: Karel Extensible Aggressively Packed Architecture for KPU

USAGE:
  keap [options] <filename> [output-filename]

FLAGS:
  -k, --kpu           sets input KPU file (default ./KPU.K99)

  -t, --text          Shows compiled binary in text format
  -m, --map           Show contents of compiled binary
  -n, --numbers       Shows line/column numbers
  -0,                 Count lines from zero
  -e, --expand        Shows expanded code
  -l, --labels        Do not expand labels with -e

  -v, --version       Prints version
  -h, --help          Show this help message
";

int main(string[] args) {
   //////////////////
   // Process Args //
   //////////////////
   if (args.length == 1) {
      writeln(help);
      return 1;
   }
   for (int i = 1; i < args.length; i++) {
      string arg = args[i];
      if (arg[0] != '-' || arg.length == 1 || arg == "--") {
         if (inputFile == "") {
            inputFile = arg;
            continue;
         }

         if (outputFile == "") {
            outputFile = arg;
            continue;
         }

         writeln("wrong argument: " ~ arg ~ "\nTry 'kasm --help'");
         return 1;
      }

      if (arg[1] == '-')
         switch (arg[2..$]) {
            case "kpu":
               if (i + 1 == args.length) {
                  writeln("-k needs a file");
                  return 1;
               }
               kpuFile = args[++i];
               break;
            case "text":
               showNonary = true;
               break;
            case "map":
               showMap = true;
               break;
            case "numbers":
               showNumbers = true;
               break;
            case "expand":
               showExpanded = true;
               break;
            case "labels":
               showLabels = true;
               break;
            case "help":
               writeln(help);
               return 0;
            case "version":
               writeln(ver);
               break;
            default:
               writeln("wrong argument: " ~ arg ~ "\nTry 'kasm --help'");
               return 1;
         }

      else
         foreach (flag; arg[1..$])
            switch (flag) {
               case 'k':
                  if (i + 1 == args.length) {
                     writeln("-k needs a file");
                     return 1;
                  }
                  kpuFile = args[++i];
                  break;
               case 't':
                  showNonary = true;
                  break;
               case 'm':
                  showMap = true;
                  break;
               case 'n':
                  showNumbers = true;
                  break;
               case '0':
                  fromZero = true;
                  break;
               case 'e':
                  showExpanded = true;
                  break;
               case 'l':
                  showLabels = true;
                  break;
               case 'h':
                  writeln(help);
                  return 0;
               case 'v':
                  writeln(ver);
                  return 0;
               default:
                  writeln("wrong argument: " ~ flag ~ "\nTry 'kasm --help'");
                  return 1;
            }
   }

   /////////////////////
   // File Extraction //
   /////////////////////
   // try read input file //
   string inputContents;
   try {
      inputContents = inputFile.readText.strip;
   } catch (FileException) {
      writeln("File " ~ inputFile ~ " could not be read");
      return 1;
   } catch (UTFException) {
      writeln("Problems while decoding file " ~ inputFile);
      return 1;
   }

   if (inputContents == "") {
      writeln("Input file is empty, nothing to do");
      return 0;
   }

   string[] code;
   try 
      code = expandMacros(inputContents.toLower, inputFile);
   catch (Exception e) {
      writeln("Error: " ~ e.message);
      return 1;
   }

   if (showExpanded && showLabels)
      displayFile(code, showNumbers, fromZero, inputFile);

   try 
      code = expandLables(code, inputFile);
   catch (Exception e) {
      writeln("Error: " ~ e.message);
      return 1;
   }

   if (showExpanded && !showLabels)
      displayFile(code, showNumbers, fromZero, inputFile);

   try 
      code = convertToKytes(code);
   catch (Exception e) {
      writeln("Error: " ~ e.message);
      return 1;
   }

	if (showNonary)
		displayFile(code, showNumbers, fromZero, inputFile);

   /////////////////////
   // WRITE KAREL MAP //
   /////////////////////

   if (!kpuFile.exists) {
      writeln("File " ~ kpuFile ~ " does not exist");
      return 1;
   }

   // try read kpu file //
   string kpuContents;
   try {
      kpuContents = kpuFile.readText.strip;
   } catch (FileException) {
      writeln("File " ~ kpuFile ~ " could not be read");
      return 1;
   } catch (UTFException) {
      writeln("Problems while decoding file " ~ kpuFile);
      return 1;
   }

   if (kpuContents == "") {
      writeln("KPU file is empty");
      return 1;
   }

   // map definition //
   if (kpuContents.canFind("Velikost města:")) {
      kpuContents = replaceFirst!(cap => "Velikost města: " ~
            to!string(mapWidth) ~ ", " ~ to!string(mapHeight) ~ "\n")
            (kpuContents, regex("Velikost města:.*\n"));
   } else if (kpuContents.canFind("Map size:")) {
      kpuContents = replaceFirst!(cap => "Map size: " ~ to!string(mapWidth) ~
            ", " ~ to!string(mapHeight) ~ "\n")
            (kpuContents, regex("Map size:.*\n"));
   }
   else {
      writeln(kpuFile ~ " does not have Map size / Velikost města");
      return 1;
   }

   // map itself //
   if (kpuContents.canFind("Definice města:")) {
      kpuContents = kpuContents.split("Definice města:")[0] ~ "Definice města:\n";
   } else if (kpuContents.canFind("Map definition:")) {
      kpuContents = kpuContents.split("Map definition:")[0] ~ "Map definition:\n";
   } else {
      writeln(kpuFile ~ " does not have Map definition / Definice města");
      return 1;
   }

   string map = getMap(code);
   kpuContents ~= map;

   if (showMap)
      displayMap(map, showNumbers, fromZero);

   if (outputFile == "") {
      string[] tmp = inputFile.split(".");
      if (tmp.length > 2)
         outputFile = join(tmp[0..$-1], ".") ~ ".K99";
      else
         outputFile = tmp[0] ~ ".K99";
   }

   std.file.write(outputFile, kpuContents);

   return 0;
}
