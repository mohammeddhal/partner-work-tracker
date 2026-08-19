enum WorkSessionStatus {
  active,
  completed,
  needsReview;

  static WorkSessionStatus fromString(String? status) {
    switch (status) {
      case 'completed':
        return WorkSessionStatus.completed;
      case 'needs_review':
        return WorkSessionStatus.needsReview;
      case 'active':
      default:
        return WorkSessionStatus.active;
    }
  }

  String toValue() {
    switch (this) {
      case WorkSessionStatus.active:
        return 'active';
      case WorkSessionStatus.completed:
        return 'completed';
      case WorkSessionStatus.needsReview:
        return 'needs_review';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case WorkSessionStatus.active:
        return 'جارية الآن';
      case WorkSessionStatus.completed:
        return 'مكتملة';
      case WorkSessionStatus.needsReview:
        return 'تحتاج مراجعة (تجاوزت اليوم)';
    }
  }
}
