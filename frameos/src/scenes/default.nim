# This code is autogenerated

import pixie, json, times, strformat

import frameos/types
import frameos/channels
import apps/split/app as splitApp
import apps/ifElse/app as ifElseApp
import apps/text/app as textApp
import apps/clock/app as clockApp
import apps/unsplash/app as unsplashApp
import apps/text/app as nodeApp8
import apps/qr/app as qrApp

const DEBUG = false

type Scene* = ref object of FrameScene
  node1: splitApp.App
  node2: ifElseApp.App
  node3: clockApp.App
  node4: unsplashApp.App
  node5: textApp.App
  node6: nodeApp8.App
  node7: qrApp.App

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
      self.node5.run(context)
      nextNode = 6.NodeId
    of 3.NodeId: # clock
      self.node3.run(context)
      nextNode = 7.NodeId
    of 4.NodeId: # unsplash
      self.node4.run(context)
      nextNode = 5.NodeId
    of 6.NodeId: # code
      self.node6.run(context)
      nextNode = -1.NodeId
    of 7.NodeId: # qr
      self.node7.run(context)
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

proc init*(frameConfig: FrameConfig, logger: Logger, dispatchEvent: proc(
    event: string, payload: JsonNode)): Scene =
  var state = %*{}
  let scene = Scene(frameConfig: frameConfig, logger: logger, state: state,
      dispatchEvent: dispatchEvent)
  let self = scene
  var context = ExecutionContext(scene: scene, event: "init", payload: %*{
    }, image: newImage(1, 1), loopIndex: 0, loopKey: ".")
  result = scene
  scene.execNode = (proc(nodeId: NodeId, context: var ExecutionContext) = self.runNode(nodeId, context))
  scene.node1 = splitApp.init(1.NodeId, scene, splitApp.AppConfig(height_ratios: "1 6", rows: 2, columns: 1,
      render_function: 2.NodeId))
  scene.node2 = ifElseApp.init(2.NodeId, scene, ifElseApp.AppConfig(condition: context.loopIndex == 0,
      thenNode: 3.NodeId, elseNode: 4.NodeId))
  scene.node5 = textApp.init(5.NodeId, scene, textApp.AppConfig(text: "Don't forget to kiss your man",
      position: "center-center", offsetX: 0.0, offsetY: 0.0, padding: 4.0, fontColor: parseHtmlColor("#ffffff"),
      fontSize: 32.0, borderColor: parseHtmlColor("#000000"), borderWidth: 1))
  scene.node3 = clockApp.init(3.NodeId, scene, clockApp.AppConfig(format: "yyyy-MM-dd HH:mm:ss", formatCustom: "",
      position: "center-center", offsetX: 0.0, offsetY: 0.0, padding: 4.0, fontColor: parseHtmlColor("#ffffff"),
      fontSize: 32.0, borderColor: parseHtmlColor("#000000"), borderWidth: 1))
  scene.node4 = unsplashApp.init(4.NodeId, scene, unsplashApp.AppConfig(keyword: "bird", cacheSeconds: 60.0))
  scene.node6 = nodeApp8.init(6.NodeId, scene, nodeApp8.AppConfig(text: ""))
  scene.node7 = qrApp.init(7.NodeId, scene, qrApp.AppConfig(code: "", padding: 4, position: "center-left",
      size: 100.0, sizeUnit: "% of smallest dimension", offsetX: 0, offsetY: 0, qrCodeColor: parseHtmlColor(
      "#000000"), backgroundColor: parseHtmlColor("#ffffff")))
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
