import UIKit

class TodoCalendarView: UICalendarView {
    var didChangeDate: ((_ date: Date) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        calendar = Calendar(identifier: .iso8601)
        locale = Locale(identifier: "ru_RU")
        selectionBehavior = UICalendarSelectionSingleDate(delegate: self)
        availableDateRange = DateInterval(start: .now, end: .distantFuture)
    }
}

extension TodoCalendarView: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard var dateComponents else { return }
        
        let currentDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        
        if dateComponents.year == currentDateComponents.year &&
            dateComponents.month == currentDateComponents.month &&
            dateComponents.day == currentDateComponents.day {
            dateComponents.hour = 23
            dateComponents.minute = 59
        } else {
            dateComponents.hour = currentDateComponents.hour
            dateComponents.minute = currentDateComponents.minute
        }
        
        guard let date = dateComponents.date else {
            return
        }

        didChangeDate?(date)
    }
}
