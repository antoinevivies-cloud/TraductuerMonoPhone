import AVFoundation
import Speech
import SwiftUI

enum SpokenLanguage: String, CaseIterable, Identifiable {
    case french = "Français"
    case english = "Anglais"
    case spanish = "Espagnol"
    case mandarin = "Mandarin"
    case italian = "Italien"
    case arabic = "Arabe"
    case german = "Allemand"

    var id: String { rawValue }

    var speechLocale: String {
        switch self {
        case .french: "fr-FR"
        case .english: "en-US"
        case .spanish: "es-ES"
        case .mandarin: "zh-Hans-CN"
        case .italian: "it-IT"
        case .arabic: "ar-SA"
        case .german: "de-DE"
        }
    }
}

enum StereoChannel: String, CaseIterable, Identifiable {
    case left = "Gauche"
    case right = "Droite"

    var id: String { rawValue }
    var pan: Float { self == .left ? -1 : 1 }
}

struct ConversationLine: Identifiable {
    let id = UUID()
    let source: SpokenLanguage
    let original: String
    let translated: String
    let destination: StereoChannel
}

@MainActor
final class ConversationModel: ObservableObject {
    @Published var firstLanguage: SpokenLanguage = .french
    @Published var secondLanguage: SpokenLanguage = .english
    @Published var firstChannel: StereoChannel = .left
    @Published var secondChannel: StereoChannel = .right
    @Published var activeSpeaker: Int = 1
    @Published var status = "Prêt"
    @Published var lines: [ConversationLine] = []
    @Published var errorMessage: String?

    private let capture = SpeechCapture()
    private let speaker = StereoSpeaker()
    private let translator: any TranslationProviding = ConfiguredTranslationService()

    func startOrStop() {
        if capture.isRunning {
            capture.stop()
            status = "Arrêté"
            return
        }
        guard firstLanguage != secondLanguage else {
            errorMessage = "Les deux langues doivent être différentes."
            return
        }
        guard firstChannel != secondChannel else {
            errorMessage = "Les canaux doivent être différents pour une écoute stéréo."
            return
        }

        let source = activeSpeaker == 1 ? firstLanguage : secondLanguage
        status = "Écoute : \\(source.rawValue)"
        Task {
            let allowed = await capture.authorize()
            guard allowed else {
                errorMessage = "Autorisez Microphone et Reconnaissance vocale dans Réglages."
                status = "Autorisation requise"
                return
            }
            do {
                try capture.start(locale: source.speechLocale) { [weak self] text, isFinal in
                    guard isFinal, !text.isEmpty else { return }
                    Task { @MainActor in self?.translateAndSpeak(text, source: source) }
                }
            } catch {
                errorMessage = error.localizedDescription
                status = "Erreur d'écoute"
            }
        }
    }

    func switchSpeaker() {
        activeSpeaker = activeSpeaker == 1 ? 2 : 1
        if capture.isRunning {
            capture.stop()
            startOrStop()
        }
    }

    private func translateAndSpeak(_ text: String, source: SpokenLanguage) {
        let target = source == firstLanguage ? secondLanguage : firstLanguage
        let channel = source == firstLanguage ? secondChannel : firstChannel
        status = "Traduction…"
        Task {
            do {
                let translated = try await translator.translate(text, from: source, to: target)
                let line = ConversationLine(source: source, original: text, translated: translated, destination: channel)
                lines.insert(line, at: 0)
                speaker.speak(translated, locale: target.speechLocale, channel: channel)
                status = "Écoute : \\(activeSpeaker == 1 ? firstLanguage.rawValue : secondLanguage.rawValue)"
            } catch {
                errorMessage = error.localizedDescription
                status = "Traduction indisponible"
            }
        }
    }
}
