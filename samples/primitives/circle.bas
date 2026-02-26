Import THREE From "https://boxgaming.github.io/three.qbjs/three.qbjs"
Import GUI From "https://boxgaming.github.io/qbjs-lib/gui/lil-gui.bas"
Import Viewer From "https://boxgaming.github.io/three.qbjs/samples/primitives/sample-viewer.bas"

Viewer.Create "CircleGeometry", @CreateGeometry
Viewer.AddControl "radius", 1, 10, 7
Viewer.AddControl "segments", 1, 50, 24, 1
Viewer.AddControl "thetaStart", 0, 2, 2
Viewer.AddControl "thetaLength", 0, 2, 2
Viewer.Start

Function CreateGeometry (opts As Object)

    CreateGeometry = THREE.CircleGeometry( _
        opts.radius, opts.segments, _
        PI * opts.thetaStart, PI * opts.thetaLength)
        
End Function