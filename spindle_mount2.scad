enable_krave = false;
enable_pcb = true;
enable_supports = true;
enable_sides = true;
enable_mount_thingies = false;

// Set an initial zoom that makes the whole thing visible.
$vpt = $vpd < 200 ? [-5, 15, 50] : $vpt;
$vpr = $vpd < 200 ? [83, 0, 114] : $vpr;
$vpd = $vpd < 200 ? 400 : $vpd;

// Fine subdivisions, for production run
$fa = 1; $fs = 0.1;
// Coarse, but faster, subdivisions, for testing.
//$fa = 8; $fs = 0.8;

// The outer radius of the motor spindle. Used when enable_krave is true,
// to put a "krave" around the spindle (but might be hard to print).
spindle_radius = 25;

// Height of the filled-in bottom part of the base, where radius increases
// with height.
base_thick = 30.5;
// Thickness of the bottom of the cutout in the base fill-in, which holds
// the screws mounting to the motor spindle.
base_thick2 = 2.5;
// Thickness of the bottom of the cut-out for the battery.
base_thick3 = 4;
// Thickness of the base at the edges around the battery cut-out.
base_thick4 = base_thick3 + 9.5;
// The diameter of the bottom of the base (which must fit within the space
// available originally for the hard-disk platters).
base_lower_dia = 88;   // Was 77.5 in spindle_mount_v2
// Cutouts for heads of screws mounting to motor spindle.
mount_screw_lowering = 1.2;
// Height of the spindle mount. This value is the height above the filled-in
// part of the base (base_thick) at which the bottom of the PCB intersects the
// Z-axis (x=y=0).
axis_height = 45.5;
// The outer dimension of the mount.
axis_dia = 149;
// Dimensions of the krave around the motor spindle.
krave_high = 7;
krave_thick = 2.5;
// Diameter of mounting screws, including a bit of slack to account for
// 3D-printer tolerance.
skrue_dia = 2 + 0.35;
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
mount_center_x = 35.5;
mount_center_y = 68;
// Distance from pcb center to top edge of pcb.
pcb_top_offset=74.5;
// Battery cutout dimensions.
bat_width = 31.2;
bat_length = 52;
bat_thick = 11;
// Position of velcro mount holes.
upper_velcro_center = bat_width/2 + 6.5;
lower_velcro_center = bat_width/2 + 5;
// Top of spindle_mount, from top of base.
cutoff_z = axis_height + pcb_top_offset*sin(pcb_angle);


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


module base() {
  rad1 = base_lower_dia/2;
  rad2 = axis_dia/2;
  base_wall_thick = 1.5;
  base_cutout_front = 19;
  base_cutout_back = 28;
  velcro_space_dist = 8;
  velcro_space_dia = 24;
  balance_weight_cutout_depth = 4;
  balance_weight_cutout_width = 58;
  balance_weight_cutout_start = 62;
  extra = 1.13;   // To avoid rendering glitches

  difference() {
    /* Truncated cone for main base. */
    cylinder(h = base_thick, r1= rad1, r2 = rad2);

    // Subtract material in the center and back, to reduce weight and get the
    // battery down to lower center-of-mass.
    intersection() {
      cylinder(h = base_thick+0.017, r1= rad1-base_wall_thick*2, r2 = rad2-base_wall_thick*2);
      translate([-(-base_cutout_front+axis_dia/2), 0, base_thick4+base_thick/2])
        cube([axis_dia, axis_dia, base_thick], center=true);
    }
    // Subtract even more material in the back, to further reduce weight and
    // try to compensate a bit for the higher mass of the back wall.
    intersection() {
      cylinder(h = base_thick+0.017, r1= rad1-base_wall_thick*2, r2 = rad2-base_wall_thick*2);
      translate([-(base_cutout_back+axis_dia/2), 0, base_thick3+base_thick/2])
        cube([axis_dia, axis_dia, base_thick], center=true);
    }
    // Subtract a bit at the front for extra balancing weights, with a hole for
    // a screw to hold the weights.
    translate([-(-balance_weight_cutout_start+axis_dia/4),
                0,
                base_thick-(balance_weight_cutout_depth-extra)/2]) {
      cube([axis_dia/2, balance_weight_cutout_width, balance_weight_cutout_depth+extra],
           center=true);
    }
    translate([38, 0, -extra])
      cylinder(h=base_thick+2*extra, r=1.5+0.2, center=false);
    // Subtract a cylinder to make room for screw holding Velcro.
    translate([-(-lower_velcro_center-velcro_space_dist+velcro_space_dia/2), 0, base_thick4]) {
      cylinder(r=velcro_space_dia/2, h=base_thick, center=false);
    }
    // Hole that fits the spindle on the hard disk motor.
    translate([0,0,-0.1])
      cylinder(h=base_thick+0.2, r = center_piece_rad);
    // Cutout in base around the spindle hole, with space for mounting screws.
    translate([0,0,base_thick2])
      cylinder(h=base_thick+0.2, r = center_piece_space);
    // Holes for 6 mounting screws.
    for (i = [0 : 5]) {
      rotate(i*360/6, [0,0,1]) {
	translate([skrue_dist, 0, -0.1])
	  cylinder(h = base_thick+0.2, r=skrue_dia/2);
	translate([skrue_dist, 0, base_thick2-mount_screw_lowering])
	  cylinder(h = base_thick+0.2, r=skrue_head/2);
      }
    }
    // Cutout for battery.
    battery(bat_width, bat_length, bat_thick);
    // Holes for screws holding the velkro strips.
    translate([lower_velcro_center, 0, -extra])
      cylinder(r=1.5+0.2, h=base_thick+2*extra, center=false);
    translate([-upper_velcro_center, 0, -extra])
      cylinder(r=1.5+0.2, h=base_thick+2*extra, center=false);
    // Holes for the mount thingies.
    mount_thingy_lower(true);
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

  %led_coords() {
    difference() {
      linear_extrude(height=thick, center=false)
        polygon(points =
          [ [45.3527264611497,-74.5], [47.9483854524943,-71.8712741696108],
            [50.4482661047597,-69.098983311901], [52.8473748313109,-66.1886651610672],
            [55.140919340459,-63.1461331649669], [57.3243182082077,-59.9774648725819],
            [59.3932100297855,-56.6889897939315], [61.3434621316825,-53.2872767566867],
            [63.1711788267896,-49.7791207847395], [64.8727091961508,-46.1715295249386],
            [66.4446543817829,-42.471709249105], [67.8838743759967,-38.6870504592872],
            [69.1874942936568,-34.8251131250118], [70.3529101148502,-30.8936115820173],
            [71.3777938864949,-26.9003991226372], [72.2600983724961,-22.8534523086127],
            [72.998061143161,-18.7608550376711], [73.5902080957058,-14.6307823956976],
            [74.03535639882,-10.4714843267558], [74.3326168554073,-6.29126915357693],
            [74.4813956787835,-2.09848698143567], [74.4813956787835,2.09848698143567],
            [74.3326168554073,6.29126915357694], [74.03535639882,10.4714843267558],
            [73.5902080957058,14.6307823956976], [72.998061143161,18.7608550376711],
            [72.2600983724961,22.8534523086127], [71.3777938864949,26.9003991226372],
            [70.3529101148502,30.8936115820173], [69.1874942936568,34.8251131250118],
            [67.8838743759967,38.6870504592872], [66.4446543817829,42.471709249105],
            [64.8727091961508,46.1715295249386], [63.1711788267896,49.7791207847395],
            [61.3434621316825,53.2872767566867], [59.3932100297855,56.6889897939315],
            [57.3243182082077,59.9774648725819], [55.140919340459,63.1461331649669],
            [52.8473748313109,66.1886651610672], [50.4482661047597,69.098983311901],
            [47.9483854524943,71.8712741696108], [45.3527264611497,74.5],
            [-45.3527264611497,74.5], [-47.9483854524943,71.8712741696108],
            [-50.4482661047598,69.098983311901], [-52.8473748313109,66.1886651610672],
            [-55.140919340459,63.1461331649669], [-57.3243182082077,59.9774648725819],
            [-59.3932100297855,56.6889897939315], [-61.3434621316825,53.2872767566867],
            [-63.1711788267896,49.7791207847395], [-64.8727091961508,46.1715295249386],
            [-66.4446543817829,42.471709249105], [-67.8838743759967,38.6870504592872],
            [-69.1874942936568,34.8251131250118], [-70.3529101148502,30.8936115820173],
            [-71.3777938864949,26.9003991226372], [-72.2600983724961,22.8534523086128],
            [-72.998061143161,18.7608550376711], [-73.5902080957058,14.6307823956976],
            [-74.03535639882,10.4714843267558], [-74.3326168554073,6.29126915357692],
            [-74.4813956787835,2.09848698143568], [-74.4813956787835,-2.09848698143566],
            [-74.3326168554073,-6.29126915357694], [-74.03535639882,-10.4714843267558],
            [-73.5902080957058,-14.6307823956976], [-72.998061143161,-18.7608550376711],
            [-72.2600983724961,-22.8534523086127], [-71.3777938864949,-26.9003991226372],
            [-70.3529101148502,-30.8936115820173], [-69.1874942936568,-34.8251131250118],
            [-67.8838743759967,-38.6870504592872], [-66.4446543817829,-42.471709249105],
            [-64.8727091961508,-46.1715295249386], [-63.1711788267896,-49.7791207847395],
            [-61.3434621316825,-53.2872767566867], [-59.3932100297855,-56.6889897939315],
            [-57.3243182082077,-59.9774648725819], [-55.140919340459,-63.146133164967],
            [-52.8473748313109,-66.1886651610672], [-50.4482661047597,-69.098983311901],
            [-47.9483854524943,-71.8712741696108], [-45.3527264611497,-74.5]
            ]);
      translate([-mount_center_x, -mount_center_y, -extra])
        cylinder(h = thick+2*extra, r = 3.6/2, center=false);
      translate([mount_center_x, -mount_center_y, -extra])
        cylinder(h = thick+2*extra, r = 3.6/2, center=false);
      translate([-mount_center_x, mount_center_y, -extra])
        cylinder(h = thick+2*extra, r = 3.6/2, center=false);
      translate([mount_center_x, mount_center_y, -extra])
        cylinder(h = thick+2*extra, r = 3.6/2, center=false);
    }
    translate([0, 0, thick])
      cylinder(h = led_active_height, r = 0.3, center = false);
  }
}


module hexagon(d, h, center=true) {
  cylinder(r=d/2*(2/sqrt(3)), h=h, center=center, $fn=6);
}


// The "mount thingies" are the brass motherboard standoffs used to mount the
// PCB to the spindle mount.
//
// When EXTRA is passed as true, extra slack is added around, as needed
// to be used in difference() to produce a hole suitable for inserting and
// gluing in the standoffs.

module mount_thingy_int2(center_x, center_y,
                        cyl_base, cyl_dia, cyl_height,
                        hex_base, hex_dia, hex_heigth) {
  led_coords() {
    translate([center_x, center_y, -cyl_base])
      cylinder(h = cyl_height, r=cyl_dia/2);
    translate([center_x, center_y, -hex_base])
      hexagon(d=hex_dia, h=hex_heigth, center=false);
  }
}


module mount_thingy_int(center_x, center_y, extra) {
  // Standoff dimensions.
  mount_thingy_length = 10.5;
  mount_thingy_cyl_dia = 3.4;
  mount_thingy_hex_height = 6.6;
  mount_thingy_hex_dia = 4.7;
  // Depression into spindle_mount, to ensure PCB can go flat against base.
  mount_thingy_lower = 0.4;
  // Extra height to ensure proper difference()
  mount_thingy_above = mount_thingy_lower + 0.023;
  if (extra) {
    // Add the extra slack to the holes for the standoffs.
    cyl_height = mount_thingy_length + 2.0;
    cyl_dia = mount_thingy_cyl_dia + 2*0.2;
    hex_height = mount_thingy_hex_height + 0.0;
    hex_dia = mount_thingy_hex_dia + 0.25;
    cyl_base = cyl_height + mount_thingy_lower;
    hex_base = hex_height + mount_thingy_lower;
    mount_thingy_int2(center_x, center_y, cyl_base, cyl_dia, cyl_height,
                      hex_base, hex_dia, hex_height + mount_thingy_above);
  } else {
    cyl_height = mount_thingy_length;
    cyl_dia = mount_thingy_cyl_dia;
    hex_height = mount_thingy_hex_height;
    hex_dia = mount_thingy_hex_dia;
    cyl_base = cyl_height + mount_thingy_lower;
    hex_base = hex_height + mount_thingy_lower;
    mount_thingy_int2(center_x, center_y, cyl_base, cyl_dia, cyl_height+0.23,
                      hex_base, hex_dia, hex_height);
  }
}


module mount_thingy_upper(extra) {
  mount_thingy_int(-mount_center_x, mount_center_y, extra);
  mount_thingy_int(mount_center_x, mount_center_y, extra);
}


module mount_thingy_lower(extra) {
  mount_thingy_int(-mount_center_x, -mount_center_y, extra);
  mount_thingy_int(mount_center_x, -mount_center_y, extra);
}


module spindle_mount_inner() {
  extra = 10;   // Extra to avoid rendering artifacts from co-planar polygons
  truncate_cube_height = axis_height*2 + base_thick + extra;
  truncate_cube_width=axis_dia + extra;
  // A an easy, conservative value that is large enough.
  slant_cube_height = axis_height + axis_dia/2 + extra;
  slant_cube_width = axis_dia + extra;
  slant_cube_length = axis_dia/cos(pcb_angle) + extra;

  sides_coords() {
    intersection() {
      cylinder(r=axis_dia/2, h=2*pcb_top_offset*sin(pcb_angle), center=false);
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
  support_extent = pcb_top_offset*cos(pcb_angle);
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
        }
        translate([0, 0, axis_height])
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
    mount_thingy_upper(true);
  }
  pcb_support();
}


module highsupport() {
  thick = axis_dia/2;
  width = 10;
  support_height = 2*axis_height;
  intersection() {
    difference() {
      union() {
        led_coords() {
          translate([-mount_center_x, mount_center_y + thick/2 - width/2, -support_height/2])
            cube([width, thick, support_height], center=true);
          translate([mount_center_x, mount_center_y + thick/2 - width/2, -support_height/2])
            cube([width, thick, support_height], center=true);
        }
        sides_coords() {
          translate([0, 0, cutoff_z])
            cube([axis_dia, axis_dia, 2*1], center=true);
        }
      }
      mount_thingy_upper(true);
    }
    spindle_mount_inner();
  }
}


module lowsupport() {
  thick = axis_dia/2;
  width = 13.5;
  breadth = 10;
  height = axis_height;
  intersection() {
    difference() {
      led_coords() {
        translate([-mount_center_x, -mount_center_y - thick/2 + width/2, -height/2])
          cube([breadth, thick, height], center=true);
        translate([mount_center_x, -mount_center_y - thick/2 + width/2, -height/2])
          cube([breadth, thick, height], center=true);
      }
      mount_thingy_lower(true);
    }
    spindle_mount_inner();
  }
}


module spindle_mount() {
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

  base();

  if (enable_sides) {
    sides();
  }

  if (enable_mount_thingies) {
    mount_thingy_lower(false);
    mount_thingy_upper(false);
  }
}


intersection() {
  spindle_mount();

  // Test prints.
  // Bottom mounting holes for harddisk spindle.
  //cube([35, 35, 40], center=true);
  // Upper support:
  //translate([-60,-15,38+axis_height/2]) cube([40,30,40]);
  // Lower support:
  //translate([15,-15,-40+axis_height/2]) cube([40,30,60]);

  // Detail for test for ledtorus 2 mount.
  //%translate([40, 50, 20])
  //  cube([80, 90, 60], center=true);
}
