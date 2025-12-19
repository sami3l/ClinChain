# Tests d'Intégration Backend

## Configuration Rapide

### 1. Mode Développement (Mock)

Utilisez les données mock pour tester sans backend :

```dart
// Dans lib/main.dart
final config = Config.development();
```

```bash
flutter run
```

### 2. Mode Production (Backend Réel)

Connectez-vous au backend Spring Boot :

```dart
// Dans lib/main.dart
final config = Config.production();
```

Assurez-vous que le backend est lancé :

```bash
# Dans votre dossier backend Spring Boot
./gradlew bootRun
# ou
java -jar target/your-backend.jar
```

Puis lancez l'application Flutter :

```bash
flutter run
```

## Endpoints à Tester

### Authentification

```bash
# Test avec curl
curl -X POST http://localhost:8888/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"grossiste","password":"votreMotDePasse"}'

# Devrait retourner :
# {"token":"eyJ...","user":{"id":"...","username":"grossiste","role":"GROSSISTE"}}
```

### Lots

```bash
# Liste des lots
curl http://localhost:8888/lots \
  -H "Authorization: Bearer VOTRE_TOKEN"

# Créer un lot
curl -X POST http://localhost:8888/lots \
  -H "Authorization: Bearer VOTRE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"medName":"Paracetamol 500mg","quantity":1000,"createdBy":"grossiste"}'

# Obtenir un lot
curl http://localhost:8888/lots/{lotId} \
  -H "Authorization: Bearer VOTRE_TOKEN"

# Valider un lot
curl -X POST http://localhost:8888/lots/{lotId}/validate \
  -H "Authorization: Bearer VOTRE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"actor":"hopitale"}'

# Marquer en stock
curl -X POST http://localhost:8888/lots/{lotId}/stock \
  -H "Authorization: Bearer VOTRE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"actor":"pharmacien"}'

# Administrer
curl -X POST http://localhost:8888/lots/{lotId}/administer \
  -H "Authorization: Bearer VOTRE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"actor":"infirmier"}'

# État blockchain
curl http://localhost:8888/lots/{lotId}/blockchain \
  -H "Authorization: Bearer VOTRE_TOKEN"

# Statistiques
curl http://localhost:8888/lots/stats \
  -H "Authorization: Bearer VOTRE_TOKEN"
```

## Tests dans l'Application Flutter

### Test 1 : Connexion

1. Lancez l'application
2. Connectez-vous avec un compte valide
3. Vérifiez que vous accédez à l'écran principal

### Test 2 : Créer un Lot

1. Cliquez sur le bouton "+"
2. Remplissez le formulaire :
   - Nom : "Paracetamol 500mg"
   - Quantité : 1000
3. Soumettez
4. Vérifiez que le lot apparaît dans la liste avec le statut "CREE_PAR_GROSSISTE"

### Test 3 : Valider un Lot

1. Sélectionnez un lot avec le statut "CREE_PAR_GROSSISTE"
2. Cliquez sur "Valider la réception"
3. Vérifiez que le statut passe à "VALIDE_PAR_HOPITAL"

### Test 4 : Workflow Complet

1. Créez un lot (CREE_PAR_GROSSISTE)
2. Validez-le (VALIDE_PAR_HOPITAL)
3. Marquez-le en stock (EN_STOCK_PHARMACIE)
4. Administrez-le (ADMINISTRE)

### Test 5 : Filtres

1. Créez plusieurs lots
2. Utilisez les filtres pour afficher uniquement :
   - Les lots en stock
   - Les lots créés par un utilisateur spécifique
   - Les lots contenant "Paracetamol"

### Test 6 : Statistiques

1. Accédez à l'écran des statistiques (si disponible)
2. Vérifiez que les chiffres sont cohérents :
   - Total des lots
   - Nombre de lots par statut
   - Quantité totale

### Test 7 : État Blockchain

1. Sélectionnez un lot
2. Consultez l'état blockchain
3. Vérifiez les informations :
   - Statut blockchain
   - Acteur
   - Date
   - Synchronisation avec la base de données

### Test 8 : Retrait de Quantité

1. Sélectionnez un lot
2. Retirez une quantité (ex: 50)
3. Vérifiez que la quantité est mise à jour
4. Vérifiez l'entrée dans l'historique

## Scénarios de Test par Rôle

### Grossiste

- ✅ Créer des lots
- ✅ Voir tous les lots créés
- ❌ Ne peut pas valider (rôle hopitale)

### Hôpital

- ✅ Voir les lots créés par les grossistes
- ✅ Valider la réception des lots
- ❌ Ne peut pas marquer en stock (rôle pharmacien)

### Pharmacien

- ✅ Voir les lots validés
- ✅ Marquer les lots en stock
- ✅ Retirer des quantités
- ❌ Ne peut pas administrer (rôle infirmier)

### Infirmier

- ✅ Voir les lots en stock
- ✅ Administrer les lots
- ✅ Voir l'historique

## Débogage

### Activer les Logs Dio

Dans [lib/src/services/api_service.dart](lib/src/services/api_service.dart), ajoutez :

```dart
import 'package:dio/dio.dart';

dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
  error: true,
));
```

### Vérifier la Connexion Backend

```bash
# Test simple
curl http://localhost:8888/actuator/health
# ou
curl http://localhost:8888/lots/stats
```

### Erreurs Courantes

#### Erreur 401 (Unauthorized)

- Vérifiez que le token JWT est valide
- Reconnectez-vous

#### Erreur 404 (Not Found)

- Vérifiez l'URL du backend dans Config
- Assurez-vous que le backend est lancé

#### Erreur de connexion

- Vérifiez que `http://localhost:8888` est accessible
- Sur Android Emulator, utilisez `http://10.0.2.2:8888`
- Sur iOS Simulator, utilisez `http://localhost:8888`

#### Données non mises à jour

- Appelez `lotProvider.clearBlockchainCache()`
- Rechargez les données avec `lotProvider.loadLots()`

## Outils de Développement

### Flutter DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Inspecter les requêtes réseau

1. Ouvrez DevTools
2. Allez dans l'onglet "Network"
3. Observez les requêtes HTTP

### Analyser les erreurs

```bash
flutter analyze
```

### Formater le code

```bash
flutter format lib/
```

## Checklist de Validation

- [ ] L'application se connecte au backend
- [ ] Les tokens JWT sont stockés et réutilisés
- [ ] La création de lots fonctionne
- [ ] La validation de lots fonctionne
- [ ] Les transitions de statut sont correctes
- [ ] Les statistiques s'affichent correctement
- [ ] L'état blockchain est accessible
- [ ] Les filtres fonctionnent
- [ ] La pagination fonctionne (si implémentée)
- [ ] Les notifications s'affichent
- [ ] L'historique des lots est cohérent
- [ ] La déconnexion fonctionne

## Prochaines Étapes

1. **Tests Automatisés** : Créer des tests d'intégration
2. **Gestion d'Erreurs** : Améliorer les messages d'erreur
3. **Performance** : Optimiser les requêtes réseau
4. **UI/UX** : Ajouter des indicateurs de chargement
5. **Sécurité** : Valider les entrées utilisateur
6. **Documentation** : Documenter les écrans et widgets
