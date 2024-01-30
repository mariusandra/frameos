# This code is autogenerated

import pixie, json, times, strformat

import frameos/types
import frameos/channels
import apps/split/app as splitApp
import apps/ifElse/app as ifElseApp
import apps/text/app as textApp
import apps/clock/app as clockApp
import apps/unsplash/app as unsplashApp
import apps/qr/app as qrApp

const DEBUG = false

type Scene* = ref object of FrameScene
  node1: splitApp.App
  node2: ifElseApp.App
  node3: clockApp.App
  node4: unsplashApp.App
  node5: textApp.App
  node6: qrApp.App

{.push hint[XDeclaredButNotUsed]: off.}
# This makes strformat available within the scene's inline code and avoids the "unused import" error
discard &""

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
    of 1.NodeId: # split
      self.node1.run(context)
      nextNode = -1.NodeId
    of 2.NodeId: # ifElse
      self.node2.appConfig.condition = context.loopIndex == 0
      self.node2.run(context)
      nextNode = -1.NodeId
    of 5.NodeId: # text
      self.node5.appConfig.text = state{"message"}.getStr
      self.node5.run(context)
      nextNode = -1.NodeId
    of 3.NodeId: # clock
      self.node3.run(context)
      nextNode = 6.NodeId
    of 4.NodeId: # unsplash
      self.node4.appConfig.keyword = state{"background"}.getStr
      self.node4.run(context)
      nextNode = 5.NodeId
    of 6.NodeId: # qr
      self.node6.run(context)
      nextNode = -1.NodeId
    else:
      nextNode = -1.NodeId
    if DEBUG:
      self.logger.log(%*{"event": "scene:debug:app", "node": currentNode, "ms": (-timer + epochTime()) * 1000})

proc runEvent*(self: Scene, context: var ExecutionContext) =
  case context.event:
  of "render":
    try: self.runNode(1.NodeId, context)
    except Exception as e: self.logger.log(%*{"event": "render:error",
        "node": 1, "error": $e.msg, "stacktrace": e.getStackTrace()})
  else: discard

proc init*(frameConfig: FrameConfig, logger: Logger, dispatchEvent: proc(event: string, payload: JsonNode)): Scene =
  var state = %*{"background": %*("kiss"), "message": %*("give a hug")}
  let scene = Scene(frameConfig: frameConfig, logger: logger, state: state, dispatchEvent: dispatchEvent)
  let self = scene
  var context = ExecutionContext(scene: scene, event: "init", payload: %*{}, image: newImage(1, 1), loopIndex: 0, loopKey: ".")
  result = scene
  scene.execNode = (proc(nodeId: NodeId, context: var ExecutionContext) = self.runNode(nodeId, context))
  scene.node1 = splitApp.init(1.NodeId, scene, splitApp.AppConfig(height_ratios: "52 748", rows: 2, columns: 1,
      render_function: 2.NodeId))
  scene.node2 = ifElseApp.init(2.NodeId, scene, ifElseApp.AppConfig(condition: context.loopIndex == 0,
      thenNode: 3.NodeId, elseNode: 4.NodeId))
  scene.node5 = textApp.init(5.NodeId, scene, textApp.AppConfig(borderWidth: 4, fontColor: parseHtmlColor("#f5dbdb"),
      fontSize: 100.0, position: "center-center", text: state{"message"}.getStr, offsetX: 0.0, offsetY: 0.0,
      padding: 10.0, borderColor: parseHtmlColor("#000000")))
  scene.node3 = clockApp.init(3.NodeId, scene, clockApp.AppConfig(borderWidth: 0, fontColor: parseHtmlColor("#000000"),
      format: "yyyy-MM-dd HH:mm:ss", position: "center-right", formatCustom: "", offsetX: 0.0, offsetY: 0.0,
      padding: 10.0, fontSize: 32.0, borderColor: parseHtmlColor("#000000")))
  scene.node4 = unsplashApp.init(4.NodeId, scene, unsplashApp.AppConfig(keyword: state{"background"}.getStr,
      cacheSeconds: 60.0))
  scene.node6 = qrApp.init(6.NodeId, scene, qrApp.AppConfig(padding: 0, position: "top-left", size: 2.0,
      sizeUnit: "pixels per dot", code: "", alRad: 30.0, moRad: 0.0, moSep: 0.0, offsetX: 0.0, offsetY: 0.0,
      qrCodeColor: parseHtmlColor("#000000"), backgroundColor: parseHtmlColor("#ffffff")))
  runEvent(scene, context)

proc render*(self: Scene): Image =
  var context = ExecutionContext(
    scene: self,
    event: "render",
    payload: %*{},
    image: case self.frameConfig.rotate:
    of 90, 270: newImage(self.frameConfig.height, self.frameConfig.width)
    else: newImage(self.frameConfig.width, self.frameConfig.height),
    loopIndex: 0,
    loopKey: "."
  )
  context.image.fill(self.frameConfig.backgroundColor)
  runEvent(self, context)
  return context.image
{.pop.}
