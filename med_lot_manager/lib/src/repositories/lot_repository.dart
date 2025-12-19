import 'package:uuid/uuid.dart';
import '../config/config.dart';
import '../services/api_service.dart';
import '../models/lot.dart';
import '../models/lot_stats.dart';
import '../models/blockchain_lot.dart';

abstract class LotRepository {
  Future<List<Lot>> fetchLots({
    LotStatus? status,
    String? createdBy,
    String? medName,
    int? page,
    int? size,
  });
  Future<Lot> createLot({
    required String medName,
    required int quantity,
    required String createdBy,
  });
  Future<Lot?> getLotById(String lotId);
  Future<Lot?> validateReception(String lotId, String actor);
  Future<Lot?> markInPharmacy(String lotId, String actor);
  Future<Lot?> administerLot(String lotId, String actor);
  Future<Lot?> withdraw(String lotId, int qty, String actor);
  Future<Lot?> addHistory(String lotId, String action, String actor);
  Future<BlockchainLotDto?> getBlockchainState(String lotId);
  Future<LotStatsDto?> getStats();

  static LotRepository create({
    required Config config,
    required ApiService apiService,
  }) {
    if (config.useMock) {
      return MockLotRepository();
    } else {
      return RemoteLotRepository(apiService: apiService);
    }
  }
}

/// Mock in-memory repository
class MockLotRepository implements LotRepository {
  final _uuid = Uuid();
  final List<Lot> _lots = [];

  MockLotRepository() {
    final now = DateTime.now();
    _lots.addAll([
      Lot(
        id: _uuid.v4(),
        medName: 'Paracetamol 500mg',
        quantity: 1000,
        createdBy: 'grossiste',
        createdAt: now.subtract(Duration(days: 10)),
        validated: true,
        status: LotStatus.EN_STOCK_PHARMACIE,
        history: [
          LotHistoryEntry(
            action: 'Validated reception',
            actor: 'hopitale',
            timestamp: now.subtract(Duration(days: 9)),
            at: now.subtract(Duration(days: 9)),
          ),
          LotHistoryEntry(
            action: 'Dispensed 20',
            actor: 'pharmacien',
            timestamp: now.subtract(Duration(days: 8)),
            at: now.subtract(Duration(days: 8)),
          ),
        ],
      ),
      Lot(
        id: _uuid.v4(),
        medName: 'Amoxicillin 250mg',
        quantity: 500,
        createdBy: 'grossiste',
        createdAt: now.subtract(Duration(days: 3)),
        validated: false,
        status: LotStatus.CREE_PAR_GROSSISTE,
      ),
    ]);
  }

  @override
  Future<Lot> createLot({
    required String medName,
    required int quantity,
    required String createdBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final newLot = Lot(
      id: _uuid.v4(),
      medName: medName,
      quantity: quantity,
      createdBy: createdBy,
      createdAt: now,
      validated: false,
      status: LotStatus.CREE_PAR_GROSSISTE,
      history: [
        LotHistoryEntry(
          action: 'Created lot',
          actor: createdBy,
          timestamp: now,
          at: now,
        )
      ],
    );
    _lots.add(newLot);
    return newLot;
  }

  @override
  Future<List<Lot>> fetchLots({
    LotStatus? status,
    String? createdBy,
    String? medName,
    int? page,
    int? size,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    var filtered = _lots.where((lot) {
      if (status != null && lot.status != status) return false;
      if (createdBy != null && lot.createdBy != createdBy) return false;
      if (medName != null &&
          !lot.medName.toLowerCase().contains(medName.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    // Simple pagination
    if (page != null && size != null) {
      final start = page * size;
      final end = start + size;
      if (start < filtered.length) {
        filtered = filtered.sublist(
          start,
          end > filtered.length ? filtered.length : end,
        );
      } else {
        filtered = [];
      }
    }

    return filtered.map((l) => Lot.fromJson(l.toJson())).toList();
  }

  @override
  Future<Lot?> getLotById(String lotId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final lot = _lots.firstWhere((l) => l.id == lotId, orElse: () => _lots[0]);
    return Lot.fromJson(lot.toJson());
  }

  @override
  Future<Lot?> validateReception(String lotId, String actor) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final idx = _lots.indexWhere((l) => l.id == lotId);
    if (idx == -1) return null;
    final now = DateTime.now();
    _lots[idx].validated = true;
    _lots[idx].status = LotStatus.VALIDE_PAR_HOPITAL;
    _lots[idx].history.add(LotHistoryEntry(
          action: 'Reception validated',
          actor: actor,
          timestamp: now,
          at: now,
        ));
    return _lots[idx];
  }

  @override
  Future<Lot?> markInPharmacy(String lotId, String actor) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final idx = _lots.indexWhere((l) => l.id == lotId);
    if (idx == -1) return null;
    final now = DateTime.now();
    _lots[idx].status = LotStatus.EN_STOCK_PHARMACIE;
    _lots[idx].history.add(LotHistoryEntry(
          action: 'Marked in pharmacy stock',
          actor: actor,
          timestamp: now,
          at: now,
        ));
    return _lots[idx];
  }

  @override
  Future<Lot?> administerLot(String lotId, String actor) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final idx = _lots.indexWhere((l) => l.id == lotId);
    if (idx == -1) return null;
    final now = DateTime.now();
    _lots[idx].status = LotStatus.ADMINISTRE;
    _lots[idx].history.add(LotHistoryEntry(
          action: 'Administered',
          actor: actor,
          timestamp: now,
          at: now,
        ));
    return _lots[idx];
  }

  @override
  Future<Lot?> withdraw(String lotId, int qty, String actor) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final idx = _lots.indexWhere((l) => l.id == lotId);
    if (idx == -1) return null;
    if (_lots[idx].quantity < qty) throw Exception('Not enough quantity');
    final now = DateTime.now();
    _lots[idx].quantity -= qty;
    _lots[idx].history.add(LotHistoryEntry(
          action: 'Withdraw $qty',
          actor: actor,
          timestamp: now,
          at: now,
        ));
    return _lots[idx];
  }

  @override
  Future<Lot?> addHistory(String lotId, String action, String actor) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _lots.indexWhere((l) => l.id == lotId);
    if (idx == -1) return null;
    final now = DateTime.now();
    _lots[idx].history.add(LotHistoryEntry(
          action: action,
          actor: actor,
          timestamp: now,
          at: now,
        ));
    return _lots[idx];
  }

  @override
  Future<BlockchainLotDto?> getBlockchainState(String lotId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final lot = _lots.firstWhere((l) => l.id == lotId, orElse: () => _lots[0]);
    return BlockchainLotDto(
      lotId: lot.id,
      name: lot.medName,
      blockchainStatus: lot.status.index,
      statusName: lot.status.name,
      actor: lot.createdBy,
      timestamp: lot.createdAt.millisecondsSinceEpoch ~/ 1000,
      syncedWithDatabase: true,
    );
  }

  @override
  Future<LotStatsDto?> getStats() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return LotStatsDto(
      totalLots: _lots.length,
      createdLots:
          _lots.where((l) => l.status == LotStatus.CREE_PAR_GROSSISTE).length,
      validatedLots:
          _lots.where((l) => l.status == LotStatus.VALIDE_PAR_HOPITAL).length,
      inStockLots:
          _lots.where((l) => l.status == LotStatus.EN_STOCK_PHARMACIE).length,
      administeredLots:
          _lots.where((l) => l.status == LotStatus.ADMINISTRE).length,
      totalQuantity: _lots.fold(0, (sum, lot) => sum + lot.quantity),
    );
  }
}

/// Remote implementation calling real endpoints
class RemoteLotRepository implements LotRepository {
  final ApiService apiService;
  RemoteLotRepository({required this.apiService});

  @override
  Future<Lot> createLot({
    required String medName,
    required int quantity,
    required String createdBy,
  }) async {
    final resp = await apiService.post('/lots', {
      'medName': medName,
      'quantity': quantity,
      'createdBy': createdBy,
    });
    return Lot.fromJson(resp.data as Map<String, dynamic>);
  }

  @override
  Future<List<Lot>> fetchLots({
    LotStatus? status,
    String? createdBy,
    String? medName,
    int? page,
    int? size,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status.name;
    if (createdBy != null) queryParams['createdBy'] = createdBy;
    if (medName != null) queryParams['medName'] = medName;
    if (page != null) queryParams['page'] = page;
    if (size != null) queryParams['size'] = size;

    final resp = await apiService.get('/lots', queryParameters: queryParams);
    final list = resp.data as List<dynamic>;
    return list.map((e) => Lot.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Lot?> getLotById(String lotId) async {
    try {
      final resp = await apiService.get('/lots/$lotId');
      return Lot.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Lot?> validateReception(String lotId, String actor) async {
    try {
      final resp =
          await apiService.post('/lots/$lotId/validate', {'actor': actor});
      return Lot.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Lot?> markInPharmacy(String lotId, String actor) async {
    try {
      final resp =
          await apiService.post('/lots/$lotId/stock', {'actor': actor});
      return Lot.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Lot?> administerLot(String lotId, String actor) async {
    try {
      final resp =
          await apiService.post('/lots/$lotId/administer', {'actor': actor});
      return Lot.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Lot?> withdraw(String lotId, int qty, String actor) async {
    try {
      final resp = await apiService
          .post('/lots/$lotId/withdraw', {'qty': qty, 'actor': actor});
      return Lot.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Lot?> addHistory(String lotId, String action, String actor) async {
    try {
      final resp = await apiService
          .post('/lots/$lotId/history', {'action': action, 'actor': actor});
      return Lot.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<BlockchainLotDto?> getBlockchainState(String lotId) async {
    try {
      final resp = await apiService.get('/lots/$lotId/blockchain');
      return BlockchainLotDto.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<LotStatsDto?> getStats() async {
    try {
      final resp = await apiService.get('/lots/stats');
      return LotStatsDto.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }
}
