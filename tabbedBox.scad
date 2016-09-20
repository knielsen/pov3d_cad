include <ledtorus_rotor.scad>

showFlat = false;
showFolded = true;
showExpanded = true;
showPlatter = true;
showOpenBox = true;

boxDepth   = 200;    // x
boxWidth   = 270;    // y
boxHeight  = 140;    // z
plateThickness = 12;
wishTabWidth = 25;
axleDia = 10;
axlePos = 90;
largeBearingDepth = 8;  // ToDo: Measure this.
largeBearingOuterDia = 38.1;
largeBearingInnerDia = 27;
largeBearingFreeDia = largeBearingOuterDia - 2*2;
smallBearingDepth = 8;  // ToDo: Measure this.
smallBearingOuterDia = 26;
smallBearingInnerDia = 10;
smallBearingFreeDia = smallBearingOuterDia - 2*2;
// Distance between LED-torus axle and motor axle (min and max, adjustable).
motorPosMin = 45;
motorPosMax = 90;
// Diameter of holes for fastening motor mount.
motorFastenerDia = 4;
// Space between top of box and bottom of LED-torus spindle mount (top of platter).
distBoxTorus = 15;
// Spacing between the two long holes for fastening motor mount.
motorFastenerDist = 50;

// Fine subdivisions, for production run
$fa = 1; $fs = 0.1;
// Coarse, but faster, subdivisions, for testing.
//$fa = 8; $fs = 0.8;


module backFront()
{
    translate([plateThickness,plateThickness])
        square([boxWidth-plateThickness*2,boxHeight-plateThickness*2]);

    tabStyle = 0;
    tab(boxWidth,wishTabWidth,tabStyle,plateThickness);
    translate([plateThickness*2,0])
      rotate([0,0,90])
        tab(boxHeight,wishTabWidth,tabStyle,plateThickness);
    translate([boxWidth,0])
      rotate([0,0,90])
        tab(boxHeight,wishTabWidth,tabStyle,plateThickness);
    translate([0,boxHeight-plateThickness*2])
      tab(boxWidth,wishTabWidth,tabStyle,plateThickness);
}

module side()
{
    translate([plateThickness,plateThickness])
        square([boxDepth-plateThickness*2,boxHeight-plateThickness*2]);

    tabStyleSide = 1;
    tabStyleTopButt = 0;
    tab(boxDepth,wishTabWidth,tabStyleTopButt,plateThickness);
    translate([plateThickness*2,0])
      rotate([0,0,90])
        tab(boxHeight,wishTabWidth,tabStyleSide,plateThickness);
    translate([boxDepth,0])
      rotate([0,0,90])
        tab(boxHeight,wishTabWidth,tabStyleSide,plateThickness);
    translate([0,boxHeight-plateThickness*2])
      tab(boxDepth,wishTabWidth,tabStyleTopButt,plateThickness);
}

module top()
{
    translate([plateThickness,plateThickness])
        square([boxWidth-plateThickness*2,boxDepth-plateThickness*2]);

    tabStyleSide = 2;
    tabStyleTopButt = 2;
    tab(boxWidth,wishTabWidth,tabStyleTopButt,plateThickness);
    translate([plateThickness*2,0])
      rotate([0,0,90])
        tab(boxDepth,wishTabWidth,tabStyleSide,plateThickness);
    translate([boxWidth,0])
      rotate([0,0,90])
        tab(boxDepth,wishTabWidth,tabStyleSide,plateThickness);
    translate([0,boxDepth-plateThickness*2])
      tab(boxWidth,wishTabWidth,tabStyleTopButt,plateThickness);
}


module topWithHoles(for2D=false) {
  epsilon = 0.17;
  difference() {
    asPlate()
      top();
    translate([axlePos, boxDepth/2, -epsilon])
      cylinder(r=largeBearingFreeDia/2, h=plateThickness+2*epsilon, center=false);
    translate([axlePos, boxDepth/2, plateThickness-largeBearingDepth])
      cylinder(r=largeBearingOuterDia/2, h=largeBearingDepth+2*epsilon);
  }
  if (for2D) {
    // Something for the CNC to get the inner diameter in the 2D drawing.
    translate([axlePos, boxDepth/2, plateThickness-0.5*largeBearingDepth])
      cylinder(r=largeBearingFreeDia/2, h=largeBearingDepth, center=false);
  }
}

module bottomWithHoles(for2D=false) {
  epsilon = 0.117;
  difference() {
    asPlate()
      top();
    // Room for the axle to not touch the box.
    translate([axlePos, boxDepth/2, -epsilon])
      cylinder(r=smallBearingFreeDia/2, h=plateThickness+2*epsilon, center=false);
    // Hole fitting the lower, small ball bearing.
    translate([axlePos, boxDepth/2, plateThickness-smallBearingDepth])
      cylinder(r=smallBearingOuterDia/2, h=smallBearingDepth+2*epsilon);
    // Holes for mounting motor, with some flexibility to adjust the belt tension.
    for (i = [-0.5 : 1 : 0.5]) {
      translate([0, i*motorFastenerDist, 0]) {
        hull() {
          translate([axlePos + motorPosMin, boxDepth/2, -epsilon])
            cylinder(r=motorFastenerDia/2, h=plateThickness+2*epsilon, center=false);
          translate([axlePos + motorPosMax, boxDepth/2, -epsilon])
            cylinder(r=motorFastenerDia/2, h=plateThickness+2*epsilon, center=false);
        }
      }
    }
  }
  if (for2D) {
    // Something for the CNC to get the inner diameter in the 2D drawing.
    translate([axlePos, boxDepth/2, plateThickness-0.5*smallBearingDepth])
      cylinder(r=smallBearingFreeDia/2, h=smallBearingDepth, center=false);
  }
}

module foldedBox(expanded) {
  delta = expanded ? plateThickness : 0;
  inRed() {
    bottomWithHoles();
    translate([0,0,boxHeight-plateThickness+2*delta])
      topWithHoles();
  }
  inGreen() {
    translate([-delta,0,delta])
      rotate([90,0,90])
        asPlate()
          side();
    translate([boxWidth-plateThickness+delta,0,delta])
      rotate([90,0,90])
        asPlate()
          side();
  }
  inBlue() {
    if (!showOpenBox) {
      translate([0,plateThickness-delta,delta])
        rotate([90,0,0])
          asPlate()
            backFront();
    }
    translate([0,boxDepth+delta,delta])
      rotate([90,0,0])
        asPlate()
          backFront();
  }

  if (showPlatter) {
    vertpos =  boxHeight + (showExpanded ? 2*plateThickness : 0) + distBoxTorus;
    translate([axlePos, boxDepth/2, vertpos])
      %ledtorus_rotor();
  }
}


if (showFlat) {
  translate([0,boxHeight])
    in2D()
      topWithHoles(for2D=true);
  translate([0,-boxDepth])
    in2D()
      bottomWithHoles(for2D=true);
  translate([boxWidth,0])
    side();
  translate([-boxDepth,0])
    side();
  backFront();
  translate([boxWidth+boxDepth,0])
    backFront();
}


if (showFolded) {
  foldedBox(showExpanded);
}


module inRed() {
  color([1, 0, 0])
    children();
}

module inGreen() {
  color([0, 1, 0])
    children();
}

module inBlue() {
  color([0, 0, 1])
    children();
}

module asPlate() {
  linear_extrude(height=plateThickness, convexity=10)
    children();
}

module in2D() {
  projection(cut=true)
    translate([0, 0, -0.99*plateThickness])
      children();
}

/*
  Create the tabs along the edge of a side of the box.
  Parameters:
    length         length of the edge.
    wishTabLength  Requested length of one tab (short length, ie. only the
                   protruding part). This length will be rounded up so that
                   there will be an integer number of tabs.
    start          tabStyle. 0 is ____####____####____
                             1 is _###____####____###_
                             2 is ####____####____####
    tabDepth       How much the tab should protrude.
*/
module tab(length, wishTabLength, start, tabDepth)
{
    tabDepthExtra = tabDepth;

    wishNum = length / wishTabLength;
    tabNum = floor(0.5*(wishNum-1));
    tabLength = length / (2*tabNum+1);

    if (start == 0) {
        for (i=[0:tabNum-1]) {
            translate([((1+2*i)*tabLength),0])
              square([tabLength,tabDepth+tabDepthExtra]);
        }
    }
    if (start == 1) {
        for (i=[0:tabNum]) {
            translate([((2*i)*tabLength),0]) {
                if(i==0) {
                  translate([tabDepth,0])
                    square([tabLength-tabDepth,tabDepth+tabDepthExtra]);
                } else if(i==tabNum) {
                  square([tabLength-tabDepth,tabDepth+tabDepthExtra]);
                } else {
                  square([tabLength,tabDepth+tabDepthExtra]);
                }
            }
        }

    }
    if (start == 2) {
        for (i=[0:tabNum]) {
            translate([((2*i)*tabLength),0])
              square([tabLength,tabDepth+tabDepthExtra]);
        }
    }
}
