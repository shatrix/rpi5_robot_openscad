// ==========================================
// Project: MECHA-STYLE ROBOT BODY - Angular Sci-Fi Design
// Status: Width 150mm→200mm | Height 50mm | PB + Battery
// Based on: robot-body-rpi.scad
// ==========================================
//
// DESIGN FEATURES:
// - Angular octagonal hull with beveled corners
// - Trapezoid profile preserved (wider at top)
// - Support-free printing optimizations
// ---------------------------------------------------------
// PRESERVED FROM ORIGINAL:
// - Dual power compartments (powerbank + battery)
// - Arm mounts on both sides
// - Neck interface plate
// - Magnet positions at corners
// - Bottom interface bolt pattern
// ---------------------------------------------------------

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
bottom_cable_hole_dia = 20; 

/* [Magnet Dimensions] */
magnet_dia = 6.5; 
magnet_thick = 2.2; 

/* [Body Dimensions] */
body_width_base = 150; 
body_depth_base = 151; 
body_width_top = 190; 
body_depth_top = 155;
torso_height = 60;      // Increased from 50mm
wall_thickness = 1.6; 

// Mecha Style Parameters (matching head design)
bevel_size = 16;        // Corner bevel size at TOP
bevel_size_bottom = 24; // Corner bevel size at BOTTOM

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
pb_extra_tilt = 13; 

// --- DUAL COMPARTMENT CENTERING ---
cw = wall_thickness;
compartment_sep = 0.3; 

total_internal_w = ank_w + cw + compartment_sep + batt_w;

pos_pb_x = -(total_internal_w / 2) + (ank_w / 2);
pos_batt_x = -(total_internal_w / 2) + ank_w + cw + compartment_sep + (batt_w / 2);


// ==========================================
// TEARDROP SHAPE (Support-Free Printing)
// ==========================================

// Teardrop 2D profile - point facing UP for no overhangs
module teardrop_2d(d) {
    r = d / 2;
    union() {
        circle(r=r, $fn=32);
        rotate([0, 0, 45])
        square([r, r], center=false);
    }
}

// 3D teardrop hole for horizontal drilling
module teardrop_hole(d, h) {
    linear_extrude(h, center=true)
    teardrop_2d(d);
}

// ==========================================
// MECHA HULL MODULES
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

// Main mecha outer hull - trapezoid with angular corners
module mecha_hull_outer() {
    hull() {
        // Bottom section (smaller, with bottom bevel)
        translate([0, 0, 0])
        linear_extrude(0.01)
        mecha_profile_2d(body_width_base, body_depth_base, bevel_size_bottom);
        
        // Top section (larger, with top bevel)
        translate([0, 0, torso_height])
        linear_extrude(0.01)
        mecha_profile_2d(body_width_top, body_depth_top, bevel_size);
    }
}

// Inner void matching mecha hull
module mecha_hull_inner() {
    w_base = body_width_base - wall_thickness * 2;
    d_base = body_depth_base - wall_thickness * 2;
    w_top = body_width_top - wall_thickness * 2;
    d_top = body_depth_top - wall_thickness * 2;
    bevel_inner = max(bevel_size - wall_thickness, 2);
    bevel_inner_bottom = max(bevel_size_bottom - wall_thickness, 2);
    
    hull() {
        translate([0, 0, wall_thickness])
        linear_extrude(0.01)
        mecha_profile_2d(w_base, d_base, bevel_inner_bottom);
        
        translate([0, 0, torso_height])
        linear_extrude(0.01)
        mecha_profile_2d(w_top, d_top, bevel_inner);
    }
}

// Front chest vent panel - TEARDROP vents for support-free printing
// Pyramid pattern: 7 bottom, 6 middle, 5 top (matches body trapezoid)
module front_chest_vents() {
    vent_size = 7;
    vent_spacing = 12;
    
    // Position on front face, centered
    y_pos = -body_depth_top/2 - 1;  // Front face (negative Y)
    z_center = torso_height / 2 + 5;
    
    translate([0, y_pos, z_center])
    rotate([90, 0, 0]) {
        // Bottom row: 7 vents
        for (ix = [-3 : 3]) {
            translate([ix * vent_spacing, -vent_spacing, 0])
            teardrop_hole(vent_size, 10);
        }
        // Middle row: 6 vents (offset by half spacing)
        for (ix = [-2.5, -1.5, -0.5, 0.5, 1.5, 2.5]) {
            translate([ix * vent_spacing, 0, 0])
            teardrop_hole(vent_size, 10);
        }
        // Top row: 5 vents
        for (ix = [-2 : 2]) {
            translate([ix * vent_spacing, vent_spacing, 0])
            teardrop_hole(vent_size, 10);
        }
    }
}

// ==========================================
// MAIN RENDER
// ==========================================

if (render_part == "ASSEMBLY_VIEW") {
    color("SlateGray") body_shell_geometry();
    color("DarkSlateGray") translate([0,0,split_z + 30]) top_lid_geometry();
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
                // 1. Main Mecha Shell
                difference() {
                    mecha_hull_outer();
                    difference() {
                        mecha_hull_inner(); 
                        cube([500,500,4], center=true); 
                    }
                }
                
                // 2. Corner Brackets
                intersection() {
                     corner_mount_brackets();
                     mecha_hull_outer(); 
                }
                
                // 3. Arm Mounts (Auto-tilted)
                side_arm_mounts_positive();
                
                // 4. Dual Power Casing
                intersection() {
                    dual_power_casing();
                    mecha_hull_outer();
                }

                // 5. Bottom Reinforcement Pads
                intersection() {
                    bottom_reinforcement_pads();
                    mecha_hull_outer();
                }
            }
        }

        // --- DRILLS ---
        union() {
            lid_insert_holes_body();
            bottom_interface_holes(); 
            side_arm_mounts_negative();
            dual_power_cutout();
            front_chest_vents();  // Decorative front vents
        }
    }
}

module top_lid_geometry() {
    difference() {
        union() {
            // Lid Plate (Cap Style) with mecha hull
            intersection() {
                mecha_hull_outer();
                translate([0,0, split_z + lid_thickness/2]) 
                    cube([500,500, lid_thickness], center=true);
            }
            translate([0,0,split_z]) neck_plate_shape();
            
            // Reinforcement pads around screw holes
            lid_screw_reinforcement();
        }
        lid_screw_holes();
        translate([0,0,split_z - 1]) neck_interface_drills();
    }
}

// ==========================================
//          DUAL POWER MODULES (UNCHANGED)
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
                rounded_box(ank_w + cw*2, ank_d + cw + 10, ank_h + cw*2, ank_corner_rad + cw);
                translate([0, -cw, 10]) 
                    rounded_box(ank_w + 0.6, ank_d + 10, ank_h + 0.6 + 20, ank_corner_rad);
            }
            translate([0, 0, -(ank_h + cw*2)/2 - 20])
                 rounded_box(ank_w + cw*2, ank_d + cw + 10, 40, ank_corner_rad + cw);
        }
        
        // 2. Battery Box (Right)
        translate([pos_batt_x, (batt_d + cw)/2 - 5, 0]) { 
            difference() {
                rounded_box(batt_w + cw*2, batt_d + cw + 10, batt_h + cw*2, batt_corner_rad + cw);
                translate([0, -cw, 10]) 
                    rounded_box(batt_w + 0.6, batt_d + 10, batt_h + 0.6 + 20, batt_corner_rad);
            }
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
//          NECK INTERFACE (UNCHANGED)
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
//          LID MOUNTING (M3 SCREWS - replaced magnets)
// ==========================================

module corner_mount_brackets() {
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

// M3 insert holes in body base (4.0mm for heat-set inserts)
module lid_insert_holes_body() {
    x_pos = body_width_top / 2 - 14;
    y_pos = body_depth_top / 2 - 14;
    insert_depth = 8;  // Depth for M3 heat-set insert
    
    for (x = [-1, 1]) for (y = [-1, 1]) {
        translate([x * x_pos, y * y_pos, split_z - insert_depth]) 
            cylinder(d = insert_hole_dia, h = insert_depth + 1); 
    }
}

// M3 screw clearance holes in lid (3.4mm for M3 screws)
module lid_screw_holes() {
    x_pos = body_width_top / 2 - 14;
    y_pos = body_depth_top / 2 - 14;
    
    for (x = [-1, 1]) for (y = [-1, 1]) {
        translate([x * x_pos, y * y_pos, split_z - 1]) 
            cylinder(d = screw_hole_dia, h = lid_thickness + 10); 
    }
}

// Reinforcement pads around lid screw holes (on top of lid)
module lid_screw_reinforcement() {
    x_pos = body_width_top / 2 - 14;
    y_pos = body_depth_top / 2 - 14;
    pad_dia = screw_hole_dia + 8;  // 8mm larger than hole
    pad_h = 3;  // Height of reinforcement boss
    
    for (x = [-1, 1]) for (y = [-1, 1]) {
        translate([x * x_pos, y * y_pos, split_z + lid_thickness]) 
            cylinder(d = pad_dia, h = pad_h); 
    }
}

// ==========================================
//          EXTERNAL ARM MODULES (UNCHANGED)
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

module bottom_interface_holes() {
    bot_insert_depth = 12; 
    off = bottom_bolt_spacing / 2; 
    
    cable_y_pos = -off + (bottom_cable_hole_dia / 2);

    translate([0,0,-0.1]) {
        // 4 corner holes
        translate([off, off, 0]) cylinder(h=bot_insert_depth, d=insert_hole_dia);
        translate([-off, off, 0]) cylinder(h=bot_insert_depth, d=insert_hole_dia);
        translate([-off, -off, 0]) cylinder(h=bot_insert_depth, d=insert_hole_dia);
        translate([off, -off, 0]) cylinder(h=bot_insert_depth, d=insert_hole_dia);
        
        // Cable hole
        translate([0, cable_y_pos, 0]) cylinder(h=bot_insert_depth, d=bottom_cable_hole_dia);
    }
}
