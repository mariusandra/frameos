# This file is autogenerated

{.warning[UnusedImport]: off.}
import pixie, json, times, strformat, strutils, sequtils, options

import frameos/types
import frameos/channels
import frameos/utils/image
import frameos/utils/url
import apps/render/split/app as render_splitApp
import apps/render/image/app as render_imageApp
import apps/data/localImage/app as data_localImageApp
import apps/data/newImage/app as data_newImageApp
import apps/render/gradient/app as render_gradientApp

const DEBUG = false
let PUBLIC_STATE_FIELDS*: seq[StateField] = @[]
let PERSISTED_STATE_KEYS*: seq[string] = @[]

type Scene* = ref object of FrameScene
  node1: render_splitApp.App
  node2: render_imageApp.App
  node3: render_imageApp.App
  node4: render_imageApp.App
  node5: render_imageApp.App
  node6: data_localImageApp.App
  node7: render_imageApp.App
  node8: data_newImageApp.App
  node9: render_gradientApp.App
  node10: data_newImageApp.App
  node11: render_imageApp.App
  node12: render_gradientApp.App
  node13: data_newImageApp.App

{.push hint[XDeclaredButNotUsed]: off.}
var cache0: Option[Image] = none(Image)
var cache0Time: float = 0
var cache1: Option[Image] = none(Image)
var cache2: Option[Image] = none(Image)
var cache3: Option[Image] = none(Image)
var cache4: Option[Image] = none(Image)

proc runNode*(self: Scene, nodeId: NodeId, context: var ExecutionContext) =
  let scene = self
  let frameConfig = scene.frameConfig
  let state = scene.state
  var nextNode = nodeId
  var currentNode = nodeId
  var timer = epochTime()
  while nextNode != -1.NodeId:
    currentNode = nextNode
    timer = epochTime()
    case nextNode:
    of 1.NodeId: # render/split
      self.node1.run(context)
      nextNode = -1.NodeId
    of 2.NodeId: # render/image
      self.node2.appConfig.image = block:
        if cache0.isNone() or epochTime() > cache0Time + 900.0:
          cache0 = some(block:
            self.node6.get(context))
          cache0Time = epochTime()
        cache0.get()
      self.node2.run(context)
      nextNode = -1.NodeId
    of 3.NodeId: # render/image
      self.node3.appConfig.image = block:
        self.node7.appConfig.inputImage = some(block:
          if cache1.isNone():
            cache1 = some(block:
              self.node8.get(context))
          cache1.get())
        self.node7.appConfig.image = block:
          self.node9.appConfig.inputImage = some(block:
            if cache2.isNone():
              cache2 = some(block:
                self.node10.get(context))
            cache2.get())
          self.node9.get(context)
        self.node7.get(context)
      self.node3.run(context)
      nextNode = -1.NodeId
    of 4.NodeId: # render/image
      self.node4.appConfig.image = block:
        self.node11.appConfig.image = block:
          if cache4.isNone():
            cache4 = some(block:
              self.node12.appConfig.inputImage = some(block:
                if cache3.isNone():
                  cache3 = some(block:
                    self.node13.get(context))
                cache3.get())
              self.node12.get(context))
          cache4.get()
        self.node11.get(context)
      self.node4.run(context)
      nextNode = -1.NodeId
    of 5.NodeId: # render/image
      self.node5.appConfig.image = block:
        if cache4.isNone():
          cache4 = some(block:
            self.node12.appConfig.inputImage = some(block:
              if cache3.isNone():
                cache3 = some(block:
                  self.node13.get(context))
              cache3.get())
            self.node12.get(context))
        cache4.get()
      self.node5.run(context)
      nextNode = -1.NodeId
    else:
      nextNode = -1.NodeId
    
    if DEBUG:
      self.logger.log(%*{"event": "debug:scene", "node": currentNode, "ms": (-timer + epochTime()) * 1000})

proc runEvent*(context: var ExecutionContext) =
  let self = Scene(context.scene)
  case context.event:
  of "render":
    try: self.runNode(1.NodeId, context)
    except Exception as e: self.logger.log(%*{"event": "render:error", "node": 1, "error": $e.msg, "stacktrace": e.getStackTrace()})
  of "setSceneState":
    if context.payload.hasKey("state") and context.payload["state"].kind == JObject:
      let payload = context.payload["state"]
      for field in PUBLIC_STATE_FIELDS:
        let key = field.name
        if payload.hasKey(key) and payload[key] != self.state{key}:
          self.state[key] = copy(payload[key])
    if context.payload.hasKey("render"):
      sendEvent("render", %*{})
  else: discard

proc render*(self: FrameScene, context: var ExecutionContext): Image =
  let self = Scene(self)
  context.image.fill(self.backgroundColor)
  runEvent(context)
  
  return context.image

proc init*(sceneId: SceneId, frameConfig: FrameConfig, logger: Logger, persistedState: JsonNode): FrameScene =
  var state = %*{}
  if persistedState.kind == JObject:
    for key in persistedState.keys:
      state[key] = persistedState[key]
  let scene = Scene(id: sceneId, frameConfig: frameConfig, state: state, logger: logger, refreshInterval: 3600.0, backgroundColor: parseHtmlColor("#000000"))
  let self = scene
  result = scene
  var context = ExecutionContext(scene: scene, event: "init", payload: state, hasImage: false, loopIndex: 0, loopKey: ".")
  scene.execNode = (proc(nodeId: NodeId, context: var ExecutionContext) = scene.runNode(nodeId, context))
  scene.node1 = render_splitApp.App(nodeName: "render/split", nodeId: 1.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_splitApp.AppConfig(
    rows: 4,
    inputImage: none(Image),
    columns: 1,
    hideEmpty: false,
    render_functions: @[
      @[
        2.NodeId,
      ],
      @[
        3.NodeId,
      ],
      @[
        4.NodeId,
      ],
      @[
        5.NodeId,
      ],
    ],
    render_function: 0.NodeId,
  ))
  scene.node2 = render_imageApp.App(nodeName: "render/image", nodeId: 2.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_imageApp.AppConfig(
    placement: "stretch",
    inputImage: none(Image),
    offsetX: 0,
    offsetY: 0,
    blendMode: "normal",
  ))
  scene.node6 = data_localImageApp.App(nodeName: "data/localImage", nodeId: 6.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: data_localImageApp.AppConfig(
    path: "./assets/image.png",
    order: "random",
    counterStateKey: "",
  ))
  scene.node6.init()
  scene.node3 = render_imageApp.App(nodeName: "render/image", nodeId: 3.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_imageApp.AppConfig(
    placement: "center",
    inputImage: none(Image),
    offsetX: 0,
    offsetY: 0,
    blendMode: "normal",
  ))
  scene.node8 = data_newImageApp.App(nodeName: "data/newImage", nodeId: 8.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: data_newImageApp.AppConfig(
    color: parseHtmlColor("#1b9d6b"),
    height: 100,
    width: 100,
    opacity: 1.0,
    renderNext: 0.NodeId,
  ))
  scene.node7 = render_imageApp.App(nodeName: "render/image", nodeId: 7.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_imageApp.AppConfig(
    placement: "center-left",
    inputImage: some(block:
      if cache1.isNone():
        cache1 = some(block:
          self.node8.get(context))
      cache1.get()),
    offsetX: 0,
    offsetY: 0,
    blendMode: "normal",
  ))
  scene.node10 = data_newImageApp.App(nodeName: "data/newImage", nodeId: 10.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: data_newImageApp.AppConfig(
    height: 30,
    width: 30,
    color: parseHtmlColor("#ffffff"),
    opacity: 1.0,
    renderNext: 0.NodeId,
  ))
  scene.node9 = render_gradientApp.App(nodeName: "render/gradient", nodeId: 9.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_gradientApp.AppConfig(
    inputImage: some(block:
      if cache2.isNone():
        cache2 = some(block:
          self.node10.get(context))
      cache2.get()),
    startColor: parseHtmlColor("#800080"),
    endColor: parseHtmlColor("#ffc0cb"),
    angle: 45.0,
  ))
  scene.node4 = render_imageApp.App(nodeName: "render/image", nodeId: 4.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_imageApp.AppConfig(
    inputImage: none(Image),
    placement: "cover",
    offsetX: 0,
    offsetY: 0,
    blendMode: "normal",
  ))
  scene.node11 = render_imageApp.App(nodeName: "render/image", nodeId: 11.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_imageApp.AppConfig(
    placement: "center-right",
    inputImage: none(Image),
    offsetX: 0,
    offsetY: 0,
    blendMode: "normal",
  ))
  scene.node13 = data_newImageApp.App(nodeName: "data/newImage", nodeId: 13.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: data_newImageApp.AppConfig(
    height: 30,
    width: 30,
    color: parseHtmlColor("#ffffff"),
    opacity: 1.0,
    renderNext: 0.NodeId,
  ))
  scene.node12 = render_gradientApp.App(nodeName: "render/gradient", nodeId: 12.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_gradientApp.AppConfig(
    inputImage: some(block:
      if cache3.isNone():
        cache3 = some(block:
          self.node13.get(context))
      cache3.get()),
    startColor: parseHtmlColor("#800080"),
    endColor: parseHtmlColor("#ffc0cb"),
    angle: 45.0,
  ))
  scene.node5 = render_imageApp.App(nodeName: "render/image", nodeId: 5.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_imageApp.AppConfig(
    placement: "tiled",
    inputImage: none(Image),
    offsetX: 0,
    offsetY: 0,
    blendMode: "normal",
  ))
  runEvent(context)
  
{.pop.}

var exportedScene* = ExportedScene(
  publicStateFields: PUBLIC_STATE_FIELDS,
  persistedStateKeys: PERSISTED_STATE_KEYS,
  init: init,
  runEvent: runEvent,
  render: render
)
