enable_krave = false;
enable_pcb = false;
enable_supports = true;
enable_sides = true;
enable_mount_thingies = false;
mount_opt1 = false;
mount_opt2 = false;
mount_opt3 = true;
with_colour = false;

spindle_radius = 25;
squash = 0.9;

base_thick = 2.5;
base_thick2 = 7.5;
base_radius = 40;
axis_height = 69;
axis_dia = 80;
krave_high = 8;
krave_thick = 2.5;
skrue_dia = 2.2;
skrue_dist = 18.5/2;
center_piece_rad = 5.5+0.3;
pcb_angle=37.5;
pcb_thick = 0.8;
sides_thick=1.0;

led_thick=0.25;
led_protude=0.62;
led_dot_offset=led_thick+led_protude*0.2;

module my_colour(col) {
  if (with_colour) {
    color(col)
      children();
  } else {
    children();
  }
}


module battery(bat_x, bat_y, bat_thick) {
  eps = 0.003152;
  eps2 = 0.001;
  translate([0, 0, base_thick]) {
    my_colour("cyan")
    translate([0,0,(bat_thick+eps)/2])
      linear_extrude(height = bat_thick+eps+eps2, center = true) {
        polygon(points = [[-bat_x/2,-bat_y/2], [bat_x/2,-bat_y/2],
                          [bat_x/2,bat_y/2], [-bat_x/2,bat_y/2]]);
      }
  }
}


module base(thick, rad) {
  difference() {
    scale([squash,1,1])
      cylinder(h = thick, r1= rad-0.75*thick, r2 = rad, $fn=120);
    translate([0,0,-0.1])
      cylinder(h=thick+0.2, r = center_piece_rad, $fn = 60);
    for (i = [0 : 5]) {
      rotate(i*360/6, [0,0,1]) {
	translate([skrue_dist, 0, -0.1])
	  cylinder(h = thick+0.2, r=skrue_dia/2, $fn = 20);
	translate([skrue_dist, 0, thick-1.2])
	  cylinder(h = thick+0.2, r=skrue_dia/2+1.2, $fn = 20);
      }
    }
  }
}


module krave(h, thick) {
  translate([0,0,-h]) {
    difference() {
      cylinder(h = h, r = spindle_radius/2+thick, $fn = 60);
      cylinder(h = h, r = spindle_radius/2, $fn = 60);
    }
  }
}


module pcb(thick) {
  my_colour("DarkSlateGray", 0.3) {
    translate([0,0,axis_height/2+2])
      rotate([0, pcb_angle, 0])
      rotate([0, 0, 90])
	linear_extrude(height=thick, center=true)
	  polygon(points = [[49,5.5], [48,16], [45,25], [33.5,34.5],
			    [9,34.5], [5,34.5+8], [-5,34.5+8], [-9,34.5],
			    [-33.5,34.5], [-45,25], [-48,16], [-49,5.5],
			    [-49,-5.5], [-48,-16], [-45,-25], [-33.5,-34.5],
			    [-9,-34.5], [-5,-(34.5+11)], [5,-(34.5+11)], [9,-34.5],
			    [33.5,-34.5], [45,-25], [48,-16], [49,-5.5]]);
  }
}


module sides_transform() {
  translate([0,0,base_thick])
    rotate([0,0,90])
      children();
}


module led_coords() {
  translate([0, 0, axis_height/2-led_dot_offset]) {
    rotate([pcb_angle, 0, 0]) {
      children();
    }
  }
}


module hexagon(d, h, center=true) {
  cylinder(r=d/2*(2/sqrt(3)), h=h, center=center, $fn=6);
}


module mount_thingies() {
  my_colour("yellow") {
    translate([0, 37, -pcb_thick-11])
      cylinder(h = 11+0.2, r=3.3/2+0.45, $fn = 20);
    translate([0, -37-5, -pcb_thick-11])
      cylinder(h = 11+0.2, r=3.3/2+0.45, $fn = 20);
  }
  my_colour("blue") {
    translate([0, 37, -0.8-6+0.1])
      hexagon(d=5.1+0.1, h=6, center=false);
    translate([0, -37-5, -0.8-6+0.1])
      hexagon(d=5.1+0.1, h=6, center=false);
  }
}

module sides_restrict() {
  nut_thick=1.5;
  nut_wide=6;

  sides_transform() {
    difference() {
      scale([1,squash,1])
        cylinder(r=axis_dia/2, h=axis_height, center=false, $fn=120);
      led_coords() {
        translate([0, 0, 100-pcb_thick]) {
          cube([200, 200, 200], center=true);
        }
      }
      led_coords() {
        translate([0, 37, -pcb_thick-12])
          cylinder(h = 24, r=3/2, $fn = 20);
        translate([0, -37-5, -pcb_thick-12])
          cylinder(h = 24, r=3/2, $fn = 20);
        if (mount_opt1) {
          translate([0, 37+10, -pcb_thick-1.5-nut_thick/2])
            cube([nut_wide, nut_wide+20, nut_thick], center=true);
          translate([0, -37-5-10, -pcb_thick-1.5-nut_thick/2])
            cube([nut_wide, nut_wide+20, nut_thick], center=true);
        }
        if (mount_opt2) {
          translate([0, 37, -0.8-3])
            hexagon(d=5.5+0.2, h=3+0.5, center=false);
          translate([0, -37-5, -0.8-3])
            hexagon(d=5.5+0.2, h=3+0.5, center=false);
        }
        if (mount_opt3) {
          mount_thingies();
        }
      }
    }
  }
}


module sides() {
  difference() {
    my_colour("Crimson", 0.7) {
      difference() {
	sides_restrict();
	sides_transform()
	  scale([1, (squash*(axis_dia/2)-sides_thick)/((axis_dia/2)-sides_thick), 1])
	    cylinder(r=axis_dia/2-sides_thick, h=axis_height*2, center=false, $fn=120);
      }
      intersection() {
	sides_restrict();
	sides_transform()
	  translate([0,-20,base_thick2/2])
	    cube([axis_dia, axis_dia, base_thick2], center=true);
      }
    }
    battery(35, 60, 11);
  }
}


module highsupport() {
  thick=8.2;
  width=10;
  intersection() {
    translate([-(axis_dia*squash/2-thick/2), 0, axis_height/2])
      cube([thick, width, axis_height], center=true);
    sides_restrict();
  }
}


module lowsupport() {
  thick=8;
  width=10;
  intersection() {
    translate([axis_dia*squash/2-thick/2, 0, axis_height/2])
      cube([thick, width, axis_height], center=true);
    sides_restrict();
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

  if (enable_pcb) {
    %pcb(pcb_thick);
  }

  difference() {
    union() {
      base(base_thick, base_radius);
      if (enable_sides)
	sides();
    }
    translate([22.5, 0, 0])
      cylinder(r=1.5+0.2, h=100, center=true, $fn=20);
    translate([-24, 0, 0])
      cylinder(r=1.5+0.2, h=100, center=true, $fn=20);
  }

  if (enable_mount_thingies) {
    sides_transform() {
      led_coords() {
        mount_thingies();
      }
    }
  }
}


intersection() {
  translate([0,0,-axis_height/2]) {
    spindle_mount();
  }
  //translate([-500,0,-500])cube([1000,1000,1000], center=false);
  // Test prints:
  //translate([19,-15,-40]) cube([40,30,40]);
  //translate([-60,-15,10]) cube([40,30,40]);
}
