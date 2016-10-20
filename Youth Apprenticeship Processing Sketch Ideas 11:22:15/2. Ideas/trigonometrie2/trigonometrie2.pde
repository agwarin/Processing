/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/193144*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */
/*----------------------------------
  
 Copyright by Diana Lange 2015
 Don't use without any permission. Creative Commons: Attribution Non-Commercial.
  
 mail: kontakt@diana-lange.de
 web: diana-lange.de
 facebook: https://www.facebook.com/DianaLangeDesign
 flickr: http://www.flickr.com/photos/dianalange/collections/
 tumblr: http://dianalange.tumblr.com/
 twitter: http://twitter.com/DianaOnTheRoad
 vimeo: https://vimeo.com/dianalange/videos
  
 -----------------------------------*/

// 25.3.2015 generel setup / grayscale trigonomitrical walker
// 28.3.2015 blaetter abstaende, 3D / Tiefen effekt
// 29.3.2015 Blaetter / drawLeaf()
// 30.3.2015 Farben, Code aufgeraeumt
// 01.3.2015 Parameter randomisiert
// 07.3.2015 Code kommentiert
// 08.3.2015 Screenshot export

/* Current position of the line */
float x, y;

/* Position of the line in last frame */
float lastX, lastY;

/* Values for calculating the next position of the line in each frame (aka moving behaviour)*/
float angle;
float rad;
float speed;

/* holds whether the animation goes clockwise or the other way */
float dir = 1;

/* angle at which the values for the moving behaviour will be re-set*/
float finish;

/* current distance of end of line to the last drawn leaf */
float distance = 0;

/* distance between two leafes */
float leafDistance = 50;

/* holds whether the leaf is left or right of line */
int leafDir = 1;

/* minimal and maximal values for current animation */
float leafDistanceMin = 20;
float leafDistanceMax = 50;

float minD = 1;
float maxD = 10;

float radMin = 0.7;
float radMax = 9;

float leafSizeMin = 10;
float leafSizeMax = 20;

/* holds whether the background or the line is darker (needed for setting the colors)*/
boolean darkBG = false;

/* value for the change of the thickness of the line */
float noiseScale = 300;

/* holds if the animation is looping or paused */
boolean isLooping = true;

void setup() {
  size(900, 450);
  smooth();
  setColors();
  setSetup();
  setDisplayValues();
}

void draw() {
  
  /* the loop just there to speed the animation up */
  for (int i = 0; i < (int) map (mouseX, 0, width, 1, 20); i++) {
    
    /* calculating the new position of the line
     * Check wiki for formula:
     * http://en.wikipedia.org/wiki/Trigonometry#Overview 
     */
    x = x + cos (angle) * rad;
    y = y + sin (angle) * rad;

    /* create current value of perlin noise and calculate current diameter of the line based on that */
    float noiseVal = noise(frameCount / noiseScale);
    float d = map (noiseVal, 0, 1, minD, maxD);
    
    /* draw the line */
    drawBranch(x, y, lastX, lastY, noiseVal, d);

    /* move the angle */
    angle += speed * dir;

    /* if angle reaches its target value (aka finish) new values for the movement behaviour are set */
    if ((dir > 0 && angle >= finish) || (dir < 0 && angle <= finish)) {
      setMovementValues();
    } 
    
    /* check if line is out of the window */
    checkEdges();


    /* update last position values */
    lastX = x;
    lastY = y;
    
    /* draw a leaf if the given distance to the last leaf is reached */
    if (distance > leafDistance) {

      
      /* draw leaf */
      stroke(colors[1]);
      fill(lerpColor(colors[2], colors[3], random(0, 0.5)));
      drawLeaf(d/2, x, y, d + random(leafSizeMin, leafSizeMax), angle, leafDir);
      
      /* alternate the value 1, -1 (which means left or right position of leaf)*/
      leafDir *= -1;
      
      /* set new value that schedules when the next leaf will be drawn*/
      distance = 0;
      leafDistance = random(leafDistanceMin, leafDistanceMax);
    }



  }
}




/* Colors that are used for the current drawing*/
color[] colors = {
  #901061,         // Hintergrund / background
  #901061,         // Outline Blaetter / outline leafes
  color(255, 200), // Fill Blaetter / fill leafes
  #FFFFFF          // Lines
};

void setColors() {
  
  /* creating a color composition */

  float h;        // the current hue value of the color
  float hChange;  // how fast the hue changes from one step to the next one
  float sChange;  // how fast the saturation changes

  h = random(360);
  hChange = random(20, 90);
  hChange = random(100) < 50 ? hChange : hChange * -1;
  sChange = random(colors.length * 10, colors.length * 30) / colors.length;

  colorMode(HSB, 360, 100, 100);

  float s = random(10, 25), b = random (75, 90);

  for (int i = 0; i < colors.length; i++) {
    colors[i] = color(h, s + sChange / colors.length * i, b - 70.0 / colors.length * i);
    h -= hChange / colors.length;
    
    /* keep the values of hue between the range of 0 to 360 */
    if (h < 0) {
      h += 360;
    } else if (h > 360) {
      h -= 360;
    }
  } 

  /* randomly chose whether the background should be darker than the line. If so, the order of the colors in the array need to be changed */
  float dice = random(100);

  if (dice < 50) {
    darkBG = true;
    color tempColor = colors[0];

    colors[0] = colors[3];
    colors[3] = tempColor;
  } 
  else {
    darkBG = false;
  }

  /* randomly set the color similarity of background and the outline color of leafs*/
  colors[1] = lerpColor(colors[0], colors[1], random(1));

  colorMode(RGB, 255, 255, 255); 

  /* randomly make the leaf fill color whiter */
  float lerpValue = random(1);
  colors[2] = color(lerp(red(colors[2]), 255, lerpValue), 
                    lerp(green(colors[2]), 255, lerpValue), 
                    lerp(blue(colors[2]), 255, lerpValue), 
                    random (150, 255));
}

void setDisplayValues() {
  
  float r = sqrt(width * height);

  
  minD = random(constrain(r * 0.0005, 0.5, 10), r * 0.0055);
  maxD = random(1.1, 4) * minD;
  
  leafDistanceMin = random(r * 0.005, (minD + maxD) * 3);
  leafDistanceMax = random(1.1, 2.5) * leafDistanceMin;
  
  noiseScale = random (r * 0.01, r * 0.3);
  
  radMin = random (r * 0.0001, r * 0.0035);
  radMax = random (1.1, 10) * radMin; 
  radMax = constrain(radMax, radMin*1.1, r * 0.005);
  
  leafSizeMin = random (constrain(r * 0.0053, 5, 50), r * 0.021);
  leafSizeMax = random (1.1, 3) * leafSizeMin;
}

void drawBranch(float x, float y, float lastX, float lastY, float noiseVal, float d) {
  
  strokeWeight(d);
  stroke( colors[3]);
  line (x, y, lastX, lastY);
  
  stroke(lerpColor(colors[0], colors[2], map(noiseVal, 0, 255, 0, 0.4)), 120);
  line (x+d/2, y, lastX+d/2, lastY);
}

void drawLeaf(float padding, float x, float y, float l, float angle, float dir) {
  strokeWeight(l / 20);

  float angleAbstand = dir * random(PI/6, PI/2);
  
  /* the leaf shouldn't start in the middle of the line / branch which means the first point of the leaf needs to be re-calculated */
  x = x + cos(angle + angleAbstand) * padding;
  y = y + sin(angle + angleAbstand) * padding;

  /* calculate the peak of the leaf */
  float endX = x + cos(angle + angleAbstand) * l;
  float endY = y + sin(angle + angleAbstand) * l;

  /* Calulating control points */
  float controlAngle = random (PI/7, PI/4.5);
  float controlPosition = random (0.25, 0.5) * dist (x, y, endX, endY);
  float controlOneX = x/*lerp (x, endX, 0.5)*/ + cos (angle + angleAbstand + controlAngle) * controlPosition;
  float controlOneY = y/*lerp (y, endY, 0.5)*/ + sin (angle + angleAbstand + controlAngle) * controlPosition;

  float controlTwoX = x/*lerp (x, endX, 0.5)*/ + cos (angle + angleAbstand - controlAngle) * controlPosition;
  float controlTwoY = y/*lerp (y, endY, 0.5)*/ + sin (angle + angleAbstand - controlAngle) * controlPosition;
  
  /* draw the leaf */
  beginShape();
  curveVertex (controlTwoX, controlTwoY);
  curveVertex (x, y);
  curveVertex (controlOneX, controlOneY);
  curveVertex (endX, endY);
  curveVertex (endX, endY);
  curveVertex (controlTwoX, controlTwoY);
  curveVertex (x, y);
  curveVertex (controlOneX, controlOneY);
  endShape (CLOSE);

  line (x, y, endX, endY);
}

/* create the gradiant for the background */
PImage createLomoImage (int rad, int sb, int eb) {
  PImage lomo = createImage (width, height, ARGB);
 
  float maxDis = dist (0, 0, width / 2, height / 2);
  float dis;
  float cb;
 
  lomo.loadPixels();
  for (int i = 0; i < lomo.height; i++)
  {
    for (int j = 0; j < lomo.width; j++)
    {
      dis = dist(width / 2, height / 2, j, i);
 
      if (dis <= rad) lomo.pixels [i * lomo.width + j] = color(sb);
      else {
        cb = map (dis, rad, maxDis, PI/2, 0);
        cb = map (sin(cb), 1, 0, sb, eb);
        lomo.pixels [i * lomo.width + j] = color(cb);
      }
    }
  }
 
  lomo.updatePixels();
 
  return lomo;
}
void mousePressed() {
  if (mouseButton == LEFT) {
    setColors();
  }

  setSetup();
  setDisplayValues();
  loop();
  isLooping = true;
}

void keyPressed() {

  if (key == ' ') {
    isLooping = !isLooping;

    if (isLooping) {
      loop();
    } else {
      noLoop();
    }
  } else if (key == 'c') {
    setDisplayValues();
    setColors();
  } else if (key == 's') {
    saveFrame("screenshots/" + timestamp() + ".png");
  }
}

String timestamp() {

  String s = "";
  s = s + nf (year(), 4) + nf (month(), 2) + nf (day(), 2);
  s = s + "_";
  s = s + nf (hour(), 2) + nf (minute(), 2) + nf (second(), 2);

  return s;
}


void setSetup() {
  
  noiseSeed((int) random (100000));
  
  background(colors[0]);  
  blend(createLomoImage (height / 2 - 50, 240, 140), 0, 0, width, height, 0, 0, width, height, darkBG ? SOFT_LIGHT :BURN);

  x = random(width);
  y = random(height);
  
  lastX = x;
  lastY = y;
  
  angle = random(TWO_PI);
  setMovementValues();

}


void setMovementValues() {
  
   dir = random(100) < 50 ? -1 : 1;
   finish = random(TWO_PI);
   rad = random (radMin, radMax);
   speed = random (rad/200, rad/10);
   speed = constrain(speed, 0.01, 0.4);
   //println(speed);
}

void checkEdges() {
  
  /* keep the angle value between the range of 0 to TWO_PI */
  if (angle > TWO_PI) {
    angle -= TWO_PI;    
  } else if (angle < 0) {
    angle += TWO_PI;
  }
  
  boolean windowRentered = false;
  /* check if the line has left the window area */
  if (x < -maxD) {
    x = width + maxD;
    windowRentered = true;
  } 
  else if (x > width+maxD) {
    x = -maxD;
    windowRentered = true;
  }

  if (y < -maxD) {
    y = height+maxD;
    windowRentered = true;
  } 
  else if (y > height+maxD) {
    y = -maxD;
    windowRentered = true;
  }

  /* update distance value for the distances between leafes*/
  if (windowRentered) {
    distance = 0;
  } 
  else {

    distance += dist(x, y, lastX, lastY);
  }
}