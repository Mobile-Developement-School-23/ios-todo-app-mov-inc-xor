import UIKit

enum R {
    static let fileStorageName = "items.json"
    
    enum Colors {
        static let appBackground = UIColor(named: "AppBackground")
        static let featureBackground = UIColor(named: "FeatureBackground")
        
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
    }
    
    enum Images {
        static let highImportanceIcon = UIImage(named: "HighImportance") ?? UIImage()
        static let lowImportanceIcon = UIImage(named: "LowImportance") ?? UIImage()
    }
}
