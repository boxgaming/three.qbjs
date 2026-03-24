Import THREE From "https://boxgaming.github.io/three.qbjs/three.qbjs"
Import GUI From "https://boxgaming.github.io/qbjs-lib/gui/lil-gui.bas"
Import Viewer From "https://boxgaming.github.io/three.qbjs/samples/primitives/sample-viewer.bas"

Viewer.Create "BufferGeometry", @CreateGeometry
Viewer.Start

Function CreateGeometry (opts As Object)

    Dim As Object geometry, vertices, attribute, normals
    geometry = THREE.BufferGeometry
    
    vertices = THREE.Float32Array( _
        -5.0, -5.0,  5.0, _
         5.0, -5.0,  5.0, _
        -5.0,  5.0,  5.0, _
        -5.0,  5.0,  5.0, _
         5.0, -5.0,  5.0, _
         5.0,  5.0,  5.0)
    THREE.SetAttribute geometry, "position", THREE.BufferAttribute(vertices, 3) 
    THREE.ComputeVertexNormals geometry
    THREE.ComputeBoundingBox geometry
    THREE.Center geometry
    CreateGeometry = geometry 
    
End Function