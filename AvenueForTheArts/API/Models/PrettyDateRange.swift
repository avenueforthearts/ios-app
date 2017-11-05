import Foundation

protocol PrettyDateRange {
    var start: Date { get }
    var end: Date? { get }
}

class PrettyDateRangeFormatters {
    fileprivate static let date: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = NSLocalizedString("month_day_format", comment:"")
        return formatter
    }()

    fileprivate static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}

extension String {
    init(prettyDateRange range: PrettyDateRange) {
        let startDate = PrettyDateRangeFormatters.date.string(from: range.start)
        let startTime = PrettyDateRangeFormatters.time.string(from: range.start)
        let startSegment = String.localizedStringWithFormat(
            NSLocalizedString("long_datetime_format", comment: ""),
            startDate,
            startTime
        )

        if let end = range.end {
            let endSegment: String
            let endTime = PrettyDateRangeFormatters.time.string(from: end)
            if Calendar.current.isDate(range.start, inSameDayAs: end) {
                endSegment = endTime
            } else {
                let endDate = PrettyDateRangeFormatters.date.string(from: end)
                endSegment = String.localizedStringWithFormat(
                    NSLocalizedString("long_datetime_format", comment: ""),
                    endDate,
                    endTime
                )
            }

            self = String.localizedStringWithFormat(
                NSLocalizedString("time_range_format", comment: ""),
                startSegment,
                endSegment
            )
        } else {
            self = startSegment
        }
    }
}

