$fa = 1; $fs = 0.1;

magnet_height = 9.75;
magnet_dia = 6.0;

spindle_mount_dia = 150;
inter_gap_space = 1.0;
//outer_dia = 161;
outer_dia = spindle_mount_dia + 2*(inter_gap_space + magnet_dia);
magnet_top = 35.0;

foot_thick = 0.6;
foot_long = 16;
foot_wide = 9;

hole_tolerance = 0.06;

function myshape_z(x, end_x, end_z) = x*x/(end_x*end_x)*end_z;
function myshape_z_derivative(x, end_x, end_z) = 2*x/(end_x*end_x)*end_z;

module myshape_recurse(x, end_x, end_z) {
  ell = 1;
  radius = 3;
  d = myshape_z_derivative(x, end_x, end_z);
  incr_x = ell/sqrt(1+d*d);
  next_x = x + incr_x;
  z0 = myshape_z(x, end_x, end_z);
  z1 = myshape_z(next_x, end_x, end_z);
  dx = next_x - x;
  dz = z1 - z0;
  ell_adj = sqrt(dx*dx + dz*dz);
  d_adj = dz/dx;
  angle = 90 - atan(d_adj);
  cube_ell = ell_adj;
  translate([x, 0, z0]) {
    rotate([0, angle, 0]) {
      cylinder(r=radius, h=ell_adj, center=false);
      translate([radius, 0, .5*ell_adj])
        cube([2*radius, 2*radius, cube_ell], center=true);
    }
  }
  if (next_x < end_x+0.001*(end_x-next_x))
    myshape_recurse(next_x, end_x, end_z);
}

module myshape() {
  start_pos = 0;
  end_pos = 25;
  end_height = 35;
  translate([10, 0, 0])
    myshape_recurse(start_pos, end_pos, end_height);
}

module magnet_mount() {
  eps = 0.0173;

  intersection() {
    difference() {
      translate([.5*spindle_mount_dia+inter_gap_space, 0, 0])
        cylinder(d=outer_dia, h=magnet_top, center=false);
      translate([.5*spindle_mount_dia+inter_gap_space, 0, -eps])
        cylinder(d=spindle_mount_dia+2*inter_gap_space, h=magnet_top+2*eps, center=false);
      translate([-.5*magnet_dia, 0, magnet_top-magnet_height])
        cylinder(d=magnet_dia+hole_tolerance, h=magnet_height+eps, center=false);
    }
//    cube([50, 38, 3*magnet_top], center=true);
    translate([-.5*magnet_dia, 0, 0])
      cylinder(d1=38, d2=magnet_dia+1.5, h=magnet_top, center=false);
  }
  translate([-.5*magnet_dia, 0, .5*foot_thick])
    cube([2*foot_long+magnet_dia, foot_wide, foot_thick], center=true);
}

magnet_mount();
//myshape();
