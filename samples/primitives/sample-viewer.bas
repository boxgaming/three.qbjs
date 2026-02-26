Export Create, AddControl, Start
Option Explicit

Dim Shared As Object renderer, camera, scene, mesh, vgui, gobj, wireframe
Dim Shared As Function fnCreateGeometry

Sub Create (gtitle As String, fnCallback As Function)
    fnCreateGeometry = fnCallback
    
    Dim As Integer sw, sh
    sw = ResizeWidth - 5: sh = ResizeHeight - 5
    Screen NewImage(sw, sh, 32)
    
    Dim As Object light, geometry, material, opts
    ' Create the camera
    camera = THREE.PerspectiveCamera(75, sw / sh, 0.01, 1000)
    camera.position.z = 10
    
    ' Create the scene
    scene = THREE.Scene
    
    ' Create the lighting
    light = THREE.HemisphereLight(&HB1E1FF, &HB97A20, .5)
    THREE.Add scene, light
    light = THREE.DirectionalLight(&Hffffff, 1)
    THREE.Set light.position, -1, 2, 4
    THREE.Add scene, light
    
    ' Create the renderer
    opts.antialias = true
    'opts.alpha = true
    'opts.premultipliedAlpha = false
    renderer = THREE.WebGLRenderer(opts)
    THREE.SetSize renderer, sw, sh
    
    ' Create the GUI
    vgui = GUI.Create
    GUI.Title vgui, gtitle
    vgui.domElement.style.top = "1px"
    vgui.domElement.style.right = "1px"
End Sub

Sub RenderScene
    If Resize Then
        Dim As Integer sw, sh
        sw = ResizeWidth - 5: sh = ResizeHeight - 5
        Screen NewImage(sw, sh, 32)
        camera.aspect = sw / sh
        THREE.UpdateProjectionMatrix camera
        THREE.SetSize renderer,sw, sh
    End If
    mesh.rotation.x = mesh.rotation.x + .005
    mesh.rotation.y = mesh.rotation.y + .01
    THREE.Render renderer, scene, camera
End Sub

Sub UpdateMesh 
    Dim As Object material, geometry, geo, mat, opts
    geometry = fnCreateGeometry(gobj)
    If mesh.material = undefined Then
        opts.color = &H336699
        opts.side = THREE.DoubleSide
        material = THREE.MeshPhongMaterial(opts)
        mesh = THREE.Mesh(geometry, material)
        THREE.Add scene, mesh
        
        opts.color = &Hffffff
        'geo = THREE.EdgesGeometry(mesh.geometry)
        geo = THREE.WireframeGeometry(mesh.geometry)
        mat = THREE.LineBasicMaterial(opts)
        wireframe = THREE.LineSegments(geo, mat)
        THREE.Add mesh, wireframe
    Else
        mesh.geometry = geometry
        geo = THREE.WireframeGeometry(mesh.geometry)
        wireframe.geometry = geo        
    End If
End Sub

Sub AddControl (attribute As String, min, max, initial, stp)
    gobj[attribute] = initial
    GUI.Add vgui, gobj, attribute, min, max, stp
End Sub

Sub Start
    UpdateMesh
    GUI.OnChange vgui, @UpdateMesh 
    THREE.SetAnimationLoop renderer, @RenderScene
End Sub
