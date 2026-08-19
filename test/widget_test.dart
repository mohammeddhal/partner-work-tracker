import 'package:flutter_test/flutter_test.dart';
import 'package:partner_work_tracker/features/auth/domain/user_role.dart';
import 'package:partner_work_tracker/features/tracker/domain/work_session_status.dart';

void main() {
  test('Enum conversion and Arabic string representation tests', () {
    expect(UserRole.fromString('admin'), UserRole.admin);
    expect(UserRole.fromString('partner'), UserRole.partner);
    expect(UserRole.admin.toValue(), 'admin');

    expect(WorkSessionStatus.fromString('active'), WorkSessionStatus.active);
    expect(WorkSessionStatus.fromString('completed'), WorkSessionStatus.completed);
    expect(WorkSessionStatus.fromString('needs_review'), WorkSessionStatus.needsReview);
    expect(WorkSessionStatus.needsReview.toValue(), 'needs_review');
  });
}
