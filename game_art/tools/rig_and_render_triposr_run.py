from __future__ import annotations

import argparse
import math
import sys
from pathlib import Path

import bpy
from mathutils import Matrix, Vector


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--mesh", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--blend-output", required=True)
    parser.add_argument("--width", type=int, default=520)
    parser.add_argument("--height", type=int, default=750)
    parser.add_argument("--frames", type=int, default=17)
    values = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    return parser.parse_args(values)


def add_edit_bone(armature, name, head, tail, parent=None, connected=False):
    bone = armature.edit_bones.new(name)
    bone.head = head
    bone.tail = tail
    bone.parent = parent
    bone.use_connect = connected
    return bone


def add_empty(name: str, location=(0.0, 0.0, 0.0)):
    value = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(value)
    value.empty_display_type = "PLAIN_AXES"
    value.empty_display_size = 0.12
    value.location = location
    return value


def look_at(obj, target: Vector):
    obj.rotation_euler = (target - obj.location).to_track_quat("-Z", "Y").to_euler()


def smooth(keys, phase):
    for (p0, x0, z0), (p1, x1, z1) in zip(keys, keys[1:]):
        if phase <= p1:
            t = (phase - p0) / (p1 - p0)
            t = t * t * (3.0 - 2.0 * t)
            return x0 + (x1 - x0) * t, z0 + (z1 - z0) * t
    return keys[-1][1], keys[-1][2]


def leg_points(hip: Vector, phase: float):
    keys = (
        (0.0, 0.92, 0.34),
        (0.125, 0.92, 0.34),
        (0.25, 0.15, 0.82),
        (0.375, -0.72, 1.35),
        (0.5, -0.55, 1.62),
        (0.625, 0.05, 1.48),
        (0.75, 0.70, 1.02),
        (0.875, 0.92, 0.34),
        (1.0, 0.92, 0.34),
    )
    x, z = smooth(keys, phase)
    ankle = Vector((hip.x + x, hip.y, z))
    direction = ankle - hip
    distance = max(direction.length, 1e-4)
    length = 1.48
    half = min(distance * 0.5, length - 1e-4)
    bend = math.sqrt(max(0.0, length * length - half * half))
    perpendicular = Vector((-direction.z / distance, 0.0, direction.x / distance))
    knee = (hip + ankle) * 0.5 + perpendicular * bend
    return knee, ankle


def arm_points(shoulder: Vector, phase: float):
    elbow_keys = (
        (0.0, 0.62, -0.42),
        (0.25, 0.0, -0.78),
        (0.5, -0.62, -0.42),
        (0.75, 0.0, -0.78),
        (1.0, 0.62, -0.42),
    )
    wrist_keys = (
        (0.0, 1.00, -0.04),
        (0.25, 0.45, -0.62),
        (0.5, -0.30, -0.86),
        (0.75, -0.48, -0.62),
        (1.0, 1.00, -0.04),
    )
    ex, ez = smooth(elbow_keys, phase)
    wx, wz = smooth(wrist_keys, phase)
    return shoulder + Vector((ex, 0.0, ez)), shoulder + Vector((wx, 0.0, wz))


def key_location(obj, frame, location):
    obj.location = location
    obj.keyframe_insert(data_path="location", frame=frame)


def assign_rigid_anatomical_weights(character, rig):
    group_names = [
        "pelvis", "spine", "chest", "neck", "head",
        "thigh.L", "calf.L", "foot.L", "upper_arm.L", "forearm.L", "hand.L",
        "thigh.R", "calf.R", "foot.R", "upper_arm.R", "forearm.R", "hand.R",
    ]
    groups = {name: character.vertex_groups.new(name=name) for name in group_names}
    for vertex in character.data.vertices:
        x, y, z = vertex.co
        side = "L" if y < 0.0 else "R"
        if x < -0.28 and z > 0.55:
            bone = "chest"
        elif z >= 5.0:
            bone = "head"
        elif z >= 4.72:
            bone = "neck"
        elif abs(y) > 0.43 and x > -0.28 and 2.25 < z < 4.78:
            if z >= 3.58:
                bone = f"upper_arm.{side}"
            elif z >= 2.78:
                bone = f"forearm.{side}"
            else:
                bone = f"hand.{side}"
        elif z < 3.08 and x > -0.28:
            if z < 0.48:
                bone = f"foot.{side}"
            elif z < 1.62:
                bone = f"calf.{side}"
            else:
                bone = f"thigh.{side}"
        elif z >= 4.18:
            bone = "chest"
        elif z >= 3.28:
            bone = "spine"
        else:
            bone = "pelvis"
        groups[bone].add([vertex.index], 1.0, "REPLACE")

    modifier = character.modifiers.new("Nino_Run_Armature", "ARMATURE")
    modifier.object = rig
    modifier.use_deform_preserve_volume = True


def main():
    args = parse_args()
    mesh_path = Path(args.mesh).resolve()
    output_dir = Path(args.output_dir).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    Path(args.blend_output).resolve().parent.mkdir(parents=True, exist_ok=True)

    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    bpy.ops.import_scene.gltf(filepath=str(mesh_path))
    meshes = [obj for obj in bpy.context.scene.objects if obj.type == "MESH"]
    if len(meshes) != 1:
        raise RuntimeError(f"Un seul maillage attendu, obtenu: {len(meshes)}")
    character = meshes[0]
    character.name = "Nino_Reconstructed"
    character.matrix_world = Matrix((
        (0.0, 0.0, 1.0, 0.0),
        (-1.0, 0.0, 0.0, 0.0),
        (0.0, -1.0, 0.0, 0.0),
        (0.0, 0.0, 0.0, 1.0),
    ))
    bpy.context.view_layer.objects.active = character
    character.select_set(True)
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    character.scale = (5.96, 5.96, 5.96)
    character.location.z = 2.897
    bpy.context.view_layer.objects.active = character
    character.select_set(True)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

    armature_data = bpy.data.armatures.new("Nino_Run_Rig")
    rig = bpy.data.objects.new("Nino_Run_Rig", armature_data)
    bpy.context.collection.objects.link(rig)
    rig.show_in_front = True
    bpy.context.view_layer.objects.active = rig
    rig.select_set(True)
    bpy.ops.object.mode_set(mode="EDIT")

    pelvis = add_edit_bone(armature_data, "pelvis", (0, 0, 2.78), (0, 0, 3.18))
    spine = add_edit_bone(armature_data, "spine", (0, 0, 3.02), (0.05, 0, 4.35), pelvis)
    chest = add_edit_bone(armature_data, "chest", (0.05, 0, 4.35), (0.10, 0, 4.78), spine, True)
    neck = add_edit_bone(armature_data, "neck", (0.10, 0, 4.78), (0.14, 0, 5.08), chest, True)
    add_edit_bone(armature_data, "head", (0.14, 0, 5.08), (0.18, 0, 5.68), neck, True)

    for side, y in (("L", -0.22), ("R", 0.22)):
        thigh = add_edit_bone(armature_data, f"thigh.{side}", (0, y, 3.0), (0.03, y, 1.52), pelvis)
        calf = add_edit_bone(armature_data, f"calf.{side}", (0.03, y, 1.52), (0.10, y, 0.18), thigh, True)
        add_edit_bone(armature_data, f"foot.{side}", (0.10, y, 0.18), (0.70, y, 0.18), calf, True)

        upper = add_edit_bone(armature_data, f"upper_arm.{side}", (0.08, y * 2.25, 4.52), (0.08, y * 2.25, 3.62), chest)
        fore = add_edit_bone(armature_data, f"forearm.{side}", (0.08, y * 2.25, 3.62), (0.10, y * 2.25, 2.78), upper, True)
        add_edit_bone(armature_data, f"hand.{side}", (0.10, y * 2.25, 2.78), (0.12, y * 2.25, 2.46), fore, True)

    bpy.ops.object.mode_set(mode="OBJECT")
    assign_rigid_anatomical_weights(character, rig)

    targets = {}
    for side in ("L", "R"):
        targets[f"ankle.{side}"] = add_empty(f"ankle_target.{side}")
        targets[f"knee.{side}"] = add_empty(f"knee_pole.{side}")
        targets[f"wrist.{side}"] = add_empty(f"wrist_target.{side}")
        targets[f"elbow.{side}"] = add_empty(f"elbow_pole.{side}")

        leg_ik = rig.pose.bones[f"calf.{side}"].constraints.new("IK")
        leg_ik.target = targets[f"ankle.{side}"]
        leg_ik.pole_target = targets[f"knee.{side}"]
        leg_ik.chain_count = 2
        leg_ik.use_stretch = False

        arm_ik = rig.pose.bones[f"forearm.{side}"].constraints.new("IK")
        arm_ik.target = targets[f"wrist.{side}"]
        arm_ik.pole_target = targets[f"elbow.{side}"]
        arm_ik.chain_count = 2
        arm_ik.use_stretch = False

        foot_copy = rig.pose.bones[f"foot.{side}"].constraints.new("COPY_ROTATION")
        foot_copy.target = targets[f"ankle.{side}"]
        foot_copy.target_space = "WORLD"
        foot_copy.owner_space = "WORLD"

    rig.pose.bones["spine"].rotation_mode = "XYZ"
    rig.pose.bones["spine"].rotation_euler[1] = 0.11
    rig.pose.bones["spine"].keyframe_insert(data_path="rotation_euler", frame=1)
    rig.pose.bones["spine"].keyframe_insert(data_path="rotation_euler", frame=args.frames)

    for frame in range(1, args.frames + 1):
        phase = 0.0 if frame == args.frames else (frame - 1) / 16.0
        bob = 0.08 * (1.0 - math.cos(4.0 * math.pi * (phase - 0.125))) * 0.5
        pelvis_pose = rig.pose.bones["pelvis"]
        pelvis_pose.location = (0.0, 0.0, bob)
        pelvis_pose.keyframe_insert(data_path="location", frame=frame)

        for side, y, offset in (("L", -0.22, 0.0), ("R", 0.22, 0.5)):
            hip = Vector((0.0, y, 3.0 + bob))
            knee, ankle = leg_points(hip, (phase + offset) % 1.0)
            elbow, wrist = arm_points(Vector((0.10, y * 2.25, 4.52 + bob)), (phase + 0.5 - offset) % 1.0)
            key_location(targets[f"ankle.{side}"], frame, ankle)
            key_location(targets[f"knee.{side}"], frame, knee)
            key_location(targets[f"wrist.{side}"], frame, wrist)
            key_location(targets[f"elbow.{side}"], frame, elbow)

    bpy.ops.object.light_add(type="AREA", location=(-4.0, -4.0, 8.0))
    key = bpy.context.object
    key.data.energy = 850
    key.data.shape = "DISK"
    key.data.size = 5.0
    look_at(key, Vector((0.0, 0.0, 3.0)))
    bpy.ops.object.light_add(type="AREA", location=(4.0, -2.0, 5.0))
    fill = bpy.context.object
    fill.data.energy = 550
    fill.data.size = 4.0
    look_at(fill, Vector((0.0, 0.0, 3.0)))

    bpy.ops.object.camera_add(location=(0.0, -12.0, 3.0))
    camera = bpy.context.object
    camera.data.type = "ORTHO"
    camera.data.ortho_scale = 6.35
    look_at(camera, Vector((0.0, 0.0, 3.0)))

    scene = bpy.context.scene
    scene.camera = camera
    scene.frame_start = 1
    scene.frame_end = args.frames
    scene.render.engine = "BLENDER_EEVEE"
    scene.render.resolution_x = args.width
    scene.render.resolution_y = args.height
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGB"
    scene.render.film_transparent = False
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
