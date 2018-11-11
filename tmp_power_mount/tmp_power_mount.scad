// Fine subdivisions, for production run
$fa = 1; $fs = 0.1;
// Coarse, but faster, subdivisions, for testing.
//$fa = 2; $fs = 0.3;

base_l = 64;
base_w = 30;
base_h = 12;
dc_dc_l = 22.3;
dc_dc_w = 17;
jack_w = 9;
jack_l = 14.5;
jack_edge_dist = 1.5;
switch_l = 11.45;
switch_w = 5.95;
switch_h = 12.5;
channel_bottom = 1.5;
channel_top = 5;
channel_h = base_h-channel_bottom-channel_top;
channel_w = 7;
channel_l = base_l - 2*6;
channel_y = -.5*base_w+jack_edge_dist+jack_l-0.5;

module power_jack_cutout(positive) {
  cutout_h = 5;
  cutout2_h = cutout_h-1.5;
  cutout2_dia = 10;
  cutout3_h = cutout_h+4;
  cutout3_l = 8;
  cutout3_w1 = 6;
  cutout3_w2 = 1;
  extra = 20;
  wall_thick = 2;
  wall_height = 4.5;
  eps=0.0013251;

  translate([-.5*base_l+jack_w+5-.5*jack_w, 0, 0]) {
    if (positive) {
      translate([0,
                 -.5*base_w+jack_edge_dist+.5*(jack_l+wall_thick)+0.5,
                 base_h-eps+.5*(wall_height+eps)])
        cube([jack_w+2*wall_thick, jack_l+wall_thick, wall_height+eps], center=true);
    } else {
      translate([0, -.5*base_w+.5*jack_l+jack_edge_dist, base_h-cutout_h+.5*(cutout_h+extra)])
        cube([jack_w, jack_l, cutout_h+extra], center=true);
      translate([0, -.5*base_w-eps, base_h+.5*cutout2_dia-cutout2_h])
        rotate([-90, 0, 0])
        cylinder(d=cutout2_dia, h=jack_edge_dist+2*eps, center=false);
      translate([.5*jack_w+cutout3_w2-.5*(cutout3_w1+cutout3_w2),
                  -.5*base_w+jack_edge_dist+jack_l-.5*cutout3_l,
                  base_h-cutout3_h+.5*(cutout3_h+extra)])
        cube([cutout3_w1+cutout3_w2, cutout3_l, cutout3_h+extra], center=true);
    }
  }
}


module switch_cutout(positive) {
  cutout = switch_h + 2;
  sw_edge = 0.5;
  sw_h2 = 6;
  eps = 0.00231;
  wall_thick = 2;
  wall_height = 4.5;

  translate([-.5*(dc_dc_w-jack_w), 0, base_h]) {
    if (positive) {
      translate([0, 0, -eps+.5*(wall_height+eps)])
        cube([switch_l+2*wall_thick, switch_w+2*wall_thick, wall_height+eps], center=true);
    } else {
      translate([0, 0, wall_height-sw_h2+.5*(sw_h2+eps)])
        cube([switch_l, switch_w, sw_h2+eps], center=true);
      translate([0, 0, wall_height-cutout+.5*(cutout+2*eps)])
        cube([switch_l-2*sw_edge, switch_w-2*sw_edge, cutout+2*eps], center=true);
    }
  }
}


module dc_dc_cutout() {
  cutout_h = 3;
  extra = 15;
  ch_w = 4.3;
  ch_depth = 2.5;
  ch_offset = 4.1;
  eps = 0.0073;

  translate([.5*base_l-dc_dc_w-5+.5*dc_dc_w, 0, base_h-cutout_h]) {
    translate([0, 0, .5*(cutout_h+extra)])
      cube([dc_dc_w, dc_dc_l, cutout_h+extra], center=true);
    translate([-.5*dc_dc_w+ch_offset, -.5*dc_dc_l+eps+.5*base_w, -ch_depth+.5*(ch_depth+eps)])
      cube([ch_w, base_w, ch_depth+eps], center=true);
    translate([+.5*dc_dc_w-ch_offset, -.5*dc_dc_l+eps+.5*base_w, -ch_depth+.5*(ch_depth+eps)])
      cube([ch_w, base_w, ch_depth+eps], center=true);
  }
}


module wire_channel() {
  translate([0, channel_y+.5*channel_w, channel_bottom+.5*channel_h])
    cube([channel_l, channel_w, channel_h], center=true);
}

module base() {
  translate([0, 0, .5*base_h])
    cube([base_l, base_w, base_h], center=true);
  power_jack_cutout(positive=true);
  switch_cutout(positive=true);
}


module tmp_power_base() {
  difference() {
    base();
    dc_dc_cutout();
    power_jack_cutout(positive=false);
    switch_cutout(positive=false);
    wire_channel();
  }
}

intersection() {
  tmp_power_base();
  // Test prints.
  //translate([-32, 0, 0]) cube([20, 50, 50], center=true);
}
