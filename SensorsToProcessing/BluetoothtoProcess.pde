import processing.serial.*;
import processing.opengl.*;
float y = 0.1;
float x = 0.1;
float z = 0.1;
float a = 0.1;
float b = 0.1;
float c = 0.1;
Serial myPort;
String val;

// String portName = "/dev/tty.HC-06-DevB";
void setup(){
printArray(Serial.list());
//String portName = Serial.list()[2];
  size(800,600,P3D);
    smooth();
 String portName = "/dev/tty.BLU-DevB";
  myPort = new Serial(this, portName, 57600);
  myPort.write('r');
 //String inBuffer = myPort.readString();
 //if (inBuffer != null)
  // println(inBuffer);
}

void draw(){
    String inBuffer = myPort.readStringUntil(33);  //this is the ! that i put int
//    String[]list = split(inBuffer,'\n');
//println(list[0]);
     if (inBuffer != null){
     String[]list= split(inBuffer,'\t');
     if (list[0]!= null)
     {
       println(inBuffer);
       x = Float.parseFloat(list[1]);
      //// println(x);
       y = Float.parseFloat(list[2]);
       z = Float.parseFloat(list[3]);
       //// println(x);
       a = Float.parseFloat(list[4]);
       b = Float.parseFloat(list[5]);
       c = Float.parseFloat(list[6]);
       translate(400+a/10,300+b/10,80+c/10); 
   rotateX(y); //pitch
   rotateY(x); //yaw
   rotateZ(z); //roll
  
    
   background(0);
   fill(0,225,225);
    box(200,100,200);
       
    line(-150, 0, 150, 0);
    line(0, 150, 0, -150);
    line (0,0, -150, 0, 0, 150);
    strokeWeight(2);
     }
     }
    
 
     delay(50);
   //translate(400,300,80);
    
   // rotateX(x); //pitch
   // rotateY(y); //yaw
   // rotateZ(z); //roll
   // rotate(100);
    
   // background(0);
   // fill(255,228,225);
   // box(200,100,200);
       
   // line(-150, 0, 150, 0);
   // line(0, 150, 0, -150);
   // line (0,0, -150, 0, 0, 150);
   // strokeWeight(2);
 
}