import SwiftUI
import WidgetKit

@main
struct HEXWidgetsBundle: WidgetBundle {
    var body: some Widget {
        OpcodeDictationLiveActivity()
        if #available(iOS 18.0, *) {
            OpcodeDictationControl()
        }
    }
}
