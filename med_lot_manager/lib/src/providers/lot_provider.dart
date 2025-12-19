import 'package:flutter/material.dart';
import '../repositories/lot_repository.dart';
import '../models/lot.dart';
import '../models/lot_stats.dart';
import '../models/blockchain_lot.dart';
import '../services/notification_service.dart';
import 'auth_provider.dart';

class LotProvider extends ChangeNotifier {
  final LotRepository lotRepository;
  final _notificationService = NotificationService();
  AuthProvider? _auth;
  List<Lot> _lots = [];
  bool _loading = false;
  LotStatsDto? _stats;
  Map<String, BlockchainLotDto> _blockchainCache = {};

  LotProvider({required this.lotRepository});

  void updateAuth(AuthProvider auth) {
    _auth = auth;
  }

  List<Lot> get lots => List.unmodifiable(_lots);
  bool get loading => _loading;
  LotStatsDto? get stats => _stats;

  Future<void> loadLots({
    LotStatus? status,
    String? createdBy,
    String? medName,
    int? page,
    int? size,
  }) async {
    _loading = true;
    notifyListeners();
    _lots = await lotRepository.fetchLots(
      status: status,
      createdBy: createdBy,
      medName: medName,
      page: page,
      size: size,
    );
    _loading = false;
    notifyListeners();
  }

  Future<void> loadStats() async {
    _stats = await lotRepository.getStats();
    notifyListeners();
  }

  Future<Lot?> getLotById(String lotId) async {
    return await lotRepository.getLotById(lotId);
  }

  Future<BlockchainLotDto?> getBlockchainState(String lotId) async {
    if (_blockchainCache.containsKey(lotId)) {
      return _blockchainCache[lotId];
    }
    final state = await lotRepository.getBlockchainState(lotId);
    if (state != null) {
      _blockchainCache[lotId] = state;
    }
    return state;
  }

  void clearBlockchainCache() {
    _blockchainCache.clear();
  }

  /// Nettoyer toutes les données (à appeler lors de la déconnexion)
  void clear() {
    _lots.clear();
    _stats = null;
    _blockchainCache.clear();
    _loading = false;
    notifyListeners();
  }

  Future<void> createLot(String medName, int qty) async {
    if (_auth == null || _auth!.user == null) return;
    _loading = true;
    notifyListeners();
    final newLot = await lotRepository.createLot(
      medName: medName,
      quantity: qty,
      createdBy: _auth!.user!.username,
    );
    _lots.add(newLot);
    _loading = false;
    notifyListeners();

    // Send notification
    await _notificationService.notifyLotCreated(medName, qty);
  }

  Future<void> validateReception(String lotId) async {
    if (_auth == null || _auth!.user == null) return;
    _loading = true;
    notifyListeners();
    final updated =
        await lotRepository.validateReception(lotId, _auth!.user!.username);
    if (updated != null) {
      final idx = _lots.indexWhere((l) => l.id == updated.id);
      if (idx != -1) _lots[idx] = updated;

      // Send notification
      await _notificationService.notifyLotValidated(updated.medName);

      // Clear blockchain cache for this lot
      _blockchainCache.remove(lotId);
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> markInPharmacy(String lotId) async {
    if (_auth == null || _auth!.user == null) return;
    _loading = true;
    notifyListeners();
    final updated =
        await lotRepository.markInPharmacy(lotId, _auth!.user!.username);
    if (updated != null) {
      final idx = _lots.indexWhere((l) => l.id == updated.id);
      if (idx != -1) _lots[idx] = updated;

      // Clear blockchain cache for this lot
      _blockchainCache.remove(lotId);
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> administerLot(String lotId) async {
    if (_auth == null || _auth!.user == null) return;
    _loading = true;
    notifyListeners();
    final updated =
        await lotRepository.administerLot(lotId, _auth!.user!.username);
    if (updated != null) {
      final idx = _lots.indexWhere((l) => l.id == updated.id);
      if (idx != -1) _lots[idx] = updated;

      // Clear blockchain cache for this lot
      _blockchainCache.remove(lotId);
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> withdraw(String lotId, int qty) async {
    if (_auth == null || _auth!.user == null) return;
    _loading = true;
    notifyListeners();
    final updated =
        await lotRepository.withdraw(lotId, qty, _auth!.user!.username);
    if (updated != null) {
      final idx = _lots.indexWhere((l) => l.id == updated.id);
      if (idx != -1) _lots[idx] = updated;

      // Send notification
      await _notificationService.notifyLotWithdrawal(updated.medName, qty);

      // Clear blockchain cache for this lot
      _blockchainCache.remove(lotId);
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> addHistory(String lotId, String action) async {
    if (_auth == null || _auth!.user == null) return;
    _loading = true;
    notifyListeners();
    final updated =
        await lotRepository.addHistory(lotId, action, _auth!.user!.username);
    if (updated != null) {
      final idx = _lots.indexWhere((l) => l.id == updated.id);
      if (idx != -1) _lots[idx] = updated;

      // Send notification for orders
      if (action.toLowerCase().contains('commande')) {
        await _notificationService.notifyOrderPlaced(updated.medName);
      }

      // Clear blockchain cache for this lot
      _blockchainCache.remove(lotId);
    }
    _loading = false;
    notifyListeners();
  }
}
