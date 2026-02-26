Import THREE From "https://boxgaming.github.io/three.qbjs/three.qbjs"
Import GUI From "https://boxgaming.github.io/qbjs-lib/gui/lil-gui.bas"
Import Viewer From "https://boxgaming.github.io/three.qbjs/samples/primitives/sample-viewer.bas"

Viewer.Create "CylinderGeometry", @CreateGeometry
Viewer.AddControl "radiusTop", 1, 10, 4
Viewer.AddControl "radiusBottom", 1, 10, 4
Viewer.AddControl "height", 1, 10, 8
Viewer.AddControl "radialSegments", 1, 50, 16, 1 
Viewer.AddControl "heightSegments", 1, 50, 1, 1 
Viewer.AddControl "openEnded", false, true, false
Viewer.AddControl "thetaStart", 0, 2, 2
Viewer.AddControl "thetaLength", 0, 2, 2
Viewer.Start

Function CreateGeometry (opts As Object)

    CreateGeometry = THREE.CylinderGeometry( _
        opts.radiusTop, opts.radiusBottom, opts.height, _
        opts.radialSegments, opts.heightSegments, _
        opts.openEnded, PI * opts.thetaStart, PI * opts.thetaLength)
        
End Function