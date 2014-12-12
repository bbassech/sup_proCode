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
int mode = 0; //This variable is changed when keys are pressed and used by serialEvent() to check what to do with incoming data
int j = 0; //This is an incrementer used for populated arrays with a fixed number of samples (neutralY, proSamplesY, etc)

//Declare variables for calculating rotation angles and visualizing on cube
float xZero=1640; //center value of x channel. Determined with controller resting "housing down" on a table
float yZero=2010; //center value of y channel
float zZero=2050; // center value of z channel
float Scale=1/300.0; //sensitivity (g/mV) of accelerometer

////This block was trying to use a different scale for each channel.
//float xScale=2/670.0; //2 g/voltage range of x channel
//float yScale=2/586.0; //2 g/voltage range of y channel
//float zScale=2/560.0; //2 g/voltage range of z channel

float roll=0; //initialize variable for roll angle
float pitch=0; //initialize variable for pitch angle
float neutralRoll=0; //variable for the roll angle of neutral postion
float proRoll=0; //variable for the roll angle of pronation threshold
float supRoll=0; //variable for the roll angle of supination threshold


//Initialize float lists for all acceleration channels. Values will be appended 
//to these lists everytime a non null string is written to the port
FloatList x_vals;
FloatList y_vals;
FloatList z_vals;

//initialize variables to store the x,y,z accelerations when thresholds are set
float[] neutralX = new float[10]; //used to collect 10 x values for neutral...
float[] neutralY = new float[10];
float[] neutralZ = new float[10];
float[] proSamplesX = new float[10]; //Used to store 10 x values for pronation to average for a threshold
float[] proSamplesY = new float[10]; //Used to store 10 y values for pronation to average for a threshold
float[] proSamplesZ = new float[10]; //Used to store 10 z values for pronation to average for a threshold
float[] supSamplesX = new float[10]; //Used to store 10 x values for supinaton to average for a threshold
float[] supSamplesY = new float[10]; //Used to store 10 y values for supinaton to average for a threshold
float[] supSamplesZ = new float[10]; //Used to store 10 y values for supinaton to average for a threshold

void setup() {
//  size(1000,400);
//  background(255);
  size(800,600,P3D); //These are for drawing Cube
  smooth();
  fill(255,228,225); //initialize fill color to neutral color
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
    box(200);

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
    port.write("adcaccel 250 100"); //tells controller to send 200 lines of acceleration data
    port.bufferUntil('\n');
    port.write("\n");
  }
}

void collectDynamic() {
  float x1 = 0;
  float y1 = 0;
  float z1 = 0;
  float xAcc=0; //x acceleration in g's
  float yAcc=0; //y acceleration in g's 
  float zAcc=0; //z acceleration in g's

    x1=x_vals.get(i-1);
    y1=y_vals.get(i-1);
    z1=z_vals.get(i-1);
    xAcc=(x1-xZero)*Scale; //Converts voltage to acceleration in g's
    yAcc=(y1-yZero)*Scale; //Converts voltage to acceleration in g's
    zAcc=(z1-zZero)*Scale; //Converts voltage to acceleration in g's

//Calculation of roll and pitch angle (4 options using    
//  //Aerospace rotation sequence
    roll=atan(yAcc/zAcc); //Approximation of roll angle in radians based on aerospace rotation sequence
    pitch=atan(-xAcc/sqrt(pow(yAcc,2)+pow(zAcc,2)));
//  //Aerospace rotation sequence (corrected)
//    roll=atan(yAcc/(zAcc/abs(zAcc)*sqrt(pow(zAcc,2)+.01*pow(xAcc,2)))); //Approximation of roll angle in radians based on aerospace rotation sequence
//    pitch=atan(-xAcc/sqrt(pow(yAcc,2)+pow(zAcc,2))); //Approximation of roll angle in radians
//  //Non-Aerospace rotation sequence    
//    roll=atan(yAcc/sqrt(pow(xAcc,2)+pow(zAcc,2))); //Approximation of roll angle in radians based on aerospace rotation sequence
//    pitch=atan(-xAcc/zAcc); 
//  //Non-Aerospace rotation sequence (corrected)
//    pitch=atan(-xAcc/(zAcc/abs(zAcc)*sqrt(pow(zAcc,2)+.01*pow(yAcc,2)))); //Approximation of roll angle in radians based on aerospace rotation sequence
//    roll=atan(yAcc/sqrt(pow(xAcc,2)+pow(zAcc,2))); //Approximation of roll angle in radians
    
println(pitch*180/PI); //prints pitch angle in degrees
println(roll*180/PI); //prints roll (supination/pronation) angle in degrees

//Check current roll angle against thresholds
    if ((roll < proRoll || roll>supRoll) && yAcc<0) { //This OR statement is simply to adress the fact the pronation past 90degrees should still count.  yAcc<0 excludes actual supination
      println("Pronated");
      fill(255,0,0);
    } else if (roll > supRoll && zAcc>0) {
      println("Supinated");
      fill(0,0,255);
    } else {
      println("neutral");
      fill(255,228,225);
    }

}


void serialEvent (Serial myPort) {
  // Read string until carriage return and save as accelString
  String accelString = myPort.readStringUntil('\n'); //defines accelString as a single line of output from the terminal

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
          if (j==9) { //if all 10 samples have been collected
            float[] neutralAvg={Descriptive.mean(neutralX), Descriptive.mean(neutralY), Descriptive.mean(neutralZ)};
            float[] neutralAcc={(neutralAvg[0]-xZero)*Scale, (neutralAvg[1]-yZero)*Scale, (neutralAvg[2]-zZero)*Scale};
//            neutralRoll=atan(neutralAcc[1]/(neutralAcc[2]/abs(neutralAcc[2])*sqrt(pow(neutralAcc[2],2)+.01*pow(neutralAcc[0],2)))); //Approximation of roll angle in radians based on corrected aerospace rotation sequence
            neutralRoll=atan(neutralAcc[1]/neutralAcc[2]); //uncorrected aerospace 
//            neutralRoll=atan(neutralAcc[1]/sqrt(pow(neutralAcc[0],2)+pow(neutralAcc[2],2))); //Approximation of roll angle in radians based on aerospace rotation sequence 
            println(neutralRoll*180/PI);
          }
          j=j+1;
        } else if (mode==2) {
          proSamplesX[j]=x_vals.get(i-1);
          proSamplesY[j]=y_vals.get(i-1);
          proSamplesZ[j]=z_vals.get(i-1);
          if (j==9) { //if all 10 samples have been collected
            float[] proAvg={Descriptive.mean(proSamplesX), Descriptive.mean(proSamplesY), Descriptive.mean(proSamplesZ)};
            float[] proAcc={(proAvg[0]-xZero)*Scale, (proAvg[1]-yZero)*Scale, (proAvg[2]-zZero)*Scale};
//            proRoll=atan(proAcc[1]/(proAcc[2]/abs(proAcc[2])*sqrt(pow(proAcc[2],2)+.01*pow(proAcc[0],2)))); //Approximation of roll angle in radians based on corrected aerospace rotation sequence
            proRoll=atan(proAcc[1]/proAcc[2]); //uncorrected aerospace rotation sequence
//            proRoll=atan(proAcc[1]/sqrt(pow(proAcc[0],2)+pow(proAcc[2],2)));
            println(proRoll*180/PI);
          }
          j=j+1;
        } else if (mode==3) {
          supSamplesX[j]=x_vals.get(i-1);
          supSamplesY[j]=y_vals.get(i-1);
          supSamplesZ[j]=z_vals.get(i-1);
          if (j==9) { //if all 10 samples have been collected
            float[] supAvg={Descriptive.mean(supSamplesX), Descriptive.mean(supSamplesY), Descriptive.mean(supSamplesZ)};
            float[] supAcc={(supAvg[0]-xZero)*Scale, (supAvg[1]-yZero)*Scale, (supAvg[2]-zZero)*Scale};
//            supRoll=atan(supAcc[1]/(supAcc[2]/abs(supAcc[2])*sqrt(pow(supAcc[2],2)+.01*pow(supAcc[0],2)))); //Approximation of roll angle in radians based on aerospace rotation sequence
            supRoll=atan(supAcc[1]/supAcc[2]); //uncorrected aerospace
//            supRoll=atan(supAcc[1]/sqrt(pow(supAcc[0],2)+pow(supAcc[2],2)));
            println(supRoll*180/PI);
          }
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


