Import String From "lib/lang/string.bas"
Import Dom From "lib/web/dom.bas"
Import Console From "lib/web/console.bas"
Import THREE From "https://boxgaming.github.io/three.qbjs/three.qbjs"
Option Explicit

PrintMode KEEPBACKGROUND

Dim Shared As Integer modelLoaded, skyboxLoaded
Dim Shared As Object scene
Dim As Object renderer, camera, mesh
Dim As Object geometry, material, opts, mopts, texture, light
Dim As Integer sw, sh
sw = ResizeWidth-5: sh = ResizeHeight-5
Screen NewImage(sw, sh, 32)

' Create the camera
camera = THREE.PerspectiveCamera(45, sw / sh, 0.1, 100)
THREE.Set camera.position, 0, 10, 30

' Create the controls
Dim As Object controls
controls = THREE.OrbitControls(camera, Dom.GetImage(0))
THREE.Set controls.target, 0, 5, 0
THREE.Update controls

' Create the scene
scene = THREE.Scene

texture = THREE.LoadTexture("https://boxgaming.github.io/three.qbjs/test/images/mirrored_hall.jpg", @OnLoadTexture)
texture.mapping = THREE.EquirectangularReflectionMapping
texture.colorSpace = THREE.SRGBColorSpace
scene.background = texture
      
' Add Lighting
Dim skyColor, groundColor, intensity
Dim As Object light
skyColor = &HB1E1FF    ' light blue
groundColor = &HB97A20 ' brownish orange
intensity = 1
light = THREE.HemisphereLight(skyColor, groundColor, intensity)
THREE.Add scene, light

Dim clr
clr = &HFFFFEE;
intensity = 1.5
light = THREE.DirectionalLight(clr, intensity)
THREE.Set light.position, 0, 10, 0
THREE.Set light.target.position, -5, 0, 0
THREE.Add scene, light
THREE.Add scene, light.target

' Load a 3d model
THREE.LoadGLTF "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Assets/main/Models/ABeautifulGame/glTF-Binary/ABeautifulGame.glb", @OnLoadModel

' Create WebGL renderer
opts.antialias = true
opts.alpha = true
opts.premultipliedAlpha = false
renderer = THREE.WebGLRenderer(opts)
THREE.SetSize renderer, sw, sh

Color 0
Do
    Cls , RGB(160, 200, 255)
    THREE.Render renderer, scene, camera
    If Not modelLoaded Then PrintString (22, 22), "Loading board..."
    If Not skyboxLoaded Then PrintString (22, 42), "Loading skybox..."
    Limit 60
Loop

Sub OnLoadTexture ()
   skyboxLoaded = -1 
End Sub

Sub OnLoadModel (model)
    'Console.Echo THREE.DumpObject(model.scene)
    THREE.Add scene, model.scene
    THREE.Set model.scene.scale, 50, 50, 50
    modelLoaded = -1
End Sub