# Mecha-Style Robot - OpenSCAD Design

> 🔗 **This repository contains the 3D printable designs (OpenSCAD sources, STL, and 3MF files) for the [RPi5 AI Robot Project](https://github.com/shatrix/rpi5-rpios-ai-robot).**

A futuristic, angular robot design featuring a Raspberry Pi 5 head and modular body with mecha/sci-fi aesthetics. All parts are optimized for support-free FDM printing.

## Assembly Overview

```
┌────────────────────────────────────┐
│           ROBOT HEAD               │
│     (robot-head-mecha.scad)        │
│   190 × 125 × 125 mm               │
│                                    │
│   - RPi5 Compartment               │
│   - Display + Camera               │
│   - Speakers + Buttons             │
├────────────────────────────────────┤
│      HEAD BOTTOM INTERFACE         │
│        150 × 100 mm plate          │
│     Connects to → Body Lid         │
├────────────────────────────────────┤
│           BODY LID                 │
│     (top_lid in body file)         │
│   Neck plate: 150 × 100 × 7 mm     │
├────────────────────────────────────┤
│           ROBOT BODY               │
│     (robot-body-mecha.scad)        │
│   150→200 × 151→155 × 50 mm        │
│                                    │
│   - Dual Power Compartments        │
│   - Arm Mounts (both sides)        │
├────────────────────────────────────┤
│      BODY BOTTOM INTERFACE         │
│     (bottom_interface.scad)        │
│   120 mm bolt spacing + cable hole │
│     Connects to → Motors Base      │
└────────────────────────────────────┘
```

---

## Files

| File | Part | Description |
|------|------|-------------|
| `robot-head-mecha.scad` | **HEAD** | Mecha-style robot head with RPi5 |
| `robot-body-mecha.scad` | **BODY** | Mecha-style robot body with power |
| `bottom_interface.scad` | **INTERFACE** | Cutout pattern for motors base |
| `robot-head-rpi.scad` | HEAD | Original rounded head design |
| `robot-body-rpi.scad` | BODY | Original rounded body design |

---

## Interfaces

### HEAD ↔ BODY Connection

The **head's bottom** connects to the **body's lid** (neck plate).

| Parameter | Value | Notes |
|-----------|-------|-------|
| Plate size | 150 × 100 mm | Rounded corners (10mm radius) |
| Plate height | 7 mm | On body lid |
| Slot opening | 100 × 20 mm | Cable passthrough |
| Mounting holes | 4× M3 | At corners (insert holes) |

### BODY ↔ MOTORS BASE Connection

The **body's bottom** uses `bottom_interface.scad` as a **negative cutout** for the motors base STL.

| Parameter | Value | Notes |
|-----------|-------|-------|
| Bolt spacing | 120 mm | 4 corners |
| Hole diameter | 4.0 mm | Insert holes |
| Cable hole | 20 mm diameter | Aligned to bottom edge |
| Cutter height | 9 mm | Depth for STL subtraction |

**Usage:** Import `bottom_interface.scad` and subtract from motors base STL.

---

# 🤖 HEAD - robot-head-mecha.scad

The robot head houses the RPi5, display, camera, speakers, and control buttons.

## HEAD - Dimensions

| Parameter | Value |
|-----------|-------|
| Overall Size | 190 × 125 × 125 mm |
| Wall Thickness | 2.0 mm |
| Split Line | z = 48 mm |
| Top Bevel | 18 mm |
| Bottom Bevel | 30 mm |

## HEAD - Components

| Component | Dimensions | Notes |
|-----------|-----------|-------|
| RPi5 Compartment | 58 × 30 × 89 mm | 60mm rail height |
| Display | 85.5 × 55.6 mm PCB | Wedge rails |
| Camera | 25.4 × 25.4 mm slot | Teardrop cutout |
| Microphone | 9.5 mm diameter | Teardrop cutout |
| Speakers | 40 × 33.6 × 17.8 mm | Both sides, teardrop vents |
| Buttons | 6× 14.5 mm holes | Teardrop shape |
| Magnets | 4× 6.5 × 2.2 mm | At corners |

## HEAD - Support-Free Features

- All holes use teardrop shapes (point up)
- Camera holder has 45° chamfered bottom
- RPi5 rails without top crossbar
- Speaker rails without bottom layer
- Flat top lid for upside-down printing

## HEAD - Printing

| Part | Orientation | Support |
|------|-------------|---------|
| Base | Right-side up (neck on bed) | None |
| Lid | Upside-down (flat top on bed) | None |

---

# 📦 BODY - robot-body-mecha.scad

The robot body holds dual power sources and provides arm mounting points.

## BODY - Dimensions

| Parameter | Value |
|-----------|-------|
| Base Size (bottom) | 150 × 151 mm |
| Top Size | 200 × 155 mm |
| Height | 60 mm |
| Wall Thickness | 1.6 mm |
| Top Bevel | 16 mm |
| Bottom Bevel | 24 mm |

## BODY - Components

| Component | Dimensions | Notes |
|-----------|-----------|-------|
| Front Chest Vents | 7-6-5 pyramid | Teardrop shape |
| Powerbank (Left) | 37.5 × 80 × 25.5 mm | 13° tilt |
| Battery (Right) | 51 × 86 × 15 mm | 13° tilt |
| Arm Mounts | 48 mm diameter | Both sides |
| Lid Screws | 4× M3 | At corners (replaces magnets) |
| Bottom Bolts | 120 mm spacing | 4 corners |

## BODY - Printing

| Part | Orientation | Support |
|------|-------------|---------|
| Shell | Right-side up (bottom on bed) | None |
| Lid | Neck plate facing up | None |

---

## Customization

### HEAD - Bevel Sizes
```scad
// In robot-head-mecha.scad:
bevel_size = 18;        // Top corners
bevel_size_bottom = 30; // Bottom corners
```

### BODY - Bevel Sizes
```scad
// In robot-body-mecha.scad:
bevel_size = 16;        // Top corners
bevel_size_bottom = 24; // Bottom corners
```

### Render Options (both files)
```scad
show_base = true;
show_lid = true;
show_mockups = true;  // HEAD only
```

---

## Version History

- **v1**: Original rounded designs (`robot-head-rpi.scad`, `robot-body-rpi.scad`)
- **v2**: Mecha-style angular redesign with octagonal beveled hulls
- **v2.1**: Support-free printing optimizations (teardrops, chamfers)
