import UIKit

final class Alerts {
    static func makeErrorAlert(message: String) -> UIAlertController {
        let confirmAction = UIAlertAction(title: "Ок", style: .default)

        let alertController = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )

        alertController.addAction(confirmAction)

        return alertController
    }

    static func makeConfirmAlert(title: String, message: String, handler: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let confirmAction = UIAlertAction(title: "Удалить", style: .destructive, handler: handler)
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)

        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        return alertController
    }
}
