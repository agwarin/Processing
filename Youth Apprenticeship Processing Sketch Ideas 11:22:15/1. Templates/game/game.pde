/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/847*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */
// Alex French
// a scrolling shooter inspired by Defender and Geometry Wars
// features parallax scrolling

building b[] = new building[80];
PImage buildings[] = new PImage[4];
int i, j;

void setup() {
  int i;
  size(800, 600, P2D);
  frameRate(60);
  
  // create buildings
  for (i = 0; i < 40; i++) {
    b[i] = new building();
  }
}

void draw() {
  background(255);
  for (i = 0; i < 4; i++) {
    for (j = 10*i; j < 10*i+10; j++) {
      b[j].show(i);
      b[j].update(10+i*5);
    }
  }
}