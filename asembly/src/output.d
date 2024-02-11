import std.stdio;
import std.conv;
import std.array;

import config;

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

void displayMap(string map, bool showNumbers, bool fromZero) {
   if (!showNumbers)
      writeln(map);
   else {
      string[] lines = map.split("\n");
      // top numbers //
      // get needed size
      ulong needed = to!string(lines[0].length - fromZero).length;

      string[] topNumbers = [];
      for (int i = 0; i < needed; i++) {
         topNumbers ~= "\t";
      }

      // fill in
      for (int i = 1; i <= lines[0].length; i++) {
         string num = to!string(i - fromZero);

         for (int j = 0; j < needed; j++)
            if (j < num.length)
               topNumbers[j] ~= num[j];
            else
               topNumbers[j] ~= ' ';
      }

      // write
      foreach (l; topNumbers)
         writeln(l);
      writeln();

      // map //
      for (int i = 1; i <= lines.length; i++) {
         writeln(to!string(i - fromZero) ~ "\t" ~ lines[i-1]);
      }
   }
}
/////////////////
// File output //
/////////////////
string getMap(string[] code) {
   // empty line
   string empty = "\n";
   for (int i = 0; i < mapWidth; i++) {
      empty ~= '.';
   }

   string output = empty[1..$] ~ empty;

   // parts of kyte
   string k1 = "";
   string k2 = "";
   string k3 = "";

   int taken = 2;

   // data
   for (int i = 0; i < code.length; i++) {
      if (i ==  mapWidth) {
         output ~= '\n' ~ k1 ~ '\n' ~ k2 ~ '\n' ~ k3;
         k1 = "";
         k2 = "";
         k3 = "";
         taken += 3;
      }

      k1 ~= code[i][0];
      k2 ~= code[i][1];
      k3 ~= code[i][2];
   }
   // finish line
   ulong left = mapWidth - k1.length;
   for (int i = 0; i < left; i++) {
      k1 ~= '.';
      k2 ~= '.';
      k3 ~= '.';
   }

   if (k1[0] != '.') {
      output ~= '\n' ~ k1 ~ '\n' ~ k2 ~ '\n' ~ k3;
      taken += 3;
   }

   // rest of map
   for (int i = 0; i < mapHeight - taken; i++) {
      output ~= empty;
   }
   return output;
}
