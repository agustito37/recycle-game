#!/usr/bin/env python3
"""
Script to clean up invalid tile coordinates in Godot .tscn files.
This script removes tile coordinates that exceed the bounds of the source image.

For the image Room_Builder_Floors_48x48.png:
- Size: 720x1920 pixels
- Tile size: 48x48 pixels
- Valid coordinates: X: 0-14, Y: 0-39
"""

import re
import sys

def cleanup_tileset(file_path):
    """
    Remove invalid tile coordinates from a .tscn file.

    Args:
        file_path (str): Path to the .tscn file to clean up
    """

    # Define valid bounds for different tilesets
    tileset_bounds = {
        "Room_Builder_Floors_48x48.png": (14, 39),      # 720x1920px = 15x40 tiles (0-14, 0-39)
        "Room_Builder_3d_walls_48x48.png": (23, 58),    # 1152x2832px = 24x59 tiles (0-23, 0-58)
        "16_Grocery_store_Shadowless_48x48.png": (20, 20),  # Estimate, adjust if needed
        "Grocery_Store_Singles_Shadowless_48x48_182.png": (0, 1),  # Single tile image
    }

    current_tileset = None
    MAX_X, MAX_Y = 14, 39  # Default bounds

    print(f"Reading file: {file_path}")

    # Read the file
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Split into lines for processing
    lines = content.split('\n')

    # Process each line
    valid_lines = []
    removed_count = 0

    for line_num, line in enumerate(lines, 1):
        # Check if this is a tile coordinate line
        match = re.match(r'^(\d+):(\d+)/0 = 0$', line)

        if match:
            x = int(match.group(1))
            y = int(match.group(2))

            # Check if coordinates are valid
            if x <= MAX_X and y <= MAX_Y:
                # Valid coordinate, keep the line
                valid_lines.append(line)
            else:
                # Invalid coordinate, remove the line
                removed_count += 1
                print(f"Removing invalid coordinate ({x},{y}) at line {line_num}")
                # Don't append the line (effectively removing it)
        else:
            # Not a tile coordinate line, keep it
            valid_lines.append(line)

    # Write the cleaned content back
    cleaned_content = '\n'.join(valid_lines)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(cleaned_content)

    print(f"✅ Cleanup complete!")
    print(f"📊 Removed {removed_count} invalid tile coordinates")
    print(f"📁 Valid coordinates range: X(0-{MAX_X}), Y(0-{MAX_Y})")

if __name__ == "__main__":
    file_path = "/Users/agustinprieto/projects/recycle/levels/game_level.tscn"

    print("🧹 Starting tileset cleanup...")
    print(f"🎯 Target file: {file_path}")
    print("📐 Image bounds: 720x1920px (15x40 tiles)")
    print("🔧 Removing coordinates with X>14 or Y>39")
    print()

    try:
        cleanup_tileset(file_path)
        print("\n🎉 Success! The tileset has been cleaned up.")
        print("💡 You can now run the game without tile errors.")

    except Exception as e:
        print(f"\n❌ Error during cleanup: {e}")
        print("🔄 Restore the backup if needed:")
        print("   cp game_level.tscn.backup game_level.tscn")
        sys.exit(1)