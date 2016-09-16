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
    translate([plateThickness*2,0])rotate([0,0,90])tab(boxWidth,wishTabWidth,tabStyle,plateThickness);
    translate([boxWidth,0])rotate([0,0,90])tab(boxWidth,wishTabWidth,tabStyle,plateThickness);
    translate([0,boxHeight-plateThickness*2])tab(boxWidth,wishTabWidth,tabStyle,plateThickness);
}

module side()
{
    translate([plateThickness,plateThickness])
        square([boxDepth-plateThickness*2,boxHeight-plateThickness*2]);
    
    tabStyleSide = 1;
    tabStyleTopButt = 0;
    tab(boxDepth,wishTabWidth,tabStyleTopButt,plateThickness);
    translate([plateThickness*2,0])rotate([0,0,90])tab(boxHeight,wishTabWidth,tabStyleSide,plateThickness);
    translate([boxDepth,0])rotate([0,0,90])tab(boxHeight,wishTabWidth,tabStyleSide,plateThickness);
    translate([0,boxHeight-plateThickness*2])tab(boxDepth,wishTabWidth,tabStyleTopButt,plateThickness);
}

module top()
{
    translate([plateThickness,plateThickness])
        square([boxWidth-plateThickness*2,boxDepth-plateThickness*2]);  
    
    tabStyleSide = 2;
    tabStyleTopButt = 2;
    tab(boxWidth,wishTabWidth,tabStyleTopButt,plateThickness);
    translate([plateThickness*2,0])rotate([0,0,90])tab(boxDepth,wishTabWidth,tabStyleSide,plateThickness);
    translate([boxWidth,0])rotate([0,0,90])tab(boxDepth,wishTabWidth,tabStyleSide,plateThickness);
    translate([0,boxDepth-plateThickness*2])tab(boxWidth,wishTabWidth,tabStyleTopButt,plateThickness); 
}


translate([0,boxHeight])top();
translate([0,-boxDepth])top();
translate([boxWidth,0])side();
translate([-boxDepth,0])side();
backFront();
translate([boxWidth+boxDepth,0])backFront();


/*
color([1,0,0])linear_extrude(height=plateThickness)top();
color([0,1,0])translate([-plateThickness,0,plateThickness])rotate([90,0,90])linear_extrude(height=plateThickness)side();
color([0,0,1])translate([0,0,plateThickness])rotate([90,0,0])linear_extrude(height=plateThickness)backFront();
color([1,0,0])translate([0,0,boxHeight+plateThickness])linear_extrude(height=plateThickness)top();
color([0,1,0])translate([boxWidth,0,plateThickness])rotate([90,0,90])linear_extrude(height=plateThickness)side();
color([0,0,1])translate([0,boxDepth+plateThickness,plateThickness])rotate([90,0,0])linear_extrude(height=plateThickness)backFront();
*/

/*
color([1,0,0])linear_extrude(height=plateThickness)top();
color([0,1,0])translate([0,0,0])rotate([90,0,90])linear_extrude(height=plateThickness)side();
color([0,0,1])translate([0,plateThickness,0])rotate([90,0,0])linear_extrude(height=plateThickness)backFront();
color([1,0,0])translate([0,0,boxHeight-plateThickness])linear_extrude(height=plateThickness)top();
color([0,1,0])translate([boxWidth-plateThickness,0,0])rotate([90,0,90])linear_extrude(height=plateThickness)side();
color([0,0,1])translate([0,boxDepth,0])rotate([90,0,0])linear_extrude(height=plateThickness)backFront();
*/



module tab(lenght, wishTabLenght, start, tabDepth)
{
    tabDepthExtra = tabDepth;
    
    wishNum = lenght / wishTabLenght;
    tabNum = floor(0.5*(wishNum-1));
    tabLenght = lenght / (2*tabNum+1);
    
    if (start == 0)
    {
        for (i=[0:tabNum-1])
        {
            translate([((1+2*i)*tabLenght),0])square([tabLenght,tabDepth+tabDepthExtra]);
        }
    }
    if (start == 1)
    {
        for (i=[0:tabNum])
        {
            translate([((2*i)*tabLenght),0])
            {
                if(i==0)
                {
                    translate([tabDepth,0])square([tabLenght-tabDepth,tabDepth+tabDepthExtra]);
                }
                else if(i==tabNum)
                {
                    square([tabLenght-tabDepth,tabDepth+tabDepthExtra]);
                }
                else
                {
                    square([tabLenght,tabDepth+tabDepthExtra]);    
                }
            }
        }
    
    }
    if (start == 2)
    {
        for (i=[0:tabNum])
        {
            translate([((2*i)*tabLenght),0])square([tabLenght,tabDepth+tabDepthExtra]);
        }
    
    }
}