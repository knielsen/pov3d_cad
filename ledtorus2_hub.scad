// Hub to mount spindle_mount2 to shaft for LED-torus 2.
// The origin is at the center top - the top surface of the hub and the
// buttom surface of the spindle_mount.

ledtorus2_hub_height = 26.4;
ledtorus2_hub_thick = 6;
ledtorus2_hub_d1 = 24;
ledtorus2_hub_d2 = 56.8;
ledtorus2_hub_bore_d = 8;
ledtorus2_hub_mounthole_dist = 47.5/2;
ledtorus2_hub_mounthole_d = 5.2;
ledtorus2_hub_setscrew_d = 6;
ledtorus2_hub_setscrew_pos = -ledtorus2_hub_height+10.2;

module ledtorus2_hub() {
  eps = 0.01;
  difference() {
    union() {
      translate([0, 0, -ledtorus2_hub_height])
        cylinder(h=ledtorus2_hub_height-eps, d=ledtorus2_hub_d1, center=false);
      translate([0, 0, -ledtorus2_hub_thick])
        cylinder(h=ledtorus2_hub_thick, d=ledtorus2_hub_d2, center=false);
    }
    translate([0, 0, -(ledtorus2_hub_height+eps)])
      cylinder(h=ledtorus2_hub_height+2*eps, d=ledtorus2_hub_bore_d, center=false);
    rotate([0, -90, 0])
      translate([ledtorus2_hub_setscrew_pos, 0, 0])
      cylinder(h=ledtorus2_hub_d1/2+eps, d=ledtorus2_hub_setscrew_d, center=false);
    for (i = [0:5]) {
      rotate([0, 0, i*360/6])
        translate([0, ledtorus2_hub_mounthole_dist, -(ledtorus2_hub_thick+eps)])
        cylinder(h=ledtorus2_hub_thick+2*eps, d=ledtorus2_hub_mounthole_d, center=false);
    }
  }
}
