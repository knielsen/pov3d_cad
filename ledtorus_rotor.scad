// Diameter of the main platter.
ledtorus_rotor1_dia = 125;
// Thickness of the main platter.
ledtorus_rotor1_thick = 5;
// Main diameter of the axle fitting, at the contact with the platter.
ledtorus_rotor2_dia = 30;
// Distance between platter and ball bearing.
ledtorus_rotor2_thick = 16;
// Diameter of grove for drive belt.
ledtorus_rotor3_dia = ledtorus_rotor2_dia-2*0.5;
// Width of the belt grove.
ledtorus_rotor3_thick = 10;
// Diameter of the part of the axle that goes into the ball bearing.
// (So identical to the inner ball bearing diameter).
ledtorus_rotor4_dia = 28;
// Length of the part of the axle fitting that goes into the ball bearing.
ledtorus_rotor4_thick = 9;
// Diameter of the hole inside the fitting for the axle.
ledtorus_axle_hole = 8;
// Total height of the fitting.
ledtorus_rotor_height = ledtorus_rotor1_thick+ledtorus_rotor2_thick+ledtorus_rotor4_thick;

// The origin is at the top center of the main platter.
// This way, the origin corresponds to the origin of the spindle_mount.
module ledtorus_rotor() {
  eps = 0.137;  // avoid rendering glitches.
  nongrove = 0.5*(ledtorus_rotor2_thick-ledtorus_rotor3_thick);
  difference() {
    union() {
      translate([0, 0, -ledtorus_rotor1_thick])
        cylinder(r=ledtorus_rotor1_dia/2, h=ledtorus_rotor1_thick, center=false);
      translate([0, 0, -(ledtorus_rotor1_thick+ledtorus_rotor2_thick)])
        cylinder(r=ledtorus_rotor3_dia/2, ledtorus_rotor2_thick, center=false);
      translate([0, 0, -(ledtorus_rotor1_thick+nongrove)])
        cylinder(r=ledtorus_rotor2_dia/2, nongrove, center=false);
      translate([0, 0, -(ledtorus_rotor1_thick+ledtorus_rotor2_thick)])
        cylinder(r=ledtorus_rotor2_dia/2, nongrove, center=false);
      translate([0, 0, -ledtorus_rotor_height])
        cylinder(r=ledtorus_rotor4_dia/2, h=ledtorus_rotor4_thick, center=false);
    }
    // Hole for the axle.
    translate([0, 0, -(ledtorus_rotor_height+eps)])
      cylinder(r=ledtorus_axle_hole/2, h=ledtorus_rotor_height+2*eps);
  }
}
