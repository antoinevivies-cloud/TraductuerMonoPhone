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

## Prototype immédiatement testable

Le sélecteur **Mode** est réglé par défaut sur **Démonstration**. Utilisez
**Phrase de test (stéréo)** : la phrase de l'interlocuteur actif est affichée,
puis la phrase d'exemple de l'autre langue est prononcée dans le canal attribué
à cet interlocuteur. Utilisez un casque stéréo pour vérifier la sortie.

Ce mode ne traduit pas le texte libre et ne doit pas être présenté comme une
traduction réelle. Le mode **Service externe** reste indisponible tant qu'un
adaptateur sécurisé n'est pas configuré.

## Usage du micro

Les interlocuteurs parlent chacun à leur tour. L'utilisateur sélectionne l'interlocuteur qui parle, démarre l'écoute, puis passe au tour suivant. Cette approche est adaptée à un unique microphone : il n'y a pas de besoin de séparation automatique de deux voix simultanées.

## Limites importantes

1. Aucun service de traduction n'est inclus : une clé Azure Translator, DeepL, Google Cloud Translation ou un autre fournisseur doit être configurée dans `ConfiguredTranslationService`. Ne stockez jamais cette clé dans le dépôt ou dans l'application.
2. Le canal gauche/droite suppose un casque ou des écouteurs stéréo. Le haut-parleur de l'iPhone n'offre pas deux canaux perceptibles.

## Ouvrir dans Swift Playgrounds

1. Dans **Working Copy**, clonez `antoinevivies-cloud/TraductuerMonoPhone`.
2. Ouvrez le dossier du dépôt dans **Swift Playgrounds**, puis ouvrez `Package.swift`.
3. Dans les réglages du projet, ajoutez les descriptions d'usage iOS :
   - `NSMicrophoneUsageDescription` : « Microphone requis pour la conversation. »
   - `NSSpeechRecognitionUsageDescription` : « Reconnaissance vocale requise pour la transcription. »
4. Lancez sur l'appareil réel (la reconnaissance vocale ne fonctionne pas de façon fiable dans un aperçu).
5. Après une modification : revenez dans Working Copy, effectuez un commit puis un push. Codemagic recevra le nouveau commit.

## Codemagic

Le fichier `codemagic.yaml` contrôle une vérification du package Swift sur macOS. Il ne produit pas encore d'IPA signée : un projet Xcode iOS (`.xcodeproj`) est nécessaire pour l'archivage et la signature Apple. Cette étape est séparée afin de préserver la compatibilité avec Swift Playgrounds sur iPad.

## Étape suivante

Implémenter un adaptateur réseau sécurisé dans `ConfiguredTranslationService`, vers un serveur intermédiaire qui garde la clé API côté serveur.
