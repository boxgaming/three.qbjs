Import THREE From "https://boxgaming.github.io/three.qbjs/three.qbjs"
Import GUI From "https://boxgaming.github.io/qbjs-lib/gui/lil-gui.bas"
Import Viewer From "https://boxgaming.github.io/three.qbjs/samples/primitives/sample-viewer.bas"

Viewer.Create "BoxGeometry", @CreateGeometry
Viewer.AddControl "width", 1, 10, 2
Viewer.AddControl "height", 1, 10, 2
Viewer.AddControl "depth", 1, 10, 2
Viewer.AddControl "widthSegments", 1, 10, 1, 1
Viewer.AddControl "heighSegments", 1, 10, 1, 1
Viewer.AddControl "depthSegments", 1, 10, 1, 1
Viewer.Start

Function CreateGeometry (opts As Object)
    ' Create the box
    CreateGeometry = THREE.BoxGeometry( _
        opts.width, opts.height, opts.depth, _
        opts.widthSegments, opts.heightSegments, opts.depthSegments)
End Function