/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/219740*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */
float yoff = 0.0;      
float x, y;

class Particle
{

  float x=width/3;
  float y=height/6;
  float xv=-3+random(6);
  float yv=-random(4);
  float maxYV=5;
  float gravity=0.1;
  float friction=1;
  float radius=random(20)+5;

 color c=color(0);
  
  Particle(){ }
  
  Particle(float xp,float yp)
  {
    x=xp;
    y=yp;
  }
  Particle(float xp,float yp,float xvel,float yvel)
  {
    this(xp,yp);
    xv=xvel;
    yv=yvel;
  }
  void run()
  {
    update();
    render();
    
  }
  public void update()
  {
    if(x<=radius)
    {
      xv=abs(xv);
    }
    else if(x>=width-radius)
    {
      xv=-abs(xv);
    }
    if(y+radius>=height)
    {
      yv=-abs(yv);
      if(y+radius-height>=0.15)
      {
        y=height-radius;
        if(yv>-0.1)
        {
          xv*=0.96;
        }
      }
    }
    if((yv<maxYV))
    {
      yv+=gravity;
    }
    yv*=friction;
     //println(yv);
    y+=yv;
    x+=xv;
  }
  void render()
  {
    fill(c);
    
    ellipse(x,y,radius,radius);
   
  }
}
class ParticleSystem
{
  ArrayList particles=new ArrayList();
  ParticleSystem(){}
  void add(Particle p)
  {
    particles.add(p);
  }
  void removeAll()
  {
    particles.clear();
  }
  void run()
  {
    for(int i=0;i<particles.size();i++)
    {
      Particle p=(Particle)particles.get(i);
      p.run();
    }
  }
}
ParticleSystem ps=new ParticleSystem();
boolean mouseDown=false;

void setup() {
  size(1500, 1000);
  
  frameRate(16);
  background(0);
   smooth();
    ellipseMode(RADIUS);
 
}

void draw() {
  
    stroke(random(255),random(255),random(255));
    strokeWeight(4);

  fill(0);
  
  

  beginShape(); 
  
  float xoff = 0;       
 

  for (float x = 0; x <= width; x += 10) {
   
    float y = map(noise(xoff, yoff), 0, 1, 900,200); 
 
    

    vertex(x, y); 
    
    xoff += 0.03;
  }
 
  yoff += 0.01;
  vertex(width, height);
  vertex(0, height);
  endShape(CLOSE);





      
  if(mousePressed==true)
  { 
    ps.add(new Particle(mouseX,height/2));
  }
  ps.run();

}
float[]colors=new float[3];
void keyPressed()
{
  if(keyPressed==true){
  if(key==' '){
    switch(key)
   {
     case ' ':ps.removeAll();break;
   }
  }
  }
}