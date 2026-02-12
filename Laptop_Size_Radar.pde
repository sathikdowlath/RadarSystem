import processing.serial.*;

Serial myPort;
String angle = "";
String distance = "";
String data = "";
String noObject;
float pixsDistance;
int iAngle, iDistance;
int index1 = 0;

void setup() {
  size(1280, 720);
  smooth();
  
  myPort = new Serial(this, "COM3", 9600);
  myPort.bufferUntil('.');
}

void draw() {
  float cx = width * 0.5;
  float cy = height * 0.65;
  float maxR = min(width * 0.8, height * 0.6);
  
  noStroke();
  fill(0, 4);
  rect(0, 0, width, cy + maxR * 1.1); // Extra space for labels
  
  drawRadar(cx, cy, maxR);
  drawLine(cx, cy, maxR);
  drawObject(cx, cy, maxR);
  drawText(cx, cy, maxR);
}

void serialEvent(Serial myPort) {
  data = myPort.readStringUntil('.');
  if (data != null) {
    data = data.substring(0, data.length() - 1);
    index1 = data.indexOf(",");
    if (index1 > 0) {
      angle = data.substring(0, index1);
      distance = data.substring(index1 + 1);
      iAngle = int(angle);
      iDistance = int(distance);
    }
  }
}

void drawRadar(float cx, float cy, float maxR) {
  pushMatrix();
  translate(cx, cy);
  
  noFill();
  strokeWeight(3);
  stroke(98, 245, 31);
  
  arc(0, 0, maxR * 2, maxR * 2, PI, TWO_PI);
  arc(0, 0, maxR * 1.6, maxR * 1.6, PI, TWO_PI);
  arc(0, 0, maxR * 1.2, maxR * 1.2, PI, TWO_PI);
  arc(0, 0, maxR * 0.8, maxR * 0.8, PI, TWO_PI);
  
  strokeWeight(1.5);
  float halfR = maxR;
  line(-halfR, 0, halfR, 0);
  line(0, 0, -halfR*cos(radians(30)), -halfR*sin(radians(30)));
  line(0, 0, -halfR*cos(radians(60)), -halfR*sin(radians(60)));
  line(0, 0, -halfR*cos(radians(90)), -halfR*sin(radians(90)));
  line(0, 0, -halfR*cos(radians(120)), -halfR*sin(radians(120)));
  line(0, 0, -halfR*cos(radians(150)), -halfR*sin(radians(150)));
  
  popMatrix();
}

void drawObject(float cx, float cy, float maxR) {
  if (iDistance >= 40 || iDistance == 0) return;
  
  pushMatrix();
  translate(cx, cy);
  strokeWeight(12);
  stroke(255, 10, 10);
  
  float pixsPerCm = maxR / 40.0;
  pixsDistance = iDistance * pixsPerCm;
  
  line(pixsDistance*cos(radians(iAngle)), -pixsDistance*sin(radians(iAngle)),
       maxR*cos(radians(iAngle)), -maxR*sin(radians(iAngle)));
  popMatrix();
}

void drawLine(float cx, float cy, float maxR) {
  pushMatrix();
  translate(cx, cy);
  strokeWeight(12);
  stroke(30, 250, 60);
  line(0, 0, maxR*cos(radians(iAngle)), -maxR*sin(radians(iAngle)));
  popMatrix();
}

void drawText(float cx, float cy, float maxR) {
  float barHeight = height * 0.12;
  float barTop = height - barHeight;
  
  // Status bar
  fill(0, 200);
  noStroke();
  rect(0, barTop, width, barHeight);
  
  // FIXED: HORIZONTAL labels RIGHT BELOW RADAR (like original)
  fill(98, 245, 31);
  textSize(height * 0.022);
  textAlign(CENTER, CENTER);
  
  float labelY = cy + maxR * 0.55; // Just below bottom of radar
  float labelSpacing = (width - cx * 2) / 4.0; // 4 labels
  
  text("10cm", cx + labelSpacing * 0.5, labelY);
  text("20cm", cx + labelSpacing * 1.5, labelY);
  text("30cm", cx + labelSpacing * 2.5, labelY);
  text("40cm", cx + labelSpacing * 3.5, labelY);
  
  // Status text
  fill(98, 245, 31);
  textSize(height * 0.035);
  textAlign(LEFT, CENTER);
  noObject = (iDistance > 40 || iDistance == 0) ? "Out of Range" : "In Range";
  text("Object: " + noObject, width * 0.02, barTop + barHeight * 0.35);
  text("Angle: " + iAngle + "°", width * 0.35, barTop + barHeight * 0.35);
  text("Distance: " + ((iDistance < 40 && iDistance > 0) ? iDistance + " cm" : "---- cm"), 
       width * 0.65, barTop + barHeight * 0.35);
  
  // Angle labels on spokes
  fill(98, 245, 60);
  textSize(height * 0.016);
  textAlign(CENTER, CENTER);
  
  int[] angles = {30, 60, 90, 120, 150};
  for (int i = 0; i < angles.length; i++) {
    pushMatrix();
    float a = radians(angles[i]);
    translate(cx + maxR * 0.85 * cos(a), cy - maxR * 0.85 * sin(a));
    rotate(-a + HALF_PI);
    text(angles[i] + "°", 0, 0);
    popMatrix();
  }
}
