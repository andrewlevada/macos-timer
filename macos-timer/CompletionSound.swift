import AppKit
import Foundation

enum CompletionSound: String, CaseIterable, Identifiable, Codable {
    case none
    case glass
    case ping
    case pop
    case tink
    case submarine

    var id: String { rawValue }

    var label: String { rawValue }

    func play() {
        guard let name = systemName, let sound = NSSound(named: name) else {
            if self != .none {
                NSSound.beep()
            }
            return
        }
        sound.play()
    }

    private var systemName: String? {
        switch self {
        case .none: return nil
        case .glass: return "Glass"
        case .ping: return "Ping"
        case .pop: return "Pop"
        case .tink: return "Tink"
        case .submarine: return "Submarine"
        }
    }
}

struct CompletionSoundStore {
    private let key = "timer.completionSound"

    func load() -> CompletionSound {
        guard
            let raw = UserDefaults.standard.string(forKey: key),
            let sound = CompletionSound(rawValue: raw)
        else {
            return .glass
        }
        return sound
    }

    func save(_ sound: CompletionSound) {
        UserDefaults.standard.set(sound.rawValue, forKey: key)
    }
}
