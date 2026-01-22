Option Explicit
Dim Shared As Object __THREE, __GLTFLoader, __OrbitControls
Init

Export RepeatWrapping, NearestFilter, SRGBColorSpace, DoubleSide

Export CreateScene, CreatePerspectiveCamera
Export CreatePlaneGeometry, CreateBoxGeometry
Export CreateAmbientLight, CreateDirectionalLight, CreateHemisphereLight
Export CreateTexture, CreateFog, CreateColor
Export CreateMesh, CreateMeshBasicMaterial, CreateMeshNormalMaterial, CreateMeshPhongMaterial
Export CreateWebGLRenderer, CreateOrbitControls
Export SetPosition, SetTarget, SetSize, SetRepeat
Export SceneAdd, Render, SetAnimationLoop, Update, GetObjectByName
Export LoadGLTF

Export DumpObject

' "Constants"
Function RepeatWrapping: RepeatWrapping = __THREE.RepeatWrapping: End Function
Function NearestFilter:  NearestFilter  = __THREE.NearestFilter:  End Function
Function SRGBColorSpace: SRGBColorSpace = __THREE.SRGBColorSpace: End Function
Function DoubleSide:     DoubleSide     = __THREE.DoubleSide:     End Function


Function CreateScene
$If Javascript Then
    return new __THREE.Scene();
$End If
End Function

Function CreatePerspectiveCamera (fov, aspect, near, far)
$If Javascript Then
    return new __THREE.PerspectiveCamera(fov, aspect, near, far);
$End If
End Function

Function CreateColor (clr)
$If Javascript Then
    return new __THREE.Color(clr);
$End If
End Function

Function CreateFog (clr, near, far)
$If Javascript Then
    return new __THREE.Fog(clr, near, far);
$End If
End Function

Function CreatePlaneGeometry (width, height)
$If Javascript Then
    return new __THREE.PlaneGeometry(width, height);
$End If
End Function

Function CreateBoxGeometry (width, height, depth, widthSegments, heightSegments, depthSegments) 
$If Javascript Then
    return new __THREE.BoxGeometry(width, height, depth, widthSegments, heightSegments, depthSegments);
$End If
End Function

Function CreateAmbientLight (clr, intensity)
$If Javascript Then
    return new __THREE.AmbientLight(clr, intensity);
$End If
End Function

Function CreateDirectionalLight (clr, intensity)
$If Javascript Then
    return new __THREE.DirectionalLight(clr, intensity);
$End If
End Function

Function CreateHemisphereLight (clr, skyColor, groundColor, intensity)
$If Javascript Then
    return new __THREE.HemisphereLight(clr, skyColor, groundColor, intensity);
$End If
End Function

Function CreateMesh (geometry, material)
$If Javascript Then
    return new __THREE.Mesh (geometry, material);
$End If
End Function

Function CreateMeshBasicMaterial (opts)
$If Javascript Then
    return new __THREE.MeshBasicMaterial(opts);
$End If
End Function

Function CreateMeshNormalMaterial
$If Javascript Then
    return new __THREE.MeshNormalMaterial();
$End If
End Function

Function CreateMeshPhongMaterial (opts)
$If Javascript Then
    return new __THREE.MeshPhongMaterial(opts);
$End If
End Function

Function CreateOrbitControls(camera, canvas)
$If Javascript Then
    var controls = __OrbitControls(camera, canvas);
    return controls;
$End If
End Function

Sub Update (element)
$If Javascript Then
    element.update();
$End If
End Sub

Function CreateTexture(path)
$If Javascript Then
    var loader = new __THREE.TextureLoader();
    var texture = loader.load(path);
    texture.colorSpace = __THREE.SRGBColorSpace;
    return texture;
$End If
End Function

Function CreateWebGLRenderer (opts)
    Dim renderer As Object
$If Javascript Then
    renderer = new __THREE.WebGLRenderer (opts);
$End If
    renderer.domElement.className = "qbjs-3js-canvas"
    renderer.domElement.style.display = "none"
    Dom.Add renderer.domElement, Dom.Container
    CreateWebGLRenderer = renderer
End Function

Sub LoadGLTF (path, callback)
$If Javascript Then
    //'const loader = new __GLTFLoader();
    __GLTFLoader.load(path, callback);
$End If
End Sub

Sub SetPosition (element, x, y, z) 
$If Javascript Then
    element.position.set(x, y, z);
$End If
End Sub

Sub SetTarget (element, x, y, z) 
$If Javascript Then
    element.target.set(x, y, z);
$End If
End Sub

Sub SceneAdd (scene, mesh)
$If Javascript Then
    scene.add(mesh);
$End If
End Sub

Sub SetSize (element, width, height)
$If Javascript Then
    element.setSize(width, height);
$End If
End Sub

Sub SetRepeat (element, width, height)
$If Javascript Then
    element.repeat.set(width, height);
$End If
End Sub

Function GetObjectByName (parent, objectName As String)
$If Javascript Then
    return parent.getObjectByName(objectName);
$End If
End Function

Sub Render (renderer, scene, camera)
$If Javascript Then
    renderer.render(scene, camera);
    GX.ctx().drawImage(renderer.domElement, 0, 0);
$End If
End Sub

Sub SetAnimationLoop (renderer, callback)
$If Javascript Then
    renderer.setAnimationLoop(callback);
$End If
End Sub

' Utilities
' ---------------------------------------------------------------
Function DumpObject (rootObj)
$If Javascript Then
    return dumpObject(rootObj).join("\n");
    
    function dumpObject(obj, lines = [], isLast = true, prefix = "") {
      var localPrefix; if (isLast) { localPrefix = "\\-"; } else { localPrefix =  "|-";}
      if (prefix) {  
          lines.push(prefix + localPrefix + (obj.name || "*no-name*") + " [" + obj.type + "]");
      } else {
          lines.push(prefix + "" + (obj.name || "*no-name*") + " [" + obj.type + "]");
      }
      var newPrefix; if (isLast) { newPrefix = prefix + " "; } else { newPrefix = prefix +  "| "; }
      const lastNdx = obj.children.length - 1;
      obj.children.forEach((child, ndx) => {
        const isLast = ndx === lastNdx;
        dumpObject(child, lines, isLast, newPrefix);
      });
      return lines;
    }
$End If
End Function

' Setup
' ---------------------------------------------------------------
Sub Init
$If Javascript Then
    var elements = document.querySelectorAll(".qbjs-3js-canvas");
    elements.forEach(el => { el.remove(); });
    console.log(window.__THREE);
$End If
    If window.__THREE Then 
        __THREE = window.__THREE;
        __GLTFLoader = window.__GLTFLoader
        __OrbitControls = window.__OrbitControls
        Exit Sub
    End If

    Dim As Object s, c
    c = Dom.Container
    s = Dom.Create("script", document.head)
        
    Dim txt As String
    txt = _
        "{" + _
        "  'imports': {" + _
        "    'three': 'https://cdn.jsdelivr.net/npm/three@0.149.0/build/three.module.js'," + _
        "    'three/addons/': 'https://cdn.jsdelivr.net/npm/three@0.149.0/examples/jsm/'" + _
        "  }" + _
        "}"
    s.type = "importmap"
    s.innerText = String.Replace(txt, "'", Chr$(34))   
    
    s = Dom.Create("script")
    s.type = "module"
    s.innerText = _
        "import * as THREE from 'three';" + _
        "import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';" + _
        "import {OrbitControls} from 'three/addons/controls/OrbitControls.js';" + _
        "window.__THREE = THREE;" + _
        "window.__GLTFLoader = new GLTFLoader();" + _
        "window.__OrbitControls = function(camera, canvas) { return new OrbitControls(camera, canvas); };"
    
    Dim wtimer As Integer
    While !window.__THREE And wtimer < 10
        Delay .1
        wtimer = wtimer + 1
    WEnd
    __THREE = window.__THREE
    __GLTFLoader = window.__GLTFLoader
    __OrbitControls = window.__OrbitControls
End Sub