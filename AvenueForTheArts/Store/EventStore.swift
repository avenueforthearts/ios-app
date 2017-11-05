import Foundation
import RxSwift

typealias Events = API.Models.Event

class EventStore {
    static func get() -> Observable<EventGrouping> {
        let request = API.Endpoints.Events.Request()
        return API.session.rx
            .request(.events(request))
            .map { (_, data) in
                return try API.decoder.decode(API.Endpoints.Events.Response.self, from: data)
            }
            .map { $0.events }
            .map { return self.groupEventsByDate($0) }
    }

    static private func groupEventsByDate(_ events: [Events]) -> EventGrouping {

        var todayList = [Events]()
        var tomorrow = [Events]()
        var upcoming = [Events]()

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let tomorrowStart = calendar.startOfDay(
            for: calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))!
        )
        var startDateBegin: Date
        var endDateEnd: Date

        for event in events {
            // get 00:00 for event's start date
            startDateBegin = calendar.startOfDay(for: event.startDate)

            // if events has an end date we need to check whether today falls between the start date and the end date
            if let endDate = event.endDate {
                // get 00:00 for day AFTER end day
                let endDateMidnight = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate))!
                // now get 11:59:59 PM for the actual END day
                endDateEnd = calendar.date(byAdding: .second, value: -1, to: endDateMidnight)!

                if todayStart >= startDateBegin && todayStart < endDateEnd {
                    todayList.append(event)
                } else if tomorrowStart >= startDateBegin && tomorrowStart < endDateEnd {
                    tomorrow.append(event)
                } else {
                    upcoming.append(event)
                }
            } else {    // the event did not have an an End Date
                if calendar.isDateInToday(event.startDate) {
                    todayList.append(event)
                } else if calendar.isDateInTomorrow(event.startDate) {
                    todayList.append(event)
                } else {
                    upcoming.append(event)
                }
            }
        }

        return EventGrouping(today: todayList, tomorrow: tomorrow, upcoming: upcoming)
    }
}

struct EventGrouping {
    let today: [Events]
    let tomorrow: [Events]
    let upcoming: [Events]
}
