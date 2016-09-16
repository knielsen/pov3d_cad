showFlat = false;
showFolded = true;
showExpanded = true;

boxDepth   = 350;    // x
boxWidth   = 500;    // y
boxHeight  = 500;    // z
plateThickness = 5;
wishTabWidth = 25;



module backFront()
{
    translate([plateThickness,plateThickness])
        square([boxWidth-plateThickness*2,boxHeight-plateThickness*2]);

    tabStyle = 0;
    tab(boxWidth,wishTabWidth,tabStyle,plateThickness);
    translate([plateThickness*2,0])
      rotate([0,0,90])
        tab(boxWidth,wishTabWidth,tabStyle,plateThickness);
    translate([boxWidth,0])
      rotate([0,0,90])
        tab(boxWidth,wishTabWidth,tabStyle,plateThickness);
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


module foldedBox(expanded) {
  delta = expanded ? plateThickness : 0;
  inRed() {
    asPlate()
      top();
    translate([0,0,boxHeight-plateThickness+2*delta])
      asPlate()
        top();
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
    translate([0,plateThickness-delta,delta])
      rotate([90,0,0])
        asPlate()
          backFront();
    translate([0,boxDepth+delta,delta])
      rotate([90,0,0])
        asPlate()
          backFront();
  }
}


if (showFlat) {
  translate([0,boxHeight])
    top();
  translate([0,-boxDepth])
    top();
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
  linear_extrude(height=plateThickness)
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
