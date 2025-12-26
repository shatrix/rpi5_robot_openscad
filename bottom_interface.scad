/* [Interface Dimensions] */
bolt_spacing = 120; 
screw_hole_dia = 3.4; 
insert_hole_dia = 4.0; 
cable_hole_dia = 20; 

/* [Cutter Settings] */
cutter_height = 9; 
selected_dia = insert_hole_dia; 

module interface_pattern() {
    offset_val = bolt_spacing / 2;
    
    // ALIGNMENT CALCULATION
    // The center of the hole is moved up by its radius relative to the bottom screw line.
    // This makes the bottom edge of the circle touch the line connecting the screw centers.
    cable_y_pos = -offset_val + (cable_hole_dia / 2);

    union() {
        // 1. The Cable Hole (Aligned)
        translate([0, cable_y_pos, 0]) 
            cylinder(h = cutter_height, d = cable_hole_dia, center = true, $fn=100);
        
        // 2. The 4 Bolt Holes
        translate([offset_val, offset_val, 0])
            cylinder(h = cutter_height, d = selected_dia, center = true, $fn=50);
            
        translate([-offset_val, offset_val, 0])
            cylinder(h = cutter_height, d = selected_dia, center = true, $fn=50);
            
        translate([-offset_val, -offset_val, 0])
            cylinder(h = cutter_height, d = selected_dia, center = true, $fn=50);
            
        translate([offset_val, -offset_val, 0])
            cylinder(h = cutter_height, d = selected_dia, center = true, $fn=50);
    }
}

interface_pattern();
