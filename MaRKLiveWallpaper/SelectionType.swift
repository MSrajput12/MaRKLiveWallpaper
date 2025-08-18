import Foundation

// Enum to keep track of the selected file type
enum SelectionType {
    case none
    case image(URL)
    case video(URL)
}
