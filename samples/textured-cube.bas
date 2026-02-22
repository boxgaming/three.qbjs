Import String From "lib/lang/string.bas"
Import Dom From "lib/web/dom.bas"
Import THREE From "https://boxgaming.github.io/three.qbjs/three.qbjs"
Option Explicit

Screen NewImage(ResizeWidth-5, ResizeHeight-5, 32)

Dim As Object scene, camera, renderer, geometry, material, cube, light, texture, opts
' Create the scene and camera
scene = THREE.Scene
camera = THREE.PerspectiveCamera(75, Width / Height, 0.1, 1000)
camera.position.z = 5;

' Create the WebGL Renderer
opts.antialias = true
opts.alpha = true
opts.premultipliedAlpha = false
renderer = THREE.WebGLRenderer(opts)
THREE.SetSize renderer, Width, Height

' Add Lighitng
light = THREE.HemisphereLight(&HB1E1FF, &HB97A20, .5)
THREE.Add scene, light
light = THREE.DirectionalLight(&HFFFFEE, 2)
THREE.Set light.position, 0, 10, 0
THREE.Set light.target.position, -3, 0, 0
THREE.Add scene, light
THREE.Add scene, light.target

' Create a 3d box with the QBJS logo as it's texture
geometry = THREE.BoxGeometry(3, 3, 3)
texture = THREE.LoadTexture("logo-256.png")
opts.map = texture
material = THREE.MeshPhongMaterial(opts)
cube = THREE.Mesh(geometry, material)
THREE.Add scene, cube

Do
    Cls , RGB(50, 50, 50)
    THREE.render renderer, scene, camera
    cube.rotation.x = cube.rotation.x + .01
    cube.rotation.y = cube.rotation.y + .01
    Limit 60
Loop