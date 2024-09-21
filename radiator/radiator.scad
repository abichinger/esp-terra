// Source: https://github.com/Irev-Dev/Round-Anything
use <Round-Anything/polyround.scad>

// Source: https://www.thingiverse.com/thing:2484395
use <honeycomb.scad>

Part_Selection = 0; // [0:Enclosure, 1:Cover, 2:Assembly, 3:Cut through]

/* [Enclosure] */

Length = 55;
Width = 35;
Height = 40;
Radius = 3;
Top_Radius = true;
Bottom_Radius = true;
Thickness = 2;
Inset = 4;
// between enclosure and cover, bolt diameter, nut width/height, screw head, ...
Tolerance = 0.4;
Cable_Diameter = 10;
Cable_X = 43;
Cable_Y = 14;

/* [Hot End Mount] */

Bolt_Size = 0; // [0:M3, 1:M4]
Bolt_Lenght = 30;
Bolt_Distance = 13.8;
Bolt_X = 6;
HEM_Height = 7;
HEM_Padding = 5;
Hotend_Width = 12.2;
// true: drill afterwards, false: supports required
Bridge = true;

/* [Honeycomb] */

// Options: top, front and back
HC_Faces = "top, front";
HC_Padding = 5;
HC_Diameter = 3.5;
HC_Wall = 2;

/* [Cover] */

C_Radius = 2;

/* [Hidden] */

// hotend cooler
he_l = 20;
he_h1 = 29;

// hotend heating block
he_h2 = 12;
he_w2 = 23;

// hem mount cover
hem_c_h = Height - 2 * Thickness - HEM_Height - Hotend_Width - Tolerance;

$fn = 30;
// values without tolerances
bolt_table = [
  // diameter, head diameter, head height, nut width, nut height
  [ 3, 5.5, 3, 5.4, 2.5 ], // M3
  [ 4, 7, 4, 6.9, 3.1 ]    // M4
];

_bolt = bolt_table[Bolt_Size];
_nut = [ _bolt[3], _bolt[4] ];

layer_h = 0.3;

module rcube(size, r = 0, topR = true, bottomR = true) {
  s = size;
  tr = topR == true ? r : topR == false ? 0 : topR;
  br = bottomR == true ? r : bottomR == false ? 0 : bottomR;

  radiiPoints = [
    [ 0, 0, r ],
    [ s[0], 0, r ],
    [ s[0], s[1], r ],
    [ 0, s[1], r ],
  ];

  echo(s[2], tr, br, $fn);
  polyRoundExtrude(radiiPoints, s[2], tr, br, fn = $fn);
}

// rcube([10,10,10], r=2);

module inv_honeycomb(x, y, dia, wall, r = 0) {

  radiPoints = [
    [ 0, 0, r ],
    [ x, 0, r ],
    [ x, y, r ],
    [ 0, y, r ],
  ];

  difference() {
    linear_extrude(Thickness) polygon(polyRound(radiPoints, $fn));
    linear_extrude(Thickness) honeycomb(x, y, dia, wall);
  }
}

module hc(x, y) {
  translate([ HC_Padding, HC_Padding ]) inv_honeycomb(
      x - 2 * HC_Padding, y - 2 * HC_Padding, HC_Diameter, HC_Wall, Radius);
}

module hc_back() {
  translate([ 0, Thickness, 0 ]) rotate([ 90, 0, 0 ]) hc(Length, Height);
}
module hc_front() { translate([ 0, Width - Thickness ]) hc_back(); }
module hc_bottom() { hc(Length, Width); }
module hc_top() { translate([ 0, 0, Height - Thickness ]) hc_bottom(); }

function includes(string, substring) = len(search(substring, string)) > 0;
function has_face(name) = includes(HC_Faces, name);

module insets(tol = 0) {
  items = [
    [ 0, 0, 0 ],
    [ 1, 0, 90 ],
    [ 1, 1, 180 ],
    [ 0, 1, -90 ],
  ];

  points = [
    [ 0, 0 ],
    [ Inset + tol, 0 ],
    [ 0, Inset + tol ],
  ];

  x = Length - 2 * Thickness;
  y = Width - 2 * Thickness;
  t = Thickness;

  for (i = items) {
    translate([ x * i[0], y * i[1], t ]) rotate([ 0, 0, i[2] ])
        linear_extrude(Height - 2 * t) polygon(points);
  }
}

function nut_radius(ri) = ri * 2 / sqrt(3);

module nut(width, height) {
  $fn = 6;
  r = nut_radius(width / 2);
  cylinder(d = r * 2, h = height);
}

module nut_slit(w, h, l) {
  hull() {
    nut(w, h);
    translate([ l, 0 ]) nut(w, h);
  }
}

// nut(10, 4);

module hem() {
  nw = _nut[0] + Tolerance;
  nh = _nut[1] + Tolerance;

  l = Bolt_X + HEM_Padding;
  w = Width - 2 * Thickness;
  h = HEM_Height;
  x = Bolt_X;
  y = (w - Bolt_Distance) / 2;
  z = (h - nh) / 2;
  d = _bolt[0] + Tolerance;

  difference() {
    union() { cube([ l, w, h ]); }
    union() {
      translate([ x, y, z ]) {
        nut_slit(nw, nh, HEM_Padding);
        translate([ 0, 0, -z ]) cylinder(d = d, h = h);
      }

      translate([ x, y + Bolt_Distance, z ]) {
        nut_slit(nw, nh, HEM_Padding);
        translate([ 0, 0, -z ]) cylinder(d = d, h = h);
      }
    }
  }

  if (Bridge) {

    translate([ 0, 0, z - layer_h ]) cube([ l, w, layer_h ]);
  }
}

// hem();

module shell() {
  // TODO: add cable hole

  color("blue") difference() {
    union() {
      rcube([ Length, Width, Height ], r = Radius, topR = Top_Radius,
            bottomR = Bottom_Radius);
    }
    union() {
      // honeycombs
      if (has_face("front")) {
        hc_front();
      }
      if (has_face("back")) {
        hc_back();
      }
      if (has_face("top")) {
        hc_top();
      }

      // cutout
      translate([ Thickness, Thickness ]) rcube(
          [ Length - 2 * Thickness, Width - 2 * Thickness, Height - Thickness ],
          r = C_Radius, topR = false, bottomR = false);

      // cable hole
      translate([ Cable_X, 0, Cable_Y ]) rotate([ -90, 0, 0 ])
          cylinder(d = Cable_Diameter, h = Thickness);
    }
  }

  translate([ Thickness, Thickness ]) {
    color("blue") insets();
    color("red") translate([ 0, 0, Height - Thickness - HEM_Height ]) hem();
  }
}

// shell();

module bolt(d, h, hd, hh) {
  cylinder(d = d, h = h);
  cylinder(d = hd, h = hh);
}

module _cover() {
  l = Length - 2 * Thickness - Tolerance;
  w = Width - 2 * Thickness - Tolerance;
  h = Thickness;

  hem_l = Bolt_X + HEM_Padding;
  hem_h = hem_c_h;

  // bolt
  b_d = _bolt[0] + Tolerance;
  bh_d = _bolt[1] + 2 * Tolerance;
  bh_h = Height - Tolerance - Bolt_Lenght;
  b_x = Bolt_X;
  b_y = (w - Bolt_Distance) / 2;

  assert(hem_h > 0, "The height of the enclosure must be increased");

  color("red") difference() {
    union() {
      rcube([ l, w, h ], r = C_Radius, topR = false, bottomR = false);
      translate([ 0, 0, h ]) {
        rcube([ hem_l, w, hem_h ], r = C_Radius, topR = false, bottomR = false);
      }
    }

    translate([ b_x, b_y ]) {
      bolt(b_d, h + hem_h, bh_d, bh_h);
      translate([ 0, Bolt_Distance ]) bolt(b_d, h + hem_h, bh_d, bh_h);
    }
  }
  if (Bridge) {
    translate([ 0, 0, bh_h ]) rcube([ hem_l, w, layer_h ], r = C_Radius,
                                    topR = false, bottomR = false);
  }
}

module cover() {
  x = Thickness + Tolerance / 2;
  translate([ x, x ]) difference() {
    _cover();
    insets();
  }
}

// cover();

module hotend() {
  cube([ he_l, he_w2, he_h2 ]);
  translate([ 0, 0, he_h2 ]) cube([ he_l, Hotend_Width, he_h1 ]);
}

module main() {
  p = Part_Selection;
  bolt_y = (Width - Bolt_Distance) / 2;

  if (p == 0) {
    shell();
  }
  if (p == 1) {
    cover();
  }
  if (p == 2) {
    shell();
    cover();
  }
  if (p == 3) {
    difference() {
      union() {
        shell();
        cover();
      }
      cube([ Length, bolt_y, Height ]);
    }
    translate([
      he_h1 + he_h2 + Thickness + 3, Width / 2 - he_l / 2,
      Hotend_Width + hem_c_h + Thickness + Tolerance / 2
    ]) rotate([ -90, 0, 90 ]) hotend();
  }
}

main();