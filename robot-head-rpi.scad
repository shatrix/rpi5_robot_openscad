// ########################
// BOXY CUTE ROBOT HEAD - FINAL PRODUCTION (9.5mm MIC / 2mm HOLDER)
//
// UPDATES:
// 1. Mic Diameter: 9.5mm
// 2. Mic Holder Wall: 1.0mm
// 3. Mic Holder Length: 2mm (Flush internal ring, using mic_d + 4 OD)
// 4. Floor Interface: Added 4mm reinforcement pads for neck screws.
// ---------------------------------------------------------
// PREVIOUS SETTINGS MAINTAINED:
// - Button Spacing: 60mm (Wide)
// - Robust Magnets (Tapered)
// - Cable Hole: Large (14x24mm) at X=45
// - Wall: 2.0mm
// - Face: Raised (Split line 48mm)
// - Neck: 150x100mm interface
// - Flush Lid/Base
// ---------------------------------------------------------

$fn = 80;

/* [Global Settings] */
render_mode = "full"; // [full, test_fit]

show_base = true;
show_lid = false; 
show_mockups = true;
embedded_magnets = true; 

/* [Dimensions] */
head_w = 190; 
head_h = 125; 
head_d = 125; 
wall = 2.0; 
split_z = 48; // Raised split line
corner_r_top = 12; 
corner_r_bot = 30; 

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

// Microphone Settings (UPDATED)
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
//              HELPER MODULES
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

module variable_rounded_hull_chamfered(w, d, h, r_top, r_bot) {
    chamfer_h = 1.0;
    hull() {
        translate([0, 0, h/2]) linear_extrude(0.01) offset(r=r_top) square([w - 2*r_top, d - 2*r_top], center=true);
        translate([0, 0, -h/2 + chamfer_h]) linear_extrude(0.01) offset(r=r_bot) square([w - 2*r_bot, d - 2*r_bot], center=true);
        translate([0, 0, -h/2]) linear_extrude(0.01) offset(r=r_bot - chamfer_h) square([w - 2*r_bot, d - 2*r_bot], center=true);
    }
}

module variable_rounded_hull(w, d, h, r_top, r_bot) {
    hull() {
        translate([0, 0, h/2]) linear_extrude(0.01) offset(r=r_top) square([w - 2*r_top, d - 2*r_top], center=true);
        translate([0, 0, -h/2]) linear_extrude(0.01) offset(r=r_bot) square([w - 2*r_bot, d - 2*r_bot], center=true);
    }
}

module inner_void_shape() {
    variable_rounded_hull(head_w - 2*wall, head_d - 2*wall, head_h - 2*wall, corner_r_top - 1, corner_r_bot - 1);
}

module flat_rounded_box(dim, r) {
    translate([0,0, -dim.z/2])
    linear_extrude(dim.z)
    offset(r=r)
    square([dim.x - 2*r, dim.y - 2*r], center=true);
}

// ==========================================
//          MAGNETS & MOUNTS (ROBUST)
// ==========================================

module corner_magnet_brackets() {
    x_pos = head_w / 2 - 14;
    y_pos = head_d / 2 - 14;
    anchor_mid_drop = 12; 
    anchor_deep_drop = 22;

    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            hull() {
                // 1. Top Platform (Solid Cylinder to hold magnet)
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
    x_pos = head_w / 2 - 14;
    y_pos = head_d / 2 - 14;
    z_offset = embedded_magnets ? split_z - mag_cover_thick - mag_height/2 : split_z - mag_height/2 + 0.01;
    for (x = [-1, 1]) for (y = [-1, 1]) 
        translate([x * x_pos, y * y_pos, z_offset]) 
        cylinder(d = mag_diam, h = mag_height + 0.02, center = true);
}

module magnet_posts_lid_solid() {
    x_pos = head_w / 2 - 14;
    y_pos = head_d / 2 - 14;
    for (x = [-1, 1]) for (y = [-1, 1]) 
        translate([x * x_pos, y * y_pos, split_z + 15]) 
        cylinder(r = 9, h = 30, center = true); 
}

module magnet_holes_lid() {
    x_pos = head_w / 2 - 14;
    y_pos = head_d / 2 - 14;
    z_offset = embedded_magnets ? split_z + mag_cover_thick + mag_height/2 : split_z + mag_height/2 - 0.01;
    for (x = [-1, 1]) for (y = [-1, 1]) 
        translate([x * x_pos, y * y_pos, z_offset]) 
        cylinder(d = mag_diam, h = mag_height + 0.02, center = true);
}

// Neck Interface Drills
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

// Neck Interface Reinforcement Pads (NEW)
module neck_mounting_pads() {
    hx = neck_plate_w/2 - 10;
    hy = neck_plate_d/2 - 10;
    pad_h = 4.0;
    pad_d = 12.0; // 12mm Diameter for reinforcement
    
    // Position on top of the internal floor
    z_pos = floor_z + pad_h/2; 
    
    for (mx=[-1,1], my=[-1,1]) {
        translate([mx * hx, my * hy, z_pos]) 
            cylinder(d=pad_d, h=pad_h, center=true);
    }
}

// ==========================================
//              INTERNALS (OPTIMIZED)
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

// UPDATED: Mic Holder (2mm length, using mic_d + 4)
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

module side_thermal_vents() {
    for (side = [-1, 1]) translate([side * (head_w / 2 - wall), 0, -10]) rotate([0, 90, 0]) 
    for (y = [-12 : 12 : 12]) translate([0, y, 0]) hull() {
        translate([-15, 0, -10]) cylinder(r=2.5, h=20);
        translate([15, 0, -10]) cylinder(r=2.5, h=20);
        translate([15 + 2.5, 0, -10]) cube([0.1, 0.1, 20], center=true);
    }
}

module top_vents() {
    for (i = [-35 : 10 : 35]) translate([i, 0, head_h / 2]) hull() {
        translate([0, -18, 0]) cylinder(r=2, h=20, center=true);
        translate([0, 18, 0]) cylinder(r=2, h=20, center=true);
    }
}

// ==========================================
//              MAIN ASSEMBLY
// ==========================================

module base_unit() {
    difference() {
        union() {
            color("LightBlue") difference() {
                intersection() {
                    variable_rounded_hull_chamfered(head_w, head_d, head_h, corner_r_top, corner_r_bot);
                    translate([0, 0, -250 + split_z]) cube([500, 500, 500], center = true);
                }
                inner_void_shape();
            }
            color("LightBlue") intersection() {
                corner_magnet_brackets();
                intersection() {
                    variable_rounded_hull(head_w, head_d, head_h, corner_r_top, corner_r_bot);
                    translate([0, 0, -250 + split_z]) cube([500, 500, 500], center = true);
                }
            }
            
            color("ForestGreen") internal_rails();
            color("#333333") camera_holder();
            color("DarkOrange") intersection() { side_speaker_rails(); inner_void_shape(); }
            color("FireBrick") microphone_holder();
            
            // NEW: Reinforcement pads
            color("Silver") neck_mounting_pads();
        }

        magnet_cutouts_base();
        back_cable_hole(); 
        
        screen_cutout_bottom = screen_center_z - 25;
        screen_cutout_top = split_z + 10; 
        screen_cutout_h = screen_cutout_top - screen_cutout_bottom;
        screen_cutout_z = screen_cutout_bottom + screen_cutout_h / 2;
        translate([0, head_d / 2 - wall * 2, screen_cutout_z]) cube([75, 20, screen_cutout_h], center = true);
        
        translate([0, head_d / 2 - wall + 1, cam_z_pos]) rotate([90,0,0]) minkowski() {
                cube([11-4, 11-4, 10], center=true); cylinder(r=2, h=0.1, center=true);
        }
        
        translate([0, head_d / 2 - wall + 1, mic_z_pos]) rotate([90,0,0]) cylinder(d=mic_d, h=20, center=true);

        side_thermal_vents();
        neck_mount_holes();
        translate([0,0, -head_h/2 - 50]) cube([500,500,100], center=true);
        
        // Push Button Holes (Teardrop) - 60mm Spacing
        for(side_x = [-1, 1]) {
            for(i = [0:2]) {
                // Spacing logic: 60mm from center, 18mm vertical spacing
                z_btn = screen_center_z - 10 - (i * 18); 
                translate([side_x * 60, head_d/2, z_btn]) rotate([90, 0, 0]) hull() {
                    cylinder(d=pb_main_dia, h=20, center=true);
                    translate([0, pb_main_dia/2 + 2, 0]) cube([0.1, 0.1, 20], center=true); // Teardrop point
                }
            }
        }
    }
}

module lid_unit() {
    translate([0, 0, 10]) difference() {
        color("CornflowerBlue") union() {
            difference() {
                union() {
                    difference() {
                        intersection() {
                            variable_rounded_hull(head_w, head_d, head_h, corner_r_top, corner_r_bot);
                            translate([0, 0, 250 + split_z]) cube([500, 500, 500], center = true);
                        }
                        inner_void_shape();
                    }
                    intersection() {
                        magnet_posts_lid_solid();
                        variable_rounded_hull(head_w, head_d, head_h, corner_r_top, corner_r_bot);
                        translate([0, 0, 250 + split_z]) cube([500, 500, 500], center = true);
                    }
                }
            }
        }
        top_vents();
        magnet_holes_lid();
    }
}

if (render_mode == "full") {
    if (show_base) base_unit();
    if (show_lid) lid_unit();
    if (show_mockups) {
        % translate([0, head_d / 2 - 14, screen_center_z]) cube([disp_pcb_w, disp_pcb_thick, disp_pcb_h], center = true);
        % translate([0, rpi_center_y_global, floor_z + rpi_lift + rpi_h_actual/2]) cube([rpi_w, rpi_thick, rpi_h_actual], center = true);
    }
} else if (render_mode == "test_fit") {
    intersection() {
        if (show_base) base_unit();
        translate([0, 0, -head_h/2 + 20]) cube([head_w+20, head_d+50, 40], center=true);
    }
}
