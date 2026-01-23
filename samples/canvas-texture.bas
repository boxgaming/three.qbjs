Import String From "lib/lang/string.bas"
Import Dom From "lib/web/dom.bas"
Import THREE From "https://boxgaming.github.io/three.qbjs/three.qbjs"
Option Explicit

PrintMode KEEPBACKGROUND
Color 15

' bplus canvas globals
Dim Shared As Single Rd, Gn, Bl
Dim Shared As Long NP, t
ReDim Shared As Long Px(1 To NP), Py(1 To NP), bcanvas

Dim Shared As Object renderer, camera, scene, mesh
Dim As Object geometry, material, opts, mopts, texture, light
Dim As Integer sw, sh
sw = _Width: sh = _Height

Setup

camera = THREE.PerspectiveCamera(70, sw / sh, 0.01, 10)
camera.position.z = 1

scene = THREE.Scene

geometry = THREE.BoxGeometry(0.5, 0.5, 0.5)
texture = THREE.CanvasTexture(Dom.GetImage(bcanvas))
mopts.map = texture
material = THREE.MeshPhongMaterial(mopts)
mesh = THREE.Mesh(geometry, material)
THREE.Add scene, mesh

light = THREE.DirectionalLight(&HFFFFFF, 3)
THREE.Set light.position, 0, 10, 2
THREE.Set light.target.position, -3, 0, -5 
THREE.Add scene, light
THREE.Add scene, light.target
    
opts.antialias = true
opts.alpha = true
opts.premultipliedAlpha = false
renderer = THREE.WebGLRenderer(opts)
THREE.SetSize renderer, sw, sh

Do
    mesh.rotation.x = mesh.rotation.x + .01
    mesh.rotation.y = mesh.rotation.y + .01
    
    Cls , RGB(30, 30, 30)
    RenderCanvas
    texture.needsUpdate = true
    THREE.Render renderer, scene, camera
    Limit 60
Loop

Sub Setup
    bcanvas = NewImage(150, 150, 32)
    
    Dim As Long i
    Rd = Rnd * Rnd: Gn = Rnd * Rnd: Bl = Rnd * Rnd
    NP = Int(Rnd * 50) + 3
    ReDim As Long Px(1 To NP), Py(1 To NP)
    For i = 1 To NP
        Px(i) = Int(Rnd * _Width(bcanvas))
        Py(i) = Int(Rnd * _Height(bcanvas))
    Next
End Sub

Sub RenderCanvas
    _Dest bcanvas
    Dim x, y, d, i, c, dist
    For y = 0 To _Height(bcanvas) - 1
        For x = 0 To _Width(bcanvas) - 1
            d = 10000
            For i = 1 To NP
                dist = _Hypot(x - Px(i), y - Py(i))
                If dist < d Then d = dist
            Next
            d = d + t
            c = _RGB32(127 + 127 * Sin(Rd * d), 127 + 127 * Sin(Gn * d), 127 + 127 * Sin(Bl * d))
            PSet (x, y), c
        Next
    Next
    t = t + 1
    _Dest 0
End Sub
