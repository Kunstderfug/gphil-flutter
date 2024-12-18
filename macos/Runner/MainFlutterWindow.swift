import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
    override func awakeFromNib() {
        let flutterViewController = FlutterViewController()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(
            NSRect(
                x: windowFrame.origin.x, y: windowFrame.origin.y,
                width: 1600, height: 960), display: true)  // Set your desired size

        RegisterGeneratedPlugins(registry: flutterViewController)

        super.awakeFromNib()
    }
}
