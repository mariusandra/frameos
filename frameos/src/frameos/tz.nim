import chrono
import system

proc initTimeZone*() =
  const tzData = staticRead("../../assets/tz/tzdata-all.json")
  loadTzData(tzData)
