Import THREE From "https://boxgaming.github.io/three.qbjs/three.qbjs"
Import GUI From "https://boxgaming.github.io/qbjs-lib/gui/lil-gui.bas"
Import Viewer From "https://boxgaming.github.io/three.qbjs/samples/primitives/sample-viewer.bas"

Viewer.Create "PlaneGeometry", @CreateGeometry
Viewer.AddControl "width", 1, 10, 9
Viewer.AddControl "height", 1, 10, 9
Viewer.AddControl "widthSegments", 1, 10, 1, 1
Viewer.AddControl "heightSegments", 1, 10, 1, 1
Viewer.Start

Function CreateGeometry (opts As Object)

    CreateGeometry = THREE.PlaneGeometry( _
        opts.width, opts.height, _
        opts.widthSegments, opts.heightSegments)
        
End Function