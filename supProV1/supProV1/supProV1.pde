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

//List<Float> x_vals = new ArrayList<Float>();
//List<Float> y_vals = new ArrayList<Float>();
//List<Float> z_vals = new ArrayList<Float>();



int r,g,b;    // Used to color background
Serial port;  // The serial port object

int XINCREMENT = 5;

int neutral = 0; //initialize neutral position

int xPos = 1;
float x0 = 0;
float x1 = 0;
float y0 = 0;
float y1 = 0;
float z0 = 0;
float z1 = 0;

//x_vals.add(x0);
//y_vals.add(y0);
//z_vals.add(z0);

void setup() {
  size(1000,400);
  background(255);
  println(Serial.list());
  port = new Serial(this, Serial.list()[0], 115200); //sets up first port for communication
  frameCount = 1; //enable use of delay()
  //port.write("\n");
  
  //If spacebar is pressed, call adcaccel to collect single line of acceleration values
   
  
  
//  port.write("adcaccel 250 100");  //tells controller to run adcaccel
//  port.bufferUntil('\n');
  
}

void keyReleased() {
  if (key =='1') {
  port.write("adcaccel 1 100");
  port.bufferUntil('\n');
  //String x = myPort.readStringUntil('\n');
  port.write("\n"); 
  //println(x);
    //collectNeutral();
  } else if (key == '2') {
    println("2 key");
  } else if (key == '3') {
    println("3 key");
  }

}

  
void draw() {

}

//function that records single x, y, z acceleration value when prompted
//int[] recordThresholds() {
// port.write("adcaccel 1 100");
// port.bufferUntil('\n'); 
//  
//}

void collectNeutral() {
  port.write("adcaccel 1 100");
  port.bufferUntil('\n'); 
}
//
//void serialEvent (Serial myPort) {
//    String accelString = myPort.readStringUntil('\n'); //defines accelString as a single line of output from the terminal
//    println(accelString);
//    if (accelString != null) {
//      try {
//        float[] accelVals = float(split(accelString, ',')); //splits line based on comma delimiter
//        println('\n');
//        println(accelVals);
//        x1 = accelVals[0];
//        y1 = accelVals[1];
//        z1 = accelVals[2];
//      }
//      catch(Exception e) {
//        println(e);
//      }
//
//    }
//  }

void serialEvent (Serial myPort) {
  // Read string until carriage return and save as accelString
  String accelString = myPort.readStringUntil('\n'); //defines accelString as a single line of output from the terminal
  //println(accelString);

  if (accelString != null) {
    try {
      float[] accelVals = float(split(accelString, ',')); //splits line based on comma delimiter
      println('\n');
      println(accelVals);
      x1 = accelVals[0];
      y1 = accelVals[1];
      z1 = accelVals[2];
      
      int proThresh;
      int supThresh;
      
      
      if (x1 > 1600 && x1 < 1800) {
       proThresh = 1850;
       supThresh = 2100;
       println("horizontal");
       //println(proThresh);
      } else if (x1 > 1800 && x1 < 1900) {
        proThresh = 1900;
        supThresh=2000;
        println("45 degrees");
    
      } else {
       proThresh = 1950;
       supThresh = 1975;
       println("vertical");
       //println(proThresh);
      }
//    
        if (y1 < proThresh) {
          println("Pronated");
        } else if (y1 > supThresh) {
          println("Supinated");
        } else {
          println("neutral");
        }
//      x_vals.add(x1);
//      y_vals.add(y1);
//      z_vals.add(z1);
//      
//      //int[] vals = {x1, y1, z1};
//      //println(accelVals);
//      

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
    catch(Exception e) {
      //println(e);
    }
  }
}


