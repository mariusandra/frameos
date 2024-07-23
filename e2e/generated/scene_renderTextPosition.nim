# This file is autogenerated

{.warning[UnusedImport]: off.}
import pixie, json, times, strformat, strutils, sequtils, options, algorithm

import frameos/types
import frameos/channels
import frameos/utils/image
import frameos/utils/url
import apps/render/split/app as render_splitApp
import apps/render/gradient/app as render_gradientApp
import apps/render/text/app as render_textApp

const DEBUG = false
let PUBLIC_STATE_FIELDS*: seq[StateField] = @[]
let PERSISTED_STATE_KEYS*: seq[string] = @[]

type Scene* = ref object of FrameScene
  node1: render_splitApp.App
  node2: render_gradientApp.App
  node3: render_splitApp.App
  node4: render_textApp.App
  node5: render_textApp.App
  node6: render_textApp.App
  node7: render_textApp.App
  node8: render_textApp.App
  node9: render_textApp.App
  node10: render_textApp.App
  node11: render_textApp.App
  node12: render_textApp.App

{.push hint[XDeclaredButNotUsed]: off.}


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
      nextNode = 3.NodeId
    of 2.NodeId: # render/gradient
      self.node2.run(context)
      nextNode = -1.NodeId
    of 3.NodeId: # render/split
      self.node3.run(context)
      nextNode = -1.NodeId
    of 4.NodeId: # render/text
      self.node4.run(context)
      nextNode = -1.NodeId
    of 5.NodeId: # render/text
      self.node5.run(context)
      nextNode = -1.NodeId
    of 6.NodeId: # render/text
      self.node6.run(context)
      nextNode = -1.NodeId
    of 7.NodeId: # render/text
      self.node7.run(context)
      nextNode = -1.NodeId
    of 8.NodeId: # render/text
      self.node8.run(context)
      nextNode = -1.NodeId
    of 9.NodeId: # render/text
      self.node9.run(context)
      nextNode = -1.NodeId
    of 10.NodeId: # render/text
      self.node10.run(context)
      nextNode = -1.NodeId
    of 11.NodeId: # render/text
      self.node11.run(context)
      nextNode = -1.NodeId
    of 12.NodeId: # render/text
      self.node12.run(context)
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
  let scene = Scene(id: sceneId, frameConfig: frameConfig, state: state, logger: logger, refreshInterval: 3600.0, backgroundColor: parseHtmlColor("#ffffff"))
  let self = scene
  result = scene
  var context = ExecutionContext(scene: scene, event: "init", payload: state, hasImage: false, loopIndex: 0, loopKey: ".")
  scene.execNode = (proc(nodeId: NodeId, context: var ExecutionContext) = scene.runNode(nodeId, context))
  scene.node1 = render_splitApp.App(nodeName: "render/split", nodeId: 1.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_splitApp.AppConfig(
    rows: 3,
    columns: 3,
    gap: "5",
    margin: "5",
    inputImage: none(Image),
    hideEmpty: false,
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
    ],
    render_function: 2.NodeId,
  ))
  scene.node2 = render_gradientApp.App(nodeName: "render/gradient", nodeId: 2.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_gradientApp.AppConfig(
    startColor: parseHtmlColor("#3f99ab"),
    endColor: parseHtmlColor("#218514"),
    inputImage: none(Image),
    angle: 45.0,
  ))
  scene.node3 = render_splitApp.App(nodeName: "render/split", nodeId: 3.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_splitApp.AppConfig(
    rows: 3,
    columns: 3,
    gap: "5",
    margin: "5",
    inputImage: none(Image),
    hideEmpty: false,
    render_functions: @[
      @[
        4.NodeId,
        5.NodeId,
        6.NodeId,
      ],
      @[
        7.NodeId,
        8.NodeId,
        9.NodeId,
      ],
      @[
        10.NodeId,
        11.NodeId,
        12.NodeId,
      ],
    ],
    render_function: 0.NodeId,
  ))
  scene.node4 = render_textApp.App(nodeName: "render/text", nodeId: 4.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_textApp.AppConfig(
    text: "ananas",
    fontSize: 24.0,
    position: "left",
    vAlign: "top",
    borderWidth: 0,
    inputImage: none(Image),
    richText: "disabled",
    offsetX: 0.0,
    offsetY: 0.0,
    padding: 10.0,
    fontColor: parseHtmlColor("#ffffff"),
    borderColor: parseHtmlColor("#000000"),
    overflow: "fit-bounds",
  ))
  scene.node4.init()
  scene.node5 = render_textApp.App(nodeName: "render/text", nodeId: 5.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_textApp.AppConfig(
    vAlign: "top",
    text: "bananas",
    fontSize: 24.0,
    borderWidth: 2,
    inputImage: none(Image),
    richText: "disabled",
    position: "center",
    offsetX: 0.0,
    offsetY: 0.0,
    padding: 10.0,
    fontColor: parseHtmlColor("#ffffff"),
    borderColor: parseHtmlColor("#000000"),
    overflow: "fit-bounds",
  ))
  scene.node5.init()
  scene.node6 = render_textApp.App(nodeName: "render/text", nodeId: 6.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_textApp.AppConfig(
    position: "right",
    vAlign: "top",
    text: "ananas",
    fontSize: 24.0,
    borderWidth: 0,
    inputImage: none(Image),
    richText: "disabled",
    offsetX: 0.0,
    offsetY: 0.0,
    padding: 10.0,
    fontColor: parseHtmlColor("#ffffff"),
    borderColor: parseHtmlColor("#000000"),
    overflow: "fit-bounds",
  ))
  scene.node6.init()
  scene.node7 = render_textApp.App(nodeName: "render/text", nodeId: 7.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_textApp.AppConfig(
    position: "left",
    text: "bananas",
    fontSize: 24.0,
    inputImage: none(Image),
    richText: "disabled",
    vAlign: "middle",
    offsetX: 0.0,
    offsetY: 0.0,
    padding: 10.0,
    fontColor: parseHtmlColor("#ffffff"),
    borderColor: parseHtmlColor("#000000"),
    borderWidth: 2,
    overflow: "fit-bounds",
  ))
  scene.node7.init()
  scene.node8 = render_textApp.App(nodeName: "render/text", nodeId: 8.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_textApp.AppConfig(
    text: "ananas",
    fontSize: 24.0,
    borderWidth: 0,
    inputImage: none(Image),
    richText: "disabled",
    position: "center",
    vAlign: "middle",
    offsetX: 0.0,
    offsetY: 0.0,
    padding: 10.0,
    fontColor: parseHtmlColor("#ffffff"),
    borderColor: parseHtmlColor("#000000"),
    overflow: "fit-bounds",
  ))
  scene.node8.init()
  scene.node9 = render_textApp.App(nodeName: "render/text", nodeId: 9.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_textApp.AppConfig(
    position: "right",
    text: "bananas",
    fontSize: 24.0,
    inputImage: none(Image),
    richText: "disabled",
    vAlign: "middle",
    offsetX: 0.0,
    offsetY: 0.0,
    padding: 10.0,
    fontColor: parseHtmlColor("#ffffff"),
    borderColor: parseHtmlColor("#000000"),
    borderWidth: 2,
    overflow: "fit-bounds",
  ))
  scene.node9.init()
  scene.node10 = render_textApp.App(nodeName: "render/text", nodeId: 10.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_textApp.AppConfig(
    position: "left",
    vAlign: "bottom",
    text: "ananas",
    fontSize: 24.0,
    borderWidth: 0,
    inputImage: none(Image),
    richText: "disabled",
    offsetX: 0.0,
    offsetY: 0.0,
    padding: 10.0,
    fontColor: parseHtmlColor("#ffffff"),
    borderColor: parseHtmlColor("#000000"),
    overflow: "fit-bounds",
  ))
  scene.node10.init()
  scene.node11 = render_textApp.App(nodeName: "render/text", nodeId: 11.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_textApp.AppConfig(
    vAlign: "bottom",
    text: "bananas",
    fontSize: 24.0,
    borderWidth: 2,
    inputImage: none(Image),
    richText: "disabled",
    position: "center",
    offsetX: 0.0,
    offsetY: 0.0,
    padding: 10.0,
    fontColor: parseHtmlColor("#ffffff"),
    borderColor: parseHtmlColor("#000000"),
    overflow: "fit-bounds",
  ))
  scene.node11.init()
  scene.node12 = render_textApp.App(nodeName: "render/text", nodeId: 12.NodeId, scene: scene.FrameScene, frameConfig: scene.frameConfig, appConfig: render_textApp.AppConfig(
    position: "right",
    vAlign: "bottom",
    text: "ananas",
    fontSize: 24.0,
    borderWidth: 0,
    inputImage: none(Image),
    richText: "disabled",
    offsetX: 0.0,
    offsetY: 0.0,
    padding: 10.0,
    fontColor: parseHtmlColor("#ffffff"),
    borderColor: parseHtmlColor("#000000"),
    overflow: "fit-bounds",
  ))
  scene.node12.init()
  runEvent(context)
  
{.pop.}

var exportedScene* = ExportedScene(
  publicStateFields: PUBLIC_STATE_FIELDS,
  persistedStateKeys: PERSISTED_STATE_KEYS,
  init: init,
  runEvent: runEvent,
  render: render
)
