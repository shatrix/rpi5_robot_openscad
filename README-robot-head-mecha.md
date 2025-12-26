# Mecha-Style Robot Head - OpenSCAD Design

A futuristic, angular robot head designed to house a Raspberry Pi 5 and various components. Features a mecha/sci-fi aesthetic with beveled octagonal geometry while maintaining full compatibility with existing hardware.

## Quick Reference

| Parameter | Value | Description |
|-----------|-------|-------------|
| Overall Size | 190 × 125 × 125 mm | Width × Height × Depth |
| Wall Thickness | 2.0 mm | Shell wall thickness |
| Split Line | z = 48 mm | Lid/base separation height |
| Top Bevel | 18 mm | Corner bevel at lid level |
| Bottom Bevel | 30 mm | Corner bevel at base |

---

## Design Features

### Mecha-Style Geometry
- **Octagonal Hull** - Angular corners with configurable bevels
- **Cheek Taper** - 12% inward taper toward top for aggressive stance
- **Flat Top** - Designed for support-free upside-down lid printing
- **Panel Lines** - Vertical accent grooves on front face

### Support-Free Printing ✅
- **Base Unit**: Print right-side up (neck interface on bed)
- **Lid Unit**: Print upside-down (flat top on bed)
- **No supports required** - All features optimized:
  - Teardrop holes for camera, mic, buttons, speaker vents
  - Chamfered camera holder bottom (45°)
  - RPi5 rails without overhanging top bar
  - Speaker rails without bottom layer (sit on floor)

---

## Components & Dimensions

### Head Shell
| Parameter | Value | Notes |
|-----------|-------|-------|
| `head_w` | 190 mm | Total width |
| `head_h` | 125 mm | Total height |
| `head_d` | 125 mm | Total depth |
| `wall` | 2.0 mm | Wall thickness |
| `bevel_size` | 18 mm | Top corner bevel |
| `bevel_size_bottom` | 30 mm | Bottom corner bevel |
| `cheek_taper` | 0.12 | Side taper ratio |

### Neck Interface (Bottom)
| Parameter | Value | Notes |
|-----------|-------|-------|
| `neck_plate_w` | 150 mm | Interface plate width |
| `neck_plate_d` | 100 mm | Interface plate depth |
| `neck_slot_w` | 100 mm | Central slot width |
| `neck_slot_d` | 20 mm | Central slot depth |
| `insert_hole_dia` | 3.4 mm | M3 screw clearance holes |
| Mounting holes | 4× at corners | 65mm × 40mm spacing |

### Display (Front)
| Parameter | Value | Notes |
|-----------|-------|-------|
| `disp_pcb_w` | 85.5 mm | PCB width |
| `disp_pcb_h` | 55.6 mm | PCB height |
| `disp_pcb_thick` | 7.0 mm | PCB + components thickness |
| Screen cutout | 75 mm wide | Front face opening |

### Raspberry Pi 5 Compartment (Back)
| Parameter | Value | Notes |
|-----------|-------|-------|
| `rpi_w` | 58 mm | RPi5 width |
| `rpi_thick` | 30 mm | RPi5 + clearance depth |
| `rpi_h_actual` | 89 mm | RPi5 height |
| Mount height | 60 mm | Side rails only (no top bar) |

### Camera (Front Center)
| Parameter | Value | Notes |
|-----------|-------|-------|
| `cam_slot_w` | 25.4 mm | Camera module width |
| `cam_slot_h` | 25.4 mm | Camera module height |
| `cam_lens_d` | 11.4 mm | Lens opening diameter |
| `cam_depth` | 14 mm | Holder depth |
| Cutout shape | Teardrop | Support-free |
| Holder bottom | 45° chamfer | Support-free |

### Microphone (Front Bottom)
| Parameter | Value | Notes |
|-----------|-------|-------|
| `mic_d` | 9.5 mm | Microphone diameter |
| Cutout shape | Teardrop | Support-free |

### Speakers (Both Sides)
| Parameter | Value | Notes |
|-----------|-------|-------|
| `dual_spk_l` | 40 mm | Speaker length |
| `dual_spk_w` | 33.6 mm | Speaker width |
| `dual_spk_d` | 17.8 mm | Speaker depth |
| Rail height | 45 mm | Side rails only (no bottom) |
| Vent shape | Teardrop | 8mm diameter, support-free |
| Vent Z position | -25 mm | Centered on speakers |

### Push Buttons (Front Sides)
| Parameter | Value | Notes |
|-----------|-------|-------|
| `pb_main_dia` | 14.5 mm | Button hole diameter |
| Quantity | 6 total | 3 per side |
| X spacing | ±60 mm | From center |
| Z spacing | 18 mm | Between buttons |
| Hole shape | Teardrop | Support-free |

### Magnets (Lid Attachment)
| Parameter | Value | Notes |
|-----------|-------|-------|
| `mag_diam` | 6.5 mm | Magnet diameter |
| `mag_height` | 2.2 mm | Magnet height |
| Quantity | 4 | One per corner |
| Position | head_w/2 - 14 | From edge |

---

## Ventilation

### Top Vents (Lid)
- Pattern: Hexagonal grid (7×5)
- Hex size: 8 mm diameter
- Spacing: 10 mm

### Side Vents (Speaker Area)
- Pattern: Teardrop grid
- Size: 8 mm diameter
- Position: z = -25 mm (aligned with speakers)

---

## Key Modules

| Module | Purpose |
|--------|---------|
| `teardrop_2d()` / `teardrop_hole()` | Support-free horizontal holes |
| `mecha_hull_outer()` | Main angular shell geometry |
| `mecha_hull_inner()` | Internal void shape |
| `internal_rails()` | Display + RPi5 mounting rails |
| `side_speaker_rails()` | Speaker side rails (no bottom) |
| `camera_holder()` | Camera mount (chamfered bottom) |
| `corner_magnet_brackets()` | Magnet mount structures |
| `hex_vent_pattern_top()` | Lid ventilation (hex) |
| `hex_vent_pattern_sides()` | Speaker ventilation (teardrop) |

---

## Render Options

```scad
render_mode = "full";     // [full, test_fit]
show_base = true;         // Show base unit
show_lid = true;          // Show lid unit
show_mockups = true;      // Show component mockups
embedded_magnets = false; // Magnet embedding mode
```

---

## Customization

### To adjust angular look:
- `bevel_size` - Top corner angles (affects magnet fit)
- `bevel_size_bottom` - Bottom corner angles (can be larger)
- `cheek_taper` - Side inward taper (0-1)

### To modify for different components:
1. Update dimension variables in `/* [Hardware Dimensions] */` section
2. Adjust holder modules if needed
3. Recalculate positions based on new dimensions

---

## File History

- **Original**: `robot-head-rpi.scad` (Boxy rounded design)
- **Current**: `robot-head-mecha.scad` (Angular mecha style)
- All internal component positions preserved from original
- **v2**: Support-free printing optimizations (teardrops, chamfers)
