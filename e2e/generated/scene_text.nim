# This file is autogenerated

import pixie, json, times, strformat, strutils, sequtils

import frameos/types
import frameos/channels
import apps/text/app as textApp

const DEBUG = false
let PUBLIC_STATE_FIELDS*: seq[StateField] = @[]
let PERSISTED_STATE_KEYS*: seq[string] = @[]

type Scene* = ref object of FrameScene
  node1: textApp.App
  node2: textApp.App
  node3: textApp.App
  node4: textApp.App
  node5: textApp.App
  node6: textApp.App
  node7: textApp.App
  node8: textApp.App
  node9: textApp.App

{.push hint[XDeclaredButNotUsed]: off.}

proc runNode*(self: Scene, nodeId: NodeId,
    context: var ExecutionContext) =
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
    of 1.NodeId: # text
      self.node1.run(context)
      nextNode = 2.NodeId
    of 2.NodeId: # text
      self.node2.run(context)
      nextNode = 3.NodeId
    of 3.NodeId: # text
      self.node3.run(context)
      nextNode = 4.NodeId
    of 5.NodeId: # text
      self.node5.run(context)
      nextNode = 6.NodeId
    of 4.NodeId: # text
      self.node4.run(context)
      nextNode = 7.NodeId
    of 7.NodeId: # text
      self.node7.run(context)
      nextNode = 8.NodeId
    of 8.NodeId: # text
      self.node8.run(context)
      nextNode = 9.NodeId
    of 9.NodeId: # text
      self.node9.run(context)
      nextNode = 5.NodeId
    of 6.NodeId: # text
      self.node6.run(context)
      nextNode = -1.NodeId
    else:
      nextNode = -1.NodeId
    
    if DEBUG:
      self.logger.log(%*{"event": "scene:debug:app", "node": currentNode, "ms": (-timer + epochTime()) * 1000})

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
  let scene = Scene(id: sceneId, frameConfig: frameConfig, state: state, logger: logger, refreshInterval: 10.016, backgroundColor: parseHtmlColor("#1230ab"))
  result = scene
  var context = ExecutionContext(scene: scene, event: "init", payload: state, image: newImage(1, 1), loopIndex: 0, loopKey: ".")
  scene.execNode = (proc(nodeId: NodeId, context: var ExecutionContext) = scene.runNode(nodeId, context))
  scene.node1 = textApp.init(1.NodeId, scene.FrameScene, textApp.AppConfig(
    position: "top-left",
    text: "topleft",
    fontSize: 16.0,
    offsetX: 0.0,
    offsetY: 0.0,
    padding: 10.0,
    fontColor: parseHtmlColor("#ffffff"),
    borderColor: parseHtmlColor("#000000"),
    borderWidth: 2,
    overflow: "fit-bounds",
  ))
  scene.node2 = textApp.init(2.NodeId, scene.FrameScene, textApp.AppConfig(
    position: "top-center",
    text: "topcenter",
    padding: 5.0,
    fontSize: 20.0,
    offsetX: 0.0,
    offsetY: 0.0,
    fontColor: parseHtmlColor("#ffffff"),
    borderColor: parseHtmlColor("#000000"),
    borderWidth: 2,
    overflow: "fit-bounds",
  ))
  scene.node3 = textApp.init(3.NodeId, scene.FrameScene, textApp.AppConfig(
    position: "top-right",
    text: "topright",
    borderWidth: 5,
    fontSize: 15.0,
    offsetX: 0.0,
    offsetY: 0.0,
    padding: 10.0,
    fontColor: parseHtmlColor("#ffffff"),
    borderColor: parseHtmlColor("#000000"),
    overflow: "fit-bounds",
  ))
  scene.node5 = textApp.init(5.NodeId, scene.FrameScene, textApp.AppConfig(
    position: "bottom-center",
    text: "bottomcenter",
    fontSize: 20.0,
    fontColor: parseHtmlColor("#00ff62"),
    offsetX: 0.0,
    offsetY: 0.0,
    padding: 10.0,
    borderColor: parseHtmlColor("#000000"),
    borderWidth: 2,
    overflow: "fit-bounds",
  ))
  scene.node4 = textApp.init(4.NodeId, scene.FrameScene, textApp.AppConfig(
    position: "center-left",
    text: "centerleft",
    offsetX: -10.0,
    fontSize: 20.0,
    offsetY: 0.0,
    padding: 10.0,
    fontColor: parseHtmlColor("#ffffff"),
    borderColor: parseHtmlColor("#000000"),
    borderWidth: 2,
    overflow: "fit-bounds",
  ))
  scene.node7 = textApp.init(7.NodeId, scene.FrameScene, textApp.AppConfig(
    text: "centercenter",
    borderColor: parseHtmlColor("#ff0000"),
    fontColor: parseHtmlColor("#000000"),
    fontSize: 20.0,
    position: "center-center",
    offsetX: 0.0,
    offsetY: 0.0,
    padding: 10.0,
    borderWidth: 2,
    overflow: "fit-bounds",
  ))
  scene.node8 = textApp.init(8.NodeId, scene.FrameScene, textApp.AppConfig(
    position: "center-right",
    text: "centerright",
    offsetX: 10.0,
    offsetY: 10.0,
    fontSize: 20.0,
    padding: 10.0,
    fontColor: parseHtmlColor("#ffffff"),
    borderColor: parseHtmlColor("#000000"),
    borderWidth: 2,
    overflow: "fit-bounds",
  ))
  scene.node9 = textApp.init(9.NodeId, scene.FrameScene, textApp.AppConfig(
    position: "bottom-left",
    text: "bottomleft",
    fontSize: 20.0,
    fontColor: parseHtmlColor("#ff0026"),
    offsetX: 0.0,
    offsetY: 0.0,
    padding: 10.0,
    borderColor: parseHtmlColor("#000000"),
    borderWidth: 2,
    overflow: "fit-bounds",
  ))
  scene.node6 = textApp.init(6.NodeId, scene.FrameScene, textApp.AppConfig(
    position: "bottom-right",
    text: "bottomright",
    fontSize: 20.0,
    fontColor: parseHtmlColor("#0062ff"),
    offsetX: 0.0,
    offsetY: 0.0,
    padding: 10.0,
    borderColor: parseHtmlColor("#000000"),
    borderWidth: 2,
    overflow: "fit-bounds",
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
