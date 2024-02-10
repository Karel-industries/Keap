import std.stdio;
import std.conv;

/////////////////
// Text output //
/////////////////
void displayFile(string[] code, bool showNumbers, bool fromZero, string fileName) {
   string output = "File " ~ fileName ~ "\n----------------\n\n";

   for (int i = 1; i <= code.length; i++) {
      if (showNumbers)
         output ~= to!string(i - fromZero);
      output ~= "\t" ~ code[i-1] ~ "\n";
   }

   writeln(output);
}

/////////////////
// File output //
/////////////////
