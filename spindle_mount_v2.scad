enable_krave = false;
enable_pcb = true;
enable_supports = true;
enable_sides = true;
enable_mount_thingies = true;

// Fine subdivisions, for production run
$fa = 1; $fs = 0.1;
// Coarse, but faster, subdivisions, for testing.
//$fa = 8; $fs = 0.8;

// The outer radius of the motor spindle. Used when enable_krave is true,
// to put a "krave" around the spindle (but might be hard to print).
spindle_radius = 25;

// Height of the filled-in bottom part of the base, where radius increases
// with height.
base_thick = 15;
// Thickness of the bottom of the cutout in the base fill-in, which holds
// the screws mounting to the motor spindle.
base_thick2 = 2.5;
// Thickness of the bottom of the cut-out for the battery.
base_thick3 = base_thick2 + 3;
// Cutouts for heads of screws mounting to motor spindle.
mount_screw_lowering = 1.2;
// Height of the spindle mount. This value is the height above the filled-in
// part of the base (base_thick) at which the bottom of the PCB intersects the
// Z-axis (x=y=0).
axis_height = 30.5;
// The outer dimension of the mount.
axis_dia = 100;
// Dimensions of the krave around the motor spindle.
krave_high = 7;
krave_thick = 2.5;
// Diameter of mounting screws, including a bit of slack to account for
// 3D-printer tolerance.
skrue_dia = 2 + 0.2;
// Diameter of mounting screw heads, including a bit of slack for easier fit.
skrue_head = 3.9 + 0.6;
// Distance of mounting screw hole center from motor spindle center.
skrue_dist = 10.15;
// Radius of the hole in the base to fit on top of the center disk of the
// motor spindle, plus a bit of slack to account for 3D printing tolerances.
center_piece_rad = 14.5/2+0.3;
// Radius of the cutout in the base fill-in to provide access to mounting
// screws.
center_piece_space = skrue_dist + skrue_dia + 2;
// Angle of the PCB with horizontal - this is an intrinsic property of the PCB
// layout.
pcb_angle=37.5;
// Manufactured thickness of the PCB.
pcb_thick = 0.8;
// Estimate of the height from the PCB at which the active light-emitting
// substrate of the LEDs sit. This is used to adjust the PCB location so that
// the light-emitting locations become centered correctly around the spin-axis
led_active_height = 0.2;
// Thickness of the walls of the mount.
sides_thick=1.0;
// Location of the mounting holes for the PCB.
mount_center_upper=35.35;
mount_center_lower=-43.65;
// Distance from pcb center to top edge of pcb.
pcb_top_offset=40.5;
// Battery cutout dimensions.
bat_width = 32;
bat_length = 52;
bat_thick = 11;


// Switch to coordinates used to model the side of the spindle_mount.
// These coordinates are centered at the top of the base, with the x-axis
// pointing towards the right (LED-side of the PCB), and Z upwards.
module sides_coords() {
  translate([0,0,base_thick])
    rotate([0,0,90])
      children();
}


// Switch to coordinates for stuff that needs to be positioned relative to the
// LEDs.
//
// The coordinates are rotated to be in the plane of the back side of the PCB,
// with X pointing to the right, towards the LED side, and Z upwards through
// the top surface of the PCB.
//
// The origin coincides with the center of the PCB's back side, and is shifted
// so that the active spots of the LEDs (led_active_height above the PCB's
// surface) sweep out cylinders centered of the axis of rotation of the
// spindle_mount.
module led_coords() {
  translate([0,0,base_thick+axis_height])
    rotate([0, pcb_angle, 0])
    rotate([0, 0, 90])
    translate([0, (pcb_thick+led_active_height)*tan(pcb_angle), 0]) {
    children();
    }
}


// Just a debugging aid, draw the coordinate axis to visualise the coordinate
// transformation in use at a given place in the code.
module coords_debug_axis() {
  #union() {
    cube([200, 0.1, 0.1], center=true);
    cube([0.1, 200, 0.1], center=true);
    cube([0.1, 0.1, 200], center=true);
  }
}


module battery(bat_x, bat_y, bat_thick) {
  translate([0, 0, base_thick3]) {
    translate([0,0,bat_thick/2])
      linear_extrude(height = bat_thick, center = true) {
        polygon(points = [[-bat_x/2,-bat_y/2], [bat_x/2,-bat_y/2],
                          [bat_x/2,bat_y/2], [-bat_x/2,bat_y/2]]);
      }
  }
}


module base(thick, thick2, rad) {
  difference() {
    cylinder(h = thick, r1= rad-0.75*thick, r2 = rad);
    translate([0,0,-0.1])
      cylinder(h=thick+0.2, r = center_piece_rad);
    translate([0,0,thick2])
      cylinder(h=thick+0.2, r = center_piece_space);
    for (i = [0 : 5]) {
      rotate(i*360/6, [0,0,1]) {
	translate([skrue_dist, 0, -0.1])
	  cylinder(h = thick+0.2, r=skrue_dia/2);
	translate([skrue_dist, 0, thick2-mount_screw_lowering])
	  cylinder(h = thick+0.2, r=skrue_head/2);
      }
    }
    battery(bat_width, bat_length, bat_thick);
  }
}


module krave(h, thick) {
  extra = 0.1754;   // To avoid rendering glitches
  translate([0,0,-h]) {
    difference() {
      cylinder(h = h, r = spindle_radius/2+thick);
      translate([0, 0, -extra])
        cylinder(h = h+2*extra, r = spindle_radius/2);
    }
  }
}


module pcb(thick) {
  extra = 0.3;    // To prevent rendering glitches

  led_coords() {
    difference() {
      linear_extrude(height=thick, center=false)
        polygon(points = [[49,5.5], [48,16], [45,25], [33.5,34.5],
                          [8,34.5], [5,40.5], [-5,40.5], [-8,34.5],
                          [-33.5,34.5], [-45,25], [-48,16], [-49,5.5],
                          [-49,-5.5], [-48,-16], [-45,-25], [-33.5,-34.5],
                          [-12.5,-34.5], [-5,-49.5], [5,-49.5], [12.5,-34.5],
                          [33.5,-34.5], [45,-25], [48,-16], [49,-5.5]]);
      translate([0, mount_center_upper, -extra])
        cylinder(h = thick+2*extra, r = 3.6/2, center=false);
      translate([0, mount_center_lower, -extra])
        cylinder(h = thick+2*extra, r = 3.6/2, center=false);
    }
    translate([0, 0, thick])
      cylinder(h = led_active_height, r = 0.3, center = false);
  }
}


module hexagon(d, h, center=true) {
  cylinder(r=d/2*(2/sqrt(3)), h=h, center=center, $fn=6);
}


module mount_thingies() {
  translate([0, 37, -pcb_thick-11])
    cylinder(h = 11+0.2, r=3.3/2+0.45);
  translate([0, -37-5, -pcb_thick-11])
    cylinder(h = 11+0.2, r=3.3/2+0.45);
  translate([0, 37, -0.8-6+0.1])
    hexagon(d=5.1+0.1, h=6, center=false);
  translate([0, -37-5, -0.8-6+0.1])
    hexagon(d=5.1+0.1, h=6, center=false);
}


module spindle_mount_inner() {
  cutoff_z = axis_height + pcb_top_offset*sin(pcb_angle);
  extra = 10;   // Extra to avoid rendering artifacts from co-planar polygons
  truncate_cube_height = axis_height*2 + base_thick + extra;
  truncate_cube_width=axis_dia + extra;
  // A an easy, conservative value that is large enough.
  slant_cube_height = axis_height + axis_dia/2 + extra;
  slant_cube_width = axis_dia + extra;
  slant_cube_length = axis_dia/cos(pcb_angle) + extra;

  sides_coords() {
    intersection() {
      cylinder(r=axis_dia/2, h=axis_height*2, center=false);
      translate([0, 0, axis_height]) {
	rotate([pcb_angle, 0, 0]) {
	  translate([0, 0, -slant_cube_height/2]) {
	    cube([slant_cube_width, slant_cube_length, slant_cube_height], center=true);
          }
        }
      }
      translate([0, 0, cutoff_z - truncate_cube_height/2])
      	cube([truncate_cube_width, truncate_cube_width, truncate_cube_height], center=true);
    }
  }
}


module sides_restrict() {
  nut_thick=1.5;
  nut_wide=6;

  difference() {
    spindle_mount_inner();
    sides_coords() {
      translate([0, 0, axis_height ]) {
	rotate([pcb_angle, 0, 0]) {
	  translate([0, 37, -pcb_thick-12])
	    cylinder(h = 24, r=3/2);
	  translate([0, -37-5, -pcb_thick-12])
	    cylinder(h = 24, r=3/2);
          mount_thingies();
	}
      }
    }
  }
}


// Supports for the PCB at the left and right sides. A narrow shelf that
// extends inwards from the sides, supporting the left and right edges of the
// PCB. A small hole is made to make room for the hall sensor.
module pcb_support() {
  // Width of the support, from outside of mount towards center.
  support_width = 2.5;
  // angle of support as it curves inwards from the sides. Smaller angles
  // should be easier to 3D-print cleanly.
  support_angle = 20;
  // How far, in the X direction, the support exists (from center outwards).
  support_extent = 20;
  support_height = support_width / tan(support_angle);
  extra = 0.0571;   // To avoid rendering gliches

  sides_coords() {
    translate([0, 0, axis_height]) {
      intersection() {
        difference() {
          // Do a shear transformation in Z corresponding to a rotation of angle
          // pcb_angle.
          multmatrix([[1, 0, 0, 0],
                      [0, 1, 0, 0],
                      [0, tan(pcb_angle), 1, 0],
                      [0, 0, 0, 1]]) {
            translate([0, 0, - support_height]) {
              difference() {
                cylinder(r=axis_dia/2, h=support_height, center=false);
                translate([0, 0, -extra])
                  cylinder(r1=axis_dia/2, r2=axis_dia/2-support_width,
                           h=support_height+2*extra, center=false);
              }
            }
          }
          // Cutout to make room for hall sensor.
          translate([-40, -21, 0]) cube([20, 20, axis_dia*4], center=true);
        }
        cube([axis_dia+extra, 2*support_extent, 4*axis_height], center=true);
      }
    }
  }
}

module sides() {
  extra = 10;  // Extra height to avoid artifacts from co-planer polygons
  difference() {
    spindle_mount_inner();
    sides_coords()
      translate([0, 0, -extra])
        cylinder(r=axis_dia/2-sides_thick, h=axis_height*2+2*extra, center=false);
  }
  pcb_support();
}


module highsupport() {
  thick=100;
  width=10;
  support_height = 2*axis_height;
  extra_bit = 1;
  magic_slope = 0.45;
  intersection() {
    sides_coords()
      multmatrix([[1, 0, 0, 0],
                  [0, 1, -magic_slope, 0],
                  [0, 0, 1, 0],
                  [0, 0, 0, 1]])
      translate([0, (axis_dia/2-sides_thick-extra_bit), 0])
      translate([0, thick/2, support_height/2])
        cube([width, thick, support_height], center=true);
    sides_restrict();
  }
}


module lowsupport() {
  thick=23;
  width=10;
  intersection() {
    translate([axis_dia/2-thick/2, 0, axis_height/2])
      cube([thick, width, axis_height], center=true);
    sides_restrict();
  }
}


module spindle_mount() {
  extra = 1.13;   // To avoid rendering glitches

  if (enable_krave) {
    krave (krave_high, krave_thick);
  }

  if (enable_supports) {
    highsupport();
    lowsupport();
  }

  if (enable_pcb) {
    pcb(pcb_thick);
  }

  difference() {
    base(base_thick, base_thick2, axis_dia/2);
    // Holes for screws holding the velkro strips.
    translate([bat_width/2+5, 0, -extra])
      cylinder(r=1.5+0.2, h=base_thick+2*extra, center=false);
    translate([-(bat_width/2+6.5), 0, -extra])
      cylinder(r=1.5+0.2, h=base_thick+2*extra, center=false);
  }

  if (enable_sides) {
    sides();
  }

  if (enable_mount_thingies) {
    sides_coords() {
      translate([0, 0, axis_height]) {
	rotate([pcb_angle, 0, 0]) {
	  mount_thingies();
	}
      }
    }
  }
}


intersection() {
  spindle_mount();
  // Test prints:
  //translate([19,-15,-40+axis_height/2]) cube([40,30,40]);
  //translate([-60,-15,10+axis_height/2]) cube([40,30,40]);
}
