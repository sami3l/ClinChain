class BlockchainLotDto {
  final String lotId;
  final String name;
  final int blockchainStatus;
  final String statusName;
  final String actor;
  final int timestamp;
  final bool syncedWithDatabase;

  BlockchainLotDto({
    required this.lotId,
    required this.name,
    required this.blockchainStatus,
    required this.statusName,
    required this.actor,
    required this.timestamp,
    required this.syncedWithDatabase,
  });

  factory BlockchainLotDto.fromJson(Map<String, dynamic> json) {
    return BlockchainLotDto(
      lotId: json['lotId'] as String,
      name: json['name'] as String,
      blockchainStatus: json['blockchainStatus'] as int,
      statusName: json['statusName'] as String,
      actor: json['actor'] as String,
      timestamp: json['timestamp'] as int,
      syncedWithDatabase: json['syncedWithDatabase'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lotId': lotId,
      'name': name,
      'blockchainStatus': blockchainStatus,
      'statusName': statusName,
      'actor': actor,
      'timestamp': timestamp,
      'syncedWithDatabase': syncedWithDatabase,
    };
  }
}
