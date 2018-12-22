enable_krave = false;
enable_supports = true;
enable_sides = true;
with_colour = false;

// Options for turning various auxillary parts on or off.
//
// 0 means diabled; 1 means enabled (in transparance).
// 2 means omit all other parts, for exporting specific parts as STL
// separately.
enable_pcb = 1;
enable_weights = 1;
enable_weight_fasteners = 1;
enable_mount_thingies = 1;


spindle_radius = 25;
squash = 0.9;

base_thick = 2.5;
base_thick2 = 2.5;
base_radius = 40;
axis_height = 69;
axis_dia = 80;
lowsupport_thick = 8;
lowsupport_width = 10;
krave_high = 8;
krave_thick = 2.5;
skrue_dia = 2;
skrue_head_dia = 4;
skrue_dist = .5*20.35;
center_piece_rad = .5*14.5+0.125;
pcb_angle=37.5;
pcb_thick = 0.8;
bat_wide = 30.7;
bat_long = 52;
bat_thick = 11;
bat_edge_height = 10.0;
bat_edge_thick = 1.2;
// Raise the bottom of battery cutout to make room for motor spindle.
bat_raise = 2;
// Estimate of the height from the PCB at which the active light-emitting
// substrate of the LEDs sit. This is used to adjust the PCB location so that
// the light-emitting locations become centered correctly around the spin-axis
led_active_height = 0.2;
sides_thick=1.0;

backweight_screw_x = -27;
frontweight_screw_x = 21.5;
// Thickness of counter-weights.
weight_plate_thick = 2;
backweight_count = 3;
frontweight_count = 4;
backweight_thick = backweight_count*weight_plate_thick;
frontweight_thick = frontweight_count*weight_plate_thick;

led_thick=0.25;
led_protude=0.62;
led_dot_offset=led_thick+led_protude*0.2;

mount_hole_top_pos = 100-64.65;
mount_hole_bot_pos = 43.65;

mount_thingy_length = 12.1;
mount_thingy_cyl_dia = 3.0;
mount_thingy_hex_height = 6.0;
mount_thingy_hex_dia = 5.0;
// Let top of hex standoffs sit a bit below the PCB surface to ensure a tight fit.
mount_thingy_lower = 2.25 - 1.0;

hole_tolerance1 = 0.05;
hole_tolerance2 = 0.1;
hole_tolerance3 = 0.4;
// Fine subdivisions, for production run
//$fa = 1; $fs = 0.1;
// Coarse, but faster, subdivisions, for testing.
$fa = 2; $fs = 0.3;

module my_colour(col) {
  if (with_colour) {
    color(col)
      children();
  } else {
    children();
  }
}


module cond_part(condition) {
  if (condition == 1) {
    %children();
  } else if (condition == 2) {
    !children();
  }
}


// Hex nut in x-y plane, origin at bottom center. The outer width is the
// distance between two parallel sides.
module generic_hex_nut(thick, outer_width, inner_dia) {
  eps=0.00972;
  difference() {
    cylinder(h=thick, d=outer_width/cos(30), center=false, $fn=6);
    translate([0, 0, -eps]) cylinder(h=thick+2*eps, d=inner_dia, center=false);
  }
}


// Screw along z-axis, origin on center axis at the transition from head to
// main, tip of screw on positive end of z.
module generic_screw(main_length, main_dia, head_thick, head_dia) {
  eps=0.01172;
  translate([0, 0, -eps]) cylinder(h=main_length+eps, d=main_dia+eps, center=false);
  translate([0, 0, -head_thick]) cylinder(h=head_thick, d=head_dia, center=false);
}


module m3_screw() {
  generic_screw(main_length=6, main_dia=3, head_thick=2, head_dia=5.8);
}


module m4_hex_nut() {
  generic_hex_nut(thick=3.1, outer_width=6.85, inner_dia=4.0);
}


module m4_screw_20mm() {
  generic_screw(main_length=20, main_dia=4, head_thick=2.5, head_dia=7);
}


module battery(bat_x, bat_y, bat_thick) {
  eps = 0.003152;
  eps2 = 0.001;
  translate([0, 0, base_thick+bat_raise]) {
    my_colour("cyan")
    translate([0,0,(bat_thick+eps)/2])
      linear_extrude(height = bat_thick+eps+eps2, center = true) {
        polygon(points = [[-bat_x/2,-bat_y/2], [bat_x/2,-bat_y/2],
                          [bat_x/2,bat_y/2], [-bat_x/2,bat_y/2]]);
      }
  }
}


module spindle_mount_subtract(thick) {
  thick2 = thick + bat_raise;
  translate([0,0,-0.1])
    cylinder(h=thick2+0.2, r = center_piece_rad);
  for (i = [0 : 5]) {
    rotate(i*360/6, [0,0,1]) {
      translate([skrue_dist, 0, -0.1])
        cylinder(h = thick2+0.2, d=skrue_dia+hole_tolerance2);
      translate([skrue_dist, 0, thick-1.2])
        cylinder(h = thick2+0.2, d=skrue_head_dia+hole_tolerance3);
    }
  }
}


module weight_fastener_holes() {
  translate([frontweight_screw_x, 0, 0])
    cylinder(r=.5*4+0.1, h=100, center=true);
  translate([backweight_screw_x, 0, 0])
    cylinder(r=.5*4+0.1, h=100, center=true);
}


module weight_fasteners() {
  translate([backweight_screw_x, 0, 0]) {
    translate([0, 0, -backweight_thick])
      m4_screw_20mm();
    translate([0, 0, base_thick])
      m4_hex_nut();
  }
  translate([frontweight_screw_x, 0, 0]) {
    translate([0, 0, base_thick + base_thick2 + frontweight_thick])
      rotate([180, 0, 0])
      m4_screw_20mm();
    rotate([180, 0, 0])
      m4_hex_nut();
  }
}


module base(thick, rad) {
  difference() {
    scale([squash,1,1])
      cylinder(h = thick, r1= rad-0.75*thick, r2 = rad);
    spindle_mount_subtract(thick);
  }
}


module krave(h, thick) {
  translate([0,0,-h]) {
    difference() {
      cylinder(h = h, r = spindle_radius/2+thick);
      cylinder(h = h, r = spindle_radius/2);
    }
  }
}


module pcb(thick) {
  my_colour("DarkSlateGray", 0.3) {
    sides_transform() led_coords() {
      translate([0, 0, .5*thick]) {
	linear_extrude(height=thick, center=true)
	  polygon(points = [[49,5.5], [48,16], [45,25], [33.5,34.5],
			    [9,34.5], [5,34.5+8], [-5,34.5+8], [-9,34.5],
			    [-33.5,34.5], [-45,25], [-48,16], [-49,5.5],
			    [-49,-5.5], [-48,-16], [-45,-25], [-33.5,-34.5],
			    [-12.5,-34.5], [-5,-49.5], [5,-49.5], [12.5,-34.5],
			    [33.5,-34.5], [45,-25], [48,-16], [49,-5.5]]);
      }
    }
  }
}


module sides_transform() {
  translate([0,0,base_thick])
    rotate([0,0,90])
      children();
}


// Switch to coordinates for stuff that needs to be positioned relative to the
// LEDs. Should be used inside a sides_transform().
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
  translate([0, 0, .5*axis_height])
    rotate([pcb_angle, 0, 0])
    translate([0, (pcb_thick+led_active_height)*tan(pcb_angle), 0]) {
    children();
    }
}


module hexagon(d, h, center=true) {
  cylinder(r=d/2*(2/sqrt(3)), h=h, center=center, $fn=6);
}


module mount_thingies_subtract() {
  eps = 0.0013;
  bot_pos = mount_thingy_length + mount_thingy_lower + 0.6;

  my_colour("yellow") {
    translate([0, mount_hole_top_pos, -bot_pos])
      cylinder(h = bot_pos+0.2, d=mount_thingy_cyl_dia+0.2);
    translate([0, -mount_hole_bot_pos, -bot_pos])
      cylinder(h = bot_pos+0.2, d=mount_thingy_cyl_dia+0.2);
  }
  my_colour("blue") {
    translate([0, mount_hole_top_pos, -(mount_thingy_lower+mount_thingy_hex_height)])
      hexagon(d=mount_thingy_hex_dia+hole_tolerance1,
              h=mount_thingy_lower+mount_thingy_hex_height+eps,
              center=false);
    translate([0, -mount_hole_bot_pos, -(mount_thingy_lower+mount_thingy_hex_height)])
      hexagon(d=mount_thingy_hex_dia+hole_tolerance1,
              h=mount_thingy_lower+mount_thingy_hex_height+eps,
              center=false);
  }
}


module mount_thingies(center_y) {
  cyl_base = mount_thingy_length + mount_thingy_lower;
  hex_base = mount_thingy_hex_height + mount_thingy_lower;

  translate([0, center_y, -cyl_base])
    cylinder(h = mount_thingy_length, r=mount_thingy_cyl_dia/2);
  translate([0, center_y, -hex_base])
    hexagon(d=mount_thingy_hex_dia, h=mount_thingy_hex_height, center=false);
  translate([0, center_y, pcb_thick])
    rotate([180, 0, 0])
    m3_screw();
}


module sides_restrict() {
  nut_thick=1.5;
  nut_wide=6;

  sides_transform() {
    difference() {
      intersection() {
        scale([1,squash,1])
          cylinder(r=axis_dia/2, h=axis_height, center=false);
        led_coords() {
          translate([0, 0, -.5*axis_dia]) {
            cube([1.2*axis_dia, 1.2*axis_dia/tan(pcb_angle), axis_dia], center=true);
          }
        }
      }
      led_coords() {
        mount_thingies_subtract();
        // Cutout for voltage regulator on PCB.
        translate([-.5*axis_dia*cos(atan2(20.5,33)), .5*axis_dia*sin(atan2(20.5,33)), 0])
          cylinder(d=17, h=2*2.7, center=true);
      }
    }
  }
}


module sides() {
  eps = 0.00108;
  difference() {
    my_colour("Crimson", 0.7) {
      difference() {
	sides_restrict();
	sides_transform() {
	  scale([1, (squash*(axis_dia/2)-sides_thick)/((axis_dia/2)-sides_thick), 1])
            translate([0, 0, -eps])
            cylinder(r=axis_dia/2-sides_thick, h=axis_height*2+2*eps, center=false);
        }
      }
      intersection() {
	sides_restrict();
	sides_transform()
	  translate([0,-20,base_thick2/2])
	    cube([axis_dia, axis_dia, base_thick2], center=true);
      }
      translate([0, 0, eps+base_thick+0.5*bat_edge_height])
        cube([bat_wide+2*bat_edge_thick,
              bat_long+2*bat_edge_thick,
              bat_edge_height], center=true);
    }
    battery(bat_wide, bat_long, bat_thick);
    spindle_mount_subtract(base_thick);
  }
}


module highsupport() {
  thick=11.2;
  width=8.2;
  extra=20;
  intersection() {
    sides_transform() led_coords() {
      translate([0, 37+.5*extra, 0])
      cube([width, thick+extra, 100], center=true);
    }
    sides_restrict();
  }
}


module lowsupport() {
  intersection() {
    translate([axis_dia*squash/2-lowsupport_thick/2, 0, axis_height/2])
      cube([lowsupport_thick, lowsupport_width, axis_height], center=true);
    sides_restrict();
  }
}


module backweigth() {
  wide = 18;
  long = 53;

  intersection() {
    translate([-(squash*(base_radius-.75*base_thick)-.5*wide), 0, -.5*backweight_thick])
      cube([wide, long, backweight_thick], center=true);
    scale([squash, 1, 1])
      cylinder(r=base_radius-.75*base_thick, h=4*axis_height, center=true);
  }
}


module frontweigth() {
  wide = axis_dia;
  long = 150;
  dist = 0.3;
  pcb_clear = 22;

  intersection() {
    difference() {
      translate([.5*bat_wide+bat_edge_thick+dist+.5*wide, 0,
                 base_thick+base_thick2+.5*frontweight_thick])
        cube([wide, long, frontweight_thick], center=true);
      translate([axis_dia*squash/2-lowsupport_thick/2, 0, axis_height/2])
        cube([lowsupport_thick+2*dist, pcb_clear, axis_height], center=true);
    }
    scale([squash, 1, 1])
      cylinder(r=.5*axis_dia-sides_thick-dist, h=4*axis_height, center=true);
  }
}


module spindle_mount() {
  if (enable_krave) {
    krave (krave_high, krave_thick);
  }

  if (enable_supports) {
    my_colour("darkgreen") {
      highsupport();
      lowsupport();
    }
  }

  difference() {
    union() {
      base(base_thick, base_radius);
      if (enable_sides)
	sides();
    }
    weight_fastener_holes();
    sides_transform() {
      led_coords() {
        mount_thingies_subtract();
      }
    }
  }
}


intersection() {
  union() {
    translate([0,0,-axis_height/2]) {
      spindle_mount();
    }

    cond_part(enable_pcb) {
      translate([0,0,-axis_height/2]) {
        pcb(pcb_thick);
      }
    }

    cond_part(enable_weights) {
      translate([0,0,-axis_height/2]) {
        difference() {
          union() {
            backweigth();
            frontweigth();
          }
          weight_fastener_holes();
        }
      }
    }

    cond_part(enable_weight_fasteners) {
      translate([0,0,-axis_height/2]) {
        weight_fasteners();
      }
    }

    cond_part(enable_mount_thingies) {
      translate([0,0,-axis_height/2]) {
        sides_transform() {
          led_coords() {
            mount_thingies(mount_hole_top_pos);
            mount_thingies(-mount_hole_bot_pos);
          }
        }
      }
    }
  }

  //translate([-500,0,-500])cube([1000,1000,1000], center=false);
  // Test prints:
  //translate([19,-15,-40]) cube([40,30,40]);
  //translate([-60,-15,10]) cube([40,30,40]);
  //difference() {
  //  translate([-17, -25, 14])
  //    cube([50, 50, 15], center=true);
  //  cube([axis_dia*squash-2*sides_thick, 8.4, 200], center=true);
  //}
}
