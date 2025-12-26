// ########################
// MECHA-STYLE FUTURISTIC ROBOT HEAD - SCI-FI DESIGN
//
// DESIGN FEATURES:
// - Angular faceted geometry with sharp bevels
// - Forward-swept crown for aggressive stance
// - Cheek armor plates with inward taper
// - Hexagonal vent patterns
// - Panel line details
// ---------------------------------------------------------
// PRESERVED FROM ORIGINAL:
// - All internal component dimensions and positions
// - RPi5 compartment with 60mm rail height
// - Screen, Camera, Mic, Button openings unchanged
// - Magnet positions at corners (6.5mm x 2.2mm)
// - Neck interface: 150x100mm plate
// - Split line at z=48mm for lid
// ---------------------------------------------------------

$fn = 80;

/* [Global Settings] */
render_mode = "full"; // [full, test_fit]

show_base = true;
show_lid = true; 
show_mockups = true;
embedded_magnets = false; 

/* [Dimensions] */
head_w = 190; 
head_h = 125; 
head_d = 125; 
wall = 2.0; 
split_z = 48; // Raised split line
corner_r_top = 12; 
corner_r_bot = 30; 

// Mecha Style Parameters
forward_rake = 0;       // Set to 0 for flat top (easier printing)
cheek_taper = 0.12;     // Side taper ratio (0-1)
bevel_size = 18;        // Corner bevel size at TOP (reduced to fit magnets)
bevel_size_bottom = 28; // Corner bevel size at BOTTOM (can be larger)
chin_angle = 20;        // Chin plate angle
crown_height = 0;       // Disabled for flat top printing

/* [Neck Interface Dimensions] */
neck_plate_w = 150;
neck_plate_d = 100;
neck_slot_w = 100;
neck_slot_d = 20;
insert_hole_dia = 3.4; // M3 screw clearance

/* [Hardware Dimensions] */
disp_pcb_w = 85.5; 
disp_pcb_h = 55.6;
disp_pcb_thick = 7.0;

// RPi
rpi_w = 58;           
rpi_thick = 30;       
rpi_h_actual = 89;    
rpi_lift = 0; 

// Dual Speakers
dual_spk_l = 50; 
dual_spk_w = 33.6; 
dual_spk_d = 17.8; 

// Camera Settings
cam_slot_w = 25.4; 
cam_slot_h = 25.4; 
cam_lens_d = 11.4; 
cam_depth = 14; 

// Microphone Settings
mic_d = 9.5; 
mic_holder_wall = 1.0; 

// Push Button Dimensions
pb_main_dia = 14.5; 
pb_nut_dia = 11.3;  
pb_hole_depth = 10.0;

// --- VERTICAL STACK CALCULATIONS ---
floor_z = -head_h/2 + wall;

// Magnet Settings
lip_h = 4; lip_thick = 1.2; lip_inset = 0.8; lip_tol = 0.4;
mag_diam = 6.5; mag_height = 2.2; mag_cover_thick = 0.6;

// --- EXTRA SUPPORT BLOCK ---
enable_support_block = true;
supp_w = 17.5; 
supp_d = 33; 
supp_h = 10.6;
supp_x_offset = ((rpi_w + 12)/2) - (supp_w/2); 

// --- RPi POSITIONING ---
back_inner_wall_global = -head_d/2 + wall;
holder_depth_global = rpi_thick + 10; 
rpi_center_y_global = back_inner_wall_global + holder_depth_global/2;

// --- FRONT FACE STACK ---

// 1. MIC POS (Touching Floor)
mic_holder_radius = (mic_d/2) + mic_holder_wall;
mic_z_pos = floor_z + mic_holder_radius; 

// 2. CAMERA POS (Raised)
mic_top_edge = mic_z_pos + mic_holder_radius;
cam_holder_height = cam_slot_h + 4 + 2; 
cam_holder_half_h = cam_holder_height / 2;
min_gap = 6.0; 
cam_z_pos = mic_top_edge + min_gap + cam_holder_half_h; 

// 3. SCREEN POS
screen_center_z = cam_z_pos + cam_slot_h/2 + 4 + disp_pcb_h/2;


// ==========================================
//          MECHA HULL MODULES
// ==========================================

// Angular octagonal profile with beveled corners
module mecha_profile_2d(w, d, bevel) {
    polygon([
        [-w/2 + bevel, -d/2],
        [w/2 - bevel,  -d/2],
        [w/2,          -d/2 + bevel],
        [w/2,           d/2 - bevel],
        [w/2 - bevel,   d/2],
        [-w/2 + bevel,  d/2],
        [-w/2,          d/2 - bevel],
        [-w/2,         -d/2 + bevel]
    ]);
}

// Main mecha outer hull with angular geometry and flat top for printing
module mecha_hull_outer(w, d, h, bevel) {
    // Calculate dimensions at different heights
    bottom_w = w;
    bottom_d = d;
    mid_w = w - 4;
    top_w = w - (w * cheek_taper);
    top_d = d - 2;
    
    hull() {
        // Bottom octagon (using bevel_size_bottom for larger angular corners)
        translate([0, 0, -h/2])
        linear_extrude(0.01)
        mecha_profile_2d(bottom_w, bottom_d, bevel_size_bottom);
        
        // Lower mid section (transition from bottom to top bevel)
        translate([0, 0, -h/4])
        linear_extrude(0.01)
        mecha_profile_2d(mid_w, d, (bevel + bevel_size_bottom) / 2);
        
        // Upper mid section (slight inward taper)
        translate([0, 0, h/4])
        linear_extrude(0.01)
        mecha_profile_2d(mid_w - 2, d, bevel - 2);
        
        // Top section - FLAT for printing upside down
        translate([0, 0, h/2])
        linear_extrude(0.01)
        mecha_profile_2d(top_w, top_d, bevel - 5);
    }
}

// Inner void matching mecha hull
module mecha_hull_inner(w, d, h, bevel) {
    wall_t = wall;
    mecha_hull_outer(w - 2*wall_t, d - 2*wall_t, h - 2*wall_t, bevel - wall_t);
}

// Crown ridge on top (DISABLED for flat top printing)
// To enable, set crown_height > 0
module crown_ridge() {
    if (crown_height > 0) {
        ridge_w = head_w * 0.4;
        ridge_d = head_d * 0.6;
        ridge_h = crown_height;
        
        translate([0, 0, head_h/2 - 2]) {
            hull() {
                translate([0, 0, 0])
                linear_extrude(0.01)
                mecha_profile_2d(ridge_w, ridge_d, 8);
                
                translate([0, 2, ridge_h])
                linear_extrude(0.01)
                mecha_profile_2d(ridge_w - 10, ridge_d - 15, 5);
            }
        }
    }
}

// Panel line grooves for tech detail
// Designed for printing without support
module panel_line_grooves() {
    groove_depth = 0.8;
    groove_width = 1.2;
    
    // Vertical accent lines on front - ONLY around camera/mic area
    cam_line_z_min = floor_z;
    cam_line_z_max = cam_z_pos + 20;
    cam_line_height = cam_line_z_max - cam_line_z_min;
    cam_line_center_z = (cam_line_z_min + cam_line_z_max) / 2;
    
    for (x_off = [-30, 30]) {  // Increased from ±20 to ±30mm spacing
        translate([x_off, head_d/2 + 1, cam_line_center_z])
        rotate([90, 0, 0])
        linear_extrude(5)
        square([groove_width, cam_line_height], center=true);
    }
}

// Hexagonal vent pattern for top (centered for flat top)
module hex_vent_pattern_top() {
    hex_size = 8;      // Increased from 6mm to 8mm
    hex_spacing = 10;  // Increased spacing for larger holes
    
    translate([0, 0, head_h/2])
    for (ix = [0 : 6]) {                           // 7 columns
        x = (ix - 3) * hex_spacing * 1.5;          // Centered: -45, -30, -15, 0, 15, 30, 45
        for (iy = [0 : 4]) {                       // 5 rows
            y = (iy - 2) * hex_spacing * 1.73;     // Centered: -34.6, -17.3, 0, 17.3, 34.6
            y_offset = (ix % 2) * (hex_spacing * 0.866);  // Stagger every other column
            translate([x, y + y_offset, 0])
            cylinder(d=hex_size, h=20, $fn=6, center=true);
        }
    }
}

// Hexagonal vent pattern for sides - LARGER for better speaker sound
module hex_vent_pattern_sides() {
    hex_size = 8;      // Increased from 5mm to 8mm
    hex_spacing = 10;  // Increased spacing for larger holes
    
    // Z position: shifted down to align with speakers at floor_z
    // Speakers are at floor_z + rail_h/2 ≈ -35mm from center
    vent_z_center = -25;  // Shifted down from -5 to align with speakers
    
    for (side = [-1, 1]) {
        translate([side * (head_w/2), 0, vent_z_center])
        rotate([0, 90, 0])
        for (y = [-12 : hex_spacing * 1.73 : 12]) {
            for (z = [-18 : hex_spacing * 1.5 : 18]) {
                z_offset = (floor((y + 12) / (hex_spacing * 1.73)) % 2) * (hex_spacing * 0.75);
                translate([z + z_offset, y, 0])
                cylinder(d=hex_size, h=20, $fn=6, center=true);
            }
        }
    }
}

// Cheek armor accent plates - DISABLED to prevent interference with speaker rails
// Uncomment to re-enable if you want decorative side plates
/*
module cheek_armor_plates() {
    plate_w = 25;
    plate_h = 40;
    plate_d = 3;
    
    for (side = [-1, 1]) {
        translate([side * (head_w/2 - 8), 15, 5])
        rotate([5, side * -15, 0])
        difference() {
            hull() {
                cube([plate_d, plate_w, plate_h], center=true);
                translate([side * 2, 0, plate_h/2 - 5])
                cube([plate_d - 1, plate_w - 10, 0.1], center=true);
            }
            // Inner cut for detail
            translate([side * -1, 0, -5])
            cube([plate_d + 2, plate_w - 8, plate_h - 15], center=true);
        }
    }
}
*/

// Temple cuts - DISABLED for printability (creates overhangs needing support)
// Uncomment if you want temple cuts and are willing to use support
/*
module temple_cuts() {
    cut_w = 30;
    cut_h = 20;
    cut_d = 8;
    
    for (side = [-1, 1]) {
        translate([side * (head_w/2 - 5), -20, head_h/2 - 25])
        rotate([20, side * 25, 0])
        cube([cut_d, cut_w, cut_h], center=true);
    }
}
*/


// ==========================================
//         ORIGINAL HELPER MODULES
// ==========================================

module wedge_box(w, d, h) {
    difference() {
        hull() {
            cube([w, d, h], center=true);
            translate([0, 0, -h/2 - (w/2)]) 
                cube([0.1, d, 0.1], center=true);
        }
        hull() {
            cube([w - 2.4, d - 2.4, h], center=true);
            translate([0, 0, -h/2 - (w/2) + 1.2]) 
                cube([0.1, d - 2.4, 0.1], center=true);
        }
    }
}

module flat_rounded_box(dim, r) {
    translate([0,0, -dim.z/2])
    linear_extrude(dim.z)
    offset(r=r)
    square([dim.x - 2*r, dim.y - 2*r], center=true);
}


// ==========================================
//          MAGNETS & MOUNTS (ORIGINAL DESIGN - prints without support)
// ==========================================

module corner_magnet_brackets() {
    x_pos = head_w / 2 - 14;  // Original position
    y_pos = head_d / 2 - 14;
    anchor_mid_drop = 12; 
    anchor_deep_drop = 22;

    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            hull() {
                // 1. Top Platform (Solid Cylinder to hold magnet) - round for printability
                translate([x * x_pos, y * y_pos, split_z - 1]) 
                    cylinder(r = 9, h = 2, center = true); 

                // 2. Wall Anchors (Mid-way down connection to walls)
                translate([x * (head_w/2 - wall + 1), y * y_pos, split_z - anchor_mid_drop]) 
                    cube([2, 8, 0.1], center = true);
                translate([x * x_pos, y * (head_d/2 - wall + 1), split_z - anchor_mid_drop]) 
                    cube([8, 2, 0.1], center = true);

                // 3. Bottom Taper (Deep structural root)
                translate([x * (head_w/2 - wall - 2), y * (head_d/2 - wall - 2), split_z - anchor_deep_drop]) 
                    sphere(r=2);
            }
        }
    }
}

module magnet_cutouts_base() {
    x_pos = head_w / 2 - 14;  // Original position
    y_pos = head_d / 2 - 14;
    z_offset = embedded_magnets ? split_z - mag_cover_thick - mag_height/2 : split_z - mag_height/2 + 0.01;
    for (x = [-1, 1]) for (y = [-1, 1]) 
        translate([x * x_pos, y * y_pos, z_offset]) 
        cylinder(d = mag_diam, h = mag_height + 0.02, center = true);
}

module magnet_posts_lid_solid() {
    x_pos = head_w / 2 - 14;  // Original position
    y_pos = head_d / 2 - 14;
    for (x = [-1, 1]) for (y = [-1, 1]) 
        translate([x * x_pos, y * y_pos, split_z + 15]) 
        cylinder(r = 9, h = 30, center = true);  // Round for printability
}

module magnet_holes_lid() {
    x_pos = head_w / 2 - 14;  // Original position
    y_pos = head_d / 2 - 14;
    z_offset = embedded_magnets ? split_z + mag_cover_thick + mag_height/2 : split_z + mag_height/2 - 0.01;
    for (x = [-1, 1]) for (y = [-1, 1]) 
        translate([x * x_pos, y * y_pos, z_offset]) 
        cylinder(d = mag_diam, h = mag_height + 0.02, center = true);
}

// Neck Interface Drills (UNCHANGED)
module neck_mount_holes() {
    drill_h = 50; 
    translate([0, 0, -head_h/2]) { 
        hull() {
            translate([-neck_slot_w/2 + 10, -neck_slot_d/2 + 10, 0]) cylinder(r=10, h=drill_h, center=true);
            translate([ neck_slot_w/2 - 10, -neck_slot_d/2 + 10, 0]) cylinder(r=10, h=drill_h, center=true);
            translate([ neck_slot_w/2 - 10,  neck_slot_d/2 - 10, 0]) cylinder(r=10, h=drill_h, center=true);
            translate([-neck_slot_w/2 + 10,  neck_slot_d/2 - 10, 0]) cylinder(r=10, h=drill_h, center=true);
        }
        hx = neck_plate_w/2 - 10;
        hy = neck_plate_d/2 - 10;
        for (mx=[-1,1], my=[-1,1]) {
            translate([mx * hx, my * hy, 0]) cylinder(d=insert_hole_dia, h=drill_h, center=true);
        }
    }
}

// Neck Interface Reinforcement Pads (UNCHANGED)
module neck_mounting_pads() {
    hx = neck_plate_w/2 - 10;
    hy = neck_plate_d/2 - 10;
    pad_h = 4.0;
    pad_d = 12.0;
    
    z_pos = floor_z + pad_h/2; 
    
    for (mx=[-1,1], my=[-1,1]) {
        translate([mx * hx, my * hy, z_pos]) 
            cylinder(d=pad_d, h=pad_h, center=true);
    }
}


// ==========================================
//         INTERNALS (UNCHANGED)
// ==========================================

module internal_rails() {
    rail_depth = 12; 
    front_inner_wall = head_d/2 - wall;
    rail_center_y = front_inner_wall - rail_depth/2; 
    screen_global_y = head_d/2 - wall*2; 
    offset_y = screen_global_y - rail_center_y; 
    screen_bottom = screen_center_z - disp_pcb_h/2;
    rail_bottom_z = floor_z; 
    rail_top_z = split_z;
    rail_height = rail_top_z - rail_bottom_z;
    rail_center_z = rail_bottom_z + rail_height/2;
    rail_x_pos = (disp_pcb_w + 0.5) / 2 - 0.5;

    translate([0, rail_center_y, 0]) {
        for(side = [-1, 1]) translate([side * rail_x_pos, 0, rail_center_z]) difference() {
            wedge_box(10, rail_depth, rail_height);
            slot_height = (rail_top_z - screen_bottom) + 10;
            slot_center_z_global = screen_bottom + slot_height/2;
            translate([-side * 2.5, offset_y, slot_center_z_global - rail_center_z]) 
                cube([6, disp_pcb_thick + 1.0, slot_height], center=true);
        }
    }
    
    rpi_mount_height = 60; 
    holder_z_pos = floor_z + rpi_lift + rpi_mount_height/2; 
    outer_w = rpi_w + 12;
    
    translate([0, rpi_center_y_global, holder_z_pos]) {
        difference() {
            union() {
                translate([-(outer_w/2 - 6), 0, 0]) cube([12, holder_depth_global, rpi_mount_height], center=true);
                translate([(outer_w/2 - 6), 0, 0]) cube([12, holder_depth_global, rpi_mount_height], center=true);
                translate([0, 0, -rpi_mount_height/2 + 2.5]) cube([outer_w, holder_depth_global, 5], center=true);
                translate([0, 0, rpi_mount_height/2 - 2.5]) cube([outer_w, holder_depth_global, 5], center=true);
            }
            translate([0, 0, 5]) cube([rpi_w + 0.6, rpi_thick + 0.6, rpi_mount_height + 10], center=true);
            translate([0, -10, 0]) cube([rpi_w - 23, 20, rpi_mount_height + 2], center=true);
            translate([0, 10, 0]) cube([rpi_w - 23, 20, rpi_mount_height + 2], center=true);
            translate([0,3, 5]) cube([rpi_w + 20, 20, rpi_mount_height + 10], center=true);
            translate([-25, 15, rpi_mount_height/2]) cube([25, 20, 70], center=true); 
        }
    }
    
    if (enable_support_block) {
        block_z = floor_z + supp_h/2;
        translate([supp_x_offset, rpi_center_y_global, block_z]) 
            cube([supp_w, supp_d, supp_h], center=true);
    }
}

module side_speaker_rails() {
    rail_z_base = floor_z;
    w = dual_spk_w; d = dual_spk_d; l = dual_spk_l; rail_h = l + 5; rail_wall = 2; lip_width = 4; 
    for (side = [-1, 1]) {
        holder_x = (head_w/2 - wall) - (d/2);
        holder_center = [side * holder_x, 0, rail_z_base + rail_h/2];
        translate(holder_center) {
            difference() {
                outer_w = w + 2 * rail_wall;
                outer_d = d + rail_wall;
                block_center_x = -side * rail_wall / 2;
                translate([block_center_x, 0, 0]) cube([outer_d, outer_w, rail_h], center=true);
                hull() {
                    translate([0, 0, 5]) cube([d, w, rail_h + 10], center=true);
                     translate([0, 0, 5 + (rail_h + 10)/2]) cube([d, w - 10, 0.1], center=true);
                }
                cutout_w = w - 2 * lip_width; 
                translate([-side * d/2, 0, 7.5]) cube([rail_wall*2 + 2, cutout_w, rail_h + 5], center=true); 
            }
            translate([0, 0, -rail_h/2 + 1]) cube([d, w + 2*rail_wall, 2], center=true);
        }
    }
}

module camera_holder() {
    holder_depth = cam_depth; slot_depth = 2; 
    translate([0, head_d/2 - wall, cam_z_pos]) {
        difference() {
            translate([0, -holder_depth/2 + 0.1, -cam_slot_h/2 + cam_slot_h/2 - 1]) cube([cam_slot_w + 6, holder_depth, cam_slot_h + 4 + 2], center=true);
            translate([0, -holder_depth/2 + 0.1 + slot_depth, 3]) cube([cam_slot_w, holder_depth, cam_slot_h + 10], center=true);
            rotate([90,0,0]) cylinder(d=cam_lens_d+2, h=20, center=true);
        }
    }
}

// Mic Holder (UNCHANGED)
module microphone_holder() {
    holder_len = 2; 
    y_pos = (head_d/2 - wall) - holder_len/2; 
    translate([0, y_pos, mic_z_pos]) {
        rotate([90, 0, 0]) difference() {
            cylinder(d = mic_d + 4, h = holder_len, center=true); 
            cylinder(d = mic_d, h = holder_len + 2, center=true);
        }
    }
}

module back_cable_hole() {
    hole_x = 45; hole_z = 30; hole_w = 14; hole_h = 24; 
    translate([hole_x, -head_d/2, hole_z]) rotate([90, 0, 0]) hull() {
        translate([0, -(hole_h/2 - hole_w/2), 0]) cylinder(d=hole_w, h=20, center=true);
        translate([0, hole_h/2, 0]) cube([0.1, 0.1, 20], center=true);
    }
}


// ==========================================
//              MAIN ASSEMBLY
// ==========================================

module base_unit() {
    difference() {
        union() {
            // Main mecha hull
            color("SlateGray") difference() {
                intersection() {
                    mecha_hull_outer(head_w, head_d, head_h, bevel_size);
                    translate([0, 0, -250 + split_z]) cube([500, 500, 500], center = true);
                }
                mecha_hull_inner(head_w, head_d, head_h, bevel_size);
            }
            
            // Cheek armor accents - DISABLED (was causing artifacts with speakers)
            // To re-enable, uncomment cheek_armor_plates() module and this block
            /*
            color("DimGray") intersection() {
                cheek_armor_plates();
                mecha_hull_outer(head_w + 10, head_d + 10, head_h, bevel_size);
                translate([0, 0, -250 + split_z]) cube([500, 500, 500], center = true);
            }
            */
            
            // Magnet brackets
            color("SlateGray") intersection() {
                corner_magnet_brackets();
                intersection() {
                    mecha_hull_outer(head_w, head_d, head_h, bevel_size);
                    translate([0, 0, -250 + split_z]) cube([500, 500, 500], center = true);
                }
            }
            
            // Internal components (unchanged)
            color("ForestGreen") internal_rails();
            color("#333333") camera_holder();
            color("DarkOrange") side_speaker_rails();  // Removed intersection to fix artifacts
            color("FireBrick") microphone_holder();
            color("Silver") neck_mounting_pads();
        }

        // Cutouts
        magnet_cutouts_base();
        back_cable_hole(); 
        panel_line_grooves();
        // temple_cuts();  // DISABLED - module commented out for printability
        
        // Screen cutout
        screen_cutout_bottom = screen_center_z - 25;
        screen_cutout_top = split_z + 10; 
        screen_cutout_h = screen_cutout_top - screen_cutout_bottom;
        screen_cutout_z = screen_cutout_bottom + screen_cutout_h / 2;
        translate([0, head_d / 2 - wall * 2, screen_cutout_z]) 
            cube([75, 20, screen_cutout_h], center = true);
        
        // Camera cutout (hexagonal for mecha look)
        translate([0, head_d / 2 - wall + 1, cam_z_pos]) 
            rotate([90,0,0]) 
            cylinder(d=cam_lens_d + 4, h=10, center=true, $fn=6);
        
        // Mic cutout
        translate([0, head_d / 2 - wall + 1, mic_z_pos]) 
            rotate([90,0,0]) 
            cylinder(d=mic_d, h=20, center=true);

        // Side vents (hex pattern)
        hex_vent_pattern_sides();
        
        // Neck mount
        neck_mount_holes();
        translate([0,0, -head_h/2 - 50]) cube([500,500,100], center=true);
        
        // Push Button Holes (Angular/Hex for mecha style)
        for(side_x = [-1, 1]) {
            for(i = [0:2]) {
                z_btn = screen_center_z - 10 - (i * 18); 
                translate([side_x * 60, head_d/2, z_btn]) 
                    rotate([90, 0, 0]) 
                    cylinder(d=pb_main_dia, h=20, center=true, $fn=6);
            }
        }
    }
}

module lid_unit() {
    // Flat top lid for easy printing upside down (no support needed)
    translate([0, 0, 10]) difference() {
        color("DarkSlateGray") union() {
            // Main lid hull - flat top
            difference() {
                intersection() {
                    mecha_hull_outer(head_w, head_d, head_h, bevel_size);
                    translate([0, 0, 250 + split_z]) cube([500, 500, 500], center = true);
                }
                mecha_hull_inner(head_w, head_d, head_h, bevel_size);
            }
            
            // Magnet posts
            intersection() {
                magnet_posts_lid_solid();
                mecha_hull_outer(head_w, head_d, head_h, bevel_size);
                translate([0, 0, 250 + split_z]) cube([500, 500, 500], center = true);
            }
        }
        
        // Top vents (hex pattern)  
        hex_vent_pattern_top();
        magnet_holes_lid();
        panel_line_grooves();
    }
}

// ==========================================
//              RENDER
// ==========================================

if (render_mode == "full") {
    if (show_base) base_unit();
    if (show_lid) lid_unit();
    if (show_mockups) {
        % translate([0, head_d / 2 - 14, screen_center_z]) 
            cube([disp_pcb_w, disp_pcb_thick, disp_pcb_h], center = true);
        % translate([0, rpi_center_y_global, floor_z + rpi_lift + rpi_h_actual/2]) 
            cube([rpi_w, rpi_thick, rpi_h_actual], center = true);
    }
} else if (render_mode == "test_fit") {
    intersection() {
        if (show_base) base_unit();
        translate([0, 0, -head_h/2 + 20]) cube([head_w+20, head_d+50, 40], center=true);
    }
}
