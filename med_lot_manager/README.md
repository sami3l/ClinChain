# ClinChain - Med Lot Manager 💊

Application Flutter de gestion de lots de médicaments avec traçabilité complète et système de rôles.

## ✨ Fonctionnalités

### Gestion des lots

- **Création de lots** : Les grossistes peuvent créer de nouveaux lots de médicaments
- **Validation** : Les hôpitaux peuvent valider la réception des lots
- **Retrait** : Les pharmaciens peuvent retirer/dispenser des médicaments
- **Commande** : Les infirmiers peuvent commander des médicaments
- **Historique complet** : Traçabilité de toutes les actions sur chaque lot

### Interface utilisateur moderne

- ✅ Design Material 3 avec palette médicale (bleu/vert/orange)
- ✅ Dashboard avec statistiques en temps réel
- ✅ Recherche et filtres avancés (statut, nom de médicament)
- ✅ Skeleton loaders pour une meilleure UX
- ✅ SnackBars personnalisés pour les feedbacks
- ✅ Écran de connexion modernisé
- ✅ Cartes interactives et animations fluides

### Architecture

- **State Management** : Provider
- **Pattern** : Repository (Mock + Remote ready)
- **HTTP Client** : Dio avec intercepteurs
- **Sécurité** : flutter_secure_storage pour les tokens
- **Mock Mode** : Données locales pour développement

## 🎭 Rôles utilisateurs

| Rôle           | Actions disponibles           |
| -------------- | ----------------------------- |
| **Grossiste**  | Créer des lots                |
| **Hôpital**    | Valider la réception des lots |
| **Pharmacien** | Retirer/Dispenser des unités  |
| **Infirmier**  | Commander des médicaments     |

## 🚀 Démarrage rapide

### Prérequis

- Flutter SDK >= 2.18.0
- Dart >= 2.18.0

### Installation

```bash
# Cloner le projet
git clone <repo-url>

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

### Mode Mock (par défaut)

L'application utilise des données mockées par défaut. Comptes de test :

| Utilisateur  | Mot de passe | Rôle       |
| ------------ | ------------ | ---------- |
| `grossiste`  | `password`   | Grossiste  |
| `hopitale`   | `password`   | Hôpital    |
| `pharmacien` | `password`   | Pharmacien |
| `infirmier`  | `password`   | Infirmier  |

### Configuration backend réel

Dans `lib/main.dart`, modifier :

```dart
final config = Config(
  useMock: false, // ⬅️ Passer à false
  baseUrl: 'https://votre-api.com', // ⬅️ URL de votre API
);
```

## 📁 Structure du projet

```
lib/
├── main.dart
└── src/
    ├── config/
    │   ├── config.dart          # Configuration app
    │   └── app_theme.dart       # Thème Material 3
    ├── models/
    │   ├── lot.dart             # Modèle de lot
    │   └── user.dart            # Modèle utilisateur
    ├── providers/
    │   ├── auth_provider.dart   # Gestion auth
    │   └── lot_provider.dart    # Gestion lots
    ├── repositories/
    │   ├── auth_repository.dart # Repository auth
    │   └── lot_repository.dart  # Repository lots
    ├── screens/
    │   ├── login_screen.dart
    │   ├── home_screen.dart
    │   ├── lot_list_screen.dart
    │   ├── lot_detail_screen.dart
    │   └── create_lot_screen.dart
    ├── services/
    │   └── api_service.dart     # Service HTTP Dio
    └── widgets/
        ├── skeleton_loader.dart # Loaders animés
        └── app_snackbar.dart    # Feedbacks UI
```

## 🎨 Améliorations Phase 1 (Complétées)

- ✅ Thème moderne avec palette médicale
- ✅ Skeleton loaders au lieu de spinners
- ✅ Recherche et filtres sur liste lots
- ✅ Dashboard avec statistiques
- ✅ SnackBars personnalisés
- ✅ Design amélioré de tous les écrans
- ✅ Meilleure gestion des erreurs

## 🚀 Phase 2 - Features Core (Complétées)

### Dashboard avec statistiques avancées

- ✅ Graphique circulaire (pie chart) pour répartition validés/en attente
- ✅ Graphique de tendance des quantités (line chart)
- ✅ Interface à onglets (Dashboard / Liste des lots)
- ✅ Statistiques visuelles en temps réel

### Timeline visuelle de l'historique

- ✅ Widget timeline avec icônes colorées selon le type d'action
- ✅ Lignes de connexion entre événements
- ✅ Badges pour l'événement le plus récent
- ✅ Affichage détaillé (acteur, date/heure)

### QR Code & Scanning

- ✅ Génération de QR Code unique pour chaque lot
- ✅ Scanner QR Code intégré avec overlay personnalisé
- ✅ Navigation directe vers le détail du lot scanné
- ✅ Format: `clinchain://lot/{lotId}`

### Notifications locales

- ✅ Notifications pour création de lot
- ✅ Notifications pour validation de réception
- ✅ Notifications pour retrait/dispensation
- ✅ Notifications pour commandes
- ✅ Support multi-plateformes (Android, iOS, Windows, Linux)

## 🔮 Roadmap Phase 3

- [ ] Export PDF/Excel des rapports
- [ ] Mode hors ligne avec synchronisation
- [ ] Multi-langue (i18n)
- [ ] Mode sombre complet
- [ ] Signature électronique pour validation
- [ ] Photos des lots
- [ ] Alertes d'expiration

## 📦 Dépendances principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5 # State management
  dio: ^5.1.2 # HTTP client
  flutter_secure_storage: ^8.0.0 # Stockage sécurisé
  uuid: ^3.0.7 # Génération d'IDs
  intl: ^0.18.0 # Formatage dates
```

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test/
```

## 📱 Plateformes supportées

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 📄 Licence

Ce projet est sous licence MIT.

## 👥 Contributeurs

- Développement initial : [Votre nom]
- UI/UX Phase 1 : Améliorations frontend modernes

---

Made with ❤️ and Flutter
