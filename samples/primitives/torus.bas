Import THREE From "https://boxgaming.github.io/three.qbjs/three.qbjs"
Import GUI From "https://boxgaming.github.io/qbjs-lib/gui/lil-gui.bas"
Import Viewer From "https://boxgaming.github.io/three.qbjs/samples/primitives/sample-viewer.bas"

Viewer.Create "TorusGeometry", @CreateGeometry
Viewer.AddControl "radius", 1, 10, 5
Viewer.AddControl "tubeRadius", 1, 10, 2
Viewer.AddControl "radialSegments", 1, 50, 8, 1
Viewer.AddControl "tubularSegments", 1, 50, 24, 1
Viewer.Start

Function CreateGeometry (opts As Object)

    CreateGeometry = THREE.TorusGeometry( _
        opts.radius, opts.tubeRadius, _
        opts.radialSegments, opts.tubularSegments )
    
End Function