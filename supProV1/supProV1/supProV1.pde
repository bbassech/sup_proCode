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
float[] neutral = {0,0,0}; 
float[] supThresh = {0,0,0};
float[] proThresh = {0,0,0};

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

  
  
//  port.write("adcaccel 250 100");  //tells controller to run adcaccel
//  port.bufferUntil('\n');
  
}

void draw() {
}

void keyReleased() {
  if (key =='1') {
    collectNeutral();
    println(neutral);
  } else if (key == '2') {
    collectPro();
    println(proThresh);
  } else if (key == '3') {
    collectSup();
    println(supThresh);
  } else if (key == '4') {
    collectDynamic();
  }
    else if (key == '5') {
      idle = 1;
      println("Done");
    }
}

void collectNeutral() {
  port.write("adcaccel 1 100");
  port.bufferUntil('\n'); 
  port.write("\n");
  delay(50);
  //println(i);
  neutral[0] = x_vals.get(i-1);
  neutral[1] = y_vals.get(i-1);
  neutral[2] = z_vals.get(i-1);
}

void collectPro() {
  port.write("adcaccel 1 100");
  port.bufferUntil('\n'); 
  port.write("\n");
  delay(50);
  proThresh[0] = x_vals.get(i-1);
  proThresh[1] = y_vals.get(i-1);
  proThresh[2] = z_vals.get(i-1);
}

void collectSup() {
  port.write("adcaccel 1 100");
  port.bufferUntil('\n'); 
  port.write("\n");
  delay(50);
  supThresh[0] = x_vals.get(i-1);
  supThresh[1] = y_vals.get(i-1);
  supThresh[2] = z_vals.get(i-1);
}

void collectDynamic() {
  float pronThresh; //new variable for yAccel threshold since it will change based on x-orientation (horizontal vs. tilted)
  float supiThresh; //new variable for yAccel threshold since it will change based on x-orientation (horizontal vs. tilted)
  
  port.write("adcaccel 200 100"); //tells controller to send 200 lines of acceleration data
  port.bufferUntil('\n');
  port.write("\n");
  idle = 0; //
  delay(1000); //waits for adcaccel to print a line before checking if anything was read from port.
 
 while (idle==0) {
     delay(50);
     x1=x_vals.get(i-1);
     y1=y_vals.get(i-1);
     z1=z_vals.get(i-1);
     println(x1);
     println(y1);
     println(z1);
     
     if (x1 > 1500 && x1 < 1800) {
     pronThresh = proThresh[1];  //0riginally 1850
     supiThresh = supThresh[1]; //Originally 2100
     println("horizontal");
     //println(proThresh);
    } else if (x1 > 1800 && x1 < 1900) {
        pronThresh = proThresh[1]+50; //Originally 1900
        supiThresh=supThresh[1]-50;  //Originally 2000
        println("45 degrees");
  
    } else {
       pronThresh = proThresh[1]+50; //Originally 1950
       supiThresh = supThresh[1]-25; //Originally 1975
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
      
//      int pronThresh;
//      int supiThresh;
//      
//      
//      if (x1 > 1600 && x1 < 1800) {
//       pronThresh = 1850;
//       supiThresh = 2100;
//       println("horizontal");
//       //println(proThresh);
//      } else if (x1 > 1800 && x1 < 1900) {
//        pronThresh = 1900;
//        supiThresh=2000;
//        println("45 degrees");
//    
//      } else {
//       pronThresh = 1950;
//       supiThresh = 1975;
//       println("vertical");
//       //println(proThresh);
//      }
////    
//        if (y1 < pronThresh) {
//          println("Pronated");
//        } else if (y1 > supiThresh) {
//          println("Supinated");
//        } else {
//          println("neutral");
//        }

//      
//      //int[] vals = {x1, y1, z1};
//      //println(accelVals);
//      


////plot x,y, and z acceleration values      
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
    catch(Exception e) {
      //println(e);
    }
  }
}


