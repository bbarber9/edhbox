include <BOSL2/std.scad>

/* [Objects] */
// Generate the main deckbox body?
Main_Body = true;
// Generate the lid?
Lid = true;
// Generate the art plate tester (has dimensions printed on)?
Art_Plate_Tester = true;
// Add art slots to the main body?
Art_Plate_Slots = true;
// Add the token compartment to the main body?
Include_Tokens = true;

/* [Card Count] */
// Number of cards in the main deck compartment
Deck_Cards = 99;
// Number of cards in the token compartment
Token_Cards = 20;

/* [Card Dimensions] */
// Thickness of each card, default should fit double-sleeved cards
Card_Thickness = 0.675;
// Width of a card, defaults to width of a sleeved card
Card_Height = 88;
// Height of a card, defaults to the height of a sleeved card
Card_Width = 63;

/* [Hidden] */

// Short for epsilon. It's for reducing z-fighting in the preview renderer
eps = 0.001;

// Rounds a number to a specified number of decimal points
function round_to(value, decimals = 0) =
  let (multiplier = pow(10, decimals)) round(value * multiplier) / multiplier;

part_gap = 10;

card_size_buf = 6;
card_height_with_buf = Card_Height + card_size_buf;
card_width_with_buf = Card_Width + card_size_buf;
magnet_diameter = 5;
magnet_thickness = 2.65;
magnet_buffer = 0.8;
magnet_back_buffer = 1;
magnet_tolerance = 0.1;
magnet_spacing = 20;
magnet_slot_d = magnet_diameter + magnet_tolerance;
// calculates the space between the edge of the magnet slot and the vertex of the hexagon
magnet_space_to_vertex = (magnet_slot_d / 2) * ( (1 / cos(30)) - 1);
magnet_vertical_inset = magnet_buffer + magnet_space_to_vertex;

divider_thickness = 1.5;
side_wall_thickness = 4;
commander_slot_thickness = 1.2;
commander_wall_thickness = 2;
commander_frame_inset = 4;

art_frame_thickness = 2;
art_indent_depth = 2;

art_top_buffer = 1;
art_plate_tolerance_h = 0.6;
art_plate_tolerance_v = 0.8;

floor_thickness = 2;

lid_tolerance = 0.4;
lid_grip_from_front = 6;
lid_grip_width = 8;
lid_grip_depth = 4;

outer_corner_fillet_radius = 1.5;
lid_edge_fillet_radius = 1.5;

// derived
back_wall_thickness = magnet_thickness + magnet_back_buffer;
deck_cavity_length = Card_Thickness * Deck_Cards;
token_cavity_length = Card_Thickness * Token_Cards;
token_section_length = Include_Tokens ? token_cavity_length + divider_thickness : 0;
commander_front_thickness = commander_wall_thickness * 2 + commander_slot_thickness;
lid_height = magnet_slot_d + (magnet_buffer * 2) + (magnet_space_to_vertex * 2);
lid_length = commander_front_thickness + token_section_length + deck_cavity_length;
lid_width = card_width_with_buf + side_wall_thickness - lid_tolerance;
lid_gap_width = card_width_with_buf + side_wall_thickness;
cavity_depth = card_height_with_buf + lid_height;
half_wall = side_wall_thickness / 2;

window_width = card_width_with_buf - commander_frame_inset * 2;
window_height = card_height_with_buf - commander_frame_inset * 2;

full_length = lid_length + back_wall_thickness;
full_width = side_wall_thickness * 2 + card_width_with_buf;
full_height = floor_thickness + card_height_with_buf + lid_height;

art_indent_length = full_length - art_frame_thickness * 2;
art_indent_height = full_height - lid_height - art_top_buffer - art_frame_thickness;
// Adding minumal rounding to these dimensions since it makes it easier to size images in hueforge
art_plate_length = round_to(art_indent_length - art_plate_tolerance_h, 2);
art_plate_height = round_to(art_indent_height - art_plate_tolerance_v, 2);

module magnet_slots() {
  xcopies(magnet_spacing, n=3)
    ycyl(l=magnet_thickness + eps, d=magnet_slot_d, circum=true, $fn=6);
}

// Create either the lid or the lid gap by 
module Lid(isLidGap = false) {
  len = isLidGap ? lid_length + eps : lid_length;
  top_height = isLidGap ? (lid_height / 2) + eps : lid_height / 2;
  width = isLidGap ? lid_gap_width : lid_width;

  module lid_body() {
    // The lid gap stays square for clearance, but the printed lid gets a rounded
    // top-front edge. This wrapper passes its children through so the lower
    // prismoid remains attached to whichever top shape is used.
    module lid_top() {
      if (isLidGap)
        cube([width - side_wall_thickness, len, top_height])
          children();
      else
        cuboid([width - side_wall_thickness, len, top_height], anchor=BOTTOM + LEFT + FRONT, rounding=lid_edge_fillet_radius, edges=TOP + FRONT, $fn=32)
          children();
    }

    lid_top() {
      attach(BOTTOM, TOP, overlap=eps)
        prismoid(
          [width, len],
          [width - side_wall_thickness, len],
          (lid_height / 2) + eps
        );
      children();
    }
  }

  if (isLidGap)
    lid_body();
  else
    diff()
      lid_body() {
        back(eps)
          attach(BACK, BACK, inside=true, align=TOP, inset=magnet_vertical_inset)
            magnet_slots();
        // grip cutout
        translate([0, lid_grip_from_front, eps])
          attach(TOP, BOTTOM, align=FRONT, inside=true)
            prismoid(size1=[lid_width, lid_grip_width], size2=[lid_width, 0], h=lid_grip_depth);
      }
}

// main body
if (Main_Body) {
  diff()
    // main body
    cuboid([full_width, full_length, full_height], anchor=BOTTOM + LEFT + FRONT, rounding=outer_corner_fillet_radius, edges=[TOP, "Z"], $fn=32) {
      // lid cutout
      translate([0, -eps, eps])
        attach(TOP + FRONT, TOP + FRONT, inside=true)
          Lid(isLidGap=true);
      // commander slot
      color("lightslategrey")
        translate([0, commander_wall_thickness, eps - lid_height])
          attach(TOP + FRONT, TOP + FRONT, inside=true)
            cube([card_width_with_buf, commander_slot_thickness, card_height_with_buf + eps]);
      // commander window
      translate([0, -eps, floor_thickness + commander_frame_inset])
        attach(FRONT + BOTTOM, FRONT + BOTTOM, inside=true)
          cube([window_width, commander_wall_thickness + eps * 2, window_height]);
      // deck cavity
      translate([0, -back_wall_thickness, floor_thickness])
        attach(BACK + BOTTOM, BACK + BOTTOM, inside=true)
          cube([card_width_with_buf, deck_cavity_length, card_height_with_buf + eps]);
      // token cavity
      if (Include_Tokens)
        translate([0, commander_front_thickness, floor_thickness])
          attach(FRONT + BOTTOM, FRONT + BOTTOM, inside=true)
            cube([card_width_with_buf, token_cavity_length, card_height_with_buf + eps]);
      if (Art_Plate_Slots) {
        // right art panel gap
        translate([eps, 0, art_frame_thickness])
          attach(RIGHT + BOTTOM, LEFT + BOTTOM, inside=true)
            cube([art_indent_depth + eps, art_indent_length, art_indent_height]);
        // left art panel gap
        translate([-eps, 0, art_frame_thickness])
          attach(LEFT + BOTTOM, RIGHT + BOTTOM, inside=true)
            cube([art_indent_depth + eps, art_indent_length, art_indent_height]);
      }

      // hexagonal magnet slots
      fwd(magnet_back_buffer + eps)
        attach(BACK, BACK, inside=true, align=TOP, inset=magnet_vertical_inset)
          magnet_slots();
    }
}

// lid
if (Lid) {
  up(z=lid_height / 2)
    right(full_width + part_gap)
      Lid();
}

// art plate tester
if (Art_Plate_Tester) {
  right(full_width + lid_width + part_gap * 2)
    cube([art_plate_length, art_plate_height, art_indent_depth])
      // text that shows how large the plate is
      position(TOP)
        color("red") {
          text(str("len:", art_plate_length, "mm"), 6, halign="center");
          fwd(10)
            text(str("ht:", art_plate_height, "mm"), 6, halign="center");
        }
}
