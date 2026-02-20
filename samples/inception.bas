Export Render3DScene
Option Explicit

Dim Shared As Object scene, camera, renderer, canvasTexture
Dim Shared As Integer sw, sh
sw = Width: sh = Height
Init3DScene


Sub OnDrawScreen
    Cls , RGB(255, 50, 50)
    Circle (100, 100), 50, 14 
    Dim i As Integer
    For i = 1 To Height Step 5
        Circle (i*2, i), 5, 14 
    Next i
    'Limit 60
Loop

Sub Render3DScene
    canvasTexture.needsUpdate = true
    THREE.Render renderer, scene, camera
End Sub

Sub OnLoadModel (model)
    'Console.Echo THREE.DumpObject(model.scene)
    'THREE.Add scene, model.scene
    Dim As Object tv, s
tv = THREE.GetObjectByName(model.scene, "GLTF_SceneRootNode")
THREE.Set tv.scale, 30, 30, 30
tv.rotation.z = PI / 2
tv.rotation.y = -PI / 2
tv.position.z = -50
    'tv = THREE.GetObjectByName(model.scene, "tv")
    's = THREE.GetObjectByName(tv, "defaultMaterial_3")
    'Console.Echo THREE.DumpObject(tv)
    THREE.Add scene, tv
    'Console.Echo s.material
    '
's = THREE.GetObjectByName(tv, "Object_4")
s = THREE.GetObjectByName(tv, "Object_6")
    Dim As Object material, opts
    'opts.color = &HFF0000
    'opts.flatShading = true
canvasTexture = THREE.CanvasTexture(Dom.GetImage(0))
opts.map = canvasTexture
    material = THREE.MeshPhongMaterial(opts)
    s.material = material
    
    Dim win As Object
$If Javascript Then
        win = window;
$End If
    Dom.Event win, "resize", @OnResize
    OnResize
End Sub

Sub OnResize
    sw = ResizeWidth
    sh = ResizeHeight
    camera.aspect = sw / sh
    THREE.UpdateProjectionMatrix camera
    THREE.SetSize renderer, sw, sh
End Sub

Sub Init3DScene
    ' Create the camera
    camera = THREE.PerspectiveCamera(45, sw / sh, 0.1, 100)
    THREE.Set camera.position, 0, 10, 30
    
    
    ' Create the scene
    scene = THREE.Scene
    Dim skyColor, groundColor, intensity
    Dim As Object light
    skyColor = &HB1E1FF    ' light blue
    groundColor = &HB97A20 ' brownish orange
    intensity = 2
    light = THREE.HemisphereLight(skyColor, groundColor, intensity)
    THREE.Add scene, light
    
    Dim clr
    clr = &HFFFFEE;
    intensity = 3
    light = THREE.DirectionalLight(clr, intensity)
    THREE.Set light.position, 0, 10, 0
    THREE.Set light.target.position, -3, 0, 0
    THREE.Add scene, light
    THREE.Add scene, light.target
    
    ' Create WebGL renderer
    Dim opts As Object
    opts.antialias = true
    opts.alpha = true
    opts.premultipliedAlpha = false
    renderer = THREE.WebGLRenderer(opts, false)
    THREE.SetSize renderer, sw, sh
    
    ' Create the controls
    Dim As Object controls
    controls = THREE.OrbitControls(camera, renderer.domElement)'Dom.GetImage(0))
    THREE.Set controls.target, 0, 5, 0
    THREE.Update controls
    'Dom.Event controls, "start", @OnOCStart
    'Dom.Event controls, "end", @OnOCEnd
    
    ' Load the tv model
    'THREE.LoadGLTF "https://boxgaming.github.io/three.qbjs/test/models/crt_tv.glb", @OnLoadModel', @OnProgress
    THREE.LoadGLTF "https://boxgaming.github.io/three.qbjs/test/models/magnavox_19_crt_tv_-_rr1938_w122.glb", @OnLoadModel', @OnProgress
    
    ' Hide the QBJS canvas
    Dim qbcanvas As Object
    qbcanvas = Dom.GetImage(0)
    qbcanvas.style.display = "none"
End Sub