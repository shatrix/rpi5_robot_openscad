// ==========================================
// Project: Boxy Cute Robot - WIDE TOP HEAD FIT + DUAL POWER
// Status: Width 200mm | Height 50mm | PB + Battery
// ==========================================

/* [Render Selection] */
render_part = "ASSEMBLY_VIEW"; // [ASSEMBLY_VIEW, PRINT_BODY_SHELL, PRINT_TOP_LID]

/* [Printing Tolerances] */
tolerance = 0.2; 

/* [Global Resolution] */
$fn = 80; 

/* [Interface Dimensions] */
bolt_spacing = 20; 
bottom_bolt_spacing = 120; 

screw_hole_dia = 3.4; 
insert_hole_dia = 4.0; 
cable_hole_dia = 16;
// EDITED: Added for bottom alignment
bottom_cable_hole_dia = 20; 

/* [Magnet Dimensions] */
magnet_dia = 6.5; 
magnet_thick = 2.2; 

/* [Body Dimensions] */
body_width_base = 150; 
body_depth_base = 151; 
body_width_top = 200; 
body_depth_top = 155;
torso_height = 50; 
wall_thickness = 1.6; 
body_corner_radius = 20;

/* [Neck Interface Dimensions] */
neck_plate_w = 150;
neck_plate_d = 100;
neck_plate_h = 7; 
neck_plate_radius = 10;
neck_slot_w = 100;
neck_slot_d = 20;

/* [Powerbank Dimensions (Left)] */
ank_w = 37.5; 
ank_d = 80; 
ank_h = 25.5;
ank_corner_rad = 3; 

/* [New Battery Dimensions (Right)] */
batt_w = 51; 
batt_d = 86; 
batt_h = 15; 
batt_corner_rad = 3;

// ==========================================
// CALCULATED VALUES
// ==========================================

lid_thickness = 4; 
split_z = torso_height - lid_thickness; 

// Calculate slopes
wall_slant_angle_x = atan((body_width_top - body_width_base) / 2 / torso_height);
wall_slant_angle_y = atan((body_depth_base - body_depth_top) / 2 / torso_height);

pb_z_center = (torso_height / 2) + 5; 
// EDITED: Increased tilt from 8 to 13 degrees
pb_extra_tilt = 13; 

// --- DUAL COMPARTMENT CENTERING ---
cw = wall_thickness;
compartment_sep = 0.3; 

// Total width of the internal voids + the shared wall + gap
total_internal_w = ank_w + cw + compartment_sep + batt_w;

// Calculate center positions relative to the back wall center (0)
// Powerbank (Left)
pos_pb_x = -(total_internal_w / 2) + (ank_w / 2);
// Battery (Right) - Shifted by gap
pos_batt_x = -(total_internal_w / 2) + ank_w + cw + compartment_sep + (batt_w / 2);


// ==========================================
// MAIN RENDER
// ==========================================

if (render_part == "ASSEMBLY_VIEW") {
    color("gold") body_shell_geometry();
    color("red") translate([0,0,split_z + 30]) top_lid_geometry();
} 
else if (render_part == "PRINT_BODY_SHELL") {
    body_shell_geometry();
} 
else if (render_part == "PRINT_TOP_LID") {
    translate([0,0,-split_z]) top_lid_geometry();
} 

// ==========================================
// GEOMETRY MODULES
// ==========================================

module body_shell_geometry() {
    difference() {
        // Cut at split line for flush top
        intersection() {
            translate([0,0, split_z/2]) cube([1000,1000, split_z], center=true);
            
            union() {
                // 1. Main Shell
                difference() {
                    hull_body_shape();
                    difference() {
                        hull_body_shape_inner(); 
                        cube([500,500,4], center=true); 
                    }
                }
                
                // 2. Corner Brackets
                intersection() {
                     corner_magnet_brackets();
                     hull_body_shape(); 
                }
                
                // 3. Arm Mounts (Auto-tilted)
                side_arm_mounts_positive();
                
                // 4. Dual Power Casing
                intersection() {
                    dual_power_casing();
                    hull_body_shape();
                }

                // 5. Bottom Reinforcement Pads
                intersection() {
                    bottom_reinforcement_pads();
                    hull_body_shape();
                }
            }
        }

        // --- DRILLS ---
        union() {
            magnet_cutouts_body();
            bottom_interface_holes(); 
            side_arm_mounts_negative();
            
            dual_power_cutout(); // Cuts both holes
        }
    }
}

module top_lid_geometry() {
    difference() {
        union() {
            // Lid Plate (Cap Style)
            intersection() {
                hull_body_shape();
                translate([0,0, split_z + lid_thickness/2]) 
                    cube([500,500, lid_thickness], center=true);
            }
            translate([0,0,split_z]) neck_plate_shape();
        }
        magnet_cutouts_lid();
        translate([0,0,split_z - 1]) neck_interface_drills();
    }
}

// ==========================================
//          DUAL POWER MODULES
// ==========================================

module dual_power_casing() {
    y_pos_wall = (body_depth_base/2) - (sin(wall_slant_angle_y) * pb_z_center);
    cw = wall_thickness; 
    
    translate([0, y_pos_wall, pb_z_center]) 
    rotate([wall_slant_angle_y + pb_extra_tilt, 0, 0]) 
    rotate([0, 0, 180]) { 
        
        // 1. Powerbank Box (Left)
        translate([pos_pb_x, (ank_d + cw)/2 - 5, 0]) { 
            difference() {
                // Outer Shell
                rounded_box(ank_w + cw*2, ank_d + cw + 10, ank_h + cw*2, ank_corner_rad + cw);
                // Inner Void
                translate([0, -cw, 10]) 
                    rounded_box(ank_w + 0.6, ank_d + 10, ank_h + 0.6 + 20, ank_corner_rad);
            }
            // Support column (aligned)
            translate([0, 0, -(ank_h + cw*2)/2 - 20])
                 rounded_box(ank_w + cw*2, ank_d + cw + 10, 40, ank_corner_rad + cw);
        }
        
        // 2. Battery Box (Right)
        translate([pos_batt_x, (batt_d + cw)/2 - 5, 0]) { 
            difference() {
                rounded_box(batt_w + cw*2, batt_d + cw + 10, batt_h + cw*2, batt_corner_rad + cw);
                // Inner Void
                translate([0, -cw, 10]) 
                    rounded_box(batt_w + 0.6, batt_d + 10, batt_h + 0.6 + 20, batt_corner_rad);
            }
            // Support column (aligned)
            translate([0, 0, -(batt_h + cw*2)/2 - 20])
                 rounded_box(batt_w + cw*2, batt_d + cw + 10, 40, batt_corner_rad + cw);
        }
    }
}

module dual_power_cutout() {
    y_pos_wall = (body_depth_base/2) - (sin(wall_slant_angle_y) * pb_z_center);
    
    translate([0, y_pos_wall, pb_z_center]) 
    rotate([wall_slant_angle_y + pb_extra_tilt, 0, 0]) 
    rotate([0, 0, 180]) 
        translate([0, 5, 0]) {
            // Powerbank Cutout (Left)
            translate([pos_pb_x, 0, 0]) {
                rounded_box(ank_w, 40, ank_h, ank_corner_rad);
                hull() {
                    translate([0, -10, 0]) rounded_box(ank_w, 0.1, ank_h, ank_corner_rad);
                    translate([0, -12, 0]) rounded_box(ank_w + 2, 0.1, ank_h + 2, ank_corner_rad);
                }
            }
            // Battery Cutout (Right)
            translate([pos_batt_x, 0, 0]) {
                rounded_box(batt_w, 40, batt_h, batt_corner_rad);
                hull() {
                    translate([0, -10, 0]) rounded_box(batt_w, 0.1, batt_h, batt_corner_rad);
                    translate([0, -12, 0]) rounded_box(batt_w + 2, 0.1, batt_h + 2, batt_corner_rad);
                }
            }
        }
}

module rounded_box(w, d, h, r) {
    hull() {
        translate([-w/2+r, -d/2, -h/2+r]) rotate([-90,0,0]) cylinder(r=r, h=d);
        translate([w/2-r, -d/2, -h/2+r]) rotate([-90,0,0]) cylinder(r=r, h=d);
        translate([w/2-r, -d/2, h/2-r]) rotate([-90,0,0]) cylinder(r=r, h=d);
        translate([-w/2+r, -d/2, h/2-r]) rotate([-90,0,0]) cylinder(r=r, h=d);
    }
}

// ==========================================
//          NECK INTERFACE
// ==========================================

module neck_plate_shape() {
    hull() {
        for (mx=[-1,1], my=[-1,1]) {
            translate([mx * (neck_plate_w/2 - neck_plate_radius), my * (neck_plate_d/2 - neck_plate_radius), 0])
            cylinder(r=neck_plate_radius, h=neck_plate_h);
        }
    }
}

module neck_interface_drills() {
    drill_h = neck_plate_h + lid_thickness + 10;
    hull() {
        translate([-neck_slot_w/2 + 10, -neck_slot_d/2 + 10, 0]) cylinder(r=10, h=drill_h);
        translate([ neck_slot_w/2 - 10, -neck_slot_d/2 + 10, 0]) cylinder(r=10, h=drill_h);
        translate([ neck_slot_w/2 - 10,  neck_slot_d/2 - 10, 0]) cylinder(r=10, h=drill_h);
        translate([-neck_slot_w/2 + 10,  neck_slot_d/2 - 10, 0]) cylinder(r=10, h=drill_h);
    }
    hx = neck_plate_w/2 - 10;
    hy = neck_plate_d/2 - 10;
    for (mx=[-1,1], my=[-1,1]) {
        translate([mx * hx, my * hy, 0]) cylinder(d=insert_hole_dia, h=drill_h);
    }
}

// ==========================================
//          MAGNETS & MOUNTS
// ==========================================

module corner_magnet_brackets() {
    x_pos = body_width_top / 2 - 14;
    y_pos = body_depth_top / 2 - 14;
    anchor_mid_drop = 12; 
    anchor_deep_drop = 22;
    for (x = [-1, 1]) for (y = [-1, 1]) {
        hull() {
            translate([x * x_pos, y * y_pos, split_z - 1]) cylinder(r = 9, h = 2, center = true); 
            translate([x * (body_width_top/2 - wall_thickness + 1), y * y_pos, split_z - anchor_mid_drop]) cube([2, 8, 0.1], center = true);
            translate([x * x_pos, y * (body_depth_top/2 - wall_thickness + 1), split_z - anchor_mid_drop]) cube([8, 2, 0.1], center = true);
            translate([x * (body_width_top/2 - 10), y * (body_depth_top/2 - 10), split_z - anchor_deep_drop]) sphere(r=2);
        }
    }
}

module magnet_cutouts_body() {
    x_pos = body_width_top / 2 - 14;
    y_pos = body_depth_top / 2 - 14;
    for (x = [-1, 1]) for (y = [-1, 1]) {
        translate([x * x_pos, y * y_pos, split_z - magnet_thick]) 
            cylinder(d = magnet_dia, h = magnet_thick + 5); 
    }
}

module magnet_cutouts_lid() {
    x_pos = body_width_top / 2 - 14;
    y_pos = body_depth_top / 2 - 14;
    for (x = [-1, 1]) for (y = [-1, 1]) {
        translate([x * x_pos, y * y_pos, split_z - 0.01]) 
            cylinder(d = magnet_dia, h = magnet_thick + 0.01); 
    }
}

// ==========================================
//          EXTERNAL ARM MODULES
// ==========================================

module side_arm_mounts_positive() {
    h_pos = torso_height / 2; 
    current_w = body_width_base + (body_width_top - body_width_base) * (h_pos / torso_height);
    stick_out = 2; 
    pos_x = current_w/2; 

    translate([pos_x, 0, h_pos]) 
        rotate([0, 90 + wall_slant_angle_x, 0]) 
        arm_boss_shape_external(stick_out, -1);
        
    translate([-pos_x, 0, h_pos]) 
        rotate([0, -90 - wall_slant_angle_x, 0]) 
        arm_boss_shape_external(stick_out, 1);
}

module arm_boss_shape_external(stick_out, dir) {
    d = 48; 
    down_vec = (dir == -1) ? 1 : -1;
    hull() {
        translate([0,0,0]) cylinder(d=d, h=0.1); 
        translate([0,0, stick_out]) cylinder(d=d, h=1); 
    }
    hull() {
        translate([d/2 * down_vec, 0, stick_out]) cube([0.1, 10, 1], center=true);
        translate([d/2 * down_vec, 0, 0]) cube([0.1, 10, 1], center=true);
        translate([(d/2 + 2) * down_vec, 0, -1]) cube([0.1, 2, 1], center=true);
    }
}

module side_arm_mounts_negative() {
    h_pos = torso_height / 2;
    current_w = body_width_base + (body_width_top - body_width_base) * (h_pos / torso_height);
    pos_x = current_w/2;
    translate([pos_x, 0, h_pos]) rotate([0, 90 + wall_slant_angle_x, 0]) arm_interface_pattern();
    translate([-pos_x, 0, h_pos]) rotate([0, -90 - wall_slant_angle_x, 0]) arm_interface_pattern();
}

module arm_interface_pattern() {
    translate([0,0,-10]) cylinder(h=50, d=cable_hole_dia);
    depth = 20; 
    off = bolt_spacing / 2;
    translate([0,0, 0]) { 
         for(mx = [-1, 1], my = [-1, 1]) {
            translate([mx*off, my*off, -10]) cylinder(h=depth, d=insert_hole_dia);
        }
    }
}

// ==========================================
//          HELPER MODULES
// ==========================================

module bottom_reinforcement_pads() {
    off = bottom_bolt_spacing / 2; 
    pad_dia = insert_hole_dia + (wall_thickness * 5); 
    pad_h = 5; 
    
    translate([0,0,0]) {
        translate([off, off, 0]) cylinder(h=pad_h, d=pad_dia);
        translate([-off, off, 0]) cylinder(h=pad_h, d=pad_dia);
        translate([-off, -off, 0]) cylinder(h=pad_h, d=pad_dia);
        translate([off, -off, 0]) cylinder(h=pad_h, d=pad_dia);
    }
}

// EDITED: Added extra aligned cable hole
module bottom_interface_holes() {
    bot_insert_depth = 12; 
    off = bottom_bolt_spacing / 2; 
    
    // Calculation:
    // Moves the hole so its bottom edge touches the line between the bottom screws.
    // y = -(spacing/2) + (hole_radius)
    cable_y_pos = -off + (bottom_cable_hole_dia / 2);

    translate([0,0,-0.1]) {
        // Original 4 holes
        translate([off, off, 0]) cylinder(h=bot_insert_depth, d=insert_hole_dia);
        translate([-off, off, 0]) cylinder(h=bot_insert_depth, d=insert_hole_dia);
        translate([-off, -off, 0]) cylinder(h=bot_insert_depth, d=insert_hole_dia);
        translate([off, -off, 0]) cylinder(h=bot_insert_depth, d=insert_hole_dia);
        
        // New cable hole
        translate([0, cable_y_pos, 0]) cylinder(h=bot_insert_depth, d=bottom_cable_hole_dia);
    }
}

module hull_body_shape() {
    hull() {
        corners(body_width_base, body_depth_base, body_corner_radius, 0);
        corners(body_width_top, body_depth_top, body_corner_radius, torso_height);
    }
}

module hull_body_shape_inner(offset_val=0) {
    w_base = body_width_base - (wall_thickness*2) + (offset_val*2);
    d_base = body_depth_base - (wall_thickness*2) + (offset_val*2);
    w_top = body_width_top - (wall_thickness*2) + (offset_val*2);
    d_top = body_depth_top - (wall_thickness*2) + (offset_val*2);
    r = body_corner_radius - wall_thickness;
    hull() {
        corners(w_base, d_base, r, wall_thickness);
        corners(w_top, d_top, r, torso_height);
    }
}

module corners(w, d, r, z) {
    translate([0,0,z]) {
        translate([w/2 - r, d/2 - r, 0]) cylinder(r=r, h=1);
        translate([-w/2 + r, d/2 - r, 0]) cylinder(r=r, h=1);
        translate([-w/2 + r, -d/2 + r, 0]) cylinder(r=r, h=1);
        translate([w/2 - r, -d/2 + r, 0]) cylinder(r=r, h=1);
    }
}
