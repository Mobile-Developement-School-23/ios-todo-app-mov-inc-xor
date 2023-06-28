import Foundation

final class DeadlineOptionViewModel {
    let date: Box<Date?>
    
    var didChangeSwitchValue: ((_ value: Bool) -> ())?
    
    init(date: Date?) {
        self.date = Box(date)
    }
}
