Import THREE From "https://boxgaming.github.io/three.qbjs/three.qbjs"
Import GUI From "https://boxgaming.github.io/qbjs-lib/gui/lil-gui.bas"
Import Viewer From "https://boxgaming.github.io/three.qbjs/samples/primitives/sample-viewer.bas"

Viewer.Create "SphereGeometry", @CreateGeometry
Viewer.AddControl "radius", 1, 10, 7
Viewer.AddControl "widthSegments", 1, 50, 12, 1
Viewer.AddControl "heightSegments", 1, 50, 8, 1
Viewer.AddControl "phiStart", 0, 2, 2
Viewer.AddControl "phiLength", 0, 2, 2
Viewer.AddControl "thetaStart", 0, 1, 1
Viewer.AddControl "thetaLength", 0, 1, 1
Viewer.Start

Function CreateGeometry (opts As Object)

    CreateGeometry = THREE.SphereGeometry( _
        opts.radius, opts.widthSegments, opts.heightSegments, _
        PI * opts.phiStart, PI * opts.phiLength, _
        PI * opts.thetaStart, PI * opts.thetaLength)
        
End Function