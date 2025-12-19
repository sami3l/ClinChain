# Guide de Migration - Nouvelles Fonctionnalités Backend

## Résumé des Changements

L'application Flutter a été mise à jour pour s'intégrer complètement avec le backend Spring Boot.

## Fichiers Modifiés

### 1. Modèles de Données

#### [lib/src/models/lot.dart](lib/src/models/lot.dart)

- ✅ Ajout de l'enum `LotStatus` avec 4 états
- ✅ Ajout du champ `status: LotStatus` dans la classe `Lot`
- ✅ Mise à jour de `LotHistoryEntry` avec les champs `timestamp` et `at`

#### Nouveaux modèles créés :

- ✅ [lib/src/models/lot_stats.dart](lib/src/models/lot_stats.dart) - Statistiques des lots
- ✅ [lib/src/models/blockchain_lot.dart](lib/src/models/blockchain_lot.dart) - État blockchain

### 2. Configuration

#### [lib/src/config/config.dart](lib/src/config/config.dart)

- ✅ Ajout de `Config.production()` - baseUrl: `http://localhost:8888`
- ✅ Ajout de `Config.development()` - useMock: true

#### [lib/main.dart](lib/main.dart)

- ✅ Utilisation de `Config.production()` par défaut

### 3. Repositories

#### [lib/src/repositories/lot_repository.dart](lib/src/repositories/lot_repository.dart)

**Nouvelles méthodes abstraites :**

```dart
Future<List<Lot>> fetchLots({
  LotStatus? status,
  String? createdBy,
  String? medName,
  int? page,
  int? size,
});
Future<Lot?> getLotById(String lotId);
Future<Lot?> markInPharmacy(String lotId, String actor);
Future<Lot?> administerLot(String lotId, String actor);
Future<BlockchainLotDto?> getBlockchainState(String lotId);
Future<LotStatsDto?> getStats();
```

**Implémentations :**

- ✅ `MockLotRepository` - Mis à jour avec toutes les nouvelles méthodes
- ✅ `RemoteLotRepository` - Appelle les vrais endpoints backend

### 4. Providers

#### [lib/src/providers/lot_provider.dart](lib/src/providers/lot_provider.dart)

**Nouvelles méthodes publiques :**

```dart
Future<void> loadLots({LotStatus? status, String? createdBy, String? medName, int? page, int? size});
Future<void> loadStats();
Future<Lot?> getLotById(String lotId);
Future<BlockchainLotDto?> getBlockchainState(String lotId);
Future<void> markInPharmacy(String lotId);
Future<void> administerLot(String lotId);
void clearBlockchainCache();
```

**Nouveaux getters :**

```dart
LotStatsDto? get stats;
```

### 5. Widgets

#### Nouveaux widgets créés :

- ✅ [lib/src/widgets/lot_stats_widget.dart](lib/src/widgets/lot_stats_widget.dart) - Affichage des statistiques
- ✅ [lib/src/widgets/blockchain_state_widget.dart](lib/src/widgets/blockchain_state_widget.dart) - État blockchain

## Comment Utiliser les Nouvelles Fonctionnalités

### 1. Charger les lots avec filtres

```dart
final lotProvider = Provider.of<LotProvider>(context, listen: false);

// Tous les lots
await lotProvider.loadLots();

// Lots en stock pharmacie seulement
await lotProvider.loadLots(status: LotStatus.EN_STOCK_PHARMACIE);

// Recherche par nom de médicament
await lotProvider.loadLots(medName: 'Paracetamol');

// Pagination
await lotProvider.loadLots(page: 0, size: 10);

// Combiner plusieurs filtres
await lotProvider.loadLots(
  status: LotStatus.VALIDE_PAR_HOPITAL,
  createdBy: 'grossiste',
  page: 0,
  size: 20,
);
```

### 2. Afficher les statistiques

```dart
// Dans un StatefulWidget
import '../widgets/lot_stats_widget.dart';

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        LotStatsWidget(), // Widget prêt à l'emploi
        // ... autres widgets
      ],
    ),
  );
}

// Ou manuellement
final lotProvider = Provider.of<LotProvider>(context, listen: false);
await lotProvider.loadStats();
final stats = lotProvider.stats;

if (stats != null) {
  print('Total: ${stats.totalLots}');
  print('En stock: ${stats.inStockLots}');
  print('Administrés: ${stats.administeredLots}');
}
```

### 3. Afficher l'état blockchain

```dart
import '../widgets/blockchain_state_widget.dart';

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        BlockchainStateWidget(lotId: widget.lotId),
        // ... autres widgets
      ],
    ),
  );
}

// Ou manuellement
final lotProvider = Provider.of<LotProvider>(context, listen: false);
final state = await lotProvider.getBlockchainState(lotId);

if (state != null) {
  print('Statut: ${state.statusName}');
  print('Synchronisé: ${state.syncedWithDatabase}');
  print('Acteur: ${state.actor}');
}
```

### 4. Gérer les transitions de statut

```dart
final lotProvider = Provider.of<LotProvider>(context, listen: false);

// Workflow complet :
// 1. Créé par grossiste (CREE_PAR_GROSSISTE)
await lotProvider.createLot('Paracetamol 500mg', 1000);

// 2. Validé par hôpital (VALIDE_PAR_HOPITAL)
await lotProvider.validateReception(lotId);

// 3. En stock pharmacie (EN_STOCK_PHARMACIE)
await lotProvider.markInPharmacy(lotId);

// 4. Administré (ADMINISTRE)
await lotProvider.administerLot(lotId);
```

### 5. Obtenir un lot par ID

```dart
final lotProvider = Provider.of<LotProvider>(context, listen: false);
final lot = await lotProvider.getLotById(lotId);

if (lot != null) {
  print('Nom: ${lot.medName}');
  print('Statut: ${lot.status.name}');
  print('Quantité: ${lot.quantity}');
}
```

## Migration du Code Existant

### Avant :

```dart
// Ancien code
await lotProvider.loadLots();
```

### Après :

```dart
// Nouveau code avec filtres optionnels
await lotProvider.loadLots(
  status: LotStatus.EN_STOCK_PHARMACIE,
  page: 0,
  size: 20,
);
```

### Accès au nouveau champ `status` :

```dart
final lot = lotProvider.lots.first;

// Nouveau champ
switch (lot.status) {
  case LotStatus.CREE_PAR_GROSSISTE:
    print('En attente de validation');
    break;
  case LotStatus.VALIDE_PAR_HOPITAL:
    print('Validé');
    break;
  case LotStatus.EN_STOCK_PHARMACIE:
    print('En stock');
    break;
  case LotStatus.ADMINISTRE:
    print('Administré');
    break;
}
```

## Tests de l'Intégration

### 1. Avec Mock (développement)

```dart
// Dans main.dart
final config = Config.development();
```

### 2. Avec Backend Réel (production)

```dart
// Dans main.dart
final config = Config.production();
```

Assurez-vous que :

- Le backend Spring Boot est lancé sur `http://localhost:8888`
- Les credentials de test sont configurés
- Les endpoints sont accessibles

## Prochaines Étapes Recommandées

1. **Tester l'authentification** avec de vrais utilisateurs
2. **Créer un écran Dashboard** utilisant `LotStatsWidget`
3. **Intégrer `BlockchainStateWidget`** dans l'écran de détails des lots
4. **Ajouter la gestion d'erreurs** pour les cas réseau
5. **Implémenter le rafraîchissement** automatique des données
6. **Ajouter des indicateurs de chargement** pour une meilleure UX

## Notes Importantes

- Le cache blockchain est automatiquement invalidé lors des modifications de lots
- Les tokens JWT sont gérés automatiquement par l'intercepteur Dio
- Tous les endpoints sont protégés par authentification (sauf `/auth/login`)
- La pagination est optionnelle mais recommandée pour de grandes listes
