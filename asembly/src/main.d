import std.stdio;
import std.file;
import std.string;
import std.uni;

import expansion;
import output;
import analyzer;

bool showNumbers = false;
bool fromZero = false;
bool showExpanded = false;
bool showLabels = false;

string ver = "kasm 0.0.1";

string inputFile = "";
string outputFile = "";
bool showNonary = false;
bool showMap = false;

string help = "Keap: Karel Extensible Aggressively Packed Architecture for KPU

USAGE:
  keap [options] <filename> [output-filename]

FLAGS:
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
   foreach (arg; args[1..$]) {
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
   string contents = cast(string)read(inputFile);
   if (contents.strip == "") {
      writeln("Input file is empty, nothing to do");
      return 0;
   }

   string[] code;
   try 
      code = expandMacros(contents.toLower, inputFile);
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

   return 0;
}
