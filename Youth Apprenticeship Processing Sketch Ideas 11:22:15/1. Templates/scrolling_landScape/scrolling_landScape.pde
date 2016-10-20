/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/194607*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */
Landscape[] layers = new Landscape[7];

//Landscape layer00, layer01, layer02;

void setup() {
  //size of sketch, initial bgcolor
  size(800, 800);
  background(125,190,210);

for(int i = 0; i < layers.length; i++){
  
  int j = int(map(i,0,layers.length,height/2.5,height));
  int k = int(map(i,0,layers.length,0,100));
  int l = int(map(i,0,layers.length,.5,25));
  
layers[i] = new Landscape(j,k,l);
}
//  layer00 = new Landscape(int(height/2.5), 60);
//  layer01 = new Landscape(int(height/2), 30);
//  layer02 = new Landscape(int(height-(height/4)), 0);
  
  for(int i = 0; i < 9999; i++){
    for(int i2 = 0; i2 < layers.length; i2++){
  
  float j = map(i2,0,layers.length,.1,10);
  
layers[i2].update(j);

}
  }
  
}

void draw() {

  background(150,200,215); 

for(int i = 0; i < layers.length; i++){
  
  float j = map(i,0,layers.length,.5,10);
  
layers[i].update(j);
if(i != 0){
  layers[i].display();
}
}

//  layer00.update(.33);
//  layer00.display();

//  layer01.update(1);
//  layer01.display();

//  layer02.update(3);
//  layer02.display();
  
    strokeWeight(5);
  for (int i = 0; i < height; i+=5) {
    float j = map(i,0,height,0,100);
    stroke(255, j);
    line(0, i, width, i);
  }
  
}

class Horizon{
 
  float x;
  float y;
  
  
  float offsety,foffsety;  

  float storedoffset;
  
 Horizon(float tx,int ty,int n){
   
   offsety= ty;
   
   storedoffset = offsety;
   
   x = tx;
   y = offsety + random(-5,5);

   
   
   foffsety = offsety;
   
  
 }

void update(float ypos, float speed, float rr){
  
  


    offsety = storedoffset+ypos; 

  


  
  foffsety += (offsety - foffsety) * .01;


  x-=speed;
  
  if(x <= 0){
     x = width;
     y = foffsety+random(-rr,rr);
    
  }
 
  
}

void display(){
  
  ellipse(x,y,10,10);
  
  
}
  
  
}
class Landscape {

  Horizon[] points = new Horizon[1000];

  int left, right;

  int timer = 0;

  float yy;
  
  float shade;
  
  float res;
  

  Landscape(int b, float s, float r) {
    
    res = r;
    
    shade = s;
    
    for (int i = 0; i < points.length; i++) {
      float j = map(i, 0, points.length, 0, width);
      points[i] = new Horizon(j, b, i);
    }
    
  }

  void update(float speedx) {
    
    


  timer-=3;

  if (timer < 0) {
    yy = random(-75, 75);
    timer = int(random(25, 200));
  }



  for (int i = 0; i < points.length; i++) {
    points[i].update(yy,speedx,res); 

    // points[i].display();
  }


  }

  void display() {
    
    pushMatrix();
  scale(1.5, 1);
  translate((-width/points.length)*2,0);
  noStroke();

  fill(75-shade,165-shade,70-shade);
  beginShape();
  for (int i = 0; i < points.length; i++) {  
    vertex(points[i].x, points[i].y); 

    if (points[i].x >= width-(width/points.length)-1) {
      vertex(width, height*2); 
      vertex(0, height*2);
    }
  }
  vertex(points[0].x, points[0].y);
  endShape();
  popMatrix();
    
    
  }

}

