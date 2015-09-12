{
  "meta": {
    "modname": "Core",
    "aurthor": "RamiLego4Game"
  },
  
  "tabs": {
    "General": {
      "tooltip": "Rectange, Circle, Triangle, etc...",
      "thumbname": "GeneralIcon"
    },
    
    "PhysicsEditor": {
      "tooltip": "Objects made using PhysicsEditor",
      "thumbname": "PhysicsEditorIcon"
    }
  },
  
  "objects": {
    "Infinite Soft Ball": {
      "tab": "General",
      "handler": "HoldCreate",
      "generator": "SoftBody",
      "thumbname": "InfinitSoftBall"
    },
    
    "Infinite Static Rectangle": {
      "tab": "General",
      "handler": "HoldCreate",
      "generator": "StaticRectangle",
      "thumbname": "InfinitStaticRectangle"
    },
    
    "Infinite Rectangle": {
      "tab": "General",
      "handler": "HoldCreate",
      "generator": "Rectangle",
      "thumbname": "InfinitRectangle"
    },
    
    "16x Square": {
      "tab": "General",
      "args": [ 16, 16 ],
      "handler": "Overlay",
      "generator": "Rectangle",
      "thumbname": "RectangleX16"
    },
    
    "32x Square": {
      "type": "Overlay",
      "tab": "General",
      "args": [ 32, 32 ],
      "handler": "Overlay",
      "generator": "Rectangle",
      "thumbname": "RectangleX32"
    },
    
    "64x Square": {
      "type": "Overlay",
      "tab": "General",
      "args": [ 64, 64 ],
      "handler": "Overlay",
      "generator": "Rectangle",
      "thumbname": "RectangleX64"
    },
    
    "128x Square": {
      "type": "Overlay",
      "tab": "General",
      "args": [ 128, 128 ],
      "handler": "Overlay",
      "generator": "Rectangle",
      "thumbname": "RectangleX128"
    }
  }
}