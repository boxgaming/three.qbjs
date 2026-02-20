Import String From "lib/lang/string.bas"
Import Dom From "lib/web/dom.bas"
Import THREE From "https://boxgaming.github.io/three.qbjs/three.qbjs"
Import Chess From "https://boxgaming.github.io/qbjs-lib/chess/js-chess-engine.bas"
Import GUI From "https://boxgaming.github.io/qbjs-lib/gui/lil-gui.bas"
Option Explicit

Const BLEFT = -0.21860846877098083
Const BTOP = -0.2200200706720352
Const BDIST = 0.06289908476173879

PrintMode KEEPBACKGROUND

Type GameConfig
    As Integer aiWhite, aiBlack, aiDelay
    As String turn, status
    As Sub onNewGame
End Type
Dim Shared config As GameConfig

Dim popts(6) As Object
Dim Shared selected, sceneMoving, aiMoving, aiThinking
Dim Shared As String lastMoveStart, lastMoveEnd
Dim Shared As Object pmap(), bmap()
Dim Shared As Integer modelLoaded, skyboxLoaded, loadComplete, progress
Dim Shared As Object scene, loadingMesh, chessboard, composer, renderer, camera, raycaster
Dim Shared As Object psel, pmoves(28), phist(2)
Dim As Object mesh, geometry, material, opts, mopts, texture, light
Dim As Integer sw, sh
sw = ResizeWidth-5: sh = ResizeHeight-5
Screen NewImage(sw, sh, 32)

' Initialize the game config and player options
config.aiBlack = 3
config.aiDelay = 3
config.turn = Chess.Turn
config.onNewGame = @OnNewGame
popts(1).value = 0: popts(1).name = "Human"
popts(2).value = 1: popts(2).name = "AI - Beginner"
popts(3).value = 2: popts(3).name = "AI - Easy"
popts(4).value = 3: popts(4).name = "AI - Intermediate"
popts(5).value = 4: popts(5).name = "AI - Advanced"
popts(6).value = 5: popts(6).name = "AI - Expert"

' Initialize the game GUI
Dim As Object cgui, ctrl, folder, ctrlTurn, ctrlStatus, ctrlDelay
cgui = GUI.Create
GUI.Title cgui, "QBJS 3D Chess"
ctrl = GUI.Add(cgui, config, "aiWhite")
GUI.Name ctrl, "White"
GUI.Options ctrl, popts
ctrl = GUI.Add(cgui, config, "aiBlack")
GUI.Name ctrl, "Black"
GUI.Options ctrl, popts
ctrlDelay = GUI.Add(cgui, config, "aiDelay", 1, 10)
GUI.Name ctrlDelay, "AI Turn Delay"
GUI.Disable ctrlDelay
ctrlTurn = GUI.Add(cgui, config, "turn")
GUI.Name ctrlTurn, "Turn"
GUI.Disable ctrlTurn
ctrlStatus = GUI.Add(cgui, config, "status")
GUI.Name ctrlStatus, "Status"
GUI.Disable ctrlStatus
folder = GUI.AddFolder(cgui, "Lighting")
GUI.Close folder

'InitPieces
InitBoard

' Create the camera
camera = THREE.PerspectiveCamera(45, sw / sh, 0.1, 100)
THREE.Set camera.position, 0, 10, 30

' Create the controls
Dim As Object controls
controls = THREE.OrbitControls(camera, Dom.GetImage(0))
THREE.Set controls.target, 0, 5, 0
THREE.Update controls
Dom.Event controls, "start", @OnOCStart
Dom.Event controls, "end", @OnOCEnd

' Create the scene
scene = THREE.Scene

CreateLoadingMesh

' Create the skybox
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
ctrl = GUI.Add(folder, light, "intensity", 0, 5)
GUI.Name ctrl, "Ambient"

Dim clr
clr = &HFFFFEE;
intensity = 2
light = THREE.DirectionalLight(clr, intensity)
THREE.Set light.position, 0, 10, 0
THREE.Set light.target.position, -3, 0, 0
THREE.Add scene, light
THREE.Add scene, light.target
ctrl = GUI.Add(folder, light, "intensity", 0, 5)
GUI.Name ctrl, "Directional"

' Create planes representing the current selection, last move, and available moves
psel = CreatePlane(&H1abaff)
Dim i As Integer
For i = 1 To UBound(pmoves)
    pmoves(i) = CreatePlane(&H1affba)
Next i
phist(1) = CreatePlane(&Hffff1a)
phist(2) = CreatePlane(&Hffff1a)

' Load the chessboard model
THREE.LoadGLTF "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Assets/main/Models/ABeautifulGame/glTF-Binary/ABeautifulGame.glb", @OnLoadModel, @OnProgress

' Add the new game button
ctrl = GUI.Add(cgui, config, "onNewGame")
GUI.Name ctrl, "New Game"

' Create WebGL renderer
opts.antialias = true
opts.alpha = true
opts.premultipliedAlpha = false
renderer = THREE.WebGLRenderer(opts)
THREE.SetSize renderer, sw, sh

raycaster = THREE.Raycaster

' Setup Post-processing
composer = THREE.EffectComposer(renderer)
THREE.SetSize composer, sw, sh

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
  
    ' Update the GUI with the current status
    config.turn = Chess.Turn
    GUI.UpdateDisplay ctrlTurn
    If Chess.IsCheckMate Then
        config.status = "Check Mate"
    ElseIf Chess.IsCheck Then
        config.status = "Check"
    Else
        config.status = ""
    End If
    If config.aiWhite And config.aiBlack Then
        GUI.Enable ctrlDelay
    Else
        GUI.Disable ctrlDelay
    End If
    GUI.UpdateDisplay ctrlStatus
    
    ' Render the scene
    Cls , RGB(75, 75, 75)
    THREE.Render composer, scene, camera
    
    ' If the 3d model is still loading show a loading cube
    If Not modelLoaded Or Not skyboxLoaded Then 
        ShowLoading
        
    ' Once loading is compelete remove the loading cube
    ElseIf Not loadComplete Then
        loadComplete = -1
        THREE.Remove scene, loadingMesh
        
    ' Show a glowing outline when the mouse hovers over a moveable piece
    ElseIf sceneMoving = 0 Then
        THREE.ArrayClear outlinePass.selectedObjects
        Dim p As Object: p = ObjectAtPointer
        If p Then
            THREE.ArrayAdd outlinePass.selectedObjects, p
        End If
    End If
    
    ' Perform an AI move, if necessary
    If loadComplete And Not aiMoving Then
        If Chess.Turn = "white" Then
            If config.aiWhite And Not Chess.IsFinished Then 
                aiMoving = -1: aiThinking = -1
                SetTimeout @AIMove, 10
            End If
        Else
            If config.aiBlack And Not Chess.IsFinished Then 
                aiMoving = -1: aiThinking = -1
                SetTimeout @AIMove, 10
            End If
        End If
    End If
    
    'If aiMoving Then
    If aiThinking Then
        'PrintString (20, 20), Chess.Turn + " is thinking..."
        DrawText 20, 20, Chess.Turn + " is thinking..."
    ElseIf Chess.IsFinished Then
        'PrintString (Width \ 2 - 30, Height \ 2 + 8), "GAME OVER"
        DrawText Width \ 2 - 30, Height \ 2 + 8, "GAME OVER"
    End If
    Limit 60
Loop

Sub DrawText (x As Integer, y As Integer, text As String)
    Color 0:  PrintString (x+1, y+1), text 
    Color 15: PrintString (x, y), text
End Sub

Sub AIMove
    Dim level
    If Chess.Turn = "white" Then level = config.aiWhite Else level = config.aiBlack
    Dim m As Object
    Chess.AIMove level - 1
    ReDim hist(0) As Object
    hist = Chess.History
    lastMoveStart = hist(UBound(hist)).from
    lastMoveEnd = hist(UBound(hist)).to
    ClearSelection
    UpdateBoard
    aiThinking = 0
    If config.aiWhite And config.aiBlack Then Delay config.aiDelay
    aiMoving = 0
End Sub

Sub OnNewGame
    lastMoveStart = ""
    lastMoveEnd = ""
    phist(1).position.z = -1000
    phist(2).position.z = -1000
    Chess.NewGame
    ClearSelection
    UpdateBoard
End Sub

Function CreatePlane(clr As Long)
    Dim As Object popts, plane, geometry, material
    popts.color = clr
    popts.side = THREE.DoubleSide
    geometry = THREE.PlaneGeometry(.064, .064)
    material = THREE.MeshBasicMaterial(popts)
    material.transparent = true
    material.opacity = .4
    plane = THREE.Mesh(geometry, material)
    plane.rotation.x = PI * -.5
    plane.position.y = .017
    plane.position.z = -1000
    CreatePlane = plane
End Function

Function ObjectAtPointer
    Dim result
    Dim p As Object: p = GetNormalizedPos
    THREE.SetFromCamera raycaster, p, camera
    Dim objects As Object
    objects = THREE.IntersectObjects(raycaster, chessboard.children)
    If THREE.ArrayLength(objects) > 0 Then 
        Dim i As Integer
        For i = 0 To THREE.ArrayLength(objects) - 1
            Dim obj As Object: obj = THREE.ArrayItem(objects, i).object
            If obj.bpos || obj.parent.bpos Then
                If obj.parent.bpos Then obj = obj.parent
                    If obj.pcolor = Chess.Turn Then
                    result = obj
                    Exit For
                End If
            ElseIf obj.nextMove Then
                result = obj
                Exit For
            End If
        Next i
    End If
    ObjectAtPointer = result
End Function

Sub OnOCStart
    sceneMoving = Timer
    THREE.ArrayClear outlinePass.selectedObjects
End Sub

Sub OnOCEnd
    Dim duration: duration = Timer - sceneMoving
    
    ' If the mouse was only held down for a short time, let's treat it as a click
    If duration < .2 Then
        Dim o: o = ObjectAtPointer
        If o Then
            If o.nextMove Then
                ' This is a selection square
                OnMoveSelected o.nextMove
            Else
                ' It's a piece
                OnSelectPiece o
            End If
        End If
    End If
    
    sceneMoving = 0
End Sub

Sub OnSelectPiece(p)
    ClearSelection
    If selected <> p Then
        selected = p
        Dim square As Object: square = bmap(p.bpos)
        psel.position.x = square.x' - .001
        psel.position.z = square.z
        ReDim moves(0) As String
        moves = Chess.Moves(p.bpos)
        Dim i As Integer
        For i = 1 To UBound(moves)
            square = bmap(moves(i))
            pmoves(i).position.x = square.x
            pmoves(i).position.z = square.z
            pmoves(i).nextMove = moves(i)
        Next i
    End If
End Sub

Sub ClearSelection
    selected = 0
    psel.position.z = -1000
    Dim i As Integer
    For i = 1 To UBound(pmoves)
        pmoves(i).position.z = -1000
        pmoves(i).nextMove = 0
    Next i
End Sub

Sub OnMoveSelected (toSquare As String)
    Dim fromSquare As String
    fromSquare = selected.bpos
    If Chess.Move(fromSquare, toSquare) Then
        lastMoveStart = fromSquare
        lastMoveEnd = toSquare
        ClearSelection
        UpdateBoard
    End If
End Sub

Sub OnLoadTexture ()
   skyboxLoaded = -1 
End Sub

Sub OnProgress (event)
    progress = Round(event.loaded / event.total * 100)
End Sub

Sub OnLoadModel (model)
    'Console.Log THREE.DumpObject(model.scene)
    chessboard = model.scene
    THREE.Set chessboard.scale, 50, 50, 50
    THREE.Add scene, chessboard
    modelLoaded = -1
    
    AddPiece "R", 1, "Castle_W1"
    AddPiece "R", 2, "Castle_W2"
    AddPiece "N", 1, "Knight_W1", -1
    AddPiece "N", 2, "Knight_W2", -1
    AddPiece "B", 1, "Bishop_W1"
    AddPiece "B", 2, "Bishop_W2"
    AddPiece "K", 1, "King_W"
    AddPiece "Q", 1, "Queen_W"
    Dim i As Integer
    For i = 1 To 8
        AddPiece "P", i, "Pawn_Body_W" + i
    Next i
    AddPiece "r", 1, "Castle_B1"
    AddPiece "r", 2, "Castle_B2"
    AddPiece "n", 1, "Knight_B1", -1
    AddPiece "n", 2, "Knight_B2", -1
    AddPiece "b", 1, "Bishop_B1", -1
    AddPiece "b", 2, "Bishop_B2", -1
    AddPiece "k", 1, "King_B"
    AddPiece "q", 1, "Queen_B"
    Dim i As Integer
    For i = 1 To 8
        AddPiece "p", i, "Pawn_Body_B" + i
    Next i
    
    UpdateBoard
    
    THREE.Add chessboard, psel
    Dim i As Integer
    For i = 1 To UBound(pmoves)
        THREE.Add chessboard, pmoves(i)
    Next i
    THREE.Add chessboard, phist(1)
    THREE.Add chessboard, phist(2)
End Sub

Sub AddPiece (p As String, idx As Integer, objectName As String, rotate As Integer)
    pmap(p, idx) = THREE.GetObjectByName(chessboard, objectName)
    If p = UCase$(p) Then
        pmap(p, idx).pcolor = "white"
    Else
        pmap(p, idx).pcolor = "black"
    End If
    If rotate Then pmap(p, idx).rotation.y = PI
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
    'If Not modelLoaded Then PrintString (cx, cy), "Loading board... " + progress + "%"
    'If Not skyboxLoaded Then PrintString (cx, cy+20), "Loading skybox..."
    If Not modelLoaded Then DrawText cx, cy, "Loading board... " + progress + "%"
    If Not skyboxLoaded Then DrawText cx, cy+20, "Loading skybox..."
End Sub

Function GetNormalizedPos
    Dim As Object pos
    pos.x = MouseX / Width * 2 - 1
    pos.y = MouseY / Height * -2 + 1
    GetNormalizedPos = pos
End Function

Sub UpdateBoard
    Dim As Integer rank, file, lastPiece(), i, j
    Dim As String bstate(), p, s, plist
    
    ' Move all of the pieces out of view
    plist = "KQBNRPkqbnrp"
    For i = 1 To Len(plist)
        p = Mid$(plist, i, 1)
        j = 1
        Dim As Object o
        o = pmap(p, j)
        While o.position
            o.position.z = -1000
            j = j + 1
            o = pmap(p, j)
        Wend
    Next i
    
    ' Get the current state of the board pieces from the chess API
    bstate = Chess.BoardPieces
    
    ' Place all active pieces on the board
    For file = 8 To 1 Step -1
        For rank = Asc("A") To Asc("H")
            s = Chr$(rank) + file
            p = bstate(s)
            If p <> "" Then
                lastPiece(p) = lastPiece(p) + 1
                Dim piece As Object
                piece = pmap(p, lastPiece(p))
                If piece.position = undefined Then
                    piece = THREE.Clone(pmap(p, 1), false)
                    THREE.Add chessboard, piece
                    pmap(p, lastPiece(p)) = piece
                End If
                piece.position.x = bmap(s).x
                piece.position.z = bmap(s).z
                piece.bpos = s
            End If
        Next rank
    Next file
    
    If lastMoveStart <> "" Then
        phist(1).position.x = bmap(lastMoveStart).x
        phist(1).position.z = bmap(lastMoveStart).z
        phist(2).position.x = bmap(lastMoveEnd).x
        phist(2).position.z = bmap(lastMoveEnd).z
    End If
End Sub

' Initialize the chessboard, calculating the position of each square
Sub InitBoard
    Dim x, z
    Dim As Integer i, file, rank
    Dim As String square
    z = BTOP
    For rank = 8 To 1 Step -1 '1 To 8
        file = Asc("H")
        x = BLEFT
        For i = 1 To 8
            square = Chr$(file) + rank
            bmap(square).x = x
            bmap(square).z = z
            x = x + BDIST
            file = file - 1 
        Next i
        z = z + BDIST
    Next rank
End Sub

Sub SetTimeout (fn As Sub, delayMillis)
$If Javascript Then
    window.setTimeout(fn, delayMillis)
$End If
End Sub
