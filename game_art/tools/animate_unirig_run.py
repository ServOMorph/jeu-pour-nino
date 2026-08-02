from __future__ import annotations

import argparse
import math
import sys
from pathlib import Path

import bpy
from mathutils import Vector


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--blend-output", required=True)
    parser.add_argument("--width", type=int, default=520)
    parser.add_argument("--height", type=int, default=750)
    values = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    return parser.parse_args(values)


def smooth(keys, phase):
    for (p0, y0, z0), (p1, y1, z1) in zip(keys, keys[1:]):
        if phase <= p1:
            t = (phase - p0) / (p1 - p0)
            t = t * t * (3.0 - 2.0 * t)
            return y0 + (y1 - y0) * t, z0 + (z1 - z0) * t
    return keys[-1][1], keys[-1][2]


def two_bone_points(root, target, first_length, second_length):
    direction = target - root
    distance = max(direction.length, 1e-6)
    maximum = first_length + second_length - 1e-5
    if distance > maximum:
        target = root + direction.normalized() * maximum
        direction = target - root
        distance = maximum
    along = (first_length * first_length - second_length * second_length + distance * distance) / (2.0 * distance)
    height = math.sqrt(max(0.0, first_length * first_length - along * along))
    unit = direction / distance
    perpendicular = Vector((0.0, -unit.z, unit.y))
    joint = root + unit * along + perpendicular * height
    return joint, target


def leg_pose(hip, phase, first_length, second_length):
    keys = (
        (0.0, 0.400, 0.110),
        (0.125, 0.400, 0.110),
        (0.25, 0.350, 0.020),
        (0.375, 0.270, -0.140),
        (0.5, 0.200, -0.200),
        (0.625, 0.230, -0.120),
        (0.75, 0.320, 0.000),
        (0.875, 0.400, 0.110),
        (1.0, 0.400, 0.110),
    )
    y, z_offset = smooth(keys, phase)
    ankle = Vector((hip.x, y, hip.z + z_offset))
    return two_bone_points(hip, ankle, first_length, second_length)


def arm_pose(shoulder, phase, first_length, second_length):
    keys = (
        (0.0, shoulder.y + 0.030, 0.220),
        (0.25, shoulder.y + 0.100, 0.100),
        (0.5, shoulder.y + 0.125, -0.165),
        (0.75, shoulder.y + 0.100, -0.030),
        (1.0, shoulder.y + 0.030, 0.220),
    )
    y, z_offset = smooth(keys, phase)
    wrist = Vector((shoulder.x, y, shoulder.z + z_offset))
    return two_bone_points(shoulder, wrist, first_length, second_length)


def add_target(name, rig):
    value = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(value)
    value.parent = rig
    value.empty_display_type = "PLAIN_AXES"
    value.empty_display_size = 0.025
    return value


def key_location(obj, frame, value):
    obj.location = value
    obj.keyframe_insert(data_path="location", frame=frame)


def look_at(obj, target):
    obj.rotation_euler = (target - obj.location).to_track_quat("-Z", "Y").to_euler()


def lock_rear_cloth(character):
    limb_names = {f"bone_{index}" for index in range(6, 28)}
    group_names = {group.index: group.name for group in character.vertex_groups}
    locked = []
    for vertex in character.data.vertices:
        if vertex.co.z >= -0.065 or not (-0.32 < vertex.co.y < 0.34):
            continue
        dominant = max(vertex.groups, key=lambda item: item.weight, default=None)
        if dominant is not None and group_names[dominant.group] in limb_names:
            locked.append(vertex.index)
    if not locked:
        return
    for group in character.vertex_groups:
        group.remove(locked)
    character.vertex_groups["bone_1"].add(locked, 1.0, "REPLACE")


def main():
    args = parse_args()
    output_dir = Path(args.output_dir).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    Path(args.blend_output).resolve().parent.mkdir(parents=True, exist_ok=True)

    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    bpy.ops.import_scene.gltf(filepath=str(Path(args.input).resolve()))
    rig = next(obj for obj in bpy.context.scene.objects if obj.type == "ARMATURE")
    character = max(
        (obj for obj in bpy.context.scene.objects if obj.type == "MESH"),
        key=lambda obj: len(obj.data.vertices),
    )
    for obj in bpy.context.scene.objects:
        if obj.type == "MESH" and obj != character:
            obj.hide_render = True
    lock_rear_cloth(character)

    scene_root = bpy.data.objects.new("Nino_Run_Root", None)
    bpy.context.collection.objects.link(scene_root)
    rig.parent = scene_root
    scene_root.rotation_euler.x = -math.pi / 2.0
    scene_root.scale = (5.96, 5.96, 5.96)
    scene_root.location.z = 2.897

    targets = {}
    for side, calf, forearm in (("L", "bone_21", "bone_8"), ("R", "bone_25", "bone_15")):
        targets[f"ankle.{side}"] = add_target(f"ankle.{side}", rig)
        targets[f"knee.{side}"] = add_target(f"knee.{side}", rig)
        targets[f"wrist.{side}"] = add_target(f"wrist.{side}", rig)
        targets[f"elbow.{side}"] = add_target(f"elbow.{side}", rig)

        leg_ik = rig.pose.bones[calf].constraints.new("IK")
        leg_ik.target = targets[f"ankle.{side}"]
        leg_ik.pole_target = targets[f"knee.{side}"]
        leg_ik.chain_count = 2
        leg_ik.use_stretch = False

        arm_ik = rig.pose.bones[forearm].constraints.new("IK")
        arm_ik.target = targets[f"wrist.{side}"]
        arm_ik.pole_target = targets[f"elbow.{side}"]
        arm_ik.chain_count = 2
        arm_ik.use_stretch = False

    bone_data = rig.data.bones
    left_hip = bone_data["bone_20"].head_local.copy()
    right_hip = bone_data["bone_24"].head_local.copy()
    left_shoulder = bone_data["bone_7"].head_local.copy()
    right_shoulder = bone_data["bone_14"].head_local.copy()

    for frame in range(1, 18):
        phase = 0.0 if frame == 17 else (frame - 1) / 16.0
        for side, hip, thigh, calf, offset in (
            ("L", left_hip, "bone_20", "bone_21", 0.0),
            ("R", right_hip, "bone_24", "bone_25", 0.5),
        ):
            knee, ankle = leg_pose(
                hip,
                (phase + offset) % 1.0,
                bone_data[thigh].length,
                bone_data[calf].length,
            )
            key_location(targets[f"knee.{side}"], frame, knee)
            key_location(targets[f"ankle.{side}"], frame, ankle)

        for side, shoulder, upper, forearm, offset in (
            ("L", left_shoulder, "bone_7", "bone_8", 0.5),
            ("R", right_shoulder, "bone_14", "bone_15", 0.0),
        ):
            elbow, wrist = arm_pose(
                shoulder,
                (phase + offset) % 1.0,
                bone_data[upper].length,
                bone_data[forearm].length,
            )
            key_location(targets[f"elbow.{side}"], frame, elbow)
            key_location(targets[f"wrist.{side}"], frame, wrist)

    bpy.ops.object.light_add(type="AREA", location=(4.0, -4.0, 8.0))
    key = bpy.context.object
    key.data.energy = 800
    key.data.size = 5.0
    look_at(key, Vector((0.0, 0.0, 2.9)))
    bpy.ops.object.light_add(type="AREA", location=(4.0, 4.0, 5.0))
    fill = bpy.context.object
    fill.data.energy = 500
    fill.data.size = 4.0
    look_at(fill, Vector((0.0, 0.0, 2.9)))

    view_angle = math.radians(10.0)
    bpy.ops.object.camera_add(location=(
        12.0 * math.cos(view_angle),
        12.0 * math.sin(view_angle),
        2.9,
    ))
    camera = bpy.context.object
    camera.data.type = "ORTHO"
    camera.data.ortho_scale = 6.35
    look_at(camera, Vector((0.0, 0.0, 2.9)))

    scene = bpy.context.scene
    scene.camera = camera
    scene.frame_start = 1
    scene.frame_end = 17
    scene.render.engine = "BLENDER_EEVEE"
    scene.render.resolution_x = args.width
    scene.render.resolution_y = args.height
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGB"
    scene.render.fps = 16
    scene.render.filepath = str(output_dir / "frame_")
    scene.world.use_nodes = True
    background = scene.world.node_tree.nodes.get("Background")
    background.inputs["Color"].default_value = (1.0, 1.0, 1.0, 1.0)
    background.inputs["Strength"].default_value = 0.8
    scene.view_settings.look = "AgX - Medium High Contrast"
    bpy.ops.wm.save_as_mainfile(filepath=str(Path(args.blend_output).resolve()))
    bpy.ops.render.render(animation=True)


if __name__ == "__main__":
    main()
