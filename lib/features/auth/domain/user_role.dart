enum UserRole {
  admin,
  partner;

  static UserRole fromString(String? role) {
    if (role == 'admin') return UserRole.admin;
    return UserRole.partner;
  }

  String toValue() {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.partner:
        return 'partner';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case UserRole.admin:
        return 'مدير النظام (Admin)';
      case UserRole.partner:
        return 'شريك (Partner)';
    }
  }
}
