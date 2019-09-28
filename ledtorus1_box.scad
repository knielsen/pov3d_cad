do_bottom = true;
do_middle = true;
do_top = true;
do_pcb = true;
do_hex_nut_supports = true;
do_exploded = true;

// Open build, to make the electronics and HDD-reuse visible.
with_open_build = false;
// Holes below PS2 connectors, as a template for soldering the connectors in
// the right position to fit in the encasing.
with_solder_holes = false;

ps2_conn_ridge_width = 2.5;
ps2_conn_ridge_length = 38.5;
ps2_conn_ridge_depth = 1.3;
ps2_conn_ridge_height = 6.3;
ps2_conn_ridge_rad = 2.15;
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
// This makes the rounded corner minimum thickness be 1/2 of box_side_thick.
box_corner_r = box_side_thick*sqrt(2)/(2*(sqrt(2)-1));
// This is perhaps better?
//box_corner_r = box_side_thick;

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
pcb_left_cutout_ypos1 = 17.5;
pcb_left_cutout_ypos2 = 38;
pcb_right_cutout_ypos1 = 25;
pcb_right_cutout_ypos2 = 36;
pcb_motor_cutout_xpos1 = 20.5 - .5*20;
pcb_motor_cutout_xpos2 = 20.5 + .5*20;
pcb_motor_cutout_ypos2 = pcb_from_front + pcb_len;
pcb_motor_cutout_ypos1 = pcb_motor_cutout_ypos2 - 30;

conn_pin_xsize = 3.2;
conn_pin_ysize = 1.5;
conn_pin_zsize = 2.5;

// The nRF24L01+ module goes 14mm above the PCB top surface. Make sure there is
// room for that and 1mm to spare.
top_height = middle_thick + pcb_lift + pcb_thick + 14 + 1;
top_top = middle_zpos + top_height;

mount_screw_len = 39;
hexnut_hole_depth = top_top - (mount_screw_len - 5);
stub_dia = 7;
hexnut_slot_tolerance=2*0.25;
side_hole_z = 6.0;
side_hole_y = [box_extra+hd_len+box_side_thick-119.3,
               box_extra+hd_len+box_side_thick-18.0];

magnet_xpos1 = 31;
magnet_ypos1 = 93.8;
//magnet_xpos2 = -(.5*(hd_width+2*box_side_thick)-26.5;
//magnet_ypos2 = box_extra+hd_len+box_side_thick-21;
magnet_xpos2 = -16.6;
// Compute magnet2 pos with same distance to torus-center as magnet1.
t_cx = 0;
t_cy = box_extra+box_torus_front_dist;
magnet_ypos2 = t_cy -
  sqrt((magnet_ypos1-t_cy)*(magnet_ypos1-t_cy) +
       (magnet_xpos1-t_cx)*(magnet_xpos1-t_cx) -
       (magnet_xpos2-t_cx)*(magnet_xpos2-t_cx));
magnet_height = 10;
magnet_dia = 6;

// It seems to fit that the bottom inner ridge of the PS2 connector sits in
// the middle of the PCB. With enough tiny slack that it should be possible
// to solder the connectors while mounted in the frame/box for a perfect fit?
ps2_conn_inner_low_zpos = pcb_top - .5*pcb_thick;

$fa = 5;
$fs = 0.2;


module cube_rounded(sizes, r, center=true) {
  sx = sizes[0];
  sy = sizes[1];
  sz = sizes[2];
  translate([(center ? 0 : .5*sx), (center ? 0 : .5*sy), (center ? 0 : .5*sz)]) {
    hull() {
      for (i = [-1:2:1]) {
        for (j = [-1:2:1]) {
          translate([i*(.5*sx-r), j*(.5*sy-r), 0])
            cylinder(h=sz, r=r, center=true);
        }
      }
    }
  }
}

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


// Cutout for motor power leads.
module motor_leads_cutout(zpos) {
  eps = 0.009435;
  cutout_xsize = pcb_motor_cutout_xpos2 - pcb_motor_cutout_xpos1;
  cutout_ysize = pcb_motor_cutout_ypos2 - pcb_motor_cutout_ypos1;
  translate([pcb_motor_cutout_xpos1+.5*cutout_xsize,
             pcb_motor_cutout_ypos1+.5*cutout_ysize+eps,
             zpos]) {
    cube([cutout_xsize, cutout_ysize, 6*box_top_thick], center=true);
  }
}


// Bottom part that wraps the HDD.
// Origin is at the front of the box in Y, centered on X and at the base on Z.
module box_base() {
  eps=0.00673;
  height = box_base_height+box_top_thick;
  side_hole_tolerance_z = 0.3;
  side_hole_tolerance_y = 0.8 - side_hole_tolerance_z;
  magnet_hole_tolerance = 0.15;
  mag_x = [magnet_xpos1, magnet_xpos2];
  mag_y = [magnet_ypos1, magnet_ypos2];

  difference() {
    union() {
      difference() {
        translate([0, .5*(box_extra+hd_len+box_side_thick), .5*height])
          cube_rounded([hd_width+2*box_side_thick,
                        box_extra+hd_len+box_side_thick,
                        height], r=box_corner_r, center=true);
        translate([0, box_extra+.5*hd_len, .5*box_base_height-eps])
          cube([hd_width, hd_len, box_base_height], center=true);
        for(i = [0:1]) {
          hull() {
            for(j = [-1:2:1]) {
              translate([0, side_hole_y[i]+j*.5*side_hole_tolerance_y, side_hole_z]) {
                rotate([0, 90, 0])
                  cylinder(d=3+side_hole_tolerance_z,
                           h=hd_width+2*box_side_thick+2*1,
                           center=true);
              }
            }
          }
        }
      }
      translate([0, box_extra+box_torus_front_dist, height-2*box_top_thick])
        cylinder(h=2*box_top_thick, d=box_torus_hole_d+2*box_side_thick, center=false);
      for (i=[0:1]) {
        translate([mag_x[i], mag_y[i], height-box_top_thick])
          rotate([180, 0, 0])
          cylinder(d=magnet_dia+2*box_top_thick, h=magnet_height+box_top_thick, center=false);
      }
    }
    translate([0, box_extra+box_torus_front_dist, 0])
      cylinder(h=1000, d=box_torus_hole_d, center=true);
    for (i=[0:1]) {
      translate([mag_x[i], mag_y[i], height+2*eps])
        rotate([180, 0, 0])
        cylinder(d=magnet_dia+magnet_hole_tolerance, h=magnet_height, center=false);
    }
    motor_leads_cutout(zpos=middle_zpos);
  }
}

module ps2_conn_ridge() {
  eps=0.031;
  zsize = ps2_conn_ridge_height-2*ps2_conn_ridge_rad;
  translate([.5*ps2_conn_ridge_width, 0, .5*zsize+ps2_conn_ridge_rad-eps]) {
    cube([ps2_conn_ridge_width+eps, ps2_conn_ridge_length, zsize+2*eps],
         center=true);
  }
  for(j = [0:1]) {
    for(i = [-1:2:1]) {
      zpos = j==0 ?
        ps2_conn_ridge_rad :
        ps2_conn_ridge_height-ps2_conn_ridge_rad;
      translate([-eps, i*(.5*ps2_conn_ridge_length-ps2_conn_ridge_rad),
                 zpos]) {
        rotate([0, 90, 0])
          cylinder(r=ps2_conn_ridge_rad, h=ps2_conn_ridge_width+2*eps, center=false);
      }
    }
  }
  for(j = [0:1]) {
    zpos = j==0 ?
      .5*ps2_conn_ridge_rad+.5*eps :
      ps2_conn_ridge_height-.5*ps2_conn_ridge_rad-.5*eps;
    translate([.5*ps2_conn_ridge_width, 0, zpos]) {
      cube([ps2_conn_ridge_width+eps, ps2_conn_ridge_length-2*ps2_conn_ridge_rad,
            ps2_conn_ridge_rad+eps], center=true);
    }
  }
  translate([0, 0, ps2_conn_ridge_height]) {
    cube([12, 5, 2*3], center=true);
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


module ps2_conn_support_high() {
  eps = 0.0171;
  z_tolerance = 0;
  fit_tolerance = 2*0.065;
  fit_tolerance_depth = 0.65;
  zsize = top_top-(ps2_conn_inner_low_zpos+.5*ps2_conn_ridge_height) - z_tolerance;
  xsize2 = conn_pin_xsize+2*top_side_thick; // middle
  xsize3 = .5*(hd_width+2*box_side_thick-pcb_width)+conn_pin_xsize+top_side_thick; // outer
  ysize2 = conn_pin_ysize+2*top_side_thick;

  difference() {
    union() {
      translate([0, .5*ps2_conn_ridge_width, top_top-.5*zsize]) {
        cube([hd_width+2*box_side_thick,
              ps2_conn_ridge_width,
              zsize],
             center=true);
      }
      for(i = [-1:1:1]) {
        this_xsize = (i == 0 ? xsize2 : xsize3);
        translate([i*.5*(hd_width+2*box_side_thick-this_xsize), .5*ysize2, top_top-.5*zsize])
          cube([this_xsize, ysize2, zsize], center=true);
      }
    }
    for(i = [-1:1:1]) {
      translate([i*.5*(pcb_width-(i == 0 ? xsize2 : conn_pin_xsize)),
                 .5*conn_pin_ysize + top_side_thick,
                 top_top-zsize-1+.5*(1+conn_pin_zsize+fit_tolerance_depth)])
        cube([conn_pin_xsize+fit_tolerance, conn_pin_ysize+fit_tolerance,
              1+conn_pin_zsize+fit_tolerance_depth], center=true);
    }
    for (i = [-1 : 2 : 1]) {
      translate([.5*i*ps2_conn_dist, 0, ps2_conn_inner_low_zpos])
        ps2_conn_holder();
    }
  }
}


module mounting_holes(do_front=true, do_back=true) {
  screw_tolerance=2*0.1;
  h=2*box_base_height;
  for(i = [-1:2:1]) {
    if (do_front) {
      translate([i*pcb_hole_xpos, pcb_hole_ypos, -1]) {
        cylinder(d=4+screw_tolerance, h=h, center=false);
        cylinder(d=7.8+hexnut_slot_tolerance, h=1+hexnut_hole_depth, center=false, $fn=6);
      }
    }
    if (do_back) {
      translate([i*pcb_hole_xpos, pcb_hole_ypos2, -1])
        cylinder(d=4+screw_tolerance, h=h, center=false);
    }
  }
}


module hex_nut_supports() {
  hole_tolerance = 0.4;
  height_tolerance = 0.8;
  height = 9.5 - height_tolerance;
  screw_tolerance = 2*0.4;

  for(i = [-1:2:1]) {
    difference() {
      translate([i*pcb_hole_xpos, pcb_hole_ypos, 0]) {
        cylinder(d=7.8+hexnut_slot_tolerance-hole_tolerance, h=height, center=false, $fn=6);
      }
      translate([i*pcb_hole_xpos, pcb_hole_ypos, -1]) {
        cylinder(d=4.0 + screw_tolerance, h=height+2*1, center=false);
      }
    }
  }
}

module bottom_part() {
  box_base();
}

module middle_part() {
  stub_h = middle_thick + pcb_lift;

  ps2_conn_support_low();
  translate([0, 0, middle_zpos]) {
    // Bottom.
    difference() {
      union() {
        ysize = pcb_from_front + pcb_len;
        translate([0, .5*ysize, .5*middle_thick])
          cube([pcb_width, ysize, middle_thick], center=true);
        ysize2 = ysize - (conn_pin_ysize+2*top_side_thick);
        translate([0, ysize-.5*ysize2, .5*middle_thick])
          cube([hd_width, ysize2, middle_thick], center=true);
      }
      motor_leads_cutout(zpos=0);
      if (with_solder_holes) {
        for (i=[-1:2:1]) {
          translate([i*21.5, 9, 0])
            cube([39, 10, 10], center=true);
        }
      }
    }
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

module top_part_main_body(top_width, top_len) {
  translate([0, .5*top_len, middle_zpos+.5*top_height])
    cube_rounded([top_width, top_len, top_height], r=box_corner_r, center=true);
}


module top_part() {
  eps = 0.00551;
  top_back_tolerance = 0.4;
  top_width = hd_width+2*box_side_thick;
  top_len = pcb_from_front+pcb_len+top_back_tolerance+top_side_thick;
  hole_tolerance1 = 2*0.05;
  hole_tolerance2 = 2*0.15;
  front_tolerance = 0.1;

  difference() {
    top_part_main_body(top_width, top_len);
    translate([0, .5*top_len-top_side_thick, middle_zpos+.5*top_height-box_top_thick])
      cube([hd_width, top_len, top_height], center=true);
    cutout_xsize = 1.2*box_side_thick;
    cutout_zsize_left = 18.5;
    cutout_zsize_right = 17.5;
    cutout_left_ysize = pcb_left_cutout_ypos2 - pcb_left_cutout_ypos1;
    translate([-(.5*hd_width+box_side_thick-.5*box_side_thick),
               pcb_left_cutout_ypos1 + .5*cutout_left_ysize,
               middle_zpos + .5*cutout_zsize_left - eps]) {
      cube([cutout_xsize, cutout_left_ysize, cutout_zsize_left], center=true);
    }
    cutout_right_ysize = pcb_right_cutout_ypos2 - pcb_right_cutout_ypos1;
    translate([+(.5*hd_width+box_side_thick-.5*box_side_thick),
               pcb_right_cutout_ypos1 + .5*cutout_right_ysize,
               middle_zpos + .5*cutout_zsize_right - eps]) {
      cube([cutout_xsize, cutout_right_ysize, cutout_zsize_right], center=true);
    }
    // Ventilation.
    vent_x = 21;
    vent_y = 56;
    vent_xsize = 32;
    vent_ysize = 2;
    vent_zsize = 1.2*box_top_thick;
    for (j = [-4:2:4]) {
      hull() {
        for (i = [-1:2:1]) {
          translate([vent_x+i*.5*vent_xsize, vent_y+j*vent_ysize, top_top-.5*box_top_thick]) {
            cylinder(d=vent_ysize, h=vent_zsize, center=true);
          }
        }
      }
    }
    translate([0, 23.4, top_top-0.4]) {
      linear_extrude(height=1)
        text("LED-Torus", halign="center", valign="bottom",
             font="Roboto:style=Regular", size=14);
    }
  }

  xsize2 = .5*(hd_width+2*box_side_thick-pcb_width)-front_tolerance;
  ysize2 = conn_pin_ysize+2*top_side_thick;
  intersection() {
    top_part_main_body(top_width, top_len);
    union() {
      ps2_conn_support_high();
      for (i = [-1:2:1]) {
        translate([i*.5*(hd_width+2*box_side_thick-xsize2), .5*ysize2, middle_zpos+.5*top_height])
          cube([xsize2, ysize2, top_height], center=true);
      }
    }
  }

  // Stubs for mounting screws.
  for(i = [-1:2:1]) {
    for(j = [0:1]) {
      h = top_height - (pcb_top - middle_zpos);
      this_y = (j == 1 ? pcb_hole_ypos2 : pcb_hole_ypos);
      hull() {
        translate([i*pcb_hole_xpos, this_y, pcb_top]) {
          cylinder(h=h, d=stub_dia, center=false);
        }
        translate([i*(.5*(hd_width+2*box_side_thick)-.1), this_y, pcb_top+.5*h]) {
          cube([0.2, stub_dia, h], center=true);
        }
      }
    }
    translate([i*pcb_hole_xpos, pcb_hole_ypos2, pcb_top-pcb_thick])
      cylinder(d=4.3-hole_tolerance1, h=pcb_thick, center=false);
    translate([i*pcb_hole_xpos, pcb_hole_ypos2, middle_zpos-2*box_top_thick])
      cylinder(d=4.0-hole_tolerance2, h=top_height, center=false);
  }
}


module open_build_subtract() {
  eps = 0.037;
  cutout_back_y1 = magnet_ypos2+.5*magnet_dia+2*box_side_thick;
  cutout_back_y2 = magnet_ypos1+.5*magnet_dia+2*box_side_thick;
  cutout_front_xsize1 = pcb_width-10;
  cutout_front_ysize1 = 40;
  cutout_front_xsize2 = pcb_width-20;
  cutout_front_ysize2 = 150;
  cutout_front_y = 18;
  cutout_front_z = middle_zpos + 5;

  translate([eps, cutout_back_y1, -top_top]) {
    mirror([1, 0, 0]) {
      cube([2*hd_width, hd_len, 3*top_top], center=false);
    }
  }
  translate([-eps, cutout_back_y2, -top_top]) {
    cube([2*hd_width, hd_len, 3*top_top], center=false);
  }
  translate([-.5*cutout_front_xsize1, cutout_front_y, cutout_front_z]) {
    cube([cutout_front_xsize1, cutout_front_ysize1, top_height], center=false);
  }
  translate([-.5*cutout_front_xsize2, cutout_front_y, cutout_front_z]) {
    cube([cutout_front_xsize2, cutout_front_ysize2, top_height], center=false);
  }
}


module assembly() {
  exp_z = (do_exploded ? 8 : 0);

  translate([0, 0, 0*exp_z]) {
    if (do_bottom) {
      difference() {
        color("gold")
          bottom_part();
        mounting_holes(do_front=true, do_back=true);
      }
    }
  }
  translate([0, 0, 1*exp_z]) {
    if (do_middle) {
      difference() {
        color("green")
          middle_part();
        mounting_holes(do_front=true, do_back=true);
      }
    }
  }
  translate([0, 0, 3*exp_z]) {
    if (do_top) {
      difference() {
        color("blue")
          top_part();
        mounting_holes(do_front=true, do_back=false);
      }
    }
  }
  translate([0, 0, 2*exp_z]) {
    if (do_pcb) {
      translate([0, pcb_from_front, pcb_top - pcb_thick])
        %//color("black")
        pcb();
    }
  }

  translate([0, 0, -2*exp_z]) {
    if (do_hex_nut_supports) {
      hex_nut_supports();
    }
  }
}

//ps2_conn_support_low();
//ps2_conn_holder();

//box_base();
//color("black") pcb();

if (!with_open_build) {
  assembly();
} else {
  difference() {
    assembly();
    open_build_subtract();
  }
}
