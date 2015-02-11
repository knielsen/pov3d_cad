$fn = 40;

// "extra" is extra spacing around the axis, to avoid too cramped innermost circle.
extra = -10.9;

axis_height = 100;
axis_dia = 98;
pcb_thick = 1.0;
pcb_width=80;
pcb_len=100;
pcb_angle=37.5;

/* 0805 LED */
led_len=1.6;
led_width=1.5;
led_thick=0.25;
led_protude=0.62;
led_dot_offset=led_thick+led_protude*0.2;

n_leds=7;
n_layers=8;
l_pix=5.5;
h_pix=l_pix;

module led() {
  d=0.22;
  translate([0,0,led_thick/2])
    cube([led_width,led_len,led_thick], center=true);
  translate([0,0,led_thick+led_protude/2])
    color("white")
      cube([led_width,led_width,led_protude], center=true);
  translate([0,0,led_thick+led_protude]) {
    color("red")
      rotate([0,0,0])
        translate([0,sqrt(8/5)*led_width*d,0])
          cylinder(r=led_width*d, h=led_thick/2, center=false);
    color("green")
      rotate([0,0,120])
        translate([0,sqrt(8/5)*led_width*d,0])
          cylinder(r=led_width*d, h=led_thick/2, center=false);
    color("blue")
      rotate([0,0,240])
        translate([0,sqrt(8/5)*led_width*d,0])
          cylinder(r=led_width*d, h=led_thick/2, center=false);
  }
}

module axis() {
  difference() {
    cylinder(r=axis_dia/2, h=axis_height, center=false);
    cylinder(r=axis_dia/2-1, h=axis_height*2, center=false);
    translate([0, 0, axis_height/2-led_dot_offset])
      rotate([pcb_angle, 0, 0])
        translate([0, 0, 100-pcb_thick])
          cube([200, 200, 200], center=true);
  }
}

module pcb() {
  W = (n_layers-1)*h_pix/tan(pcb_angle)/2+extra;
  L = (n_leds-1)*l_pix/2;
  translate([0,0,-led_dot_offset]) {
    translate([0,0,-pcb_thick/2])
      cube(size=[pcb_len,pcb_width,pcb_thick], center=true);
    for (r = [0,180]) {
      rotate([0,0,r]) {
        for (i = [0:n_layers-1]) {
          assign(y=(i-(n_layers-1)/2)*h_pix/tan(pcb_angle)) {
            for (j = [0:n_leds-1]) {
if (!( (i==0||i==n_layers-1)&&(j<=1 || j >=n_leds-1) ) &&
    !( (i==1||i==n_layers-2)&&j<=0 ) )
              assign(x=sqrt((W+j*l_pix)*(W+j*l_pix)-y*y)) {
                translate([x,y/cos(pcb_angle),0])
                  led();
              }
            }
          }
        }
      }
    }
  }
}

module pcb_place() {
  translate([0,0,axis_height/2])
  {
    rotate([pcb_angle,0,0])
      pcb();
/*
    difference() {
      cylinder(r=30.1, h=28, center=true);
      cylinder(r=29.9, h=28, center=true);
    }
*/
  }
}

translate([0,0,-axis_height/2]) rotate([0,0,$t*360]) {
  axis();
  pcb_place();
}
