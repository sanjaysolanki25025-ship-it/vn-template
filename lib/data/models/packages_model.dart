class PackagesModel {
  final String id;
  final int coin;
  final int rupes;
  final int template;

  PackagesModel({
    required this.id,
    required this.coin,
    required this.rupes,
    required this.template,
  });

  static List<PackagesModel> fromMetadataMap(Map<String, dynamic> map) {
    return map.entries.map((entry) {
      final Map<String, dynamic> data = entry.value is Map
          ? Map<String, dynamic>.from(entry.value)
          : {};

      return PackagesModel(
        id: entry.key,
        coin: data['coin'] ?? 0,
        rupes: data['rupes'] ?? 0,
        template: data['template'] ?? 0,
      );
    }).toList()..sort((a, b) => a.rupes.compareTo(b.rupes));
  }
}
