class FeesDueModel {
  final Map<String, dynamic> raw;

  const FeesDueModel(this.raw);

  String? get feesGroup => _firstString(['fees_group_name', 'fees_group']);
  String? get feesType => _firstString(['fees_type_name', 'fees_type']);
  double get amount => _asDouble(raw['amount']) ?? 0;
  double get amountPaid => _asDouble(raw['amount_paid']) ?? 0;
  double get amountDue => amount - amountPaid;
  String? get dueDate => _firstString(['due_date']);

  String? _firstString(List<String> keys) {
    for (final key in keys) {
      final value = raw[key];
      if (value != null && value.toString().trim().isNotEmpty) return value.toString();
    }
    return null;
  }

  static double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  factory FeesDueModel.fromJson(Map<String, dynamic> json) => FeesDueModel(json);
}
