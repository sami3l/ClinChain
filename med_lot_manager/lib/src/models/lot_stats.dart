class LotStatsDto {
  final int totalLots;
  final int createdLots;
  final int validatedLots;
  final int inStockLots;
  final int administeredLots;
  final int totalQuantity;

  LotStatsDto({
    required this.totalLots,
    required this.createdLots,
    required this.validatedLots,
    required this.inStockLots,
    required this.administeredLots,
    required this.totalQuantity,
  });

  factory LotStatsDto.fromJson(Map<String, dynamic> json) {
    return LotStatsDto(
      totalLots: json['totalLots'] as int,
      createdLots: json['createdLots'] as int,
      validatedLots: json['validatedLots'] as int,
      inStockLots: json['inStockLots'] as int,
      administeredLots: json['administeredLots'] as int,
      totalQuantity: json['totalQuantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalLots': totalLots,
      'createdLots': createdLots,
      'validatedLots': validatedLots,
      'inStockLots': inStockLots,
      'administeredLots': administeredLots,
      'totalQuantity': totalQuantity,
    };
  }
}
