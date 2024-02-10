import std.stdio;
import std.string;
import std.regex;
import std.conv;

import analyzer;

////////////
// Macros //
////////////

// Define stuff //
struct Macro {
   string[] params;
   string name;
   int startLine;
   string code = "";

   string[] apply(string[] args, string file, int origin) {
      for (int i = 0; i < params.length; i++) {
			// fix regex
			if (args[i][0] == '$')
				args[i] = "$" ~ args[i];
         // only match entire words
         code = code.replaceAll(regex("\\b" ~ params[i] ~ "\\b"), args[i]);
		}

      // yes, macros are recursive
      return applyMacros(code[1..$].split(newLine), startLine+1, file
            ~ " while expanding macro !" ~ name ~ " at " ~ to!string(origin));
   }
}

Macro[string] macros;

string[] expandMacros(string code, string fileName) {
	int macroStartLine = 0;
	string currentMacro = "";

   string[] lines = code.split(newLine);

   // get macros //
   for (int i = 1; i <= lines.length; i++) {
      string line = lines[i-1].strip;
      if (line == "")
         line = " ";

      string[] tokens = line.split(";")[0].split(whiteSpace);
		if (tokens.length == 0)
			tokens = [" "];
      // starting macro
      if (tokens[0] == ".macro") {
         if (currentMacro != "")
            throw new Exception("Macro embedding in file " ~ fileName
                  ~ " at line " ~ to!string(i) ~ " " ~ line);

         if (tokens.length < 2)
            throw new Exception("Not named in file " ~ fileName
                  ~ " at line " ~ to!string(i));

         currentMacro = tokens[1];
         macroStartLine = i;
         macros[currentMacro] = Macro(tokens[2..$], currentMacro,  macroStartLine);

      // ending macro
      } else if (tokens[0] == ".endmacro") {
         if (currentMacro == "")
            throw new Exception("Macro not opened in file " ~ fileName
                  ~ " at line " ~ to!string(i));
         currentMacro = "";

      // readnig macros
      } else if (currentMacro != "") {
         if (tokens[0] == "!"~currentMacro)
            throw new Exception("Recursive macro in file " ~ fileName
                  ~ " at line " ~ to!string(i) ~ " " ~ line);
         if (tokens[0] == ".here")
            throw new Exception(".HERE in macro in file " ~ fileName
                  ~ " at line " ~ to!string(i) ~ " " ~ line);

         macros[currentMacro].code ~= "\n" ~ line.strip;
      }
   }

   // not closed macros
   if (currentMacro != "")
      throw new Exception("Macro not closed in file " ~ fileName
            ~ " at line " ~ to!string(macroStartLine));

   // apply macros //
   return applyMacros(lines, 1, fileName);
}

// this will currently evaluate macros even in macro definitions
// but I would not call that a bad thing
string[] applyMacros(string[] code, int startLine, string fileName) {
	bool inMacro = false;
   for (int i = 0; i < code.length; i++) {
		if (code[i].length == 0)
			continue;
		string[] tokens = code[i].split(";")[0].strip.split(whiteSpace);
      if (tokens.length == 0 || tokens[0][0] == ';')
         continue;

		if (tokens[0] == ".macro") {
			inMacro = true;
			continue;
		}
		if (tokens[0] == ".endmacro") {
			inMacro = false;
			continue;
		}

		// check for correct syntax
		// done here, becouse correct error messages while expandnig macros
		if (!inMacro)
			syntaxCheck(tokens, i+startLine, fileName);

      if (tokens[0][0] == '!') {
         if (!(tokens[0][1..$] in macros))
            throw new Exception("Undaclared macro in file " ~ fileName
                  ~ " at line " ~ to!string(i+startLine));

         if (macros[tokens[0][1..$]].params.length != tokens[1..$].length)
            throw new Exception("Wrong number of macro parameters in file "
                  ~ fileName ~ " at line " ~ to!string(i+startLine));

         if (i+1 < code.length)
            code = code[0..i] ~ macros[tokens[0][1..$]].apply(tokens[1..$],
                  fileName, i+startLine) ~ code[i+1..$];
         else
            code = code[0..i] ~ macros[tokens[0][1..$]].apply(tokens[1..$],
                  fileName, i+startLine);
      }
   }

   return code;
}

////////////
// Labels //
////////////

struct Label {
   string definedIn;
   int definedAt;
   int value;
}

Label[string] labels;

string[] expandLables(string[] code, string fileName) {
   // get labels //
   for (int i = 0; i < code.length; i++) {
      string line = code[i].strip;
      if (line == "" || line[0] == ';')
         continue;

      string[] tokens = line.split(whiteSpace);

      // here
      if (tokens[0] == ".here") {
         if (tokens.length < 2)
            throw new Exception(".HERE without label in file " ~ fileName
                  ~ " at line " ~ to!string(i+1));
         if (tokens[1] in labels)
            throw new Exception("Label " ~ tokens[1] ~ " in file " ~ fileName
                  ~ " at line " ~ to!string(i+1) ~ " is already defined in file "
                  ~ labels[tokens[1]].definedIn ~ " at line "
                  ~ to!string(labels[tokens[1]].definedAt));

         labels[tokens[1]] = Label(fileName, i+1, i);
         tokens[1] = to!string(i);
         code[i] = tokens.join(" ");
         
      }
   }

   // apply them //
   for (int i = 0; i < code.length; i++) {
      string[] tokens = code[i].strip.split(whiteSpace);
      if (tokens.length == 0 || tokens[0][0] == ';')
         continue;
      
      for (int j = 0; j < tokens.length; j++) {
         if (tokens[j][0] == '$') {
            if (!(tokens[j][1..$] in labels))
               throw new Exception("Undefined label " ~ tokens[j][1..$]
                     ~ " in file " ~ fileName ~ "at line " ~ to!string(i+1));

            tokens[j] = to!string(labels[tokens[j][1..$]].value);
            code[i] = tokens.join(" ");
         }
      }
   }

   return code;
}
