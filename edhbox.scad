include <BOSL2/std.scad>

// Short for epsilon. It's for reducing z-fighting in the preview renderer
eps = 0.001;
card_thickness = 0.675;
card_height = 94;
card_width = 69;

magnet_diameter = 5;
magnet_thickness = 2.65;
magnet_buffer = 0.8;
magnet_back_buffer = 1;
magnet_tolerance = 0.1;
magnet_spacing = 20;

divider_thickness = 1.5;
side_wall_thickness = 4;
commander_slot_thickness = 1.2;
commander_wall_thickness = 2;
commander_frame_inset = 4;

art_frame_thickness = 2;
art_indent_depth = 2;

art_top_buffer = 1;
art_plate_tolerance = 0.2;

floor_thickness = 2;

deck_cards = 99;
token_cards = 20;

outer_corner_fillet_radius = 1;

lid_tolerance = 0.2;

// derived
back_wall_thickness = magnet_thickness + magnet_buffer;
deck_cavity_length = card_thickness * deck_cards;
token_cavity_length = card_thickness * token_cards;
commander_front_thickness = commander_wall_thickness * 2 + commander_slot_thickness;
lid_height = magnet_diameter + (magnet_buffer * 2);
lid_length = commander_front_thickness + token_cavity_length + divider_thickness + deck_cavity_length;
lid_width = card_width + side_wall_thickness - lid_tolerance;
lid_gap_width = card_width + side_wall_thickness;
cavity_depth = card_height + lid_height;
half_wall = side_wall_thickness / 2;

window_width = card_width - commander_frame_inset * 2;
window_height = card_height - commander_frame_inset * 2;

full_length = lid_length + back_wall_thickness;
full_width = side_wall_thickness * 2 + card_width;
full_height = floor_thickness + card_height + lid_height;

art_indent_length = full_length - art_frame_thickness * 2;
art_indent_height = full_height - lid_height - art_top_buffer - art_frame_thickness;
art_plate_length = art_indent_length - art_plate_tolerance;
art_plate_height = art_indent_height - art_plate_tolerance;

// Create either the lid or the lid gap by 
module lid(isLidGap = false) {
  len = isLidGap ? lid_length + eps : lid_length;
  top_height = isLidGap ? (lid_height / 2) + eps : lid_height / 2;
  width = isLidGap ? lid_gap_width : lid_width;

  cube([width - side_wall_thickness, len, top_height])
    attach(BOTTOM, TOP, overlap=eps)
      prismoid(
        [width, len],
        [width - side_wall_thickness, len],
        (lid_height / 2) + eps
      );
}

diff()
  // main body
  cuboid([full_width, full_length, full_height], anchor=BOTTOM + LEFT + FRONT, rounding=outer_corner_fillet_radius, edges="Z", $fn=32) {
    // lid cutout
    translate([0, -eps, eps])
      attach(TOP + FRONT, TOP + FRONT, inside=true)
        lid(isLidGap=true);
    // commander slot
    color("lightslategrey")
      translate([0, commander_wall_thickness, eps - lid_height])
        attach(TOP + FRONT, TOP + FRONT, inside=true)
          cube([card_width, commander_slot_thickness, card_height + eps]);
    // commander window
    translate([0, -eps, floor_thickness + commander_frame_inset])
      attach(FRONT + BOTTOM, FRONT + BOTTOM, inside=true)
        cube([window_width, commander_wall_thickness + eps * 2, window_height]);
    // deck cavity
    translate([0, -back_wall_thickness, floor_thickness])
      attach(BACK + BOTTOM, BACK + BOTTOM, inside=true)
        cube([card_width, deck_cavity_length, card_height + eps]);
    // token cavity
    translate([0, commander_front_thickness, floor_thickness])
      attach(FRONT + BOTTOM, FRONT + BOTTOM, inside=true)
        cube([card_width, token_cavity_length, card_height + eps]);
    // right art panel gap
    translate([eps, 0, art_frame_thickness])
      attach(RIGHT + BOTTOM, LEFT + BOTTOM, inside=true)
        cube([art_indent_depth + eps, art_indent_length, art_indent_height]);
    // left art panel gap
    translate([-eps, 0, art_frame_thickness])
      attach(LEFT + BOTTOM, RIGHT + BOTTOM, inside=true)
        cube([art_indent_depth + eps, art_indent_length, art_indent_height]);
  }

// lid
up(z=lid_height / 2)
  right(full_width + 10)
    lid();
// art plate tester
right(180)
  cube([art_plate_length, art_indent_height, art_frame_thickness]);
