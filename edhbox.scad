card_thickness = 0.675;
card_height = 94;
card_width = 69;

magnet_diameter = 5;
magnet_thickness = 2.65;
magnet_buffer = 0.5;

divider_thickness = 1.5;
side_wall_thickness = 2.5;
commander_slot_thickness = 1.2;
commander_wall_thickness = 2.5;
commander_frame_inset = 4;
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
lid_width = card_width+side_wall_thickness-lid_tolerance;
cavity_depth = card_height + lid_height;
half_wall = side_wall_thickness/2;

window_width = card_width - commander_frame_inset*2;
window_height = card_height - commander_frame_inset*2;




full_length = lid_length + back_wall_thickness;
full_width = side_wall_thickness * 2 + card_width;
full_height = floor_thickness + card_height + lid_height;

module lid_profile(w=lid_width, o=0) {
   polygon([
        [0,0],
        [w, 0],
        [w-half_wall, lid_height/2],
        [w-half_wall, lid_height+o],
        [half_wall, lid_height+o],
        [half_wall, lid_height/2],
    ]);
}

module filleted_cube(w,l,h,rad){
    linear_extrude(height=h)
        offset(r = rad)
            square([w,l]);
}

// box

difference() {
    // main body
    //filleted_cube(w=full_width, l=full_length, h=full_height, rad=outer_corner_fillet_radius);
    cube([full_width, full_length, full_height]);
    // lid cutout
    color("blue")
    translate([half_wall ,lid_length-1, floor_thickness + card_height])
        rotate([90,0,0])
            linear_extrude(height=lid_length+1)
                lid_profile(o=1);
    // commander slot
    translate([side_wall_thickness, commander_wall_thickness, floor_thickness])
        cube([card_width, commander_slot_thickness, card_height]);
    // token cavity
    translate([side_wall_thickness, commander_front_thickness, floor_thickness])
        cube([card_width, token_cavity_length, card_height]);
    // deck cavity
    translate([side_wall_thickness, full_length-back_wall_thickness-deck_cavity_length, floor_thickness])
        cube([card_width, deck_cavity_length, card_height]);
    // commander window
    translate([side_wall_thickness+commander_frame_inset, 0, floor_thickness+commander_frame_inset])
        cube([window_width, commander_wall_thickness, window_height]);
};


// lid
translate([full_width + 10,lid_length,0])
    rotate([90,0,0])
        linear_extrude(height=lid_length)
            lid_profile(lid_width-lid_tolerance);

