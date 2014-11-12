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


int r,g,b;    // Used to color background
Serial port;  // The serial port object

int i = 0;  //I is an incrementing counter that increments everytime something is read from serialEvent
int idle = 0; //This is used to stop the loop in collectDynamic

int XINCREMENT = 5;


int xPos = 1;
float x0 = 0;
float x1 = 0;
float y0 = 0;
float y1 = 0;
float z0 = 0;
float z1 = 0;

//Initialize float lists for all acceleration channels. Values will be appended 
//to these lists everytime a non null string is written to the port
FloatList x_vals;
FloatList y_vals;
FloatList z_vals;

//initialize variables to store the x,y,z accelerations when thresholds are set
float[] neutral = {0,0,0}; //currently unused
float[] supSample = {0,0,0}; //currently unused
float[] proSample = {0,0,0}; //curently unused
float[] neutralX = new float[10]; //used to collect 10 x values for neutral...
float[] neutralY = new float[10];
float[] neutralZ = new float[10];
float[] proSamplesY = new float[10]; //Used to store 10 y values for pronation to average for a threshold
float[] supSamplesY = new float[10]; //Used to store 10 y values for supinaton to average for a threshold


void setup() {
  size(1000,400);
  background(255);
  x_vals = new FloatList();
  y_vals = new FloatList();
  z_vals = new FloatList();
  println(Serial.list());
  port = new Serial(this, Serial.list()[0], 115200); //sets up first port for communication
  frameCount = 1; //enable use of delay()
  //port.write("\n");

  
}

void draw() {
}

void keyReleased() {
  if (key =='1') {
    collectNeutral();
    delay(2000); //waits enough time for all 10 values to be added to y_vals
    for (int j=0; j<10 ; j = j+1) { //Creates an array from the 10 data points just added to y_vals
      neutralY[9-j]=y_vals.get(i-1-j);
    }
    println("Neutral Samples (y):");
    println(neutralY);
  
  } else if (key == '2') {
      collectPro();
      delay(2000);
      for (int j=0; j<10 ; j = j+1) { //Creates an array from the 10 data points just added to y_vals
        proSamplesY[9-j]=y_vals.get(i-1-j);
      }
      println("Pronation Samples (y):");
      println(proSamplesY);
  
  } else if (key == '3') {
      collectSup();
      delay(2000);
      for (int j=0; j<10 ; j = j+1) { //Creates an array from the 10 data points just added to y_vals
        supSamplesY[9-j]=y_vals.get(i-1-j);
      }
      println("Supination Samples (y):");
      println(supSamplesY);
  
  } else if (key == '4') { //Starts "continuous" collection of acceleration data
      collectDynamic();
  }
    else if (key == '5') { //THIS IS AN ATTEMPT TO HAVE A WAY OF STOPPING DYNAMIC COLLECTION BUT 
    //IT IS NOT WORKING (POSSIBLY BECAUSE KEYEVENTS CANT BE DETECTED IN WHILE LOOP?
      idle = 1;
      println("Done");
    }
}

void collectNeutral() {
  port.write("adcaccel 10 100");
  port.bufferUntil('\n'); 
  port.write("\n");
  delay(50);
  //println(i);
//  neutral[0] = x_vals.get(i-1);
//  neutral[1] = y_vals.get(i-1);
//  neutral[2] = z_vals.get(i-1);
}

void collectPro() {
  port.write("adcaccel 10 100");
  port.bufferUntil('\n'); 
  port.write("\n");
  delay(50);
//  proSample[0] = x_vals.get(i-1);
//  proSample[1] = y_vals.get(i-1);
//  proSample[2] = z_vals.get(i-1);
}

void collectSup() {
  port.write("adcaccel 1 100");
  port.bufferUntil('\n'); 
  port.write("\n");
  delay(50);
//  supSample[0] = x_vals.get(i-1);
//  supSample[1] = y_vals.get(i-1);
//  supSample[2] = z_vals.get(i-1);
}

void collectDynamic() {
  float proThresh; //new variable for yAccel threshold since it will change based on x-orientation (horizontal vs. tilted)
  float supThresh; //new variable for yAccel threshold since it will change based on x-orientation (horizontal vs. tilted)
  
  port.write("adcaccel 200 100"); //tells controller to send 200 lines of acceleration data
  port.bufferUntil('\n');
  port.write("\n");
  idle = 0; //
//  delay(1000); //waits for adcaccel to print a line before checking if anything was read from port.
 
 while (idle==0) {
  delay(150); //THis is necessary for Serial event to run and add new vals before current x1,y1,and z1 get redefined
//I WOULD PREFER TO SYNC THIS WITH SERIALEVENT IN A BETTER WAY THAN USING DELAYS 
     x1=x_vals.get(i-1);
     y1=y_vals.get(i-1);
     z1=z_vals.get(i-1);
     println(x1);
     println(y1);
     println(z1);
     
     if (x1 > 1500 && x1 < 1800) {
       proThresh = Descriptive.mean(proSamplesY);  //0riginally 1850
       supThresh = Descriptive.mean(supSamplesY); //Originally 2100
     println("horizontal");
     //println(proThresh);
    } else if (x1 > 1800 && x1 < 1900) {
        proThresh = Descriptive.mean(proSamplesY)+25; //Originally 1900
        supThresh=Descriptive.mean(supSamplesY)-25;  //Originally 2000
        println("45 degrees");
  
    } else {
       proThresh = Descriptive.mean(proSamplesY)+50; //Originally 1950
       supThresh = Descriptive.mean(supSamplesY)-50; //Originally 1975
       println("vertical");
    }
    
    if (y1 < pronThresh) {
      println("Pronated");
    } else if (y1 > supiThresh) {
      println("Supinated");
    } else {
      println("neutral");
    }
//plot x,y, and z acceleration values      
      stroke(255,0,0);
      line(xPos, height*(x0/3300), xPos+XINCREMENT, height*(x1/3300));
      stroke(0,255,0);
      line(xPos, height*(y0/3300), xPos+XINCREMENT, height*(y1/3300));
      stroke(0,0,255);
      line(xPos, height*(z0/3300), xPos+XINCREMENT, height*(z1/3300));       
      
      x0 = x1;
      y0 = y1;
      z0 = z1;
      xPos = xPos + XINCREMENT;
  }
}


void serialEvent (Serial myPort) {
  // Read string until carriage return and save as accelString
  String accelString = myPort.readStringUntil('\n'); //defines accelString as a single line of output from the terminal
  //println(accelString);

  if (accelString != null) {
    try {
      float[] accelVals = float(split(accelString, ',')); //splits line based on comma delimiter
      
     if (!Float.isNaN(x1)) {
      x_vals.append(accelVals[0]);
      y_vals.append(accelVals[1]);
      z_vals.append(accelVals[2]);
      i = i + 1;   //Increments list index if actual acceleration values were appended
     }
  
    }
    catch(Exception e) {
      //println(e);
    }
  }
}


