import AVFoundation
import Speech

final class SpeechCapture {
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private(set) var isRunning = false

    func authorize() async -> Bool {
        let speechGranted = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
        let microphoneGranted = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { continuation.resume(returning: $0) }
        }
        return speechGranted && microphoneGranted
    }

    func start(locale: String, onResult: @escaping (String, Bool) -> Void) throws {
        stop()
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: locale)), recognizer.isAvailable else {
            throw NSError(domain: "StereoDashVoice", code: 1, userInfo: [NSLocalizedDescriptionKey: "La reconnaissance n'est pas disponible pour cette langue."])
        }

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers, .allowBluetooth])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true
        request = recognitionRequest

        let input = audioEngine.inputNode
        input.removeTap(onBus: 0)
        let format = input.outputFormat(forBus: 0)
        input.installTap(onBus: 0, bufferSize: 1_024, format: format) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
        isRunning = true

        task = recognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result {
                onResult(result.bestTranscription.formattedString, result.isFinal)
            }
            if error != nil || result?.isFinal == true {
                self.stop()
            }
        }
    }

    func stop() {
        guard isRunning else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        isRunning = false
    }
}

protocol TranslationProviding {
    func translate(_ text: String, from: SpokenLanguage, to: SpokenLanguage) async throws -> String
}

enum TranslationError: LocalizedError {
    case notConfigured
    var errorDescription: String? {
        "Aucun service de traduction n'est configuré. Consultez README.md."
    }
}

/// Point d'intégration volontairement sans clé secrète.
/// Remplacez cette implémentation par un adaptateur vers votre service (Azure, DeepL, etc.).
struct ConfiguredTranslationService: TranslationProviding {
    func translate(_ text: String, from: SpokenLanguage, to: SpokenLanguage) async throws -> String {
        throw TranslationError.notConfigured
    }
}

final class StereoSpeaker {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let synthesizer = AVSpeechSynthesizer()
    private var isPrepared = false

    func speak(_ text: String, locale: String, channel: StereoChannel) {
        do {
            if !isPrepared {
                engine.attach(player)
                engine.connect(player, to: engine.mainMixerNode, format: nil)
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.allowBluetoothA2DP])
                try AVAudioSession.sharedInstance().setActive(true)
                try engine.start()
                player.play()
                isPrepared = true
            }
            player.pan = channel.pan
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: locale)
            synthesizer.write(utterance) { [weak self] buffer in
                guard let pcm = buffer as? AVAudioPCMBuffer, pcm.frameLength > 0 else { return }
                self?.player.scheduleBuffer(pcm)
            }
        } catch {
            // La transcription reste visible même si la sortie audio n'est pas disponible.
        }
    }
}
