import ../ical
import lib/tz
import chrono, times

block test_lincoln:
    echo "Test: lincoln"
    let iCalFile = readFile("./src/apps/data/icalJson/tests/data/lincoln.ics")
    let events = parseICalendar(iCalFile).events
    doAssert len(events) == 1
    doAssert events[0].startTs == Timestamp(1202774400.0)
    doAssert events[0].endTs == Timestamp(1202860800.0)
    doAssert events[0].location == "Hodgenville, Kentucky"
    doAssert events[0].description == "Born February 12, 1809\nSixteenth President (1861-1865)\n\n\n\nhttp://AmericanHistoryCalendar.com"
    doAssert events[0].summary == "Abraham Lincoln"

block test_meetings:
    echo "Test: meetings"
    let iCalFile = readFile("./src/apps/data/icalJson/tests/data/meetings.ics")
    let events = parseICalendar(iCalFile).events
    doAssert len(events) == 5
    doAssert events[0].startTs == Timestamp(1618419600.0)
    doAssert events[0].endTs == Timestamp(1618421400.0)
    doAssert events[0].location == "https://example.com/location-url/"
    doAssert events[0].description == ""
    doAssert events[0].summary == "Team Standup"
    doAssert events[0].rrules[0] == RRule(freq: weekly, interval: 1, timeInterval: TimeInterval(weeks: 1), byDay: @[(
            we, 0)], byMonth: @[], byMonthDay: @[], until: Timestamp(1777388399.0), count: 0,
                    weekStart: none)
    doAssert events[1].startTs == Timestamp(1624528800.0)
    doAssert events[1].endTs == Timestamp(1624532400.0)
    doAssert events[1].location == ""
    doAssert events[1].description == ""
    doAssert events[1].summary == "Hacklunch for Project"
    doAssert events[2].startTs == Timestamp(1629309600.0)
    doAssert events[2].endTs == Timestamp(1629313200.0)
    doAssert events[2].location == "https://example.com/another-meeting-link"
    doAssert events[2].description == "Hey, let\'s try pairing for an hour and see where we end up :)."
    doAssert events[2].summary == "Pairing Two / Three"
    doAssert events[3].startTs == Timestamp(1629313200.0)
    doAssert events[3].endTs == Timestamp(1629316800.0)
    doAssert events[3].location == "https://example.com/link-again"
    doAssert events[3].description == "Hey, let\'s do a bit of pair coding :)"
    doAssert events[3].summary == "Pairing Three / One"
    doAssert events[4].startTs == Timestamp(1629448200.0)
    doAssert events[4].endTs == Timestamp(1629451800.0)
    doAssert events[4].location == "https://example.com/zoom-is-back"
    doAssert events[4].description == "Hey Team! The sugarly overlord commands me to set up a meeting. This is the meeting"
    doAssert events[4].summary == "One / Two - Meeting"

block test_holidays:
    echo "Test: holidays"
    let iCalFile = readFile("./src/apps/data/icalJson/tests/data/holidays.ics")
    let calendar = parseICalendar(iCalFile)
    doAssert calendar.timezone == "Europe/Tallinn"

    let events = calendar.events
    doAssert len(events) == 49
    doAssert events[0].startTs == Timestamp(1147564800.0)
    doAssert events[0].summary == "Emadepäev"


block test_parse_ical_datetime:
    echo "Test: parse_ical_datetime"
    doAssert parseICalDateTime("20240101", "UTC") == parseICalDateTime("20240101", "Europe/Brussels")
    doAssert parseICalDateTime("20240101T000000", "UTC") == parseICalDateTime("20240101T000000", "Europe/Brussels")
    doAssert parseICalDateTime("20240101T000000Z", "UTC") == parseICalDateTime("20240101T000000Z", "Europe/Brussels")
    initTimeZone()
    doAssert parseICalDateTime("20240101", "UTC") != parseICalDateTime("20240101", "Europe/Brussels")
    doAssert parseICalDateTime("20240101T000000", "UTC") != parseICalDateTime("20240101T000000", "Europe/Brussels")
    doAssert parseICalDateTime("20240101T000000Z", "UTC") == parseICalDateTime("20240101T000000Z", "Europe/Brussels")


block test_get_events:
    echo "Test: get_events"
    let iCalFile = readFile("./src/apps/data/icalJson/tests/data/meetings.ics")

    var calendar = parseICalendar(iCalFile)
    doAssert calendar.timezone == "Europe/Brussels"
    let allEvents = getEvents(calendar, parseICalDateTime("20240101", "UTC"), parseICalDateTime("20250101", "UTC"), "", 100)
    echo len(allEvents)
    doAssert len(allEvents) == 52
    echo "5"
    echo allEvents[0][0]
    echo allEvents[51][0]
    doAssert allEvents[0][0] == Timestamp(1704294000.0)
    doAssert allEvents[51][0] == Timestamp(1735138800.0)
    doAssert allEvents[0][1].summary == "Team Standup"

    calendar = parseICalendar(iCalFile)
    let allEventsOld = getEvents(calendar, parseICalDateTime("20210101", "UTC"), parseICalDateTime("20220101", "UTC"),
            "", 100)
    echo allEventsOld[0][0]
    echo allEventsOld[41][0]
    doAssert len(allEventsOld) == 42
    doAssert allEventsOld[0][0] == Timestamp(1618412400.0)
    doAssert allEventsOld[41][0] == Timestamp(1640790000.0)
    doAssert allEventsOld[0][1].summary == "Team Standup"
    doAssert allEventsOld[11][1].summary == "Hacklunch for Project"

    calendar = parseICalendar(iCalFile)
    let standupEvents = getEvents(calendar, parseICalDateTime("20210101", "UTC"), parseICalDateTime("20220101", "UTC"),
            "Team Standup", 1000)
    doAssert len(standupEvents) == 38

