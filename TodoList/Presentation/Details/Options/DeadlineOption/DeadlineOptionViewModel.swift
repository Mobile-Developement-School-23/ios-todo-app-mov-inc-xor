import Foundation

final class DeadlineOptionViewModel {
    let date: Box<Date?>

    var didChangeSwitchValue: ((_ value: Bool) -> Void)?

    init(date: Date?) {
        self.date = Box(date)
    }
}
