Import THREE From "https://boxgaming.github.io/three.qbjs/three.qbjs"
Import GUI From "https://boxgaming.github.io/qbjs-lib/gui/lil-gui.bas"
Import Viewer From "https://boxgaming.github.io/three.qbjs/samples/primitives/sample-viewer.bas"

Viewer.Create "TorusKnotGeometry", @CreateGeometry
Viewer.AddControl "radius", 1, 10, 3.5
Viewer.AddControl "tubeRadius", 1, 10, 1.5
Viewer.AddControl "radialSegments", 1, 30, 8, 1
Viewer.AddControl "tubularSegments", 1, 100, 64, 1
Viewer.AddControl "p", 1, 20, 2, 1
Viewer.AddControl "q", 1, 20, 3, 1
Viewer.Start

Function CreateGeometry (opts As Object)

    CreateGeometry = THREE.TorusKnotGeometry( _
        opts.radius, opts.tubeRadius, _
        opts.tubularSegments, opts.radialSegments, _
        opts.p, opts.q )
    
End Function