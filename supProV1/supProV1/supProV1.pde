import processing.serial.*;
import java.util.List;
import java.util.ArrayList;
import java.awt.AWTException;
import java.awt.Robot;
import java.awt.PointerInfo;
import java.awt.MouseInfo;
import java.awt.Point;
import java.awt.event.KeyEvent;
import controlP5.*;
import papaya.*;
//import processing.opengl.*;


int r,g,b;    // Used to color background
Serial port;  // The serial port object

int i = 0;  //This is an incrementing counter that increments everytime something is read from serialEvent
int idle = 0; //This is used to stop the loop in collectDynamic
int mode = 0; //This variable is changed when keys are pressed and used by serialEvent() to check what to do with incoming data
int j = 0; //This is an incrementer used for populated arrays with a fixed number of samples (neutralY, proSamplesY, etc)
int XINCREMENT = 5; //Increment for plotting acceleration data

//Declare variables for calculating rotation angles and visualizing on cube
float xZero=1640; //center value of x channel. Determined with controller resting "housing down" on a table
float yZero=2010; //center value of y channel
float zZero=2050; // center value of z channel

//float xScale=2/670.0; //2 g/voltage range of x channel
//float yScale=2/586.0; //2 g/voltage range of y channel
//float zScale=2/560.0; //2 g/voltage range of z channel

//float rotz = 0;
float roll=0; //initialize roll angle
float pitch=0; //initialize pitch angle
float neutralRoll=0;
float proRoll=0;
float supRoll=0;

//float x0 = 0;
float x1 = 0;
//float y0 = 0;
float y1 = 0;
//float z0 = 0;
float z1 = 0;

//Initialize float lists for all acceleration channels. Values will be appended 
//to these lists everytime a non null string is written to the port
FloatList x_vals;
FloatList y_vals;
FloatList z_vals;

//initialize variables to store the x,y,z accelerations when thresholds are set
//float[] neutral = {0,0,0}; //currently unused
//float[] supSample = {0,0,0}; //currently unused
//float[] proSample = {0,0,0}; //curently unused
float[] neutralX = new float[10]; //used to collect 10 x values for neutral...
float[] neutralY = new float[10];
float[] neutralZ = new float[10];
float[] proSamplesX = new float[10]; //Used to store 10 x values for pronation to average for a threshold
float[] proSamplesY = new float[10]; //Used to store 10 y values for pronation to average for a threshold
float[] proSamplesZ = new float[10]; //Used to store 10 z values for pronation to average for a threshold
float[] supSamplesX = new float[10]; //Used to store 10 x values for supinaton to average for a threshold
float[] supSamplesY = new float[10]; //Used to store 10 y values for supinaton to average for a threshold
float[] supSamplesZ = new float[10]; //Used to store 10 y values for supinaton to average for a threshold

float threshAdjust = 100; //multiples of this are used to modify the thresholds according to the "x" orientation of the arm

void setup() {
//  size(1000,400);
//  background(255);
  size(800,600,P3D); //These are for drawing Cube
  smooth();
  x_vals = new FloatList();
  y_vals = new FloatList();
  z_vals = new FloatList();
  println(Serial.list());
  port = new Serial(this, Serial.list()[0], 115200); //sets up first port for communication
  frameCount = 1; //enable use of delay()

}

void draw() {
  if (mode==4) {
  //Code to draw and rotate a cube.
    translate(400,300,0);
    rotateX(pitch);
    rotateZ(roll);
    background(255);
    fill(255,228,225);
    box(200);
//    xZero=Descriptive.mean(neutralX); //"Center" for x acceleration
//    yZero=Descriptive.mean(neutralY); //"Center for y acceleration


  }
}

void keyReleased() {
  if (key =='1') {
    mode=1;
    j=0; //starts j over to be incremented with each iteration of serialEvent()
    port.write("adcaccel 10 100");
    port.bufferUntil('\n'); 
    port.write("\n");
    println("Neutral Samples (y):");
  } else if (key == '2') {
    mode=2;
    j=0; //starts j over to be incremented with each iteration of serialEvent()
    port.write("adcaccel 10 100");
    port.bufferUntil('\n'); 
    port.write("\n");
    println("Pronation Samples (y):");
  } else if (key == '3') {
    mode=3;
    j=0; //starts j over to be incremented with each iteration of serialEvent()
    port.write("adcaccel 10 100");
    port.bufferUntil('\n'); 
    port.write("\n");
    println("Supination Samples (y):");
  } else if (key == '4') { //Starts "continuous" collection of acceleration data
    mode = 4; //Tells serialEvent we are in collectDynamic() mode
    port.write("adcaccel 200 100"); //tells controller to send 200 lines of acceleration data
    port.bufferUntil('\n');
    port.write("\n");
  }
    else if (key == '5') { //THIS IS AN ATTEMPT TO HAVE A WAY OF STOPPING DYNAMIC COLLECTION BUT 
    //IT IS NOT WORKING (POSSIBLY BECAUSE KEYEVENTS CANT BE DETECTED IN WHILE LOOP?
    idle = 1;
    println("Done");
    }
}

void collectDynamic() {
  float xAcc=0; //x acceleration in g's
  float yAcc=0; //y acceleration in g's 
  float zAcc=0; //z acceleration in g's
  float[] proThresh={0,0,0}; //array to hold x,y,z accelerometer values for pronation threshold
  float[] supThresh={0,0,0}; //array to hold x,y,z accelerometer values for supination threshold
  
  idle = 0; //

     x1=x_vals.get(i-1);
     y1=y_vals.get(i-1);
     z1=z_vals.get(i-1);
    xAcc=(x1-xZero)*Scale; //Converts voltage to acceleration in g's
    yAcc=(y1-yZero)*Scale; //Converts voltage to acceleration in g's
    zAcc=(z1-zZero)*Scale; //Converts voltage to acceleration in g's
//    println(xAcc);
//    println(yAcc);
//    println(zAcc);
    
    //Aerospace rotation sequence
//    roll=atan(yAcc/zAcc); //Approximation of roll angle in radians based on aerospace rotation sequence
//    pitch=atan(-xAcc/sqrt(pow(yAcc,2)+pow(zAcc,2)));
//    //Aerospace rotation sequence (corrected)
    roll=atan(yAcc/(zAcc/abs(zAcc)*sqrt(pow(zAcc,2)+.01*pow(xAcc,2)))); //Approximation of roll angle in radians based on aerospace rotation sequence
    pitch=atan(-xAcc/sqrt(pow(yAcc,2)+pow(zAcc,2))); //Approximation of roll angle in radians
//    //Non-Aerospace rotation sequence    
//    roll=atan(yAcc/sqrt(pow(xAcc,2)+pow(zAcc,2))); //Approximation of roll angle in radians based on aerospace rotation sequence
//    pitch=atan(-xAcc/zAcc); 
//    //Non-Aerospace rotation sequence (corrected)
//    pitch=atan(-xAcc/(zAcc/abs(zAcc)*sqrt(pow(zAcc,2)+.01*pow(yAcc,2)))); //Approximation of roll angle in radians based on aerospace rotation sequence
//    roll=atan(yAcc/sqrt(pow(xAcc,2)+pow(zAcc,2))); //Approximation of roll angle in radians
    println(pitch*180/PI); //prints pitch angle in degrees
    println(roll*180/PI); //prints roll (supination/pronation) angle in degrees

proThresh = {Descriptive.mean(proSamplesX), Descriptive.mean(proSamplesY), Descriptive.mean(proSamplesZ)};
supThresh = {Descriptive.mean(supSamplesX), Descriptive.mean(supSamplesY), Descriptive.mean(supSamplesZ)}
proAcc = atan(proThresh[1]/(proThresh[2]/proThresh[2])*sqrt(pow(proThresh[2],2)+.01*pow(proThresh[0],2))));
//     if (x1 > 1600 && x1 < 1850) { 
//       proThresh = Descriptive.mean(proSamplesY);  //Threshold
//       supThresh = Descriptive.mean(supSamplesY); //
//       //println("horizontal");
//     //println(proThresh);
//    } else if ((x1 > 1450 && x1 < 1600) || (x1 > 1800 && x1 < 1950)) {
//        proThresh = Descriptive.mean(proSamplesY)+threshAdjust;
//        supThresh=Descriptive.mean(supSamplesY)-threshAdjust;
//        //println("45 degrees");
//  
//    } else {
//       proThresh = Descriptive.mean(proSamplesY)+2*threshAdjust;
//       supThresh = Descriptive.mean(supSamplesY)-2*threshAdjust;
//       //println("vertical");
//    }
    
    if (y1 < proThresh) {
      //println("Pronated");
    } else if (y1 > supThresh) {
      //println("Supinated");
    } else {
      //println("neutral");
    }
//plot x,y, and z acceleration values      
//      stroke(255,0,0);
//      line(xPos, height*(x0/3300), xPos+XINCREMENT, height*(x1/3300));
//      stroke(0,255,0);
//      line(xPos, height*(y0/3300), xPos+XINCREMENT, height*(y1/3300));
//      stroke(0,0,255);
//      line(xPos, height*(z0/3300), xPos+XINCREMENT, height*(z1/3300));       
//      
//      x0 = x1;
//      y0 = y1;
//      z0 = z1;
//      xPos = xPos + XINCREMENT;
     
}


void serialEvent (Serial myPort) {
  // Read string until carriage return and save as accelString
  String accelString = myPort.readStringUntil('\n'); //defines accelString as a single line of output from the terminal
  //println(accelString);

  if (accelString != null) {
    try {
      float[] accelVals = float(split(accelString, ',')); //splits line based on comma delimiter
        
      if (!Float.isNaN(accelVals[0])) { //If a value for the acceleration was output 
        x_vals.append(accelVals[0]);
        y_vals.append(accelVals[1]);
        z_vals.append(accelVals[2]);
        i = i + 1;   //Increments list index if actual acceleration values were appended
        if (mode==1) {
          neutralX[j]=x_vals.get(i-1);
          neutralY[j]=y_vals.get(i-1);
          neutralZ[j]=z_vals.get(i-1);
          if (j==9) {
            
          println(neutralY[j]);
//          println(Descriptive.mean(neutralX));
//          println(Descriptive.mean(neutralY));
//          println(Descriptive.mean(neutralZ));
          j=j+1;
        } else if (mode==2) {
          proSamplesX[j]=x_vals.get(i-1);
          proSamplesY[j]=y_vals.get(i-1);
          proSamplesZ[j]=z_vals.get(i-1);
          println(proSamplesY[j]);
          j=j+1;
        } else if (mode==3) {
          supSamplesX[j]=x_vals.get(i-1);
          supSamplesY[j]=y_vals.get(i-1);
          supSamplesZ[j]=z_vals.get(i-1);
          println(supSamplesY[j]);
          j=j+1;
        } else if (mode==4) {
          collectDynamic();
        }
      }
    
    }
    catch(Exception e) {
      //println(e);
    }
  }
}


