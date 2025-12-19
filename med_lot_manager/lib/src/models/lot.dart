enum LotStatus {
  CREE_PAR_GROSSISTE,
  VALIDE_PAR_HOPITAL,
  EN_STOCK_PHARMACIE,
  ADMINISTRE;

  static LotStatus fromString(String value) {
    return LotStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LotStatus.CREE_PAR_GROSSISTE,
    );
  }
}

class Lot {
  final String id;
  String medName;
  int quantity;
  String createdBy;
  DateTime createdAt;
  bool validated;
  LotStatus status;
  List<LotHistoryEntry> history;

  Lot({
    required this.id,
    required this.medName,
    required this.quantity,
    required this.createdBy,
    required this.createdAt,
    this.validated = false,
    this.status = LotStatus.CREE_PAR_GROSSISTE,
    List<LotHistoryEntry>? history,
  }) : history = history ?? [];

  factory Lot.fromJson(Map<String, dynamic> json) {
    return Lot(
      id: json['id'] as String,
      medName: json['medName'] as String,
      quantity: json['quantity'] as int,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      validated: json['validated'] as bool? ?? false,
      status: json['status'] != null
          ? LotStatus.fromString(json['status'] as String)
          : LotStatus.CREE_PAR_GROSSISTE,
      history: (json['history'] as List<dynamic>?)
              ?.map((e) => LotHistoryEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medName': medName,
      'quantity': quantity,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'validated': validated,
      'status': status.name,
      'history': history.map((h) => h.toJson()).toList(),
    };
  }
}

class LotHistoryEntry {
  final String action;
  final String actor;
  final DateTime timestamp;
  final DateTime at;

  LotHistoryEntry({
    required this.action,
    required this.actor,
    required this.timestamp,
    required this.at,
  });

  factory LotHistoryEntry.fromJson(Map<String, dynamic> json) {
    final timestampStr = json['timestamp'] as String?;
    final atStr = json['at'] as String?;
    final timestamp = timestampStr != null
        ? DateTime.parse(timestampStr)
        : (atStr != null ? DateTime.parse(atStr) : DateTime.now());
    final at = atStr != null ? DateTime.parse(atStr) : timestamp;

    return LotHistoryEntry(
      action: json['action'] as String,
      actor: json['actor'] as String,
      timestamp: timestamp,
      at: at,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'actor': actor,
      'timestamp': timestamp.toIso8601String(),
      'at': at.toIso8601String(),
    };
  }
}
