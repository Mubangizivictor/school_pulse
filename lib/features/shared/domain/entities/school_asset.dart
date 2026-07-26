enum AssetStatus { operational, repairNeeded, decommissioned }

class SchoolAsset {
  final String id;
  final String name;
  final String category;
  final String location;
  final AssetStatus status;
  final DateTime purchaseDate;
  final double value;

  const SchoolAsset({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.status,
    required this.purchaseDate,
    required this.value,
  });
}

class MaintenanceTicket {
  final String id;
  final String assetId;
  final String assetName;
  final String description;
  final String priority; // Low, Medium, High
  final String status; // Pending, In-Progress, Resolved
  final DateTime createdAt;

  const MaintenanceTicket({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
  });
}
