int mapWidth = 20;
int mapHeight = 20;

int maxInstructions;

static this() {
   maxInstructions = mapWidth * ((mapHeight-2) / 3);
}
