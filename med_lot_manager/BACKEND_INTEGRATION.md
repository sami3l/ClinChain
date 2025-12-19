# Intégration Backend - Med Lot Manager

## Configuration

L'application est maintenant intégrée avec le backend ClinChain.

### Basculer entre Mock et Backend Réel

Dans [lib/main.dart](lib/main.dart), vous pouvez choisir le mode :

```dart
// Mode production (backend réel)
final config = Config.production(); // baseUrl: http://localhost:8888

// Mode développement (données mock)
final config = Config.development(); // useMock: true

// Configuration personnalisée
final config = Config(useMock: false, baseUrl: 'http://votre-serveur:8888');
```

## Endpoints Intégrés

### Authentification

- ✅ `POST /auth/login` - Connexion avec JWT
- ✅ `POST /auth/logout` - Déconnexion
- ✅ `GET /auth/me` - Utilisateur actuel

### Gestion des Lots

- ✅ `GET /lots` - Liste des lots (avec filtres: status, createdBy, medName, page, size)
- ✅ `POST /lots` - Créer un lot
- ✅ `GET /lots/{lotId}` - Obtenir un lot par ID
- ✅ `POST /lots/{lotId}/validate` - Valider un lot
- ✅ `POST /lots/{lotId}/stock` - Marquer en stock pharmacie
- ✅ `POST /lots/{lotId}/administer` - Administrer un lot
- ✅ `POST /lots/{lotId}/withdraw` - Retirer une quantité
- ✅ `POST /lots/{lotId}/history` - Ajouter une entrée d'historique
- ✅ `GET /lots/{lotId}/blockchain` - État blockchain
- ✅ `GET /lots/stats` - Statistiques globales

## Nouveaux Modèles

### LotStatus (Enum)

```dart
enum LotStatus {
  CREE_PAR_GROSSISTE,      // Créé par grossiste
  VALIDE_PAR_HOPITAL,      // Validé par hôpital
  EN_STOCK_PHARMACIE,      // En stock pharmacie
  ADMINISTRE               // Administré
}
```

### LotStatsDto

```dart
class LotStatsDto {
  final int totalLots;
  final int createdLots;
  final int validatedLots;
  final int inStockLots;
  final int administeredLots;
  final int totalQuantity;
}
```

### BlockchainLotDto

```dart
class BlockchainLotDto {
  final String lotId;
  final String name;
  final int blockchainStatus;
  final String statusName;
  final String actor;
  final int timestamp;
  final bool syncedWithDatabase;
}
```

## Utilisation dans le Code

### Charger les lots avec filtres

```dart
final lotProvider = Provider.of<LotProvider>(context);

// Tous les lots
await lotProvider.loadLots();

// Lots filtrés
await lotProvider.loadLots(
  status: LotStatus.EN_STOCK_PHARMACIE,
  medName: 'Paracetamol',
  page: 0,
  size: 20,
);
```

### Nouvelles méthodes disponibles

```dart
// Marquer en stock pharmacie
await lotProvider.markInPharmacy(lotId);

// Administrer un lot
await lotProvider.administerLot(lotId);

// Charger les statistiques
await lotProvider.loadStats();
final stats = lotProvider.stats;

// Obtenir l'état blockchain
final blockchainState = await lotProvider.getBlockchainState(lotId);
```

## Démarrage du Backend

Assurez-vous que votre backend Spring Boot est démarré sur `http://localhost:8888` avant de lancer l'application en mode production.

## Prochaines Étapes

1. **Tester l'authentification** : Vérifier la connexion avec de vrais comptes utilisateurs
2. **Tester les opérations CRUD** : Créer, lire, modifier des lots
3. **Vérifier la synchronisation blockchain** : Utiliser l'endpoint `/lots/{lotId}/blockchain`
4. **Afficher les statistiques** : Créer un écran dashboard avec les stats
5. **Gérer les erreurs** : Ajouter une meilleure gestion des erreurs réseau

## Notes Importantes

- Le JWT est automatiquement attaché à chaque requête via un intercepteur Dio
- Les tokens sont stockés de manière sécurisée via `flutter_secure_storage`
- En cas d'erreur 401, le token est automatiquement supprimé
- Le cache blockchain est invalidé lors des modifications de lots
