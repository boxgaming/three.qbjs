Import THREE From "https://boxgaming.github.io/three.qbjs/three.qbjs"
Import GUI From "https://boxgaming.github.io/qbjs-lib/gui/lil-gui.bas"
Import Viewer From "https://boxgaming.github.io/three.qbjs/samples/primitives/sample-viewer.bas"

Viewer.Create "TetrahedronGeometry", @CreateGeometry
Viewer.AddControl "radius", 1, 10, 7
Viewer.AddControl "detail", 0, 5, 0, 1
Viewer.Start

Function CreateGeometry (opts As Object)

    CreateGeometry = THREE.TetrahedronGeometry( opts.radius, opts.detail )
    
End Function