Import String From "lib/lang/string.bas"
Import Dom From "lib/web/dom.bas"
Import Console From "lib/web/console.bas"
Import THREE From "https://boxgaming.github.io/three.qbjs/three.qbjs"
'Import THREE From "three.bas"
Option Explicit

PrintMode KEEPBACKGROUND

Dim Shared pieces() ' distance between pieces .055
Dim Shared As Integer modelLoaded, skyboxLoaded, loadComplete, progress
Dim Shared As Object scene, loadingMesh, chessboard, composer, renderer, camera
Dim As Object mesh, geometry, material, opts, mopts, texture, light
Dim As Integer sw, sh
sw = ResizeWidth-5: sh = ResizeHeight-5
Screen NewImage(sw, sh, 32)

InitPieces

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

CreateLoadingMesh

texture = THREE.LoadTexture("https://boxgaming.github.io/three.qbjs/test/images/mirrored_hall.jpg", @OnLoadTexture)
texture.mapping = THREE.EquirectangularReflectionMapping
texture.colorSpace = THREE.SRGBColorSpace
scene.background = texture
      
' Add Lighting
Dim skyColor, groundColor, intensity
Dim As Object light
skyColor = &HB1E1FF    ' light blue
groundColor = &HB97A20 ' brownish orange
intensity = .5 
light = THREE.HemisphereLight(skyColor, groundColor, intensity)
THREE.Add scene, light

Dim clr
clr = &HFFFFEE;
intensity = 2
light = THREE.DirectionalLight(clr, intensity)
THREE.Set light.position, 0, 10, 0
THREE.Set light.target.position, -3, 0, 0
THREE.Add scene, light
THREE.Add scene, light.target

Dim gui As Object
gui = THREE.GUI
THREE.AddGUIItem gui, light, "intensity", 0, 10
THREE.AddGUIItem gui, light.target.position, "x", -10, 10
THREE.AddGUIItem gui, light.target.position, "y", -10, 10
THREE.AddGUIItem gui, light.target.position, "z", -10, 10

' Load a 3d model
THREE.LoadGLTF "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Assets/main/Models/ABeautifulGame/glTF-Binary/ABeautifulGame.glb", @OnLoadModel, @OnProgress
'THREE.LoadGLTF "https://boxgaming.github.io/three.qbjs/test/models/chess_board_and_figures.glb", @OnLoadModel, @OnProgress

' Create WebGL renderer
opts.antialias = true
opts.alpha = true
opts.premultipliedAlpha = false
renderer = THREE.WebGLRenderer(opts)
THREE.SetSize renderer, sw, sh

Dim raycaster As Object
raycaster = THREE.Raycaster

' Setup Post-processing
composer = THREE.EffectComposer(renderer)
THREE.SetSize composer, sw, sh
'THREE.SetPixelRatio composerio(Math.min(window.devicePixelRatio, 2));

Dim Shared As Object renderPass, outlinePass, effectFXAA
Dim Shared hoverObj
' render pass
renderPass = THREE.RenderPass(scene, camera)
THREE.AddPass composer, renderPass
' outline pass
outlinePass = THREE.OutlinePass(THREE.Vector2(sw, sh), scene, camera)
outlinePass.edgeStrength = 3.0
outlinePass.edgeGlow = 1.0
outlinePass.edgeThickness = 3.0
outlinePass.pulsePeriod = 0 
outlinePass.usePatternTexture = false             ' pattern texture for an object mesh
THREE.Set outlinePass.visibleEdgeColor, "#1abaff" ' set basic edge color
THREE.Set outlinePass.hiddenEdgeColor, "#333333"  ' set edge color when it hidden by other objects
THREE.AddPass composer, outlinePass
' shader
effectFXAA = THREE.ShaderPass(THREE.FXAAShader)
THREE.Set effectFXAA.uniforms.resolution.value, 1 / sw, 1 / sh
effectFXAA.renderToScreen = true
THREE.AddPass composer, effectFXAA

Do
    If Resize Then
        sw = ResizeWidth - 5: sh = ResizeHeight - 5
        Screen NewImage(sw, sh, 32)
        
        camera.aspect = sw / sh
        THREE.UpdateProjectionMatrix camera
        THREE.SetSize renderer,sw, sh
        THREE.SetSize composer,sw, sh
    End If
    
    Cls , RGB(75, 75, 75)
    THREE.Render composer, scene, camera
    If Not modelLoaded Or Not skyboxLoaded Then 
        ShowLoading
    ElseIf Not loadComplete Then
        loadComplete = -1
        THREE.Remove scene, loadingMesh
    Else
        Color 0
        Dim p As Object: p = GetNormalizedPos
        PrintString (22, 22), p.x + ", " + p.y
        THREE.SetFromCamera raycaster, p, camera
        Dim obj As Object
        obj = THREE.IntersectFirstObject(raycaster, chessboard.children)
        THREE.ArrayClear outlinePass.selectedObjects
        If obj Then 
            If pieces(obj.name) || pieces(obj.parent.name) Then
                If pieces(obj.parent.name) Then obj = obj.parent
                PrintString (22, 42), pieces(obj.name) + " - " + obj.position.x + ", " + obj.position.y + ", " + obj.position.z
                THREE.ArrayAdd outlinePass.selectedObjects, obj
            End If
        End If
    End If
    Limit 60
Loop

Sub OnLoadTexture ()
   skyboxLoaded = -1 
End Sub

Sub OnProgress (event)
    'Console.Log "onprogess: " + event.loaded + "/" + event.total
    progress = Round(event.loaded / event.total * 100)
End Sub

Sub OnLoadModel (model)
    'Console.Log THREE.DumpObject(model.scene)
    chessboard = model.scene
    THREE.Set chessboard.scale, 50, 50, 50
    THREE.Add scene, chessboard
    modelLoaded = -1
End Sub

Sub CreateLoadingMesh
    Dim As Object geometry, texture, material, opts
    geometry = THREE.BoxGeometry(3, 3, 3)
    texture = THREE.LoadTexture("logo-256.png")
    opts.map = texture
    material = THREE.MeshPhongMaterial(opts)
    
    loadingMesh = THREE.Mesh(geometry, material)
    loadingMesh.position.y = 5 
    THREE.Add scene, loadingMesh
End Sub

Sub ShowLoading
    loadingMesh.rotation.x = loadingMesh.rotation.x + .02
    loadingMesh.rotation.y = loadingMesh.rotation.y + .02
    Dim As Integer cx, cy
    cx = ResizeWidth \ 2 - 65 
    cy = ResizeHeight \ 2 + 70
    If Not modelLoaded Then PrintString (cx, cy), "Loading board... " + progress + "%"
    If Not skyboxLoaded Then PrintString (cx, cy+20), "Loading skybox..."
End Sub

Function GetNormalizedPos
    Dim As Object pos
    pos.x = _MouseX / _Width * 2 - 1
    pos.y = _MouseY / _Height * -2 + 1
    GetNormalizedPos = pos
End Function

Sub InitPieces
    Dim i As Integer
    For i = 1 To 8
        pieces("Pawn_Body_W" + i) = "WP" + i
        pieces("Pawn_Body_B" + i) = "BP" + i
    Next i
    For i = 1 To 2
        pieces("Castle_W" + i) = "WR" + i
        pieces("Castle_B" + i) = "BR" + i
        pieces("Knight_W" + i) = "WK" + i
        pieces("Knight_B" + i) = "BK" + i
        pieces("Bishop_W" + i) = "WB" + i
        pieces("Bishop_B" + i) = "BB" + i
    Next i
    pieces("King_W") = "WQ"
    pieces("King_B") = "BQ"
    pieces("Queen_W") = "WQ"
    pieces("Queen_B") = "BQ"
End Sub