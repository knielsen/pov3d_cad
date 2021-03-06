include <ledtorus2_hub.scad>

enable_pcb = true;
enable_supports = false;
enable_sides = false;
enable_mount_thingies = false;
enable_hub = true;

// Set an initial zoom that makes the whole thing visible.
$vpt = $vpd < 200 ? [-5, 15, 50] : $vpt;
$vpr = $vpd < 200 ? [83, 0, 114] : $vpr;
$vpd = $vpd < 200 ? 400 : $vpd;

// Fine subdivisions, for production run
$fa = 1; $fs = 0.1;
// Coarse, but faster, subdivisions, for testing.
//$fa = 8; $fs = 0.8;

// Height of the filled-in bottom part of the base, where radius increases
// with height.
base_thick = 8.0;
// Minimum thickness (in the cut-out part on the back).
base_min_thick = 4;
// Thickness of the bottom of the cut-out for the battery.
base_thick3 = 10;
// Height of the spindle mount. This value is the height above the filled-in
// part of the base (base_thick) at which the bottom of the PCB intersects the
// Z-axis (x=y=0).
axis_height = 40;    // Was 47
// The outer dimension of the mount.
axis_dia = 149;
// Diameter of mounting screws, including a bit of slack to account for
// 3D-printer tolerance.
skrue_dia = 3 + 0.35;
// Distance of mounting screw hole center from mount center.
skrue_dist = 54;
// The diameter of the bottom of the base.
base_lower_dia = 72;
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
sides_thick=1.5;
// Location of the mounting holes for the PCB.
mount_center_x = 35.5;
mount_center_y = 68;
// Distance from pcb center to top edge of pcb.
pcb_top_offset=74.5;
// Battery cutout dimensions.
bat_width = 31.2;
bat_length = 52;
bat_thick = 11;
// Thickness of the sides around the battery.
bat_holder_sides = 1.5;
// Position of velcro mount holes.
upper_velcro_center = bat_width/2 + 6.5;
lower_velcro_center = bat_width/2 + 6.5;
// Top of spindle_mount, from top of base.
cutoff_z = axis_height +
  (pcb_top_offset+(led_active_height+pcb_thick)*tan(pcb_angle))*sin(pcb_angle);
// Diameter of axle on rotor.
axle_dia = 8;
// For bolts mounting spindle_mount to hub on shaft.
mount_bolt_lower_dia = 10.5;
mount_bolt_lower_depth = 4.2;
// Standoff dimensions.
mount_thingy_length = 12.1;  // was 10.5;
mount_thingy_cyl_dia = 3.0;  // was 3.4;
mount_thingy_hex_height = 6.0; // was 6.6;
mount_thingy_hex_dia = 5.0;  // was 4.7;


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
  epsilon = 0.04;
  translate([0, 0, base_thick3]) {
    translate([0,0,(bat_thick+epsilon)/2])
      linear_extrude(height = bat_thick+epsilon, center = true) {
        polygon(points = [[-bat_x/2,-bat_y/2], [bat_x/2,-bat_y/2],
                          [bat_x/2,bat_y/2], [-bat_x/2,bat_y/2]]);
      }
  }
}


module base() {
  rad1 = base_lower_dia/2;
  rad2 = rad1;
  back_cutout_depth = base_thick - base_min_thick;
  back_cutout_dia1 = base_lower_dia;
  back_cutout_dia2 = axis_dia - 2*sides_thick;
  back_cutout_x = axis_dia/2;
  back_cutout_bat_extra = 2.1;
  back_cutout_epsilon = 0.01753;
  velcro_cutout_width = 22;
  velcro_cutout_length = 13;
  extra = 1.13;   // To avoid rendering glitches

  difference() {
    union() {
      /* Truncated cone for main base. */
      cylinder(h = base_thick, r1= rad1, r2 = rad2);
      /* Sides for holding the battery. */
      translate([0, 0, (base_thick3+bat_thick-0.03)/2]) {
        cube([bat_width+bat_holder_sides*2,bat_length+bat_holder_sides*2,
              base_thick3+bat_thick-0.03],
             center=true);
      }
      // Sides need to bulge out a bit where the mounting screws are placed.
      for (i = [0 : 5]) {
        rotate(i*360/6+90, [0,0,1]) {
          if ((i % 3) != 0) {
            translate([0, ledtorus2_hub_mounthole_dist, 0.001])
              cylinder(h = base_thick3 + bat_thick - 0.002, d=mount_bolt_lower_dia+2*bat_holder_sides, center=false);
          }
        }
      }
    }

    // Cutout for battery.
    battery(bat_width, bat_length, bat_thick);

    // Holes for fastening on the plane connected to the motor.
    for (i = [0 : 5]) {
      rotate(i*360/6+90, [0,0,1]) {
	translate([0, ledtorus2_hub_mounthole_dist, -0.1])
	  cylinder(h = max(base_thick, base_thick3)+0.2, d=ledtorus2_hub_mounthole_d);
        if (i == 7) {
          translate([0, ledtorus2_hub_mounthole_dist+2*back_cutout_epsilon, base_min_thick])
            cylinder(h = bat_thick+base_thick+0.3, d=mount_bolt_lower_dia, center=false);
        } else if (i == 0 || i == 3) {
          translate([0, ledtorus2_hub_mounthole_dist,
                     base_thick3+0.5*(bat_thick-mount_bolt_lower_depth+0.3)])
            cube([velcro_cutout_width, velcro_cutout_length,
                  bat_thick+mount_bolt_lower_depth+0.3], center=true);
        } else {
          translate([0, ledtorus2_hub_mounthole_dist, base_thick3-mount_bolt_lower_depth])
            cylinder(h = bat_thick+mount_bolt_lower_depth+0.3, d=mount_bolt_lower_dia, center=false);
        }
      }
    }
    // Hole for axle (for precise centering of mount on rotor).
    translate([0, 0, -extra])
      cylinder(h=max(base_thick, base_thick3)+2*extra, r=axle_dia/2, center=false);
  }
}


module pcb_holder() {
  thick = 2;
  mw1 = 39;
  mw2 = 25;
  mh1 = 72;
  mh2 = 35;
  mh3 = 20;
  led_coords() {
    translate([0, 0, -(mount_thingy_hex_height+thick)]) {
      linear_extrude(height=thick, center=false) {
        difference() {
          polygon(points =
                  [ [-mw1,mh1], [-mw2,mh1], [-mw2,mh2], [mw2,mh2], [mw2,mh1], [mw1,mh1],
                    [mw1,-mh1], [mw2,-mh1], [mw2,-mh2], [-mw2,-mh2], [-mw2,-mh1], [-mw1, -mh1]
                    ]);
          polygon(points =
                  [ [-mw2, -mh3], [-mw2, mh3], [mw2, mh3], [mw2, -mh3]
                    ]);
          }
        }
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
                         hex_base, hex_dia, hex_heigth,
                         col1, col2) {
  led_coords() {
    color(col1)
    translate([center_x, center_y, -cyl_base])
      cylinder(h = cyl_height, r=cyl_dia/2);
    color(col2)
    translate([center_x, center_y, -hex_base])
      hexagon(d=hex_dia, h=hex_heigth, center=false);
  }
}


module mount_thingy_int(center_x, center_y, extra) {
  // Depression into spindle_mount, to ensure PCB can go flat against base.
  mount_thingy_lower = 2.4;    // was 0.4;
  // Extra height to ensure proper difference()
  mount_thingy_above = mount_thingy_lower + 0.023;
  if (extra) {
    // Add the extra slack to the holes for the standoffs.
    cyl_height = mount_thingy_length + 0.6;
    cyl_dia = mount_thingy_cyl_dia + 2*0.2;
    hex_height = mount_thingy_hex_height + 0.6;
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
                      hex_base, hex_dia, hex_height, "red", "blue");
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
      cylinder(r=axis_dia/2, h=cutoff_z, center=false);
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
  support_width = sides_thick + 1.5;
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
            cube([axis_dia, axis_dia, 2*sides_thick], center=true);
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
  if (enable_supports) {
    highsupport();
    lowsupport();
  }

  pcb_holder();

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

  %if (enable_hub) {
    rotate([0, 0, 90])
      ledtorus2_hub();
  }
}


intersection() {
  spindle_mount();

  // Debug
  // Cut through the middle.
  //translate([-500, 0, 0]) cube([1000,1000,1000], center=false);

  // Test prints.

  //translate([0, 0, 1]) cube([100, 100, 2], center=true);
  // Detail for test for ledtorus 2 mount.
  //%translate([40, 50, 20])
  //  cube([80, 90, 60], center=true);
}
