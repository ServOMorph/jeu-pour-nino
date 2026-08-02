from __future__ import annotations

import argparse
import math
import sys

import bpy
from mathutils import Vector


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--output", required=True)
    values = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    return parser.parse_args(values)


def material(name, color):
    value = bpy.data.materials.new(name)
    value.diffuse_color = color
    return value


def look_at(obj, target):
    obj.rotation_euler = (target - obj.location).to_track_quat("-Z", "Y").to_euler()


def main():
    args = parse_args()
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    bpy.ops.import_scene.fbx(filepath=args.input)
    armature = next(obj for obj in bpy.context.scene.objects if obj.type == "ARMATURE")
    mesh = next(obj for obj in bpy.context.scene.objects if obj.type == "MESH")
    mesh.data.materials.clear()
    mesh.data.materials.append(material("Mesh", (0.08, 0.10, 0.12, 1.0)))
    bone_material = material("Bones", (0.95, 0.05, 0.02, 1.0))
    joint_material = material("Joints", (1.0, 0.75, 0.02, 1.0))
    debug_objects = [mesh]

    for bone in armature.data.bones:
        head = armature.matrix_world @ bone.head_local
        tail = armature.matrix_world @ bone.tail_local
        direction = tail - head
        bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.012, depth=direction.length)
        cylinder = bpy.context.object
        cylinder.location = (head + tail) * 0.5
        cylinder.rotation_euler = direction.to_track_quat("Z", "Y").to_euler()
        cylinder.data.materials.append(bone_material)
        debug_objects.append(cylinder)
        bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=6, radius=0.022, location=head)
        sphere = bpy.context.object
        sphere.data.materials.append(joint_material)
        debug_objects.append(sphere)

    for obj in debug_objects:
        obj.rotation_euler.x = math.pi / 2.0

    bpy.ops.object.light_add(type="AREA", location=(-2.0, -3.0, 3.0))
    light = bpy.context.object
    light.data.energy = 900
    light.data.size = 4.0
    look_at(light, Vector((0.0, 0.0, 0.0)))
    bpy.ops.object.camera_add(location=(0.0, -4.0, 0.0))
    camera = bpy.context.object
    camera.data.type = "ORTHO"
    camera.data.ortho_scale = 2.25
    look_at(camera, Vector((0.0, 0.0, 0.0)))

    scene = bpy.context.scene
    scene.camera = camera
    scene.render.engine = "BLENDER_EEVEE"
    scene.render.resolution_x = 700
    scene.render.resolution_y = 900
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.filepath = args.output
    scene.world.color = (0.8, 0.8, 0.8)
    bpy.ops.render.render(write_still=True)


if __name__ == "__main__":
    main()
