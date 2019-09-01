do_bottom = true;
do_middle = true;
do_top = true;
do_pcb = true;

ps2_conn_ridge_width = 2.5;
ps2_conn_ridge_length = 38.5;
ps2_conn_ridge_depth = 1.3;
ps2_conn_ridge_height = 6;
ps2_conn_ridge_rad = 2.0;
ps2_conn_back_box_thick = 1.8;
ps2_conn_dist = 124 - 76;

hd_width = 101.3+0.25;
hd_len = 146.3+0.25;
hd_height = 22.5;
box_side_thick = 1.2;
box_top_thick = 1.2;
box_base_height = 25.4;
box_torus_hole_d = 80 + 2*1.5;
box_torus_front_dist = 95.0;
box_extra = 35.7;

middle_zpos = box_base_height + box_top_thick;
middle_thick = box_top_thick;
top_side_thick = box_side_thick;

pcb_width = 100;
pcb_len = 68;
pcb_thick = 1.6;
pcb_hole_dia = 4.3;
pcb_hole_dist = 5;
pcb_hole_dist2 = 8;
pcb_lift = 3.0;
pcb_top = box_base_height + box_top_thick + middle_thick + pcb_lift + pcb_thick;
pcb_from_front = 14.55-.5*4.3-8;
pcb_hole_ypos = pcb_from_front + pcb_hole_dist2;
pcb_hole_ypos2 = pcb_from_front + pcb_len - pcb_hole_dist;
pcb_hole_xpos = .5*pcb_width-pcb_hole_dist;

conn_pin_xsize = 3.2;
conn_pin_ysize = 1.5;
conn_pin_zsize = 2.5;

// It seems to fit that the bottom inner ridge of the PS2 connector sits in
// the middle of the PCB. With enough tiny slack that it should be possible
// to solder the connectors while mounted in the frame/box for a perfect fit?
ps2_conn_inner_low_zpos = pcb_top - .5*pcb_thick;

$fa = 10;
$fs = 0.2;


module pcb() {
  w=pcb_width;
  h=pcb_len;
  t=pcb_thick;
  r=1;
  d=pcb_hole_dia;
  D=pcb_hole_dist;
  D2=pcb_hole_dist2;
  translate([0, .5*h, 0])
  difference() {
    hull() {
      for(i = [-1:2:1]) {
        for (j = [-1:2:1]) {
          translate([i*(.5*w-r), j*(.5*h-r), 0])
            cylinder(r=r, h=t, center=false);
        }
      }
    }

    for(i = [-1:2:1]) {
      for (j = [-1:2:1]) {
        translate([i*(.5*w-D), j*(.5*h-(j==-1 ? D2 : D)), -1])
          cylinder(d=d, h=t+2, center=false);
      }
    }
  }
}


// Bottom part that wraps the HDD.
// Origin is at the front of the box in Y, centered on X and at the base on Z.
module box_base() {
  eps=0.00173;
  difference() {
    height = box_base_height+box_top_thick;
    translate([0, .5*(box_extra+hd_len+box_side_thick), .5*height])
      cube([hd_width+2*box_side_thick,
            box_extra+hd_len+box_side_thick,
            height], center=true);
    translate([0, box_extra+.5*hd_len, .5*box_base_height-eps])
      cube([hd_width, hd_len, box_base_height], center=true);
    translate([0, box_extra+box_torus_front_dist, 0])
      cylinder(h=1000, d=box_torus_hole_d, center=true);
  }
}

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
  rotate([0,0,90])
    ps2_conn_ridge();
}

module ps2_conn_support_low() {
  eps = 0.0171;
  difference() {
    union() {
      zsize = ps2_conn_inner_low_zpos-(box_base_height+box_top_thick) +
        .5*ps2_conn_ridge_height;
      translate([0, .5*ps2_conn_ridge_width, middle_zpos+.5*zsize]) {
        cube([pcb_width,
              ps2_conn_ridge_width-eps,
              zsize],
             center=true);
      }
      xsize2 = conn_pin_xsize+2*top_side_thick; // middle
      xsize3 = conn_pin_xsize+top_side_thick;   // outer
      ysize2 = conn_pin_ysize+2*top_side_thick;
      for(i = [-1:1:1]) {
        this_xsize = (i == 0 ? xsize2 : xsize3);
        translate([0, 0, middle_zpos]) {
          translate([i*.5*(pcb_width-(i == 0 ? xsize2 : conn_pin_xsize)),
                     .5*conn_pin_ysize + top_side_thick,
                     .5*(zsize+conn_pin_zsize)])
            cube([conn_pin_xsize, conn_pin_ysize, zsize+conn_pin_zsize], center=true);
          translate([i*.5*(pcb_width-this_xsize), .5*ysize2, .5*zsize])
            cube([this_xsize, ysize2, zsize], center=true);
        }
      }
    }
    for (i = [-1 : 2 : 1]) {
      translate([.5*i*ps2_conn_dist, 0, ps2_conn_inner_low_zpos])
        ps2_conn_holder();
    }
  }
}


module mounting_holes() {
  h=2*box_base_height;
  for(i = [-1:2:1]) {
    translate([i*pcb_hole_xpos, pcb_hole_ypos, -1])
      cylinder(d=4, h=h, center=false);
    translate([i*pcb_hole_xpos, pcb_hole_ypos2, -1])
      cylinder(d=4, h=h, center=false);
  }
}

module bottom_part() {
  box_base();
}

module middle_part() {
  stub_dia = 7;
  stub_h = middle_thick + pcb_lift;

  ps2_conn_support_low();
  translate([0, 0, middle_zpos]) {
    // Bottom.
    ysize = pcb_from_front + pcb_len;
    translate([0, .5*ysize, .5*middle_thick])
      cube([hd_width, ysize, middle_thick], center=true);
    // Stubs for mounting screws.
    for (i = [-1:2:1]) {
      hull() {
        translate([i*pcb_hole_xpos, 1, .5*stub_h])
          cube([stub_dia, 2, stub_h], center=true);
        translate([i*pcb_hole_xpos, pcb_hole_ypos, 0])
          cylinder(d=stub_dia, h=stub_h, center=false);
      }
      translate([i*pcb_hole_xpos, pcb_hole_ypos2, 0])
        cylinder(d=stub_dia, h=stub_h, center=false);
    }
  }
}

module top_part() {
}

module assembly() {
  difference() {
    union() {
      if (do_bottom) {
        color("gold")
          bottom_part();
      }
      if (do_middle) {
        color("green")
          middle_part();
      }
      if (do_top) {
        color("blue")
          top_part();
      }
    }
    mounting_holes();
  }
  if (do_pcb) {
    translate([0, pcb_from_front, pcb_top - pcb_thick])
      %//color("black")
      pcb();
  }
}

//ps2_conn_support_low();
//ps2_conn_holder();

//box_base();
//color("black") pcb();

assembly();
