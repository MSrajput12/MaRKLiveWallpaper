import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var selection: SelectionType = .none
    @State private var previewImage: NSImage? = nil
    @State private var statusMessage: String = "Welcome!"
    
    // A clean, light background for a professional look.
    private let backgroundColor = Color(nsColor: .windowBackgroundColor)
    
    var body: some View {
        VStack(spacing: 20) {
            headerView
            previewArea
            statusView
            actionButtons
            Spacer() // Pushes the following content to the bottom
            HStack {
                Spacer() // Pushes the name to the right
                nameView
            }
        }
        .padding(30)
        .background(backgroundColor)
        .edgesIgnoringSafeArea(.all)
    }
    
    private var isApplyDisabled: Bool {
        if case .none = selection { return true }
        return false
    }
}

// MARK: - UI Components
private extension ContentView {
    var headerView: some View {
        VStack {
            Text("Live Wallpaper")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundColor(.primary)
            
            Text("Select an image or video to begin")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
    }
    
    var previewArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

            if let preview = previewImage {
                Image(nsImage: preview)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .layoutPriority(-1)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(5)
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("Preview Area")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(height: 200)
    }
    
    var statusView: some View {
        HStack {
            Image(systemName: "info.circle.fill")
            Text(statusMessage)
        }
        .font(.callout)
        .foregroundColor(.secondary)
        .transition(.opacity.combined(with: .scale))
        .id("status_" + statusMessage)
    }
    
    var actionButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                GlassButton(label: "Choose Image", systemImage: "photo", action: chooseImage)
                GlassButton(label: "Choose Video", systemImage: "video", action: chooseVideo)
            }
            GlassButton(label: "Apply as Wallpaper", systemImage: "wand.and.stars.sparkles", action: applySelection)
                .disabled(isApplyDisabled)
            GlassButton(label: "Clear Video Wallpaper", systemImage: "xmark.circle", role: .destructive, action: clearVideoWallpaper)
        }
    }

    // This is the view for your name.
    var nameView: some View {
        Text("MaRK")
            .font(.system(size: 14, weight: .bold, design: .monospaced))
            .foregroundColor(.secondary.opacity(0.6))
            .padding(.top, 10)
    }
}

// MARK: - UI Functions
private extension ContentView {
    func chooseImage() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.title = "Choose an image"
        panel.allowedFileTypes = ["public.image"] // Older, compatible API
        if panel.runModal() == .OK, let url = panel.url {
            self.selection = .image(url)
            self.previewImage = NSImage(contentsOf: url)
            updateStatus(message: "Image selected. Ready to apply.")
        }
    }
    
    func chooseVideo() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.title = "Choose a video"
        panel.allowedFileTypes = ["public.movie", "public.video"] // Older, compatible API
        if panel.runModal() == .OK, let url = panel.url {
            self.selection = .video(url)
            updateStatus(message: "Generating video preview...")
            Task {
                let image = await generateThumbnail(for: url)
                await MainActor.run {
                    self.previewImage = image
                    updateStatus(message: "Video selected. Ready to apply.")
                }
            }
        }
    }
    
    func applySelection() {
        switch selection {
        case .image(let url):
            VideoWallpaperManager.shared.hideWallpaper()
            do {
                for screen in NSScreen.screens {
                    try NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
                }
                updateStatus(message: "Image wallpaper set successfully!")
            } catch {
                updateStatus(message: "Error setting image: \(error.localizedDescription)")
            }
        case .video(let url):
            VideoWallpaperManager.shared.setWallpaper(with: url)
            updateStatus(message: "Video wallpaper is now active!")
        case .none:
            updateStatus(message: "Please select a file first.")
        }
    }
    
    func clearVideoWallpaper() {
        VideoWallpaperManager.shared.hideWallpaper()
        if case .video = self.selection {
            self.selection = .none
            self.previewImage = nil
        }
        updateStatus(message: "Video wallpaper cleared.")
    }
    
    func generateThumbnail(for url: URL) async -> NSImage? {
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        do {
            let (cgImage, _) = try await imageGenerator.image(at: time)
            return NSImage(cgImage: cgImage, size: .zero)
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    func updateStatus(message: String) {
        withAnimation(.spring()) { self.statusMessage = message }
    }
}
