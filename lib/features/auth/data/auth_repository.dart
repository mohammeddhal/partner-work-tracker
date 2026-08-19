import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_model.dart';
import '../domain/user_role.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return Stream.value(null);
  return ref.watch(authRepositoryProvider).watchUser(authUser.uid);
});

final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(authRepositoryProvider).watchAllUsers();
});

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({
    required this.auth,
    required this.firestore,
  });

  Stream<User?> authStateChanges() => auth.authStateChanges();

  User? get currentAuthUser => auth.currentUser;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      firestore.collection('users');

  Stream<UserModel?> watchUser(String uid) {
    return _usersCol.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserModel.fromMap(snapshot.data()!, snapshot.id);
    });
  }

  Stream<List<UserModel>> watchAllUsers() {
    return _usersCol.where('isActive', isEqualTo: true).snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
      // Filter out any obsolete dummy IDs
      return list.where((u) => u.id != 'partner_mohammad' && u.id != 'partner_masoud').toList();
    });
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersCol.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<UserCredential> signIn(String email, String password) async {
    final credential = await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    // Sync or initialize user profile in Firestore
    if (credential.user != null) {
      await _syncUserProfile(credential.user!);
    }

    return credential;
  }

  Future<void> _syncUserProfile(User user) async {
    final doc = await _usersCol.doc(user.uid).get();
    final emailLower = (user.email ?? '').trim().toLowerCase();

    if (!doc.exists || doc.data() == null) {
      final now = DateTime.now();

      // Real Account 1: Mohammad (m@m.com)
      if (emailLower == 'm@m.com') {
        final mohammad = UserModel(
          id: user.uid,
          name: 'محمد',
          email: 'm@m.com',
          role: UserRole.admin,
          requiredDailyMinutes: 120, // 2 Hours
          workingDaysPerWeek: 5,
          workingDays: [7, 1, 2, 3, 4], // Sun, Mon, Tue, Wed, Thu
          effectiveStartDate: DateTime(now.year, now.month, 1),
          isActive: true,
          createdAt: now,
        );
        await _usersCol.doc(user.uid).set(mohammad.toMap());
      }
      // Real Account 2: Masoud (estrdaad@gmail.com)
      else if (emailLower == 'estrdaad@gmail.com') {
        final masoud = UserModel(
          id: user.uid,
          name: 'مسعود',
          email: 'estrdaad@gmail.com',
          role: UserRole.partner,
          requiredDailyMinutes: 240, // 4 Hours
          workingDaysPerWeek: 5,
          workingDays: [7, 1, 2, 3, 4], // Sun, Mon, Tue, Wed, Thu
          effectiveStartDate: DateTime(now.year, now.month, 1),
          isActive: true,
          createdAt: now,
        );
        await _usersCol.doc(user.uid).set(masoud.toMap());
      } else {
        // Generic fallback if another user is added later
        final generic = UserModel(
          id: user.uid,
          name: user.displayName ?? emailLower.split('@').first,
          email: user.email ?? '',
          role: UserRole.partner,
          requiredDailyMinutes: 120,
          workingDaysPerWeek: 5,
          workingDays: [7, 1, 2, 3, 4],
          effectiveStartDate: DateTime(now.year, now.month, 1),
          isActive: true,
          createdAt: now,
        );
        await _usersCol.doc(user.uid).set(generic.toMap());
      }
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> updateUser(UserModel user) async {
    await _usersCol.doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  Future<void> createUser(UserModel user) async {
    await _usersCol.doc(user.id).set(user.toMap());
  }

  /// Cleans up any obsolete demo documents from previous tests
  Future<void> cleanObsoleteDemoUsers() async {
    try {
      await _usersCol.doc('partner_mohammad').delete();
      await _usersCol.doc('partner_masoud').delete();
    } catch (_) {}
  }
}
