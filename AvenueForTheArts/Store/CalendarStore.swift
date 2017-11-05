import Foundation
import EventKit
import RxSwift
import EventKitUI

class CalendarStore {
    enum AddError: Error {
        case disallowed
    }

    enum Status {
        case success
    }

    static func addToCalendar(_ event: API.Models.Event) -> Single<Status> {
        let eventStore = EKEventStore()

        return Single.create { subscriber in
            eventStore.requestAccess(to: .event) { (granted, error) in
                if granted {
                    let ekEvent = EKEvent(eventStore: eventStore)

                    ekEvent.title = event.name
                    ekEvent.startDate = event.startDate
                    ekEvent.endDate = event.endDate
                    if event.endDate == nil {
                        ekEvent.isAllDay = true
                    }
                    ekEvent.notes =  event.description
                    ekEvent.calendar = eventStore.defaultCalendarForNewEvents

                    do {
                        try eventStore.save(ekEvent, span: .thisEvent)
                        subscriber(.success(.success))
                    } catch {
                        subscriber(.error(error))
                    }
                } else {
                    subscriber(.error(AddError.disallowed))
                }
            }

            return Disposables.create()
        }
    }

}
