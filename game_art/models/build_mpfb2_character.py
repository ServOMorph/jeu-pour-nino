import bpy
import math

OUTPUT_BLEND = r"D:\ServOMorph\Jeu pour Nino\game_art\models\player_adventurer_mpfb2_v1.blend"
OUTPUT_RENDER = r"D:\ServOMorph\Jeu pour Nino\game_art\models\player_adventurer_mpfb2_v1_preview.png"


def material(name, color, metallic=0.0, roughness=0.5, textured=False):
    result = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    result.use_nodes = True
    nodes = result.node_tree.nodes
    links = result.node_tree.links
    bsdf = nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    if textured and not nodes.get("CharacterNoise"):
        noise = nodes.new("ShaderNodeTexNoise")
        noise.name = "CharacterNoise"
        noise.inputs["Scale"].default_value = 7.0
        noise.inputs["Detail"].default_value = 4.0
        ramp = nodes.new("ShaderNodeValToRGB")
        ramp.color_ramp.elements[0].color = tuple(max(0.01, v * 0.3) for v in color) + (1.0,)
        ramp.color_ramp.elements[1].color = tuple(min(1.0, v * 1.2 + 0.03) for v in color) + (1.0,)
        bump = nodes.new("ShaderNodeBump")
        bump.inputs["Strength"].default_value = 0.22
        bump.inputs["Distance"].default_value = 0.08
        links.new(noise.outputs["Fac"], ramp.inputs["Fac"])
        links.new(ramp.outputs["Color"], bsdf.inputs["Base Color"])
        links.new(noise.outputs["Fac"], bump.inputs["Height"])
        links.new(bump.outputs["Normal"], bsdf.inputs["Normal"])
    return result


skin = material("Adventurer skin", (0.30, 0.12, 0.06), 0.0, 0.52, True)
cloth = material("Charcoal cloth", (0.018, 0.020, 0.026), 0.0, 0.82, True)
leather = material("Worn brown leather", (0.11, 0.040, 0.014), 0.0, 0.36, True)
leather_trim = material("Leather trim", (0.22, 0.075, 0.018), 0.0, 0.28, True)
metal = material("Aged bronze", (0.16, 0.055, 0.012), 0.78, 0.27, True)
steel = material("Sword steel", (0.16, 0.19, 0.23), 0.88, 0.18, True)
hair = material("Black hair", (0.006, 0.007, 0.010), 0.0, 0.42, True)


for item in list(bpy.data.objects):
    if item.name.startswith("ADV_") or item.name in {"Cube", "Light", "Camera", "ADV_Root", "ADV_Camera", "ADV_Target", "ADV_Key", "ADV_Fill", "ADV_Rim", "ADV_Ground"}:
        bpy.data.objects.remove(item, do_unlink=True)

human = bpy.data.objects.get("Human")
if human is None:
    raise RuntimeError("Base humaine MPFB2 introuvable")
if human.data.materials:
    human.data.materials[0] = skin
else:
    human.data.materials.append(skin)

root = bpy.data.objects.new("ADV_Root", None)
bpy.context.collection.objects.link(root)


def finish(obj, name, mat, bevel=0.0):
    obj.name = name
    obj.parent = root
    obj.data.materials.append(mat)
    if hasattr(obj.data, "polygons"):
        for polygon in obj.data.polygons:
            polygon.use_smooth = True
    if bevel:
        modifier = obj.modifiers.new("Soft edges", "BEVEL")
        modifier.width = bevel
        modifier.segments = 3
    return obj


def sphere(name, location, scale, mat, segments=32):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=max(16, segments // 2), location=location)
    obj = bpy.context.object
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return finish(obj, name, mat)


def cube(name, location, scale, mat, rotation=(0.0, 0.0, 0.0), bevel=0.025):
    bpy.ops.mesh.primitive_cube_add(location=location, rotation=rotation)
    obj = bpy.context.object
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return finish(obj, name, mat, bevel)


def cylinder(name, location, radius, depth, mat, rotation=(0.0, 0.0, 0.0)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=radius, depth=depth, location=location, rotation=rotation)
    return finish(bpy.context.object, name, mat, 0.02)


def curve(name, points, bevel, mat):
    data = bpy.data.curves.new(name, "CURVE")
    data.dimensions = "3D"
    data.bevel_depth = bevel
    data.bevel_resolution = 3
    spline = data.splines.new("BEZIER")
    spline.bezier_points.add(len(points) - 1)
    for point, co in zip(spline.bezier_points, points):
        point.co = co
        point.handle_left_type = "AUTO"
        point.handle_right_type = "AUTO"
    obj = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(obj)
    obj.parent = root
    obj.data.materials.append(mat)
    return obj


# Torso clothing and articulated cuirass.
sphere("ADV_Undershirt", (0, 0, 0.98), (0.49, 0.235, 0.51), cloth)
for index, z in enumerate((1.26, 1.14, 1.02, 0.90, 0.78)):
    cube("ADV_Cuirass_%02d" % index, (0, -0.265, z), (0.41 - index * 0.012, 0.045, 0.080), leather, bevel=0.045)
    cube("ADV_CuirassRim_%02d" % index, (0, -0.318, z + 0.064), (0.34 - index * 0.010, 0.012, 0.012), metal, bevel=0.008)
for z in (0.73, 0.65):
    cube("ADV_Belt", (0, -0.27, z), (0.48, 0.045, 0.025), leather_trim, bevel=0.012)
    cube("ADV_Buckle", (0, -0.325, z), (0.055, 0.012, 0.045), metal, bevel=0.006)
for side in (-1, 1):
    cube("ADV_CrossStrap", (side * 0.18, -0.315, 1.04), (0.045, 0.022, 0.34), leather_trim, rotation=(0, side * 0.45, 0), bevel=0.014)

# Shoulder armor, forearm guards and gloves.
for side in (-1, 1):
    x = side * 0.53
    for index in range(3):
        plate = sphere("ADV_Pauldron_%s_%d" % (side, index), (side * (0.50 + index * 0.025), -0.005, 1.23 - index * 0.06), (0.20 - index * 0.016, 0.19, 0.10), metal, 24)
        plate.rotation_euler = (0.0, side * 0.22, side * 0.1)
    for index, z in enumerate((0.91, 0.84, 0.77)):
        cube("ADV_Bracer_%s_%d" % (side, index), (side * 0.66, -0.01, z), (0.12, 0.14, 0.038), leather_trim, bevel=0.018)

# Tassets, leggings and boots.
for side in (-1, 1):
    sphere("ADV_Legging_%s" % side, (side * 0.21, 0.02, 0.43), (0.17, 0.16, 0.43), cloth)
    cube("ADV_Tasset_%s" % side, (side * 0.24, -0.25, 0.60), (0.14, 0.045, 0.20), leather, rotation=(0, side * 0.10, 0), bevel=0.035)
    sphere("ADV_Boot_%s" % side, (side * 0.21, -0.07, 0.13), (0.20, 0.29, 0.19), leather_trim)
    for index, z in enumerate((0.26, 0.18)):
        cube("ADV_BootStrap_%s_%d" % (side, index), (side * 0.21, -0.24, z), (0.17, 0.014, 0.018), metal, bevel=0.005)

# Cloth cape, segmented to preserve a ragged silhouette.
vertices = []
faces = []
columns = 9
rows = 8
for row in range(rows):
    t = row / (rows - 1)
    for col in range(columns):
        u = col / (columns - 1)
        x = -0.52 + u * 1.04 + 0.025 * math.sin(row * 2.0 + col)
        y = 0.20 + 0.075 * math.sin(t * 5.0 + u * 4.0)
        z = 1.42 - t * 1.25 - 0.055 * math.sin(u * math.pi) * t
        vertices.append((x, y, z))
for row in range(rows - 1):
    for col in range(columns - 1):
        start = row * columns + col
        faces.append((start, start + 1, start + columns + 1, start + columns))
mesh = bpy.data.meshes.new("ADV_CapeMesh")
mesh.from_pydata(vertices, [], faces)
cape = bpy.data.objects.new("ADV_Cape", mesh)
bpy.context.collection.objects.link(cape)
cape.parent = root
cape.data.materials.append(cloth)
solidify = cape.modifiers.new("Cape thickness", "SOLIDIFY")
solidify.thickness = 0.018
subdivision = cape.modifiers.new("Cape smoothing", "SUBSURF")
subdivision.levels = 1
for index, x in enumerate((-0.42, -0.24, 0.0, 0.24, 0.42)):
    cube("ADV_CapeTear_%d" % index, (x, 0.23, 0.22 - abs(x) * 0.18), (0.025, 0.012, 0.16 + abs(x) * 0.15), cloth, rotation=(0, x * 0.2, 0), bevel=0.008)

# Black hair: a cap and free curved strands rather than a helmet-like mass.
sphere("ADV_HairCap", (0, -0.015, 1.535), (0.30, 0.245, 0.19), hair, 36)
for index, x in enumerate((-0.24, -0.17, -0.10, -0.03, 0.05, 0.13, 0.20, 0.26)):
    curve("ADV_Hair_%02d" % index, [(x, -0.20, 1.60), (x * 1.08, -0.29, 1.52), (x * 1.18, -0.285, 1.43 + abs(x) * 0.08)], 0.018, hair)

# Sheathed sword on the back.
blade = cube("ADV_SwordBlade", (0.34, 0.26, 1.03), (0.034, 0.020, 0.45), steel, rotation=(0, 0.28, 0.05), bevel=0.010)
cylinder("ADV_SwordGrip", (0.13, 0.245, 1.40), 0.032, 0.22, leather_trim, rotation=(0, 0.28, 0.05))
cube("ADV_SwordGuard", (0.16, 0.24, 1.31), (0.13, 0.025, 0.018), metal, rotation=(0, 0.28, 0.05), bevel=0.006)

# Studio setup.
bpy.ops.mesh.primitive_plane_add(size=12, location=(0, 0, -0.055))
ground = bpy.context.object
ground.name = "ADV_Ground"
ground.data.materials.append(material("Studio ground", (0.012, 0.014, 0.019), 0.0, 0.9))
bpy.ops.object.empty_add(type="PLAIN_AXES", location=(0, 0, 0.85))
target = bpy.context.object
target.name = "ADV_Target"
bpy.ops.object.camera_add(location=(2.8, -5.5, 2.05))
camera = bpy.context.object
camera.name = "ADV_Camera"
bpy.context.scene.camera = camera
camera.data.lens = 62
constraint = camera.constraints.new("TRACK_TO")
constraint.target = target
constraint.track_axis = "TRACK_NEGATIVE_Z"
constraint.up_axis = "UP_Y"
for name, location, energy, color, size in (
    ("ADV_Key", (2.8, -3.5, 3.6), 900, (1.0, 0.68, 0.43), 3.0),
    ("ADV_Fill", (-3.0, -2.2, 2.1), 500, (0.32, 0.47, 1.0), 2.5),
    ("ADV_Rim", (1.2, 2.6, 3.2), 1100, (1.0, 0.32, 0.12), 2.0),
):
    bpy.ops.object.light_add(type="AREA", location=location)
    light = bpy.context.object
    light.name = name
    light.data.energy = energy
    light.data.shape = "DISK"
    light.data.size = size
    light.data.color = color
    tracking = light.constraints.new("TRACK_TO")
    tracking.target = target
    tracking.track_axis = "TRACK_NEGATIVE_Z"
    tracking.up_axis = "UP_Y"

scene = bpy.context.scene
scene.render.engine = "BLENDER_EEVEE_NEXT"
scene.render.resolution_x = 700
scene.render.resolution_y = 900
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.render.filepath = OUTPUT_RENDER
scene.world.color = (0.008, 0.010, 0.015)
bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_BLEND)
bpy.ops.render.render(write_still=True)
print("MPFB2_CHARACTER_OK", len(root.children), OUTPUT_BLEND, OUTPUT_RENDER)
