/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/330*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */
/*
Sky Composition
December 18, 2007 - howard winston
http://www.howardwinston.com
email: info@howardwinston.com
create a cloud filled sky based on the sensation of looking up and watching the sky
clouds will slowly take form and change
mouse click to build a new sky and cloud formation
*/

// set sizes, counts, arrays, etc.
int w = 900;
int h = 450;
int halfW = w/2; // use for max x coordinate
int halfH = h/2; // use for max y coordinate
// color info
color skyColor = color(60, 135, 245);
color cloudColor = color(220, 250, 255);
// cloud info
float cloudSize = .01; 
int cloudAlpha = 4;
int numOfClouds = 18;
int cloudMovement = 16; // range of movement for cloud within its location
int cloudSharpness = 160; // number of pixels to adjust edges
// arrays to hold cloud point and position info - this is lousy OO design!
int numOfPts = 9;
int cloudBase [][][] = new int [numOfClouds][numOfPts][2]; // base coordinates
int cloudTranslate [][] = new int [numOfClouds][2]; // translate offset for each cloud

void setup () {
  size(900, 450);
  buildCloudBases();
  buildTranslateArray();
  smooth();
  background(skyColor);
  frameRate(24);
}

void draw () {
  for (int i = 0; i < numOfClouds; i++) {
    cloud(i);
  }
}

void mousePressed() { 
  // restartbuildCloudBases();
  buildTranslateArray();
  background(skyColor);
}
