import AppKit
import AVFoundation

@MainActor
class VideoWallpaperManager {
    static let shared = VideoWallpaperManager()

    private let wallpaperWindow: NSWindow
    private let player: AVPlayer
    private var timeObserver: Any?

    private init() {
        self.player = AVPlayer()
        self.player.isMuted = true
        self.player.actionAtItemEnd = .none

        let screenFrame = NSScreen.main?.frame ?? .zero
        self.wallpaperWindow = NSWindow(contentRect: screenFrame, styleMask: [.borderless], backing: .buffered, defer: false)
        self.wallpaperWindow.level = NSWindow.Level(Int(CGWindowLevelForKey(.desktopIconWindow)) - 1)
        self.wallpaperWindow.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        self.wallpaperWindow.isOpaque = true
        self.wallpaperWindow.ignoresMouseEvents = true
        self.wallpaperWindow.contentView = PlayerNSView(frame: screenFrame, player: self.player)

        self.timeObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak self] notification in
            if (notification.object as? AVPlayerItem) == self?.player.currentItem {
                self?.player.seek(to: .zero)
                self?.player.play()
            }
        }
    }

    func setWallpaper(with url: URL) {
        let playerItem = AVPlayerItem(url: url)
        self.player.replaceCurrentItem(with: playerItem)
        self.player.play()
        self.wallpaperWindow.orderFront(nil)
    }

    func hideWallpaper() {
        self.player.pause()
        self.player.replaceCurrentItem(with: nil)
        self.wallpaperWindow.orderOut(nil)
    }
}
