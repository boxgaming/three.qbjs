Export Render3DScene, IsLoaded
Option Explicit

Dim Shared As Object scene, camera, renderer, canvasTexture, g, loadingMesh
Dim Shared As Integer sw, sh, modelsLoaded
sw = Width: sh = Height
Init3DScene

Sub Render3DScene
    canvasTexture.needsUpdate = true
    THREE.Render renderer, scene, camera
    If modelsLoaded < 2 Then ShowLoading
End Sub

Function IsLoaded
    Dim loaded As Integer
    If modelsLoaded = 2 Then loaded = -1
    IsLoaded = loaded
End Function

Sub OnLoadTV (model)
    'Console.Echo THREE.DumpObject(model.scene)
    Dim As Object tv, s
    tv = THREE.GetObjectByName(model.scene, "GLTF_SceneRootNode")
    THREE.Set tv.scale, 30, 30, 30
    tv.rotation.z = PI / 2
    tv.rotation.y = -PI / 2
    tv.position.z = -50
    THREE.Add scene, tv
    
    s = THREE.GetObjectByName(tv, "Object_6")
    Dim As Object material, opts
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
    modelsLoaded = modelsLoaded + 1
    If modelsLoaded = 2 Then THREE.Remove scene, loadingMesh
End Sub

Sub OnLoadNES (model)
    'Console.Echo THREE.DumpObject(model.scene)
    Dim nes As Object
    nes = THREE.GetObjectByName(model.scene, "GLTF_SceneRootNode")
    THREE.Add scene, nes
    THREE.Set nes.scale, 35, 35, 35
    nes.rotation.x = 0
    nes.rotation.y = -1
    nes.position.x = 10
    nes.position.z = -2
    nes.position.y = -8.2
    modelsLoaded = modelsLoaded + 1
    If modelsLoaded = 2 Then THREE.Remove scene, loadingMesh
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
    THREE.Set camera.position, -17.332125459906038, 0.33936720694222683, 22.941122980046135 
    THREE.Set camera.rotation, -0.0005593641765830877, -0.5744825819528998, -0.0003039587981861564
    
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
    clr = &HFFFFFF;
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
    THREE.Set controls.target, -2.5, 0, 0
    THREE.Update controls
    
    CreateLoadingMesh
    
    ' Load the tv model
    THREE.LoadGLTF "https://boxgaming.github.io/three.qbjs/test/models/magnavox_19_crt_tv_-_rr1938_w122.glb", @OnLoadTV
    THREE.LoadGLTF "https://boxgaming.github.io/three.qbjs/test/models/nes_console_and_controller.glb", @OnLoadNES
    
    ' Hide the QBJS canvas
    Dim qbcanvas As Object
    qbcanvas = Dom.GetImage(0)
    qbcanvas.style.display = "none"
End Sub

Sub CreateLoadingMesh
    Dim As Object geometry, texture, material, opts
    geometry = THREE.BoxGeometry(3, 3, 3)
    texture = THREE.LoadTexture("logo-256.png")
    opts.map = texture
    material = THREE.MeshPhongMaterial(opts)
    
    loadingMesh = THREE.Mesh(geometry, material)
    'loadingMesh.position.y = 5 
    THREE.Set loadingMesh.position, 8, -10, 5
    'THREE.Set loadingMesh.scale, 30, 30, 30
    'THREE.Set loadingMesh.position, -17.332125459906038, 0.33936720694222683, 22.941122980046135
    THREE.Add scene, loadingMesh
End Sub

Sub ShowLoading
    loadingMesh.rotation.x = loadingMesh.rotation.x + .02
    loadingMesh.rotation.y = loadingMesh.rotation.y + .02
    Dim As Integer cx, cy
    cx = ResizeWidth \ 2 - 65 
    cy = ResizeHeight \ 2 + 70
End Sub