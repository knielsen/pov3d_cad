enable_krave = false;
enable_pcb = true;

spindle_radius = 25;
squash = 0.82;

base_thick = 2.5;
base_thick2 = 7.5;
base_radius = 40;
axis_height = 64;
axis_dia = 80;
krave_high = 8;
krave_thick = 2.5;
skrue_dia = 2;
skrue_dist = 18.5/2;
center_piece_dia = 5.5;
pcb_angle=37.5;
pcb_thick = 0.8;

led_thick=0.25;
led_protude=0.62;
led_dot_offset=led_thick+led_protude*0.2;

module battery(bat_x, bat_y, bat_thick) {
  translate([0, 0, base_thick]) {
    color("cyan")
    translate([0,0,bat_thick/2])
      linear_extrude(height = bat_thick, center = true) {
        polygon(points = [[-bat_x/2,-bat_y/2], [bat_x/2,-bat_y/2],
                          [bat_x/2,bat_y/2], [-bat_x/2,bat_y/2]]);
      }
  }
}


module base(thick, rad) {
  difference() {
    scale([squash,1,1])
      cylinder(h = thick, r = rad);
    translate([0,0,-0.1])
      cylinder(h=thick+0.2, r = center_piece_dia, $fn = 60);
    for (i = [0 : 5]) {
      rotate(i*360/6, [0,0,1]) {
	translate([skrue_dist, 0, -0.1])
	  cylinder(h = thick+0.2, r=skrue_dia/2, $fn = 20);
	translate([skrue_dist, 0, thick-1.2])
	  cylinder(h = thick+0.2, r=skrue_dia/2+1.1, $fn = 20);
      }
    }
  }
}


module krave(h, thick) {
  translate([0,0,-h]) {
    difference() {
      cylinder(h = h, r = spindle_radius/2+thick);
      cylinder(h = h, r = spindle_radius/2, $fn = 60);
    }
  }
}


module pcb(thick) {
  color("DarkSlateGray", 0.3) {
    translate([0,0,34])
      rotate([0, pcb_angle, 0])
      rotate([0, 0, 90])
	linear_extrude(height=thick, center=true)
	  polygon(points = [[49,5.5], [48,16], [45,25], [33.5,34.5],
			    [11,34.5], [5,34.5+6], [-5,34.5+6], [-11,34.5],
			    [-33.5,34.5], [-45,25], [-48,16], [-49,5.5],
			    [-49,-5.5], [-48,-16], [-45,-25], [-33.5,-34.5],
			    [-11,-34.5], [-5,-(34.5+6)], [5,-(34.5+6)], [11,-34.5],
			    [33.5,-34.5], [45,-25], [48,-16], [49,-5.5]]);
  }
}


module sides_transform() {
  translate([0,0,base_thick])
    rotate([0,0,90])
      for (i = [0:$children-1]) {
	child(i);
      }
}


module sides_restrict() {
  nut_thick=1.5;
  nut_wide=6;

  sides_transform() {
    difference() {
      scale([1,squash,1])
        cylinder(r=axis_dia/2, h=axis_height, center=false);
      translate([0, 0, axis_height/2-led_dot_offset])
	rotate([pcb_angle, 0, 0]) {
	  translate([0, 0, 100-pcb_thick]) {
	    cube([200, 200, 200], center=true);
          }
        }
      translate([0, 0, axis_height/2-led_dot_offset])
	rotate([pcb_angle, 0, 0]) {
	  translate([0, 37, -pcb_thick-12])
	    cylinder(h = 24, r=3/2, $fn = 20);
          translate([0, 37+10, -pcb_thick-1.5-nut_thick/2])
            cube([nut_wide, nut_wide+20, nut_thick], center=true);
        }
      translate([0, 0, axis_height/2-led_dot_offset])
	rotate([pcb_angle, 0, 0]) {
	  translate([0, -37, -pcb_thick-12])
	    cylinder(h = 24, r=3/2, $fn = 20);
          translate([0, -37-10, -pcb_thick-1.5-nut_thick/2])
            cube([nut_wide, nut_wide+20, nut_thick], center=true);
        }
    }
  }
}


module sides() {
  difference() {
    color("Crimson", 0.7) {
      difference() {
	sides_restrict();
	sides_transform()
	  scale([1,squash,1])
	    cylinder(r=axis_dia/2-1, h=axis_height*2, center=false);
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
  thick=5;
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


if (enable_krave) {
  krave (krave_high, krave_thick);
}

color("darkgreen") {
  highsupport();
  lowsupport();
}



if (enable_pcb) {
  pcb(pcb_thick);
}

difference() {
  union() {
    base(base_thick, base_radius);
    sides();
  }
  translate([22, 0, 0])
    cylinder(r=1.5, h=100, center=true, $fn=20);
  translate([-24, 0, 0])
    cylinder(r=1.5, h=100, center=true, $fn=20);
}
