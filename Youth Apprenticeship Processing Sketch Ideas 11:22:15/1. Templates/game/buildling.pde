class building {
  int height, width;
  float xpos, ypos;
  building () {
    height = (int)random(0, 450);
    width = (int)random(30, 200);
    xpos = width+random(width);
    ypos = 500-height/2;
  }
  
  void show(int depth) {
      noStroke();
      fill(64+(depth*32));
      rect((int)map(xpos, 0, 5000, 0, 500), (int)ypos, width, height);
  }
  
  void update(int parallax) {
    xpos = xpos-parallax;
    if (xpos < 0-width*10) {
      xpos = 5000+(int)random(5000);
    }
  }
}