# This file is autogenerated

{.warning[UnusedImport]: off.}
import pixie, json, times, strformat, strutils, sequtils, options

import frameos/types
import frameos/channels
import frameos/utils/image
import frameos/utils/url
import apps/render/image/app as render_imageApp
import apps/logic/setAsState/app as logic_setAsStateApp
import apps/data/localImage/app as data_localImageApp
import apps/render/gradient/app as render_gradientApp
import apps/render/text/app as render_textApp
import apps/render/split/app as render_splitApp
import apps/logic/ifElse/app as logic_ifElseApp

const DEBUG = false
let PUBLIC_STATE_FIELDS*: seq[StateField] = @[]
let PERSISTED_STATE_KEYS*: seq[string] = @[]

type Scene* = ref object of FrameScene
  node1: render_imageApp.App
  node2: data_localImageApp.App
  node3: render_textApp.App
  node4: logic_setAsStateApp.App
  node5: render_splitApp.App
  node6: render_gradientApp.App
  node7: render_splitApp.App
  node8: render_gradientApp.App
  node9: logic_ifElseApp.App

{.push hint[XDeclaredButNotUsed]: off.}
var cache0: Option[Image] = none(Image)
var cache0Time: float = 0

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
    of 1.NodeId: # render/image
      self.node1.appConfig.blendMode = state{"mode"}{context.loopIndex mod 17}.getStr()
      self.node1.appConfig.image = block:
        if cache0.isNone() or epochTime() > cache0Time + 900.0:
          cache0 = some(block:
            self.node2.get(context))
          cache0Time = epochTime()
        cache0.get()
      self.node1.run(context)
      nextNode = 3.NodeId
    of 4.NodeId: # logic/setAsState
      self.node4.appConfig.valueJson = %*["normal","overwrite","darken","multiply","color-burn","lighten","screen","color-dodge","overlay","soft-light","hard-light","difference","exclusion","hue","saturation","color","luminosity"]
      self.node4.run(context)
      nextNode = 5.NodeId
    of 6.NodeId: # render/gradient
      self.node6.run(context)
      nextNode = -1.NodeId
    of 3.NodeId: # render/text
      self.node3.appConfig.text = state{"mode"}{context.loopIndex mod 17}.getStr()
      self.node3.run(context)
      nextNode = -1.NodeId
    of 5.NodeId: # render/split
      self.node5.run(context)
      nextNode = -1.NodeId
    of 7.NodeId: # render/split
      self.node7.run(context)
      nextNode = 9.NodeId
    of 8.NodeId: # render/gradient
      self.node8.run(context)
      nextNode = -1.NodeId
    of 9.NodeId: # logic/ifElse
      self.node9.appConfig.condition = context.loopIndex < 17
      self.node9.run(context)
      nextNode = -1.NodeId
    else:
      nextNode = -1.NodeId
    
    if DEBUG:
      self.logger.log(%*{"event": "debug:scene", "node": currentNode, "ms": (-timer + epochTime()) * 1000})

proc runEvent*(context: var ExecutionContext) =
  let self = Scene(context.scene)
  case context.event:
  of "render":
    try: self.runNode(4.NodeId, context)
    except Exception as e: self.logger.log(%*{"event": "render:error", "node": 4, "error": $e.msg, "stacktrace": e.getStackTrace()})
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
  scene.node1 = render_imageApp.App(nodeName: "render/image", nodeId: 1.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_imageApp.AppConfig(
    inputImage: none(Image),
    placement: "cover",
    offsetX: 0,
    offsetY: 0,
    blendMode: state{"mode"}{context.loopIndex mod 17}.getStr(),
  ))
  scene.node2 = data_localImageApp.App(nodeName: "data/localImage", nodeId: 2.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: data_localImageApp.AppConfig(
    path: "./assets/bird.png",
    order: "random",
    counterStateKey: "",
    search: "",
  ))
  scene.node2.init()
  scene.node4 = logic_setAsStateApp.App(nodeName: "logic/setAsState", nodeId: 4.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: logic_setAsStateApp.AppConfig(
    stateKey: "mode",
  ))
  scene.node6 = render_gradientApp.App(nodeName: "render/gradient", nodeId: 6.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_gradientApp.AppConfig(
    startColor: parseHtmlColor("#ffffff"),
    endColor: parseHtmlColor("#000000"),
    angle: 0.0,
    inputImage: none(Image),
  ))
  scene.node3 = render_textApp.App(nodeName: "render/text", nodeId: 3.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_textApp.AppConfig(
    fontSize: 16.0,
    inputImage: none(Image),
    text: state{"mode"}{context.loopIndex mod 17}.getStr(),
    position: "center",
    vAlign: "middle",
    offsetX: 0.0,
    offsetY: 0.0,
    padding: 10.0,
    fontColor: parseHtmlColor("#ffffff"),
    borderColor: parseHtmlColor("#000000"),
    borderWidth: 2,
    overflow: "fit-bounds",
  ))
  scene.node3.init()
  scene.node5 = render_splitApp.App(nodeName: "render/split", nodeId: 5.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_splitApp.AppConfig(
    rows: 6,
    columns: 3,
    hideEmpty: true,
    inputImage: none(Image),
    render_functions: @[
      @[
        0.NodeId,
        0.NodeId,
        0.NodeId,
      ],
      @[
        0.NodeId,
        0.NodeId,
        0.NodeId,
      ],
      @[
        0.NodeId,
        0.NodeId,
        0.NodeId,
      ],
      @[
        0.NodeId,
        0.NodeId,
        0.NodeId,
      ],
      @[
        0.NodeId,
        0.NodeId,
        0.NodeId,
      ],
      @[
        0.NodeId,
        0.NodeId,
        0.NodeId,
      ],
    ],
    render_function: 7.NodeId,
  ))
  scene.node7 = render_splitApp.App(nodeName: "render/split", nodeId: 7.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_splitApp.AppConfig(
    columns: 1,
    rows: 2,
    inputImage: none(Image),
    hideEmpty: false,
    render_functions: @[
      @[
        6.NodeId,
      ],
      @[
        8.NodeId,
      ],
    ],
    render_function: 0.NodeId,
  ))
  scene.node8 = render_gradientApp.App(nodeName: "render/gradient", nodeId: 8.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_gradientApp.AppConfig(
    angle: 0.0,
    startColor: parseHtmlColor("#88cd70"),
    endColor: parseHtmlColor("#652f7f"),
    inputImage: none(Image),
  ))
  scene.node9 = logic_ifElseApp.App(nodeName: "logic/ifElse", nodeId: 9.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: logic_ifElseApp.AppConfig(
    condition: context.loopIndex < 17,
    thenNode: 1.NodeId,
    elseNode: 0.NodeId,
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
