import AppKit
import AVFoundation

class PlayerNSView: NSView {
    private var playerLayer: AVPlayerLayer?
    init(frame: NSRect, player: AVPlayer) {
        super.init(frame: frame)
        self.wantsLayer = true
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        self.layer?.addSublayer(playerLayer)
        self.playerLayer = playerLayer
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
