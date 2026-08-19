class SlotSymbol {
  final String id;
  final String svgAsset;
  final int coinReward;
  final bool isTemplate;

  const SlotSymbol({
    required this.id,
    required this.svgAsset,
    required this.coinReward,
    this.isTemplate = false,
  });
}
