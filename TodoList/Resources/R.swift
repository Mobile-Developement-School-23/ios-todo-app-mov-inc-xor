import UIKit

enum R {
    static let fileStorageName = "items.json"

    enum Colors {
        static let appBackground = UIColor(named: "AppBackground")
        static let modalBackground = UIColor(named: "ModalBackground")
        static let featureBackground = UIColor(named: "FeatureBackground")
        static let navBarBackground = UIColor(named: "NavBarBackground")

        static let accent = UIColor(named: "AccentColor")

        static let text = UIColor(named: "Text")
        static let disabledText = UIColor(named: "DisabledText")
        static let attentionText = UIColor(named: "AttentionText")
        static let accentText = UIColor(named: "AccentText")

        static let separator = UIColor(named: "Separator")

        static let switchOffBackground = UIColor(named: "SwitchOffBackground")
        static let switchOnBackground = UIColor(named: "SwitchOnBackground")

        static let segmentedControlBackground = UIColor(named: "SegmentedControlBackground")
        static let selectedSegmentedControl = UIColor(named: "SelectedSegmentedControl")

        static let addButtonShadow = UIColor(named: "AddButtonShadow")

        static let completedSwipeAction = UIColor(named: "CompletedSwipeActionColor")
        static let detailsSwipeAction = UIColor(named: "DetailsSwipeActionColor")
        static let removeSwipeAction = UIColor(named: "RemoveSwipeActionColor")
    }

    enum Images {
        static let highImportanceIcon = UIImage(named: "HighImportance") ?? UIImage()
        static let lowImportanceIcon = UIImage(named: "LowImportance") ?? UIImage()

        static let basicCheckbox = UIImage(named: "BasicCheckbox")
        static let importantCheckbox = UIImage(named: "ImportantCheckbox")
        static let checkedCheckbox = UIImage(named: "CheckedCheckbox")

        static let calendar = UIImage(named: "Calendar")

        static let arrowRight = UIImage(named: "ArrowRight")

        static let addButton = UIImage(named: "AddButton")

        static let completedSwipeAction = UIImage(named: "CompletedSwipeActionIcon")
        static let detailsSwipeAction = UIImage(named: "DetailsSwipeActionIcon")
        static let removeSwipeAction = UIImage(named: "RemoveSwipeActionIcon")
    }
}
