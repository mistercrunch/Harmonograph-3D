/*
    Harmonograph3d: An interactive 3d harmonograph 
    Copyright (C) 2010 Maxime Beauchemin

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
How to interact with this program:
Mouse:         Changes the point of view around the drawing
Space bar:     Shows/hide the 3d menu, menu is best viewed when the camera is centered, bring the mouse to the middle of the screen
Arrows:        While the menu is up, the arrows allow modifying the different variables 
  Up/Down:     Change from a variable to the next/previous
  Left/Right:  Increment/Decrement the variable
Numbers(1to9) quick:    Recalls a variable preset
Numbers(1to9) held:     Saves/overwrite a variable preset for that number

*/

//Global variables
int     WINDOW_SIZE=700;
float   SIZE=1000; 
float   DISTANCE=3000;
int     MARGIN=20;
float   RANGE; 
Vect3d   v3dLast;
boolean isMuted = false;


Sound snd = new Sound(this);
//Since pointers don't explicitely exist in Java, using container class Myfloat to allow passing pointers to the menu object
MyFloat PeriodX = new MyFloat(4);
MyFloat PeriodY = new MyFloat(3);
MyFloat PeriodZ = new MyFloat(2);  
MyFloat StrokeWeight = new MyFloat(2);
MyFloat PhaseXY= new MyFloat(0);
MyFloat PhaseXZ= new MyFloat(0);
MyFloat SpiralSpeed = new MyFloat(15);
MyFloat ColorMode = new MyFloat(3);
MyFloat SpiralSpacing = new MyFloat(0.1);
MyFloat PhaseXYAnimationSpeed = new MyFloat(0);
MyFloat ColorBlending = new MyFloat(0);

Vect3d v3dCam = new Vect3d();    //Vector for the camera position
float period;
OpenGLAbstraction gl;            //Object to keep all OpenGl code abstracted from the main program
VariableMenu Menu;               //Object for the menu
boolean firstLine;
float StartingPeriod=0;

void setup()
{
  ////////////////////////////////////////////////////////////////////////
  //Creating the menu
  int MenuWidth=800;
  int MenuHeight=1200;
  Menu = new VariableMenu(-MenuWidth/2,-MenuHeight/2, 1000, MenuWidth, MenuHeight, 60   );
  //Passing the variables to be used in the menu, and their repective increment boundary and value
  Menu.AddItem("PeriodX+-1:", 1, PeriodX);
  Menu.AddItem("PeriodX+-.01%:", 0.0001, PeriodX);
  Menu.AddItem("PeriodY+-1:", 1, PeriodY);
  Menu.AddItem("PeriodY+-.01%:", 0.0001, PeriodY);
  Menu.AddItem("PeriodZ+-1:", 1, PeriodZ);
  Menu.AddItem("StrokeWeight:", 1, StrokeWeight, 1f, 10f);
  Menu.AddItem("PhaseXY(%):", 0.01, PhaseXY, 0, 1);
  Menu.AddItem("PhaseXZ(%):", 0.01, PhaseXZ, 0, 1);
  Menu.AddItem("SpiralSpeed:", 1, SpiralSpeed, -1000, 1000);
  Menu.AddItem("ColorMode:", 1, ColorMode, 1, 5);
  Menu.AddItem("SpiralSpacing:", 0.001, SpiralSpacing, 0, 0.5);
  Menu.AddItem("PhaseAnimation:", 0.0001, PhaseXYAnimationSpeed, -1, 1);
  Menu.AddItem("ColorBlending:", 1, ColorBlending, 0, 1);
  ////////////////////////////////////////////////////////////////////////
  
  size(WINDOW_SIZE,WINDOW_SIZE, OPENGL);
  frameRate(30);
  strokeWeight(StrokeWeight.value);
  gl = new OpenGLAbstraction();
  
  cursor(CROSS);
  background(0);
  colorMode(HSB,1);
  fill(1);
  point(100,100);
  period=0;
  
  fill(1);
  stroke(1);
}

void draw()
{
   RANGE=SIZE;
   int nbSegment=(int)(RANGE/SpiralSpacing.value);
   
   gl.OpenGLStartDraw(nbSegment);
   smooth();

   background(0);
   
   period=StartingPeriod;
   StartingPeriod+=SpiralSpeed.value/100;
   
   firstLine=true;
   strokeWeight(StrokeWeight.value);
   
   PhaseXY.value+=PhaseXYAnimationSpeed.value;
   if(PhaseXY.value>1)PhaseXY.value-=1;
   for(int i=0; i<nbSegment; i++)
   {
     DrawSegment();
   }
   ///////////////////////////////////////////////////
   //Calculating perspective
   float percX=(((float)mouseX ) -((float)width)) / width;
   float percY=(float)mouseY / (height*2);
    
   float radX = percX * TWO_PI;
   float radY = percY * TWO_PI;
   
   v3dCam.x    = sin(radX) * sin(radY) * DISTANCE;
   v3dCam.y    = cos(radY) * DISTANCE;
   v3dCam.z    = cos(radX) * -sin(radY) * DISTANCE;
   gl.OpenGLEndDraw();
   Menu.Draw();

   camera(v3dCam.x, v3dCam.y, v3dCam.z,   0,0,0,   0,1,0);
   ///////////////////////////////////////////////////
   
   if(!keyPressed)Menu.KeyEvents();
  
}
void keyPressed()
{
  Menu.KeyEvents(); 
}


void DrawSegment()
{ 
  //Drawing a single segment of the line 
  period+=0.02;
  
  RANGE-=SpiralSpacing.value;
  Vect3d v3d =new Vect3d();
  v3d.x = sin(period*PeriodY.value) * RANGE;
  v3d.y = sin((period*PeriodX.value) + ((PhaseXY.value) * TWO_PI)) * RANGE;
  v3d.z = sin((period*PeriodZ.value) + ((PhaseXZ.value) * TWO_PI)) * RANGE;
    
  color c;
    if(ColorMode.value==1)
      c=color((v3d.z/(SIZE*2))+0.5,1,1, 1);
    else if(ColorMode.value==2)
      c=color((v3d.Distance()/(DISTANCE)*1.5),1,1, 1) ;
    else if(ColorMode.value==3)
      c=color((period/TWO_PI)%1, 1,1) ;  
    else if(ColorMode.value==4)
      c=color((period/(TWO_PI/8))%1, 1,1);  
    else 
      c=color(1,0,1, 0.5);
      
  gl.AddPoint(v3d, c);
  
  v3dLast = v3d;
}


void stop()
{
  snd.Stop();
  super.stop();
}

class MyFloat
{
  //Container class to simulate using pointers on a float
  float value;
  MyFloat(float in)
  {value=in;}
}


