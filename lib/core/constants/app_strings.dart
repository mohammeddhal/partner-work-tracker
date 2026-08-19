class AppStrings {
  static const String appName = 'متابع عمل الشركاء';
  static const String appTagline = 'نظام متابعة العمل، الساعات، والنقاط بدقة وشفافية سحابية';

  // Navigation
  static const String navHome = 'الرئيسية';
  static const String navHistory = 'السجل';
  static const String navReports = 'التقارير والمقارنة';
  static const String navProfile = 'الحساب';
  static const String navAdmin = 'الإدارة';

  // Authentication
  static const String loginTitle = 'تسجيل الدخول';
  static const String loginSubtitle = 'أدخل بريدك الإلكتروني وكلمة المرور للمتابعة';
  static const String emailLabel = 'البريد الإلكتروني';
  static const String passwordLabel = 'كلمة المرور';
  static const String loginButton = 'تسجيل الدخول';
  static const String quickSwitchTitle = 'حسابات التجربة السريعة:';
  static const String loginError = 'فشل تسجيل الدخول، يرجى التحقق من البيانات';
  static const String logout = 'تسجيل الخروج';
  static const String logoutConfirm = 'هل أنت متأكد من تسجيل الخروج؟';

  // Home Tracker
  static const String welcomeBack = 'مرحباً، ';
  static const String notWorkingYet = 'لم تبدأ العمل اليوم';
  static const String currentlyWorking = 'جلسة عمل جارية الآن';
  static const String startWork = 'بدء العمل';
  static const String endWork = 'إنهاء العمل';
  static const String sessionActiveWarning = 'لديك جلسة عمل نشطة بالفعل. قم بإنهائها أولاً.';
  static const String activeSince = 'بدأت في الساعة';
  static const String todayWorkTime = 'مدة العمل اليوم';
  static const String requiredTime = 'المطلوب اليوم';
  static const String todayPoints = 'النقاط';
  static const String achievementRatio = 'نسبة الإنجاز';
  static const String differenceTime = 'الفارق';
  static const String overtime = 'ساعات إضافية';
  static const String deficit = 'ساعات ناقصة';
  static const String sessionsCount = 'الجلسات اليوم';

  // History
  static const String historyTitle = 'سجل الجلسات والأيام';
  static const String noSessions = 'لا توجد جلسات مسجلة في هذا التاريخ';
  static const String firstCheckIn = 'أول دخول';
  static const String lastCheckOut = 'آخر خروج';
  static const String totalWorked = 'الإجمالي الفعلي';
  static const String manualSessionTag = 'معدلة يدوياً';
  static const String sessionDetails = 'تفاصيل الجلسة';

  // Reports & Comparison
  static const String monthlyReportTitle = 'التقرير الشهري';
  static const String partnerComparison = 'مقارنة الشركاء';
  static const String effortRatio = 'نسبة المجهود الشهرية';
  static const String effortShareDisclaimer = 'ملاحظة: نسبة المجهود تقيس نسبة تحقيق التزام كل شريك من إجمالي النقاط، ولا تعد نسبة ملكية تلقائية.';
  static const String closeMonthButton = 'إغلاق الشهر';
  static const String reopenMonthButton = 'إعادة فتح الشهر';
  static const String closedMonthTag = 'مغلق';
  static const String openMonthTag = 'مفتوح (جاري)';
  static const String previousMonthsTitle = 'الأشهر السابقة';
  static const String closeMonthConfirmTitle = 'تأكيد إغلاق الشهر';
  static const String closeMonthConfirmMsg = 'هل أنت متأكد من إغلاق هذا الشهر؟ سيتم إنشاء لقطة نهائية (Snapshot) وتجميد النتائج.';
  static const String commitmentRatio = 'نسبة الالتزام';
  static const String attendanceDays = 'أيام الحضور';
  static const String absentDays = 'أيام بدون عمل';

  // Admin
  static const String adminDashboard = 'لوحة التحكم والإدارة';
  static const String partnersManagement = 'إدارة الشركاء';
  static const String auditLogsTitle = 'سجل التدقيق (Audit Log)';
  static const String editPartnerSettings = 'تعديل إعدادات الشريك';
  static const String requiredDailyMinutesLabel = 'ساعات العمل اليومية المطلوبة';
  static const String workingDaysLabel = 'أيام العمل الأسبوعية';
  static const String addManualSession = 'إضافة جلسة يدوياً';
  static const String editSession = 'تعديل جلسة العمل';
  static const String deleteSession = 'حذف الجلسة';
  static const String editReasonLabel = 'سبب التعديل (إلزامي)';
  static const String editReasonHint = 'مثال: نسي الشريك تسجيل الخروج، أو عطل تقني...';
  static const String saveChanges = 'حفظ التعديلات';
  static const String cancel = 'إلغاء';
  static const String confirm = 'تأكيد';

  // Warnings & Notifications
  static const String longSessionWarningTitle = 'تنبيه جلسة طويلة';
  static const String longSessionWarningBody = 'لديك جلسة عمل مستمرة منذ أكثر من 4 ساعات، هل نسيت تسجيل الخروج؟';
  static const String offlineBanner = 'أنت تعمل حالياً بدون اتصال، سيتم المزامنة تلقائياً عند عودة الشبكة.';
}
