ps2_conn_ridge_width = 2.5;
ps2_conn_ridge_length = 38.5;
ps2_conn_ridge_depth = 1.3;
ps2_conn_ridge_height = 6;
ps2_conn_ridge_rad = 2.0;
ps2_conn_back_box_thick = 1.8;
ps2_conn_dist = 124 - 76;

$fa = 10;
$fs = 0.1;

module ps2_conn_ridge() {
  eps=0.031;
  zsize = ps2_conn_ridge_height-2*ps2_conn_ridge_rad;
  translate([.5*ps2_conn_ridge_width, 0, .5*zsize+ps2_conn_ridge_rad-eps]) {
    cube([ps2_conn_ridge_width, ps2_conn_ridge_length, zsize+2*eps],
         center=true);
  }
  for(j = [0:1]) {
    for(i = [-1:2:1]) {
      zpos = j==0 ?
        ps2_conn_ridge_rad :
        ps2_conn_ridge_height-ps2_conn_ridge_rad;
      translate([0, i*(.5*ps2_conn_ridge_length-ps2_conn_ridge_rad),
                 zpos]) {
        rotate([0, 90, 0])
          cylinder(r=ps2_conn_ridge_rad, h=ps2_conn_ridge_width, center=false);
      }
    }
  }
  for(j = [0:1]) {
    zpos = j==0 ?
      .5*ps2_conn_ridge_rad :
      ps2_conn_ridge_height-.5*ps2_conn_ridge_rad;
    translate([.5*ps2_conn_ridge_width, 0, zpos]) {
      cube([ps2_conn_ridge_width, ps2_conn_ridge_length-2*ps2_conn_ridge_rad,
            ps2_conn_ridge_rad], center=true);
    }
  }
  translate([0, 0, ps2_conn_ridge_height]) {
    cube([12, 4.5, 2.5], center=true);
  }
}

module ps2_conn_holder() {
  ps2_conn_ridge();
}

module ledtorus1_box() {
  eps = 0.0171;
  difference() {
    union() {
      translate([.5*ps2_conn_ridge_width, 0, 0]) {
        cube([ps2_conn_ridge_width-eps,
              100,
              2*(ps2_conn_ridge_height-ps2_conn_ridge_rad-eps)],
             center=true);
      }
    }
    for (i = [-1 : 2 : 1]) {
      translate([0, .5*i*ps2_conn_dist, 0])
        ps2_conn_holder();
    }
  }
}

//ledtorus1_box();
ps2_conn_holder();
