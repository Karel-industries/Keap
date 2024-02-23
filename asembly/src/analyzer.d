import std.stdio;
import std.algorithm;
import std.string;
import std.conv;
import std.regex;

import config;

auto newLine = regex("[\\r\\n]");
auto whiteSpace = regex("\\s+");

/////////////////
// ACTUAL CODE //
/////////////////
string[] convertToKytes (string[] code) {
   bool inMacro = false;
   string[] output = [];

   // go through code //
   for (int i = 1; i <= code.length; i++) {
      string line = code[i-1].strip;
      if (line == "" || line[0] == ';')
         continue;

      string[] tokens = line.split(";")[0].strip.split(whiteSpace);

      // macros // (do not evaluate)
      switch (tokens[0]) {
         case ".macro":
            inMacro = true;
            break;
         case ".endmacro":
            inMacro = false;
            break;

         default: break;
      }

      if (inMacro) continue;

      // preprocessors //
      if (tokens[0][0] == '.') {
         switch (tokens[0]) {
            /*
               NOT NEEDED:
               .HERE
             */
            case ".padding":
               for (int j = 0; j < to!int(tokens[1]); j++)
                  output ~= "000";
               break;

            case ".data":
               if (tokens[1][0] == 'd') {
                  string s = to!string(to!int(tokens[1][1..$]), 9);
                  ulong left = 3 - s.length;
                  for (int j = 0; j < left; j++)
                     s = "0" ~ s;
                  output ~= s;
               } else
                  output ~= tokens[1][1..$];
               break;

            default: break;
         }
      }

      // instructions //
      else {
         output ~= instructionsDo(tokens);
      }

      if (output.length > maxInstructions)
         throw new Exception("Code has more instructions than "
               ~ to!string(maxInstructions));
   }

   return output;
}

//////////////////
// INSTRUCTIONS //
//////////////////

// test //
immutable string[] registers = ["r0", "r1", "r2", "r3", "r4"];

void syntaxCheck(string[] tokens, int line, string fileName) pure {
   switch (tokens[0]) {
      case ".padding":
         if (tokens.length != 2)
            wrongArgNum(".PADDING", line, fileName);
         if (!tokens[1].isNumeric || to!int(tokens[1]) <= 0)
            wrongArgs(".PADDING", line, fileName);

         break;

      case ".data":
         if (tokens.length != 2)
            wrongArgNum(".DATA", line, fileName);

         if (tokens[1].length >= 2) {
            if (tokens[1][0] == 'd' && tokens[1][1..$].isNumeric
            && !(tokens[1][1] == '0' && tokens[1] != "d0")){
               int i = to!int(tokens[1][1..$]);
               if (i >= 0 && i <= 728)
                  return;
            }
            else if (tokens[1][0] == 'n' && tokens[1][1..$].isNumeric
            && !tokens[1][1..$].canFind("9")) {
               int i = to!int(tokens[1][1..$], 9);
               if (i >= 0 && i <= 728)
                  return;
            }
         }

         wrongArgs(".DATA", line, fileName);
         break;

      case "drl", "drr", "uinc", "udec": // #ONE
         if (tokens.length != 2)
            wrongArgNum(tokens[0], line, fileName);

         if (!registers.canFind(tokens[1]))
            wrongArgs(tokens[0], line, fileName);
         break;

      case "swp", "wll", "wlr", "wrl", "usub", "umul", "udiv": // #DIFFERENT
         if (tokens.length != 3)
            wrongArgNum(tokens[0], line, fileName);

         if (!registers.canFind(tokens[1]) || !registers.canFind(tokens[2])
               || tokens[1] == tokens[2])
            wrongArgs(tokens[0], line, fileName);
         break;

      case "uadd": // #NON_DIFFERENT
         if (tokens.length != 3)
            wrongArgNum(tokens[0], line, fileName);

         if (!registers.canFind(tokens[1]) || !registers.canFind(tokens[2]))
            wrongArgs(tokens[0], line, fileName);
         break;

		case "?": // #NOTHING
			if (tokens.length != 1)
				wrongArgNum(tokens[0], line, fileName);
			break;

		case "??": // #CONDITION
			if (tokens.length != 3)
				wrongArgNum(tokens[0], line, fileName);

			int t1 = to!int(tokens[1]);
			int t2 = to!int(tokens[2]);
			if (t1 < 0 || t1 > 8 || t2 < 0 || t2 > 3)
				wrongArgs(tokens[0], line, fileName);
			break;

		case "???": // #CONDITION_END
			if (tokens.length != 2)
				wrongArgNum(tokens[0], line, fileName);

			int t1 = to!int(tokens[1]);
			int t2 = to!int(tokens[2]);
			if (t1 < 0 || t1 > 3)
				wrongArgs(tokens[0], line, fileName);
			break;

      default:
         if (tokens[0].length == 0 || tokens[0][0] == '.'
               || tokens[0][0] == '!' || tokens[0] == " ")
            return;

         throw new Exception("Unknown instruction " ~ tokens[0] ~ " in file: "
               ~ fileName ~ " at line: " ~ to!string(line));
   }
}

// do //
string instructionsDo(string[] tokens) pure {
   switch (tokens[0]) {
// #BEGIN

      case "swp":
         if (tokens.canFind("r0")) {
            if (tokens.canFind("r1"))
               return "100";
            if (tokens.canFind("r2"))
               return "101";
            if (tokens.canFind("r3"))
               return "102";
            if (tokens.canFind("r4"))
               return "103";
         }
         if (tokens.canFind("r1")) {
            if (tokens.canFind("r2"))
               return "104";
            if (tokens.canFind("r3"))
               return "105";
            if (tokens.canFind("r4"))
               return "106";
         }
         if (tokens.canFind("r2")) {
            if (tokens.canFind("r3"))
               return "107";
            if (tokens.canFind("r4"))
               return "108";
         }
         if (tokens.canFind("r3")) {
            if (tokens.canFind("r4"))
               return "110";
         }
      break;

      case "wll":
         if (tokens[1] == "r0") {
            if (tokens[2] == "r1")
               return "111";
            if (tokens[2] == "r2")
               return "112";
            if (tokens[2] == "r3")
               return "113";
            if (tokens[2] == "r4")
               return "114";
         }
         if (tokens[1] == "r1") {
            if (tokens[2] == "r0")
               return "115";
            if (tokens[2] == "r2")
               return "116";
            if (tokens[2] == "r3")
               return "117";
            if (tokens[2] == "r4")
               return "118";
         }
         if (tokens[1] == "r2") {
            if (tokens[2] == "r0")
               return "120";
            if (tokens[2] == "r1")
               return "121";
            if (tokens[2] == "r3")
               return "122";
            if (tokens[2] == "r4")
               return "123";
         }
         if (tokens[1] == "r3") {
            if (tokens[2] == "r0")
               return "124";
            if (tokens[2] == "r1")
               return "125";
            if (tokens[2] == "r2")
               return "126";
            if (tokens[2] == "r4")
               return "127";
         }
         if (tokens[1] == "r4") {
            if (tokens[2] == "r0")
               return "128";
            if (tokens[2] == "r1")
               return "130";
            if (tokens[2] == "r2")
               return "131";
            if (tokens[2] == "r3")
               return "132";
         }
      break;

      case "wlr":
         if (tokens[1] == "r0") {
            if (tokens[2] == "r1")
               return "133";
            if (tokens[2] == "r2")
               return "134";
            if (tokens[2] == "r3")
               return "135";
            if (tokens[2] == "r4")
               return "136";
         }
         if (tokens[1] == "r1") {
            if (tokens[2] == "r0")
               return "137";
            if (tokens[2] == "r2")
               return "138";
            if (tokens[2] == "r3")
               return "140";
            if (tokens[2] == "r4")
               return "141";
         }
         if (tokens[1] == "r2") {
            if (tokens[2] == "r0")
               return "142";
            if (tokens[2] == "r1")
               return "143";
            if (tokens[2] == "r3")
               return "144";
            if (tokens[2] == "r4")
               return "145";
         }
         if (tokens[1] == "r3") {
            if (tokens[2] == "r0")
               return "146";
            if (tokens[2] == "r1")
               return "147";
            if (tokens[2] == "r2")
               return "148";
            if (tokens[2] == "r4")
               return "150";
         }
         if (tokens[1] == "r4") {
            if (tokens[2] == "r0")
               return "151";
            if (tokens[2] == "r1")
               return "152";
            if (tokens[2] == "r2")
               return "153";
            if (tokens[2] == "r3")
               return "154";
         }
      break;

      case "wrl":
         if (tokens[1] == "r0") {
            if (tokens[2] == "r1")
               return "155";
            if (tokens[2] == "r2")
               return "156";
            if (tokens[2] == "r3")
               return "157";
            if (tokens[2] == "r4")
               return "158";
         }
         if (tokens[1] == "r1") {
            if (tokens[2] == "r0")
               return "160";
            if (tokens[2] == "r2")
               return "161";
            if (tokens[2] == "r3")
               return "162";
            if (tokens[2] == "r4")
               return "163";
         }
         if (tokens[1] == "r2") {
            if (tokens[2] == "r0")
               return "164";
            if (tokens[2] == "r1")
               return "165";
            if (tokens[2] == "r3")
               return "166";
            if (tokens[2] == "r4")
               return "167";
         }
         if (tokens[1] == "r3") {
            if (tokens[2] == "r0")
               return "168";
            if (tokens[2] == "r1")
               return "170";
            if (tokens[2] == "r2")
               return "171";
            if (tokens[2] == "r4")
               return "172";
         }
         if (tokens[1] == "r4") {
            if (tokens[2] == "r0")
               return "173";
            if (tokens[2] == "r1")
               return "174";
            if (tokens[2] == "r2")
               return "175";
            if (tokens[2] == "r3")
               return "176";
         }
      break;

      case "drl":
         if (tokens[1] == "r0")
            return "177";
         if (tokens[1] == "r1")
            return "178";
         if (tokens[1] == "r2")
            return "180";
         if (tokens[1] == "r3")
            return "181";
         if (tokens[1] == "r4")
            return "182";
      break;

      case "drr":
         if (tokens[1] == "r0")
            return "183";
         if (tokens[1] == "r1")
            return "184";
         if (tokens[1] == "r2")
            return "185";
         if (tokens[1] == "r3")
            return "186";
         if (tokens[1] == "r4")
            return "187";
      break;

      case "uadd":
         if (tokens[1] == "r0") {
            if (tokens[2] == "r0")
               return "200";
            if (tokens[2] == "r1")
               return "201";
            if (tokens[2] == "r2")
               return "202";
            if (tokens[2] == "r3")
               return "203";
         }
         if (tokens[1] == "r1") {
            if (tokens[2] == "r0")
               return "204";
            if (tokens[2] == "r1")
               return "205";
            if (tokens[2] == "r2")
               return "206";
            if (tokens[2] == "r3")
               return "207";
         }
         if (tokens[1] == "r2") {
            if (tokens[2] == "r0")
               return "208";
            if (tokens[2] == "r1")
               return "210";
            if (tokens[2] == "r2")
               return "211";
            if (tokens[2] == "r3")
               return "212";
         }
         if (tokens[1] == "r3") {
            if (tokens[2] == "r0")
               return "213";
            if (tokens[2] == "r1")
               return "214";
            if (tokens[2] == "r2")
               return "215";
            if (tokens[2] == "r3")
               return "216";
         }
      break;

      case "usub":
         if (tokens[1] == "r0") {
            if (tokens[2] == "r1")
               return "217";
            if (tokens[2] == "r2")
               return "218";
            if (tokens[2] == "r3")
               return "220";
         }
         if (tokens[1] == "r1") {
            if (tokens[2] == "r0")
               return "221";
            if (tokens[2] == "r2")
               return "222";
            if (tokens[2] == "r3")
               return "223";
         }
         if (tokens[1] == "r2") {
            if (tokens[2] == "r0")
               return "224";
            if (tokens[2] == "r1")
               return "225";
            if (tokens[2] == "r3")
               return "226";
         }
         if (tokens[1] == "r3") {
            if (tokens[2] == "r0")
               return "227";
            if (tokens[2] == "r1")
               return "228";
            if (tokens[2] == "r2")
               return "230";
         }
      break;

      case "umul":
         if (tokens[1] == "r0") {
            if (tokens[2] == "r1")
               return "231";
            if (tokens[2] == "r2")
               return "232";
            if (tokens[2] == "r3")
               return "233";
         }
         if (tokens[1] == "r1") {
            if (tokens[2] == "r0")
               return "234";
            if (tokens[2] == "r2")
               return "235";
            if (tokens[2] == "r3")
               return "236";
         }
         if (tokens[1] == "r2") {
            if (tokens[2] == "r0")
               return "237";
            if (tokens[2] == "r1")
               return "238";
            if (tokens[2] == "r3")
               return "240";
         }
         if (tokens[1] == "r3") {
            if (tokens[2] == "r0")
               return "241";
            if (tokens[2] == "r1")
               return "242";
            if (tokens[2] == "r2")
               return "243";
         }
      break;

      case "udiv":
         if (tokens[1] == "r0") {
            if (tokens[2] == "r1")
               return "244";
            if (tokens[2] == "r2")
               return "245";
            if (tokens[2] == "r3")
               return "246";
         }
         if (tokens[1] == "r1") {
            if (tokens[2] == "r0")
               return "247";
            if (tokens[2] == "r2")
               return "248";
            if (tokens[2] == "r3")
               return "250";
         }
         if (tokens[1] == "r2") {
            if (tokens[2] == "r0")
               return "251";
            if (tokens[2] == "r1")
               return "252";
            if (tokens[2] == "r3")
               return "253";
         }
         if (tokens[1] == "r3") {
            if (tokens[2] == "r0")
               return "254";
            if (tokens[2] == "r1")
               return "255";
            if (tokens[2] == "r2")
               return "256";
         }
      break;

      case "uinc":
         if (tokens[1] == "r0")
            return "257";
         if (tokens[1] == "r1")
            return "258";
         if (tokens[1] == "r2")
            return "260";
         if (tokens[1] == "r3")
            return "261";
      break;

      case "udec":
         if (tokens[1] == "r0")
            return "262";
         if (tokens[1] == "r1")
            return "263";
         if (tokens[1] == "r2")
            return "264";
         if (tokens[1] == "r3")
            return "265";
      break;
// #END

      default: break;
   }
   return "";
}

////////////
// ERRORS //
////////////
string wrongArgNum(string name, int line, string fileName) pure {
   throw new Exception("Wrong number of arguments for " ~ name ~ " in file: "
         ~ fileName ~ " at line: " ~ to!string(line));
}

string wrongArgs(string name, int line, string fileName) pure {
   throw new Exception("Wrong argument given to " ~ name ~ " in file: "
         ~ fileName ~ " at line: " ~ to!string(line));
}
