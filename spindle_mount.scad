difference() {
  cylinder(h = 2.5, r = 40);
  translate([0,0,-10])
    cylinder(h=20, r = 5.5, $fn = 60);
  for (i = [0 : 5]) {
    rotate(i*360/6, [0,0,1])
      translate([18.5/2, 0, 0])
        cylinder(h = 2.7, r=1, $fn = 20);
  }
}

translate([0,0,-8]) {
  difference() {
    cylinder(h = 8, r = 25/2+2.5);
    cylinder(h = 8, r = 25/2, $fn = 60);
  }
}
