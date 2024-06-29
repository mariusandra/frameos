import pixie
import times
import options
import json
import strformat
import strutils
import httpclient
import frameos/apps
import frameos/types
import chrono

import ./ical

type
  AppConfig* = object
    ical*: string
    exportFrom*: string
    exportUntil*: string
    exportCount*: int

  App* = ref object of AppRoot
    appConfig*: AppConfig

proc get*(self: App, context: ExecutionContext): JsonNode =
  result = %*[]
  if self.appConfig.iCal.startsWith("http"):
    self.logError "Pass in iCal data as a string, not a URL."
    return
  if self.appConfig.iCal == "":
    self.logError "No iCal data provided."
    return

  var client = newHttpClient(timeout = 60000)
  var parsedEvents: seq[VEvent]
  try:
    parsedEvents = parseICalendar(self.appConfig.ical).events
  except CatchableError as e:
    self.logError "Error parsing iCal: " & $e.msg
    return
  finally:
    client.close()

  let timezone = now().timezone()
  let exportFrom = (if self.appConfig.exportFrom != "": parse(self.appConfig.exportFrom, "yyyy-MM-dd",
      timezone) else: now()).toTime().toUnixFloat().Timestamp
  var exportUntil = if self.appConfig.exportUntil != "": parse(self.appConfig.exportUntil, "yyyy-MM-dd",
      timezone).toTime().toUnixFloat().Timestamp else: 0.Timestamp
  let matchedEvents = getEvents(parsedEvents, exportFrom, exportUntil, self.appConfig.exportCount)
  var eventsReply: JsonNode = %[]
  for (time, event) in matchedEvents:
    let startTime = if event.fullDay: fromUnixFloat(time.float).format("yyyy-MM-dd")
                    else: fromUnixFloat(time.float).format("yyyy-MM-dd'T'HH:mm:ss")
    let endTimeFloat = time.float + (event.endTime.float - event.startTime.float) - (if event.fullDay: 0.001 else: 0.0)
    let endTime = if event.fullDay: fromUnixFloat(endTimeFloat).format("yyyy-MM-dd")
                  else: fromUnixFloat(endTimeFloat).format("yyyy-MM-dd'T'HH:mm:ss")
    let jsonEvent = %*{
      "summary": event.summary,
      "startTime": startTime,
      "endTime": endTime,
      "location": event.location,
      "description": event.description,
    }
    eventsReply.add(jsonEvent)
  self.log(%*{"event": &"reply", "events": len(eventsReply), "inRange": len(eventsReply)})
  return eventsReply
