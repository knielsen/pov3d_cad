enable_bat = true;
enable_krave = true;

spindle_radius = 25;

base_thick = 2.5;
base_radius = 40;
krave_high = 8;
krave_thick = 2.5;
skrue_dia = 2;
skrue_dist = 18.5/2;
center_piece_dia = 5.5;

module battery(bat_x, bat_y, bat_thick) {
  if (enable_bat) {
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
    cylinder(h = thick, r = rad);
    translate([0,0,-0.1])
      cylinder(h=thick+0.2, r = center_piece_dia, $fn = 60);
    for (i = [0 : 5]) {
      rotate(i*360/6, [0,0,1])
	translate([skrue_dist, 0, -0.1])
	  cylinder(h = thick+0.2, r=skrue_dia/2, $fn = 20);
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


base(base_thick, base_radius);

if (enable_krave) {
  krave (krave_high, krave_thick);
}

translate([0, 0, base_thick])
  battery(35, 60, 11);
