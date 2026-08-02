"""Cree une video locale de course laterale pour le guidage DWPose."""

from __future__ import annotations

import argparse
import math
import sys
from pathlib import Path

import bpy
from mathutils import Euler, Vector


def args_after_separator() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True)
    parser.add_argument("--width", type=int, default=448)
    parser.add_argument("--height", type=int, default=640)
    parser.add_argument("--fps", type=int, default=16)
    parser.add_argument("--cycle-frames", type=int, default=16)
    parser.add_argument("--cycle-count", type=int, default=1)
    parser.add_argument("--include-loop-frame", action="store_true")
    parser.add_argument("--phase-offset", type=float, default=0.0)
    parser.add_argument("--view-angle", type=float, default=0.0)
    parser.add_argument("--alpha-mask-output")
    parser.add_argument("--warmup-frames", type=int, default=0)
    values = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    return parser.parse_args(values)


def material(name: str, color: tuple[float, float, float, float], roughness: float = 0.7):
    value = bpy.data.materials.new(name)
    value.diffuse_color = color
    value.roughness = roughness
    value.use_nodes = True
    shader = value.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = color
    shader.inputs["Roughness"].default_value = roughness
    return value


def add_uv_sphere(name: str, radius: float, mat, location=(0.0, 0.0, 0.0)):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=12, radius=radius, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(mat)
    return obj


def add_cube(name: str, scale: tuple[float, float, float], mat):
    bpy.ops.mesh.primitive_cube_add(size=2)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    obj.data.materials.append(mat)
    bevel = obj.modifiers.new("Bevel", "BEVEL")
    bevel.width = 0.22
    bevel.segments = 3
    return obj


def add_bone(name: str, radius: float, mat):
    bpy.ops.mesh.primitive_cylinder_add(vertices=20, radius=1.0, depth=2.0)
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(mat)
    obj["radius"] = radius
    return obj


def keyframe_transform(obj, frame: int):
    obj.keyframe_insert("location", frame=frame)
    obj.keyframe_insert("rotation_quaternion", frame=frame)
    obj.keyframe_insert("scale", frame=frame)


def place_bone(obj, start: Vector, end: Vector, frame: int):
    direction = end - start
    obj.location = (start + end) * 0.5
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = direction.to_track_quat("Z", "Y")
    radius = float(obj["radius"])
    obj.scale = (radius, radius, direction.length * 0.5)
    keyframe_transform(obj, frame)


def keyframe_location(obj, location: Vector, frame: int, scale=None, rotation_y: float = 0.0):
    obj.location = location
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = Euler((0.0, rotation_y, 0.0)).to_quaternion()
    if scale is not None:
        obj.scale = scale
    keyframe_transform(obj, frame)


def interpolate_cycle(keys: tuple[tuple[float, float, float], ...], phase: float) -> tuple[float, float]:
    for (p0, x0, z0), (p1, x1, z1) in zip(keys, keys[1:]):
        if phase <= p1:
            t = (phase - p0) / (p1 - p0)
            t = t * t * (3.0 - 2.0 * t)
            return x0 + (x1 - x0) * t, z0 + (z1 - z0) * t
    return keys[-1][1], keys[-1][2]


def leg_points(hip: Vector, phase: float, near: bool):
    foot_keys = (
        (0.0, 1.05, 0.43),
        (0.125, 0.55, 0.72),
        (0.25, -0.35, 1.02),
        (0.375, -0.82, 1.38),
        (0.5, -0.48, 1.58),
        (0.625, 0.08, 1.46),
        (0.75, 0.7, 1.18),
        (0.875, 1.02, 0.72),
        (1.0, 1.05, 0.43),
    )
    foot_x, foot_z = interpolate_cycle(foot_keys, phase)
    foot = Vector((hip.x + foot_x, hip.y, foot_z))

    direction = Vector((foot.x - hip.x, 0.0, foot.z - hip.z))
    distance = max(0.001, direction.length)
    thigh_length = 1.48 if near else 1.44
    half = min(distance * 0.5, thigh_length - 0.001)
    bend = math.sqrt(max(0.0, thigh_length * thigh_length - half * half))
    perpendicular = Vector((-direction.z / distance, 0.0, direction.x / distance))
    knee = (hip + foot) * 0.5 + perpendicular * bend
    return knee, foot


def arm_points(shoulder: Vector, phase: float):
    elbow_keys = (
        (0.0, 0.68, -0.44),
        (0.25, 0.0, -0.82),
        (0.5, -0.68, -0.44),
        (0.75, 0.0, -0.82),
        (1.0, 0.68, -0.44),
    )
    wrist_keys = (
        (0.0, 1.02, -0.05),
        (0.25, 0.48, -0.6),
        (0.5, -0.28, -0.86),
        (0.75, -0.48, -0.6),
        (1.0, 1.02, -0.05),
    )
    elbow_x, elbow_z = interpolate_cycle(elbow_keys, phase)
    wrist_x, wrist_z = interpolate_cycle(wrist_keys, phase)
    elbow = shoulder + Vector((elbow_x, 0.0, elbow_z))
    wrist = shoulder + Vector((wrist_x, 0.0, wrist_z))
    return elbow, wrist


def look_at(obj, target: Vector):
    direction = target - obj.location
    obj.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()


def main() -> None:
    args = args_after_separator()
    output = Path(args.output).resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    frame_dir = output.with_suffix("")
    frame_dir.mkdir(parents=True, exist_ok=True)

    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)

    skin = material("Skin", (0.48, 0.22, 0.12, 1.0))
    hair = material("Hair", (0.025, 0.018, 0.015, 1.0))
    shirt = material("Shirt", (0.055, 0.15, 0.24, 1.0))
    shirt_far = material("ShirtFar", (0.025, 0.075, 0.12, 1.0))
    pants = material("Pants", (0.06, 0.065, 0.075, 1.0))
    pants_far = material("PantsFar", (0.025, 0.03, 0.04, 1.0))
    shoes = material("Shoes", (0.035, 0.025, 0.02, 1.0))
    sword_metal = material("SwordMetal", (0.12, 0.09, 0.065, 1.0), roughness=0.35)
    wall = material("Wall", (0.42, 0.44, 0.47, 1.0))
    floor_mat = material("Floor", (0.18, 0.19, 0.21, 1.0))

    torso = add_cube("Torso", (0.58, 0.34, 0.82), shirt)
    pelvis = add_cube("Pelvis", (0.48, 0.3, 0.36), pants)
    head = add_uv_sphere("Head", 0.38, skin)
    hair_obj = add_uv_sphere("Hair", 0.395, hair)
    hair_obj.scale = (1.0, 1.0, 0.76)
    nose = add_uv_sphere("Nose", 0.12, skin)

    bones = {
        "right_upper_arm": add_bone("RightUpperArm", 0.18, shirt_far),
        "right_lower_arm": add_bone("RightLowerArm", 0.145, skin),
        "left_upper_arm": add_bone("LeftUpperArm", 0.2, shirt),
        "left_lower_arm": add_bone("LeftLowerArm", 0.155, skin),
        "right_upper_leg": add_bone("RightUpperLeg", 0.27, pants_far),
        "right_lower_leg": add_bone("RightLowerLeg", 0.22, pants_far),
        "left_upper_leg": add_bone("LeftUpperLeg", 0.3, pants),
        "left_lower_leg": add_bone("LeftLowerLeg", 0.235, pants),
    }
    right_hand = add_uv_sphere("RightHand", 0.18, skin)
    left_hand = add_uv_sphere("LeftHand", 0.19, skin)
    right_foot = add_cube("RightFoot", (0.35, 0.2, 0.16), shoes)
    left_foot = add_cube("LeftFoot", (0.38, 0.21, 0.17), shoes)
    sword_sheath = add_cube("SwordSheath", (0.08, 0.12, 1.18), shoes)
    sword_grip = add_cube("SwordGrip", (0.095, 0.13, 0.3), sword_metal)
    sword_guard = add_cube("SwordGuard", (0.28, 0.13, 0.055), sword_metal)
    sword_pommel = add_uv_sphere("SwordPommel", 0.12, sword_metal)

    render_frames = args.warmup_frames + args.cycle_frames * args.cycle_count + (1 if args.include_loop_frame else 0)
    for index in range(render_frames):
        frame = index + 1
        in_warmup = index < args.warmup_frames
        phase_index = max(0, index - args.warmup_frames)
        phase = (phase_index / float(args.cycle_frames) + args.phase_offset) % 1.0
        warmup = index / float(max(1, args.warmup_frames)) if in_warmup else 1.0
        warmup = warmup * warmup * (3.0 - 2.0 * warmup)
        bob = warmup * 0.14 * (1.0 - math.cos(4.0 * math.pi * (phase - 0.125))) * 0.5
        pelvis_center = Vector((0.0, 0.0, 3.05 + bob))
        neck = Vector((0.12, 0.0, 4.67 + bob))
        head_center = Vector((0.22, 0.0, 5.22 + bob))
        right_shoulder = Vector((0.08, 0.17, 4.5 + bob))
        left_shoulder = Vector((0.16, -0.45, 4.5 + bob))
        right_hip = Vector((-0.08, 0.14, 3.0 + bob))
        left_hip = Vector((0.08, -0.3, 3.0 + bob))

        right_knee, right_ankle = leg_points(right_hip, phase, False)
        left_knee, left_ankle = leg_points(left_hip, (phase + 0.5) % 1.0, True)
        right_elbow, right_wrist = arm_points(right_shoulder, (phase + 0.5) % 1.0)
        left_elbow, left_wrist = arm_points(left_shoulder, phase)

        if in_warmup:
            right_knee = (right_hip + Vector((0.18, 0.0, -1.32))).lerp(right_knee, warmup)
            right_ankle = (right_hip + Vector((0.06, 0.0, -2.55))).lerp(right_ankle, warmup)
            left_knee = (left_hip + Vector((0.22, 0.0, -1.32))).lerp(left_knee, warmup)
            left_ankle = (left_hip + Vector((0.12, 0.0, -2.55))).lerp(left_ankle, warmup)
            right_elbow = (right_shoulder + Vector((0.02, 0.0, -0.78))).lerp(right_elbow, warmup)
            right_wrist = (right_shoulder + Vector((0.04, 0.0, -1.48))).lerp(right_wrist, warmup)
            left_elbow = (left_shoulder + Vector((0.05, 0.0, -0.78))).lerp(left_elbow, warmup)
            left_wrist = (left_shoulder + Vector((0.08, 0.0, -1.48))).lerp(left_wrist, warmup)

        keyframe_location(torso, Vector((0.16, 0.0, 3.86 + bob)), frame, (0.58, 0.34, 0.82), rotation_y=0.14)
        keyframe_location(pelvis, pelvis_center, frame, (0.48, 0.3, 0.36), rotation_y=0.04)
        keyframe_location(head, head_center, frame, (1.0, 1.0, 1.0))
        keyframe_location(hair_obj, head_center + Vector((-0.08, 0.04, 0.09)), frame, (1.02, 1.02, 0.78))
        keyframe_location(nose, head_center + Vector((0.36, -0.02, 0.015)), frame, (1.0, 0.72, 0.72))

        place_bone(bones["right_upper_arm"], right_shoulder, right_elbow, frame)
        place_bone(bones["right_lower_arm"], right_elbow, right_wrist, frame)
        place_bone(bones["left_upper_arm"], left_shoulder, left_elbow, frame)
        place_bone(bones["left_lower_arm"], left_elbow, left_wrist, frame)
        place_bone(bones["right_upper_leg"], right_hip, right_knee, frame)
        place_bone(bones["right_lower_leg"], right_knee, right_ankle, frame)
        place_bone(bones["left_upper_leg"], left_hip, left_knee, frame)
        place_bone(bones["left_lower_leg"], left_knee, left_ankle, frame)
        keyframe_location(right_hand, right_wrist, frame, (1.0, 0.8, 1.15))
        keyframe_location(left_hand, left_wrist, frame, (1.0, 0.8, 1.15))
        keyframe_location(right_foot, right_ankle + Vector((0.22, 0.0, -0.16)), frame, (0.35, 0.2, 0.16))
        keyframe_location(left_foot, left_ankle + Vector((0.22, 0.0, -0.17)), frame, (0.38, 0.21, 0.17))
        keyframe_location(sword_sheath, Vector((-0.48, 0.14, 3.76 + bob)), frame, (0.08, 0.12, 1.18), rotation_y=-0.08)
        keyframe_location(sword_grip, Vector((-0.60, 0.14, 5.19 + bob)), frame, (0.095, 0.13, 0.3), rotation_y=-0.08)
        keyframe_location(sword_guard, Vector((-0.58, 0.14, 4.92 + bob)), frame, (0.28, 0.13, 0.055), rotation_y=-0.08)
        keyframe_location(sword_pommel, Vector((-0.63, 0.14, 5.52 + bob)), frame, (1.0, 1.0, 1.0))

    bpy.ops.mesh.primitive_plane_add(size=30, location=(0.0, 0.0, 0.0))
    floor = bpy.context.object
    floor.data.materials.append(floor_mat)
    bpy.ops.mesh.primitive_plane_add(size=30, location=(0.0, 3.0, 6.0), rotation=(math.pi / 2.0, 0.0, 0.0))
    back_wall = bpy.context.object
    back_wall.data.materials.append(wall)

    bpy.ops.object.light_add(type="AREA", location=(-4.0, -4.0, 8.0))
    key = bpy.context.object
    key.data.energy = 420
    key.data.shape = "RECTANGLE"
    key.data.size = 5.0
    look_at(key, Vector((0.0, 0.0, 3.0)))
    bpy.ops.object.light_add(type="AREA", location=(4.0, -2.0, 5.0))
    fill = bpy.context.object
    fill.data.energy = 220
    fill.data.size = 4.0
    look_at(fill, Vector((0.0, 0.0, 3.0)))

    view_angle = math.radians(args.view_angle)
    camera_radius = 12.0
    bpy.ops.object.camera_add(location=(
        camera_radius * math.sin(view_angle),
        -camera_radius * math.cos(view_angle),
        3.1,
    ))
    camera = bpy.context.object
    camera.data.type = "ORTHO"
    camera.data.ortho_scale = 6.45
    look_at(camera, Vector((0.0, 0.0, 3.1)))
    bpy.context.scene.camera = camera

    scene = bpy.context.scene
    scene.frame_start = 1
    scene.frame_end = render_frames
    scene.render.engine = "BLENDER_EEVEE"
    scene.render.resolution_x = args.width
    scene.render.resolution_y = args.height
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.fps = args.fps
    scene.render.filepath = str(frame_dir / "frame_")
    scene.render.film_transparent = False
    scene.render.image_settings.color_mode = "RGB"
    scene.world.color = (0.055, 0.055, 0.06)
    scene.render.use_file_extension = True
    bpy.ops.render.render(animation=True)

    if args.alpha_mask_output:
        mask_dir = Path(args.alpha_mask_output).resolve()
        mask_dir.mkdir(parents=True, exist_ok=True)
        floor.hide_render = True
        back_wall.hide_render = True
        key.hide_render = True
        fill.hide_render = True
        scene.render.film_transparent = True
        scene.render.image_settings.color_mode = "RGBA"
        scene.render.filepath = str(mask_dir / "frame_")
        bpy.ops.render.render(animation=True)


if __name__ == "__main__":
    main()
