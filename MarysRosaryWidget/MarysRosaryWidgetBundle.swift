import WidgetKit
import SwiftUI

@main
struct MarysRosaryWidgetBundle: WidgetBundle {
    var body: some Widget {
        RosaryWidget()
        RosaryLiveActivity()
    }
}
