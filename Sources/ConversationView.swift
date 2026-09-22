import SwiftUI

struct ConversationView: View {
    @EnvironmentObject private var model: ConversationModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Langues") {
                    Picker("Interlocuteur 1", selection: $model.firstLanguage) {
                        ForEach(SpokenLanguage.allCases) { Text($0.rawValue).tag($0) }
                    }
                    Picker("Canal 1", selection: $model.firstChannel) {
                        ForEach(StereoChannel.allCases) { Text($0.rawValue).tag($0) }
                    }
                    Picker("Interlocuteur 2", selection: $model.secondLanguage) {
                        ForEach(SpokenLanguage.allCases) { Text($0.rawValue).tag($0) }
                    }
                    Picker("Canal 2", selection: $model.secondChannel) {
                        ForEach(StereoChannel.allCases) { Text($0.rawValue).tag($0) }
                    }
                }

                Section("Conversation — un tour à la fois") {
                    Picker("Interlocuteur qui parle", selection: $model.activeSpeaker) {
                        Text("Interlocuteur 1").tag(1)
                        Text("Interlocuteur 2").tag(2)
                    }
                    .pickerStyle(.segmented)

                    Button(model.captureButtonTitle) { model.startOrStop() }
                        .frame(maxWidth: .infinity)

                    Button("Passer au tour suivant") { model.switchSpeaker() }
                        .frame(maxWidth: .infinity)

                    Button("Phrase de test (stéréo)") { model.playDemonstration() }
                        .frame(maxWidth: .infinity)

                    Text("1. Démarrer l'écoute · 2. Parler · 3. Passer au tour suivant.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text(model.status).foregroundStyle(.secondary)
                    if !model.liveTranscript.isEmpty {
                        Text("Entendu : \(model.liveTranscript)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Traduction") {
                    Picker("Mode", selection: $model.translationMode) {
                        ForEach(TranslationMode.allCases) { Text($0.rawValue).tag($0) }
                    }
                    Text(model.translationMode == .demonstration
                         ? "Le mode démonstration traduit uniquement la phrase de test."
                         : "Nécessite un serveur de traduction configuré : aucune clé ne doit être placée dans l’app.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Historique") {
                    if model.lines.isEmpty {
                        Text("Les transcriptions et traductions apparaîtront ici.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(model.lines) { line in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(line.source.rawValue).font(.caption).foregroundStyle(.secondary)
                            Text(line.original)
                            Text(line.translated).fontWeight(.semibold)
                            Text("Sortie : \(line.destination.rawValue)").font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Stereo Dash Voice")
            .alert("Information", isPresented: Binding(
                get: { model.errorMessage != nil },
                set: { if !$0 { model.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { model.errorMessage = nil }
            } message: {
                Text(model.errorMessage ?? "")
            }
        }
    }
}

private extension ConversationModel {
    var captureButtonTitle: String { isListening ? "Arrêter l'écoute" : "Démarrer l'écoute" }
}
