import SwiftUI
import XenditComponents

@main
struct XenditExampleApp: App {
    init() {
        PlayfairFont.register()
        OpenSansFont.register()
        SpaceMonoFont.register()
        NotoSerifFont.register()
        XenditComponents.initialize(appearance: XenditAppearance())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
