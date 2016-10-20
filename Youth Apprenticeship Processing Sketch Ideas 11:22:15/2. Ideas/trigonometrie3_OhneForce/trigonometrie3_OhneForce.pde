/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/197587*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */
import processing.pdf.*;

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
// 01.4.2015 Parameter randomisiert
// 07.4.2015 Code kommentiert
// 08.4.2015 Screenshot export
// 11.4.2015 Uebersetzung in Klassen (BranchWalker, ColorManager). BranchWalker mit Kindelementen, Astverduennung
// 12.4.2015 Eigenschaftenvererbung und Kindbranches, Neuer Überlagerungsmodus
// 17.4.2015 Kinderbranches als ArrayList, Farbchema update
// 18.4.2015 PDF Export


/* holds if the animation is looping or paused */
boolean isLooping = true;

/* variable for pdf recordings */
boolean savePDF = false;

/* every drawing starts with a single branch */
BranchWalker walker;

void setup() {
  size(900, 450);
  smooth();
  
  /* initalize first branch */ 
  walker = new BranchWalker();

  setSetup();
  
}

void draw() {
  /* the loop just there to speed the animation up */
  for (int i = 0; i < (int) map (mouseX, 0, width, 1, 20); i++) {
    
    if (walker != null) {
      walker.update();
    }

  }
  
  if (savePDF && walker.getAllGrowthEnded()) {
    endRecord();
    savePDF = false;
    println("done recording at " + timestamp());
    saveFrame("pdf/" + timestamp() + ".png");
  }
}


class BranchWalker {
  
  /* holds all colors of the walker */
  ColorManager colorManager;
  
  /* each walker can have child-branches which are BranchWalkers, too*/
  ArrayList<BranchWalker> childWalker = new ArrayList<BranchWalker>();

  /* Current position of the line */
  PVector pos = new PVector(0, 0);

  /* Position of the line in last frame */
  PVector lastPos = new PVector(0, 0);

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

  /* how fast should the branch get smaller? */
  float shrink;

  /* value for the change of the thickness of the line */
  float noiseScale = 300;

  /* did the branch stop growing? */
  boolean endOfGrowth = false;

  /* value for the likelihood of getting childbranches */
  float childBranch = 1;

  BranchWalker() {
    /* set new colors */
    colorManager = new ColorManager();
    
    /* set position and walking direction */
    setSetup();
    
    /* set look*/
    setDisplayValues();
  }

  BranchWalker(BranchWalker parent) {
    // set new random look
    setDisplayValues();
    
    /*
     * this walker is a child of another walker. the child inherits attributes of its parent. 
     * but each child doesn't adopt simply the parents attributes. instead it mixes its own 
     * new attributes with the ones of the parent. the values "simularity" and "amt" sets, 
     * how the values should be mixed 
     */
    float amt = random (0.8, 0.9);
    float simularity = random(0.7, 0.99);
    this.angle = random(TWO_PI);

    this.childBranch = lerp(childBranch, parent.childBranch, simularity);

    this.shrink = lerp(shrink, parent.shrink, simularity) * random(0.97, 1);
    //this.shrink = parent.shrink * random(0.97, 1);
    this.pos = parent.pos.get();
    this.lastPos = parent.pos.get();

    this.leafDistanceMin = lerp(leafDistanceMin, parent.leafDistanceMin, simularity);
    this.leafDistanceMax = lerp(leafDistanceMax, parent.leafDistanceMax, simularity);

    this.minD = constrain(parent.minD * amt, 1, parent.maxD);
    this.maxD = parent.maxD * amt;

    this.radMin = lerp(radMin, parent.radMin, simularity);
    this.radMax = lerp(radMax, parent.radMax, simularity);

    this.leafSizeMin = lerp(leafSizeMin, parent.leafSizeMin * amt, simularity);
    this.leafSizeMax = lerp(leafSizeMax, parent.leafSizeMax * amt, simularity);

    /* value for the change of the thickness of the line */
    this.noiseScale = lerp(noiseScale, parent.noiseScale, simularity);

    this.colorManager = new ColorManager(parent.colorManager, random(0.5, 0.95));

    setMovementValues();
  }

  // Getter -----------

  color getBackgroundColor() {
    return colorManager.getBackgroundColor();
  }

  boolean getIsDarkBG() {
    return colorManager.darkBG;
  }
  
  /**
   * Calculates if the BranchWalker and all its children (and children's children) have stopped growing.
   */
  boolean getAllGrowthEnded() {
    if (endOfGrowth && childWalker.size() > 0) {

      boolean f = true;
      for (int i = 0; i < childWalker.size() && f; i++) {
        f = childWalker.get(i).getAllGrowthEnded();
      }

      return f;
    } 
    else if (endOfGrowth && childWalker.size() >= 0) {
      return true;
    } 
    else {
      return false;
    }
  }

  // Setter ------------

  void updateColors() {
    colorManager.updateColors(true);
  }
  void setSetup() {
    // remove all existing children
    childWalker.clear();
    
    // set random position
    pos.x = random(width);
    pos.y = random(height);

    lastPos = pos.get();
    
    // set random movement direction
    angle = random(TWO_PI);
    setMovementValues();
    
    // start growing
    endOfGrowth = false;
    
  }

  void setDisplayValues() {
    
    // all values are calculated based on the size of the window
    float r = sqrt(width * height);

    minD = random(constrain(r * 0.0005, 1.1, 15), r * 0.0055);
    maxD = random(1.1, 4) * minD;

    shrink = random (map (maxD, constrain(r * 0.0005, 1.1, 15) * 1.1, r * 0.0055 * 4, 0.9995, 0.995), 0.9999999);

    leafDistanceMin = random(r * 0.005, (minD + maxD) * 3);
    leafDistanceMax = random(1.1, 2.5) * leafDistanceMin;

    noiseScale = random (r * 0.001, r * 0.2);

    radMin = random (r * 0.0001, r * 0.0035);
    radMax = random (1.1, 10) * radMin; 
    radMax = constrain(radMax, radMin*1.1, r * 0.005);

    leafSizeMin = random (constrain(r * 0.0053, 5, 50), r * 0.021);
    leafSizeMax = random (1.1, 3) * leafSizeMin;

    childBranch = random(0.5, 10);
  }

  // Movement ---------------

  void setMovementValues() {

    dir = random(100) < 50 ? -1 : 1;
    finish = random(TWO_PI);
    rad = random (radMin, radMax);
    speed = random (rad/200, rad/10);
    speed = constrain(speed, 0.01, 0.4);
  }

  void checkEdges() {

    /* keep the angle value between the range of 0 to TWO_PI */
    if (angle > TWO_PI) {
      angle -= TWO_PI;
    } 
    else if (angle < 0) {
      angle += TWO_PI;
    }

    boolean windowRentered = false;
    /* check if the line has left the window area */
    if (pos.x < -maxD) {
      pos.x = width + maxD;
      windowRentered = true;
    } 
    else if (pos.x > width+maxD) {
      pos.x = -maxD;
      windowRentered = true;
    }

    if (pos.y < -maxD) {
      pos.y = height+maxD;
      windowRentered = true;
    } 
    else if (pos.y > height+maxD) {
      pos.y = -maxD;
      windowRentered = true;
    }

    /* update distance value for the distances between leafes*/
    if (windowRentered) {
      distance = 0;
    } 
    else {

      distance += PVector.dist(pos, lastPos);
    }
  }

  // Display----------------

  void update() {

    // update all children
    for (int i = 0; i < childWalker.size(); i++) {

      childWalker.get(i).update();
       
      // remove child if and all its children stopped growing
      if (childWalker.get(i).getAllGrowthEnded()) {
        childWalker.remove(i);
      }
    }


    if (!endOfGrowth) {

      /* calculating the new position of the line
       * Check wiki for formula:
       * http://en.wikipedia.org/wiki/Trigonometry#Overview 
       */

      pos.add(cos(angle) * rad, sin(angle) * rad, 0);


      /* create current value of perlin noise and calculate current diameter of the line based on that */
      float noiseVal = noise(frameCount / noiseScale);
      float d = map (noiseVal, 0, 1, minD, maxD);

      /* draw the line */
      drawBranch(noiseVal, d);

      /* move the angle */
      angle += speed * dir;

      /* if angle reaches its target value (aka finish) new values for the movement behaviour are set */
      if ((dir > 0 && angle >= finish) || (dir < 0 && angle <= finish)) {
        setMovementValues();
      } 

      /* check if line is out of the window */
      checkEdges();


      /* update last position values */
      lastPos = pos.get();

      /* draw a leaf if the given distance to the last leaf is reached */
      if (distance > leafDistance) {

        float dice = random(100);
        boolean doDrawLeaf = true;
        
        // chose weather a leaf should be drawn or a new child branch should be created
        if (dice < childBranch) {
          BranchWalker newWalker = new BranchWalker(this);
          doDrawLeaf = false;
          if (newWalker.maxD < 1) {
            doDrawLeaf = true;
          } 
          else {
            childWalker.add(newWalker);
          }
        } 

        if (doDrawLeaf) {

          /* draw leaf */
          stroke(colorManager.getLeafOutlineColor());
          fill(lerpColor(colorManager.getLeafColor(), colorManager.getBranchColor(), random(0, 0.5)));
          drawLeaf(d/2, d + random(leafSizeMin, leafSizeMax), angle, leafDir);
        }

        /* alternate the value 1, -1 (which means left or right position of leaf)*/
        leafDir *= -1;

        /* set new value that schedules when the next leaf will be drawn*/
        distance = 0;
        leafDistance = random(leafDistanceMin, leafDistanceMax);
      }
      
      // shrink the diameter
      minD *= shrink;
      maxD *= shrink;

      // stop the branch walk if the diameter is really small
      if (maxD < 1 && !endOfGrowth) {
        endOfGrowth = true;
        
        // draw a leaf at the end of each branch
        drawLeaf(d/2, d + random(leafSizeMin, leafSizeMax), angle, 0);
      }
    }
  }

  void drawBranch(float noiseVal, float d) {
    strokeWeight(d);
    stroke(colorManager.getBranchColor());
    line (pos.x, pos.y, lastPos.x, lastPos.y);

    stroke(lerpColor(colorManager.getBackgroundColor(), colorManager.getLeafColor(), map(noiseVal, 0, 255, 0, 0.4)), 120);
    line (pos.x + d / 2, pos.y, lastPos.x + d/2, lastPos.y);
  }

  void drawLeaf(float padding, float l, float angle, float dir) {
    strokeWeight(l / 20);

    float angleAbstand = dir * random(PI/6, PI/2);

    /* the leaf shouldn't start in the middle of the line / branch which means the first point of the leaf needs to be re-calculated */
    float x = pos.x + cos(angle + angleAbstand) * padding;
    float y = pos.y + sin(angle + angleAbstand) * padding;

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
}

class ColorManager {

  /* holds whether the background or the line is darker (needed for setting the colors)*/
  boolean darkBG = false;

  /* Colors that are used for the current drawing*/
  private final color[] colors = {
    #901061, // Hintergrund / background
    #901061, // Outline Blaetter / outline leafes
    0xCCFFFFFF, // Fill Blaetter / fill leafes
    #FFFFFF          // Lines
  };

  /**
   * Creates a new ColorManger Object with random colors.
   */
  public ColorManager() {
    setColors(getColors2(colors.length, true));
  }

 /**
  * Creates a new ColorManager object based on an existing ColorManager. This will create new random colors. 
  * But it will lerp this new Colors with the colors from parent. 
  * The amt parameter sets, how the parent and the new colors are mixed (0 for 100% new colors, 1 for 100% parent colors)  
  */
  public ColorManager(ColorManager parent, float amt) {
    this.darkBG = parent.darkBG;
    updateColors(false);

    // mix all colors
    for (int i = 0; i < colors.length; i++) {
      colors[i] = lerpColor(colors[i], parent.colors[i], amt);
    }
  }

  void updateColors(boolean checkBG) {
    
    float dice = random(100);
    
    /* this choses randomly which of the two slighly different color creating algorithms should be executed */
    if (dice < 50) {
      setColors(getColors2(colors.length, checkBG));
    } else {
      setColors(getColors(colors.length, checkBG));
    }
    
  }

  color getBackgroundColor() {
    return colors[0];
  }

  color getLeafOutlineColor() {
    return colors[1];
  }

  color getLeafColor() {
    return colors[2];
  }

  color getBranchColor() {
    return colors[3];
  }

  void setColors(color[] newColors) {

    for (int i = 0; i < colors.length; i++) {
      colors[i] = newColors[i];
    }
  }

  int getColorsNum() {
    return colors.length;
  }

  color[] getColors(int num, boolean checkBG) {

    color[] newColors = new color[num];
    /* creating a color composition */

    float h;        // the current hue value of the color
    float s;        // the current saturation value of the color
    float b;        // the current brightness value of the color
    float hChange;  // how fast the hue changes from one step to the next one
    float sChange;  // how fast the saturation changes
    float bChange;  // how fast the brightness changes
    int sDir;       // saturation value will increase or decrease
    int bDir;       // brightness value will increase or decrease
    
    // randomly chose, if values will increase or decrease
    sDir = random(100) < 50 ? 1 : -1;
    bDir = random(100) < 50 ? 1 : -1;
    
    // randomly chose starting color values
    h = random(360);
    s = sDir == 1 ? random(5, 15)  : random(20, 40);
    b = bDir == -1 ? random (70, 95) : random(30, 50);
    
    // randomly chose the steps, in which the colors will change
    hChange = random(10, 60);
    hChange = random(100) < 50 ? hChange : hChange * -1;
    sChange = (s / 2) / newColors.length;
    bChange = random(20, 50) / newColors.length;
    
    // set colormode to HSB
    colorMode(HSB, 360, 100, 100);

    // create the colors and save them in the array
    for (int i = 0; i < newColors.length; i++) {
      
      // calculate color, save it in the array
      newColors[i] = color(h, s + sDir * sChange * i, b + bDir * bChange * i);
      
      h -= hChange / newColors.length;

      /* keep the values of hue between the range of 0 to 360 */
      if (h < 0) {
        h += 360;
      } 
      else if (h > 360) {
        h -= 360;
      }
    } 
    
    if (bDir == 1) {
      darkBG = true;
    } else {
      darkBG = false;
    }

    /* randomly set the color similarity of background and the outline color of leafs*/
    newColors[1] = lerpColor(newColors[0], newColors[1], random(1));

    /* set color mode back to RGB */
    colorMode(RGB, 255, 255, 255); 

    /* randomly make the leaf fill color whiter */
    float lerpValue = random(1);
    newColors[2] = color(lerp(red(newColors[2]), 255, lerpValue), 
                         lerp(green(newColors[2]), 255, lerpValue), 
                         lerp(blue(newColors[2]), 255, lerpValue), 
                         random (150, 255));

    return newColors;
  }

  color[] getColors2(int num, boolean checkBG) {
    color[] newColors = new color[num];
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
      newColors[i] = color(h, s + sChange / colors.length * i, b - 70.0 / colors.length * i);
      h -= hChange / colors.length;

      /* keep the values of hue between the range of 0 to 360 */
      if (h < 0) {
        h += 360;
      } 
      else if (h > 360) {
        h -= 360;
      }
    }

    /* randomly chose whether the background should be darker than the line. If so, the order of the colors in the array need to be changed */
    float dice = random(100);

    if ((checkBG && dice < 50) ||(!checkBG && darkBG)) {
      darkBG = true;
      color tempColor = newColors[0];

      newColors[0] = newColors[3];
      newColors[3] = tempColor;
    } 
    else if (checkBG) {
      darkBG = false;
    }

    /* randomly set the color similarity of background and the outline color of leafs*/
    newColors[1] = lerpColor(newColors[0], newColors[1], random(1));

    colorMode(RGB, 255, 255, 255);

    /* randomly make the leaf fill color whiter */
    float lerpValue = random(1);
    newColors[2] = color(lerp(red(newColors[2]), 255, lerpValue), 
                         lerp(green(newColors[2]), 255, lerpValue), 
                         lerp(blue(newColors[2]), 255, lerpValue), 
                         random (150, 255));
    return newColors;
  }
}

/**
 * Draws a background and starts a new BranchWalker with a randomly Position 
 */
void setSetup() {
  noiseSeed((int) random (100000));

  background(walker.getBackgroundColor());  
  blend(createLomoImage (height / 2 - 50, 240, 140), 0, 0, width, height, 0, 0, width, height, walker.getIsDarkBG() ? SOFT_LIGHT :BURN);
  
  walker.setSetup();
}

/**
 * create the gradiant for the background 
 */
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
    // set new colors
    walker.updateColors();
  }
  
  // draw a new background, start new branchwalker
  setSetup();
  
  // set new, random look for BranchWalker
  walker.setDisplayValues();
  
  // start looping
  loop();
  isLooping = true;
}

void keyPressed() {

  if (key == ' ') {
    
    // pause / play animation
    isLooping = !isLooping;

    if (isLooping) {
      loop();
    } 
    else {
      noLoop();
    }
  } 
  else if (key == 'c') {
    // don't draw a new background, but start a new branch
    
    // set new, random values for the BranchWalker Position & walking behavior
    walker.setSetup();
    
    // set new, random look for BranchWalker
    walker.setDisplayValues();
    
    // set new colors
    walker.updateColors();
    
    // start looping
    loop();
    isLooping = true;
  } 
  else if (key == 'v') {
    
    // draw a transparent background
    noStroke();
    fill(walker.getBackgroundColor(), random(10, 100));
    rect(0, 0, width, height);
    
    // randomly choose a blend mode
    int dice = (int) random(4);
    int ADDMODE = SOFT_LIGHT;
    if (dice == 0) ADDMODE = SOFT_LIGHT;
    else if (dice == 1) ADDMODE = BURN;
    else if (dice == 2) ADDMODE = SOFT_LIGHT;
    else if (dice == 2) ADDMODE = EXCLUSION;

    blend(createLomoImage (height / 2 - 50, 240, 140), 0, 0, width, height, 0, 0, width, height, ADDMODE);

    // set new, random values for the BranchWalker Position & walking behavior
    walker.setSetup();
    
    // set new, random look for BranchWalker
    walker.setDisplayValues();
    
    // set new colors
    walker.updateColors();
    
    // start looping
    loop();
    isLooping = true;
  } 
  else if (key == 's') {
    // Save a screenshot
    saveFrame("screenshots/" + timestamp() + ".png");
  } 
  else if (key == 'p') {  
    recordPDF(false);
  } else if (key == 'o') {  
    recordPDF(true);
  }
}

/**
 * Will save a (new) drawing as PDF. Recording ends when all branches stopped 
 * @param newColors true - will start recording with new, random colors, false - will start recording with same colors
 */
void recordPDF(boolean newColors) {
  
    savePDF = true;
    
    // new, random colors
    walker.updateColors();

    // call setup (draw new background & set new, random values for the BranchWalker Position & walking behavior)
    setSetup();
    
    // set new, random look for BranchWalker
    walker.setDisplayValues();

    // start looping
    isLooping = true;
    loop();

    beginRecord(PDF, "pdf/" + timestamp() + ".pdf");
    println("recording started at " + timestamp());
}

/**
 * Generates a String containing the current date & time information
 */
String timestamp() {

  String s = "";
  s = s + nf(year(), 4) + nf(month(), 2) + nf(day(), 2);
  s = s + "_";
  s = s + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);

  return s;
}


