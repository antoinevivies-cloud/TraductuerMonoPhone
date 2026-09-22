# Stereo Dash Voice

Projet SwiftUI destiné à être ouvert dans **Swift Playgrounds sur iPad**.

## Fonctionnel aujourd'hui

- sélection de deux langues : français, anglais, espagnol, mandarin, italien, arabe, allemand ;
- choix gauche/droite pour chaque traduction ;
- autorisations Microphone et Reconnaissance vocale ;
- transcription vocale de l'interlocuteur actif ;
- synthèse vocale routée vers le canal gauche ou droit ;
- historique des phrases.

## Limites importantes

1. Un iPhone/iPad n'identifie pas de manière fiable deux personnes et deux langues dans un seul flux micro. Cette version demande de sélectionner l'interlocuteur actif. L'automatisation exige deux micros séparés ou un service de diarisation/identification de locuteur.
2. Aucun service de traduction n'est inclus : une clé Azure Translator, DeepL, Google Cloud Translation ou un autre fournisseur doit être configurée dans `ConfiguredTranslationService`. Ne stockez jamais cette clé dans le dépôt ou dans l'application.
3. Le canal gauche/droite suppose un casque ou des écouteurs stéréo. Le haut-parleur de l'iPhone n'offre pas deux canaux perceptibles.

## Ouvrir dans Swift Playgrounds

1. Téléchargez/clônez ce dépôt sur l'iPad.
2. Ouvrez `Package.swift` dans Swift Playgrounds.
3. Dans les réglages du projet, ajoutez les descriptions d'usage iOS :
   - `NSMicrophoneUsageDescription` : « Microphone requis pour la conversation. »
   - `NSSpeechRecognitionUsageDescription` : « Reconnaissance vocale requise pour la transcription. »
4. Lancez l'appareil réel (la reconnaissance vocale ne fonctionne pas de façon fiable dans un aperçu).

## Étape suivante

Implémenter un adaptateur réseau sécurisé dans `ConfiguredTranslationService`, vers un serveur intermédiaire qui garde la clé API côté serveur.
