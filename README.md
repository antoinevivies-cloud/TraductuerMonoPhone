# Stereo Dash Voice

Projet SwiftUI destiné à être ouvert dans **Swift Playgrounds sur iPad** et suivi dans GitHub.

## Fonctionnel aujourd'hui

- sélection de deux langues : français, anglais, espagnol, mandarin, italien, arabe, allemand ;
- choix gauche/droite pour chaque traduction ;
- autorisations Microphone et Reconnaissance vocale ;
- conversation à tours de parole alternés ;
- transcription vocale de l'interlocuteur actif ;
- synthèse vocale routée vers le canal gauche ou droit ;
- historique des phrases.

## Usage du micro

Les interlocuteurs parlent chacun à leur tour. L'utilisateur sélectionne l'interlocuteur qui parle, démarre l'écoute, puis passe au tour suivant. Cette approche est adaptée à un unique microphone : il n'y a pas de besoin de séparation automatique de deux voix simultanées.

## Limites importantes

1. Aucun service de traduction n'est inclus : une clé Azure Translator, DeepL, Google Cloud Translation ou un autre fournisseur doit être configurée dans `ConfiguredTranslationService`. Ne stockez jamais cette clé dans le dépôt ou dans l'application.
2. Le canal gauche/droite suppose un casque ou des écouteurs stéréo. Le haut-parleur de l'iPhone n'offre pas deux canaux perceptibles.

## Ouvrir dans Swift Playgrounds

1. Téléchargez/clônez ce dépôt sur l'iPad.
2. Ouvrez `Package.swift` dans Swift Playgrounds.
3. Dans les réglages du projet, ajoutez les descriptions d'usage iOS :
   - `NSMicrophoneUsageDescription` : « Microphone requis pour la conversation. »
   - `NSSpeechRecognitionUsageDescription` : « Reconnaissance vocale requise pour la transcription. »
4. Lancez l'appareil réel (la reconnaissance vocale ne fonctionne pas de façon fiable dans un aperçu).

## Codemagic

Le fichier `codemagic.yaml` contrôle une vérification du package Swift sur macOS. Il ne produit pas encore d'IPA signée : un projet Xcode iOS (`.xcodeproj`) est nécessaire pour l'archivage et la signature Apple. Cette étape est séparée afin de préserver la compatibilité avec Swift Playgrounds sur iPad.

## Étape suivante

Implémenter un adaptateur réseau sécurisé dans `ConfiguredTranslationService`, vers un serveur intermédiaire qui garde la clé API côté serveur.
