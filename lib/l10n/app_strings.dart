import 'package:flutter/material.dart';

/// Centralized localization for court+
///
/// Usage: AppStrings.of(context).translate('key')
/// or: AppStrings.translate('key', 'en')
class AppStrings {
  static const Map<String, Map<String, String>> _translations = {
    'en': _en,
    'ar': _ar,
  };

  AppStrings._();

  /// Get translation by key for a given locale code.
  /// Falls back to English, then returns the key itself.
  static String translate(String key, [String locale = 'en']) {
    return _translations[locale]?[key] ??
        _translations['en']?[key] ??
        key;
  }

  /// Convenience: get from BuildContext
  static AppStringsInherited of(BuildContext context) {
    return AppStringsInherited.of(context);
  }
}

/// InheritedWidget for easy access: AppStrings.of(context).t('key')
class AppStringsInherited extends InheritedWidget {
  final String locale;

  const AppStringsInherited({
    super.key,
    required this.locale,
    required super.child,
  });

  String t(String key) => AppStrings.translate(key, locale);

  static AppStringsInherited of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<AppStringsInherited>();
    assert(result != null, 'No AppStringsInherited found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant AppStringsInherited oldWidget) =>
      locale != oldWidget.locale;
}

// ═════════════════════════════════════════════════════════════════════════════
// ENGLISH TRANSLATIONS
// ═════════════════════════════════════════════════════════════════════════════

const Map<String, String> _en = {
  // ── App ──
  'appName': 'court+',
  'appTitle': 'court+',

  // ── Language Screen ──
  'chooseLanguage': 'Choose Your Language',
  'arabic': 'العربية',
  'english': 'English',
  'done': 'Done',
  'byContinuingAgree': 'By continuing you agree to our Terms of Service\nand Privacy Policy',

  // ── Onboarding ──
  'yourPathToPlay': 'Your Path to Play,\nAnytime, Anywhere.',
  'bookCourtsFindCoaches': 'Book courts, find coaches and join matches near you — all in one place.',
  'getStarted': 'Get Started',
  'continueAsGuest': 'Continue as Guest',

  // ── Auth (Signup / Login) ──
  'signUp': 'Sign up',
  'fullName': 'Full name',
  'enterFullName': 'Enter your full name',
  'email': 'Email',
  'enterEmail': 'Enter your email',
  'username': 'Username',
  'usernameHint': 'username',
  'phoneNumber': 'Phone number',
  'phoneHint': '5X XXX XXXX',
  'dateOfBirth': 'Date of Birth',
  'dobHint': 'DD / MM / YYYY',
  'gender': 'Gender',
  'selectGender': 'Select gender',
  'male': 'Male',
  'female': 'Female',
  'preferNotToSay': 'Prefer not to say',
  'or': 'or',
  'alreadyHaveAccount': 'Already have an account? ',
  'signIn': 'Sign In',
  'login': 'Login',
  'password': 'Password',
  'enterPassword': 'Enter your password',
  'forgotPassword': 'Forgot Password?',
  'dontHaveAccount': "Don't have an account? ",
  'signUpLink': 'Sign Up',

  // ── OTP ──
  'inputOtp': 'Input OTP for Account to\nSign up',
  'otpSentMessage': 'Court+ just sent you a 6-Digit Code to ',
  'otpCheckMessages': ' please check your messages & enter the code below.',
  'resendOtp': 'Resend OTP code',
  'resendOtpTimer': 'Resend OTP code in 00:',
  'didntReceiveCode': "Didn't receive code? Resend",

  // ── Profile Setup ──
  'completeProfileSetup': 'Complete Your\nProfile Setup',
  'yourName': 'Your name',
  'usernameAt': '@username',
  'bio': 'Bio',
  'tellUsAboutYourself': 'Tell us about yourself…',
  'sportsLevel': 'Sports level',
  'addGame': 'Add Game',
  'skip': 'Skip',
  'addASport': 'Add a Sport',
  'selectSportSkill': 'Select your sport and skill level:',
  'tennis': 'Tennis',
  'football': 'Football',
  'basketball': 'Basketball',
  'padel': 'Padel',

  // ── Home ──
  'location': 'Location',
  'riyadhSaudiArabia': 'Riyadh, Saudi Arabia',
  'findCourtsCoaches': 'Find a courts, coaches + more',
  'allCourts': 'All courts',
  'courts': 'Courts',
  'seeAll': 'See all',
  'playAmazingMatch': 'Play amazing Match',
  'openMatch': 'Open match',
  'coaches': 'Coaches',
  'home': 'Home',
  'activity': 'Activity',
  'profile': 'Profile',
  'explore': 'Explore',

  // ── Courts ──
  'searchCourts': 'Search courts...',
  'nearest': 'Nearest',
  'highestRated': 'Highest Rated',
  'priceLow': 'Price Low',
  'priceHigh': 'Price High',
  'filters': 'Filters',
  'rating': 'Rating',
  'enterLocation': 'Enter location',
  'surface': 'Surface',
  'any': 'Any',
  'clay': 'Clay',
  'grass': 'Grass',
  'hard': 'Hard',
  'applyFilters': 'Apply Filters',
  'resultsFound': 'results found',
  'loading': 'Loading...',
  'kmAway': 'km away',
  'mAway': 'm away',
  'noCourtsFound': 'No courts found',

  // ── Court Details ──
  'courtDetails': 'Court Details',
  'details': 'Details',
  'availability': 'Availability',
  'specs': 'Specs',
  'moments': 'Moments',
  'ratePerHour': 'Rate per hour',
  'minTime': 'Min time',
  'sessions': 'Sessions',
  'failedToLoadCourt': 'Failed to load court',
  'court': 'Court',
  'center': 'Center',
  'duration': 'Duration',
  'addOns': 'Add-ons',
  'addOnsTotal': 'Add-ons total',
  'courtFee': 'Court Fee',
  'total': 'Total',
  'bookingSummary': 'Booking Summary',
  'selectDate': 'Select Date',
  'selectTime': 'Select Time',
  'next': 'Next',

  // ── Booking ──
  'booking': 'Booking',
  'selectACourt': 'Select a Court',
  'selectDuration': 'Select Duration',
  'noAvailableSlots': 'No available slots for this date',
  'extrasEquipment': 'Extras & Equipment',
  'racketRental': 'Racket Rental',
  'ballPack': 'Ball Pack',
  'waterBottle': 'Water Bottle',
  'towel': 'Towel',
  'wristband': 'Wristband',
  'subtotal': 'Subtotal',
  'reviewBooking': 'Review Booking',
  'freeCancellation': 'Free cancellation up to 24 hours before your booking.',
  'proceedToPay': 'Proceed to Pay - SR ',
  'confirmBooking': 'Confirm Booking',
  'bookingFailed': 'Booking failed: ',
  'bookSummary': 'Book Summary',
  'payYourPart': 'Pay Your Part',
  'payEverything': 'Pay Everything',
  'youPayYourShare': 'You only pay your share',
  'payFullAmount': 'Pay the full amount now',

  // ── Payment Gateway ──
  'payment': 'Payment',
  'orderSummary': 'Order Summary',
  'selectPaymentMethod': 'Select Payment Method',
  'applePay': 'Apple Pay',
  'googlePay': 'Google Pay',
  'creditCard': 'Credit Card',
  'stcPay': 'STC Pay',
  'cardNumber': 'Card Number',
  'cardHint': '1234 5678 9012 3456',
  'expiry': 'Expiry',
  'expiryHint': 'MM/YY',
  'cvv': 'CVV',
  'cvvHint': '123',
  'securePayment': 'Secure payment via SSL encryption',
  'pay': 'Pay SR ',

  // ── Booking Success ──
  'bookingConfirmed': 'Booking Confirmed',
  'bookingSuccessful': 'Booking Successful!',
  'courtReservedSuccessfully': 'Your court has been reserved successfully.',
  'bookingDetails': 'Booking Details',
  'bookingId': 'Booking ID',
  'date': 'Date',
  'paymentMethod': 'Payment Method',
  'amountPaid': 'Amount Paid',
  'viewTicket': 'View Ticket',
  'backToHome': 'Back to Home',
  'confirmed': 'Confirmed',

  // ── Booking Ticket ──
  'bookingTicket': 'Booking Ticket',
  'addToCalendar': 'Add to Calendar',
  'shareComingSoon': 'Share functionality coming soon',
  'addedToCalendar': 'Added to calendar',
  'player': 'Player',

  // ── Notifications ──
  'notification': 'Notification',
  'today': 'Today',
  'yesterday': 'Yesterday',
  'earlier': 'Earlier',
  'followBack': 'Follow back',
  'following': 'Following',
  'accept': 'Accept',
  'view': 'View',
  'startedFollowingYou': 'started following you.',
  'inviteYouToMatch': 'invite you to open match.',
  'confirmedYourBooking': 'confirmed your booking for Court A.',
  'likedYourMoment': 'liked your Moment.',

  // ── Reviews ──
  'reviews': 'Reviews',
  'whenInvited': 'When someone invites you to play,\nit will appear here.',

  // ── Activity ──
  'currentBookings': 'Current bookings',
  'bookingHistory': 'Booking History',
  'noBookingsYet': 'No bookings yet',
  'enterCourt': 'Enter Court',
  'captureMoment': '📷 Capture a Court+ Moment',
  'reviewed': '✅  Reviewed',
  'addReview': '✏️  Add Review',

  // ── Add Review ──
  'rateYourExperience': 'Rate your experience',
  'tapToRate': 'Tap to rate',
  'poor': 'Poor',
  'good': 'Good',
  'veryGood': 'Very Good',
  'excellent': 'Excellent',
  'writeYourReview': 'Write your review',
  'shareExperience': 'Share your experience...',
  'submitReview': 'Submit Review',
  'thankYou': 'Thank you!',
  'reviewSubmitted': 'Your review has been submitted.',
  'wannaRateUs': 'Wanna Rate Us ?',
  'reviewSubtitle': 'Your input is valuable in helping us better understand your needs and tailor our service accordingly.',
  'addComment': 'Add a Comment . . .',
  'thankYouTitle': 'Thank You !',
  'thankYouSubtitle': 'Your review has been submitted, your feedback is important to us as to the doctors and the community.',

  // ── Activity Log ──
  'activityLog': 'Activity Log',
  'matchPlayed': 'Match Played',
  'reviewWritten': 'Review Written',
  'invitationAccepted': 'Invitation Accepted',
  'new': 'NEW',

  // ── Explore ──
  'all': 'All',
  'nearby': 'Nearby',
  'topRated': 'Top Rated',
  'loadingPleaseWait': 'Please wait',
  'couldNotLoadCourts': 'Could not load courts',
  'tapToRetry': 'Tap to retry',
  'noCourtsNearby': 'No courts nearby',
  'zoomOutToSeeMore': 'Zoom out to see more',

  // ── Search Results ──
  'searchResults': 'Search results',
  'courtsTab': 'Courts',
  'coachesTab': 'Coaches',
  'recent': 'Recent',

  // ── Profile ──
  'myProfile': 'My Profile',
  'update': 'Update',
  'follower': 'Follower',
  'myMoments': 'My Moments',
  'courtsPlayed': 'courts played',
  'courtTimes': 'court times',
  'amateur': 'Amateur',
  'advanced': 'Advanced',
  'defaultBio': 'Professional athlete & sports enthusiast. Love competing and exploring new courts around the world.',

  // ── Update Profile ──
  'updateProfile': 'Update Profile',
  'save': 'Save',
  'userName': 'User name',
  'mobileNumber': 'Mobile number',
  'userNotAuthenticated': 'User not authenticated',

  // ── Settings ──
  'settingsAndActivity': 'Settings and activity',
  'saved': 'Saved',
  'settings': 'Settings',
  'notifications': 'Notifications',
  'language': 'Language',
  'howCourtPlusWorks': 'How Court+ work',
  'legalInformation': 'Legal information',
  'termsOfUse': 'Terms of use',
  'privacyPolicy': 'Privacy policy',
  'logOut': 'log out',
  'version': 'Version 1.0.0',
  'selectLanguage': 'Select Language',
  'logout': 'Logout',
  'areYouSureLogout': 'Are you sure you want to logout?',
  'cancel': 'Cancel',

  // ── Match (Start Match / Create Match) ──
  'startAMatch': 'Start a Match',
  'continue': 'Continue',
  'chooseDate': 'Choose a date for your match',
  'chooseLocation': 'Choose your location',
  'setMatchPreference': 'Set match preference',
  'availableSlots': 'Available Slots',
  'beginner': 'Beginner',
  'intermediate': 'Intermediate',
  'openToAll': 'Open to All',
  'createMatch': 'Create Match',
  'sportAndCourt': 'Sport & Court',
  'chooseYourCourt': 'Choose your court',
  'dateAndTime': 'Date & Time',
  'pickDateAndTime': 'Pick a date and time slot',
  'matchLevel': 'Match Level',
  'whatSkillLevel': 'What skill level?',
  'privacyAndFormat': 'Privacy & Format',
  'whoCanJoin': 'Who can join?',
  'step1of2': 'Step 1 of 2',
  'step2of2': 'Step 2 of 2',
  'selectCourt': 'Select Court',

  // ── Invite Players ──
  'invitePlayers': 'Invite Players',
  'searchPlayers': 'Search players by name or phone...',
  'suggestedPlayers': 'Suggested Players',
  'shareInviteLink': 'Share Invite Link',
  'sendInviteLink': 'Send invite link to your friends',
  'linkCopied': 'Share link copied to clipboard',
  'invited': 'Invited',
  'invite': '+ Invite',
  'playersAdded': 'Players Added',

  // ── Invitation ──
  'invitationDetails': 'Invitation Details',
  'pending': 'Pending',
  'accepted': 'Accepted',
  'declined': 'Declined',
  'sender': 'Sender',
  'message': 'Message',
  'matchId': 'Match ID',
  'viewBookingTicket': 'View Booking Ticket',
  'acceptAndPayShare': 'Accept & Pay Share',
  'invitations': 'Invitations',
  'failedToLoadInvitations': 'Failed to load invitations',
  'noInvitationsYet': 'No invitations yet',

  // ── Open Matches ──
  'openMatches': 'Open Matches',
  'filter': 'Filter',
  'sort': 'Sort',
  'spots': 'spots',
  'perPerson': '/person',
  'person': '/person',

  // ── Match Filter ──
  'time': 'Time',
  'showResults': 'Show Results',
  'searchLocation': 'Search location…',

  // ── Coach ──
  'searchCoaches': 'Search coaches...',
  'sortBy': 'Sort by',
  'noCoachesFound': 'No coaches found',
  'failedToLoadCoaches': 'Failed to load coaches',
  'coachProfile': 'Coach Profile',
  'coachNotFound': 'Coach not found',
  'failedToLoadCoach': 'Failed to load coach',
  'about': 'About',
  'noBioAvailable': 'No bio available.',
  'bookSession': 'Book Session — SR ',
  'experience': 'Experience',
  'perSession': 'Per session',

  // ── Moments ──
  'latest': 'Latest',
  'popular': 'Popular',
  'noMomentsYet': 'No moments yet',
  'shareYourFirstMoment': 'Share your first moment!',
  'createMoment': 'Create Moment',
  'failedToLoadMoments': 'Failed to load moments',

  // ── Add Players ──
  'addPlayers': 'Add Players',
  'added': 'Added',
  'add': '+ Add',
  'selected': 'Selected',

  // ── Booking Card ──
  'friends': 'FRIENDS',
  'coach': 'COACH',

  // ── Weekday labels ──
  'mon': 'Mon',
  'tue': 'Tue',
  'wed': 'Wed',
  'thu': 'Thu',
  'fri': 'Fri',
  'sat': 'Sat',
  'sun': 'Sun',
  'tomorrow': 'Tomorrow',

  // ── Error messages ──
  'failed': 'Failed: ',
  'noInvitationData': 'No invitation data',

  // ── Month names ──
  'jan': 'Jan',
  'feb': 'Feb',
  'mar': 'Mar',
  'apr': 'Apr',
  'may': 'May',
  'jun': 'Jun',
  'jul': 'Jul',
  'aug': 'Aug',
  'sep': 'Sep',
  'oct': 'Oct',
  'nov': 'Nov',
  'dec': 'Dec',
};

// ═════════════════════════════════════════════════════════════════════════════
// ARABIC TRANSLATIONS
// ═════════════════════════════════════════════════════════════════════════════

const Map<String, String> _ar = {
  // ── App ──
  'appName': 'كورت+',
  'appTitle': 'كورت+',

  // ── Language Screen ──
  'chooseLanguage': 'اختر لغتك',
  'arabic': 'العربية',
  'english': 'English',
  'done': 'تم',
  'byContinuingAgree': 'بالمتابعة أنت توافق على شروط الخدمة\nوسياسة الخصوصية',

  // ── Onboarding ──
  'yourPathToPlay': 'طريقك للعب،\nفي أي وقت وفي أي مكان.',
  'bookCourtsFindCoaches': 'احجز الملاعب، وابحث عن المدربين وانضم إلى المباريات القريبة منك — كل ذلك في مكان واحد.',
  'getStarted': 'ابدأ الآن',
  'continueAsGuest': 'المتابعة كزائر',

  // ── Auth ──
  'signUp': 'إنشاء حساب',
  'fullName': 'الاسم الكامل',
  'enterFullName': 'أدخل اسمك الكامل',
  'email': 'البريد الإلكتروني',
  'enterEmail': 'أدخل بريدك الإلكتروني',
  'username': 'اسم المستخدم',
  'usernameHint': 'اسم المستخدم',
  'phoneNumber': 'رقم الهاتف',
  'phoneHint': '5XX XXX XXXX',
  'dateOfBirth': 'تاريخ الميلاد',
  'dobHint': 'DD / MM / YYYY',
  'gender': 'الجنس',
  'selectGender': 'اختر الجنس',
  'male': 'ذكر',
  'female': 'أنثى',
  'preferNotToSay': 'أفضل عدم الإفصاح',
  'or': 'أو',
  'alreadyHaveAccount': 'لديك حساب بالفعل؟ ',
  'signIn': 'تسجيل الدخول',
  'login': 'تسجيل الدخول',
  'password': 'كلمة المرور',
  'enterPassword': 'أدخل كلمة المرور',
  'forgotPassword': 'نسيت كلمة المرور؟',
  'dontHaveAccount': 'ليس لديك حساب؟ ',
  'signUpLink': 'إنشاء حساب',

  // ── OTP ──
  'inputOtp': 'أدخل رمز التحقق\nلتأكيد الحساب',
  'otpSentMessage': 'أرسل كورت+ رمزاً مكوناً من 6 أرقام إلى ',
  'otpCheckMessages': '، يرجى التحقق من رسائلك وإدخال الرمز أدناه.',
  'resendOtp': 'إعادة إرسال الرمز',
  'resendOtpTimer': 'إعادة إرسال الرمز بعد 00:',
  'didntReceiveCode': 'لم يصلك الرمز؟ أعد الإرسال',

  // ── Profile Setup ──
  'completeProfileSetup': 'أكمل إعداد\nملفك الشخصي',
  'yourName': 'اسمك',
  'usernameAt': '@اسم_المستخدم',
  'bio': 'نبذة عني',
  'tellUsAboutYourself': 'حدثنا عن نفسك…',
  'sportsLevel': 'المستوى الرياضي',
  'addGame': 'أضف رياضة',
  'skip': 'تخطي',
  'addASport': 'أضف رياضة',
  'selectSportSkill': 'اختر رياضتك ومستوى مهارتك:',
  'tennis': 'تنس',
  'football': 'كرة قدم',
  'basketball': 'كرة سلة',
  'padel': 'بادل',

  // ── Home ──
  'location': 'الموقع',
  'riyadhSaudiArabia': 'الرياض، المملكة العربية السعودية',
  'findCourtsCoaches': 'ابحث عن ملاعب، مدربين والمزيد',
  'allCourts': 'جميع الملاعب',
  'courts': 'الملاعب',
  'seeAll': 'عرض الكل',
  'playAmazingMatch': 'العب مباراة رائعة',
  'openMatch': 'مباراة مفتوحة',
  'coaches': 'المدربون',
  'home': 'الرئيسية',
  'activity': 'النشاطات',
  'profile': 'الملف الشخصي',
  'explore': 'استكشف',

  // ── Courts ──
  'searchCourts': 'ابحث عن ملاعب...',
  'nearest': 'الأقرب',
  'highestRated': 'الأعلى تقييماً',
  'priceLow': 'الأقل سعراً',
  'priceHigh': 'الأعلى سعراً',
  'filters': 'تصفية',
  'rating': 'التقييم',
  'enterLocation': 'أدخل الموقع',
  'surface': 'نوع الأرضية',
  'any': 'الكل',
  'clay': 'ترابية',
  'grass': 'عشبية',
  'hard': 'صلبة',
  'applyFilters': 'تطبيق التصفية',
  'resultsFound': 'نتيجة',
  'loading': 'جارٍ التحميل...',
  'kmAway': 'كم',
  'mAway': 'م',
  'noCourtsFound': 'لا توجد ملاعب',

  // ── Court Details ──
  'courtDetails': 'تفاصيل الملعب',
  'details': 'التفاصيل',
  'availability': 'التوفر',
  'specs': 'المواصفات',
  'moments': 'اللحظات',
  'ratePerHour': 'السعر للساعة',
  'minTime': 'الحد الأدنى',
  'sessions': 'الجلسات',
  'failedToLoadCourt': 'فشل تحميل بيانات الملعب',
  'court': 'الملعب',
  'center': 'المركز',
  'duration': 'المدة',
  'addOns': 'الإضافات',
  'addOnsTotal': 'إجمالي الإضافات',
  'courtFee': 'رسوم الملعب',
  'total': 'الإجمالي',
  'bookingSummary': 'ملخص الحجز',
  'selectDate': 'اختر التاريخ',
  'selectTime': 'اختر الوقت',
  'next': 'التالي',

  // ── Booking ──
  'booking': 'حجز',
  'selectACourt': 'اختر ملعباً',
  'selectDuration': 'اختر المدة',
  'extrasEquipment': 'الإضافات والمعدات',
  'racketRental': 'استئجار مضرب',
  'ballPack': 'حزمة كرات',
  'waterBottle': 'زجاجة مياه',
  'towel': 'منشفة',
  'wristband': 'سوار معصم',
  'subtotal': 'المجموع الفرعي',
  'reviewBooking': 'مراجعة الحجز',
  'freeCancellation': 'إلغاء مجاني حتى 24 ساعة قبل الحجز.',
  'proceedToPay': 'المتابعة للدفع - SR ',
  'bookingFailed': 'فشل الحجز: ',

  // ── Payment Gateway ──
  'payment': 'الدفع',
  'orderSummary': 'ملخص الطلب',
  'selectPaymentMethod': 'اختر طريقة الدفع',
  'applePay': 'Apple Pay',
  'googlePay': 'Google Pay',
  'creditCard': 'بطاقة ائتمان',
  'stcPay': 'STC Pay',
  'cardNumber': 'رقم البطاقة',
  'cardHint': '1234 5678 9012 3456',
  'expiry': 'تاريخ الانتهاء',
  'expiryHint': 'MM/YY',
  'cvv': 'CVV',
  'cvvHint': '123',
  'securePayment': 'دفع آمن عبر تشفير SSL',
  'pay': 'ادفع SR ',

  // ── Booking Success ──
  'bookingConfirmed': 'تم تأكيد الحجز',
  'bookingSuccessful': 'تم الحجز بنجاح!',
  'courtReservedSuccessfully': 'تم حجز ملعبك بنجاح.',
  'bookingDetails': 'تفاصيل الحجز',
  'bookingId': 'رقم الحجز',
  'date': 'التاريخ',
  'paymentMethod': 'طريقة الدفع',
  'amountPaid': 'المبلغ المدفوع',
  'viewTicket': 'عرض التذكرة',
  'backToHome': 'العودة للرئيسية',
  'confirmed': 'مؤكد',

  // ── Booking Ticket ──
  'bookingTicket': 'تذكرة الحجز',
  'addToCalendar': 'أضف إلى التقويم',
  'shareComingSoon': 'خاصية المشاركة قريباً',
  'addedToCalendar': 'تمت الإضافة إلى التقويم',
  'player': 'اللاعب',

  // ── Notifications ──
  'notification': 'الإشعارات',
  'today': 'اليوم',
  'yesterday': 'أمس',
  'earlier': 'سابقاً',
  'followBack': 'متابعة بالمثل',
  'following': 'متابعة',
  'accept': 'قبول',
  'view': 'عرض',
  'startedFollowingYou': 'بدأ متابعتك.',
  'inviteYouToMatch': 'دعاك لمباراة مفتوحة.',
  'confirmedYourBooking': 'أكد حجزك للملعب A.',
  'likedYourMoment': 'أعجب بلحظتك.',

  // ── Reviews ──
  'reviews': 'التقييمات',
  'whenInvited': 'عندما يدعوك أحدهم للعب،\nسيظهر هنا.',

  // ── Activity ──
  'currentBookings': 'الحجوزات الحالية',
  'bookingHistory': 'سجل الحجوزات',
  'noBookingsYet': 'لا توجد حجوزات بعد',
  'enterCourt': 'ادخل الملعب',
  'captureMoment': '📷 التقط لحظة كورت+',
  'reviewed': '✅  تم التقييم',
  'addReview': '✏️  أضف تقييماً',

  // ── Add Review ──
  'rateYourExperience': 'قيم تجربتك',
  'tapToRate': 'اضغط للتقييم',
  'poor': 'سيئ',
  'good': 'جيد',
  'veryGood': 'جيد جداً',
  'excellent': 'ممتاز',
  'writeYourReview': 'اكتب تقييمك',
  'shareExperience': 'شارك تجربتك...',
  'submitReview': 'إرسال التقييم',
  'thankYou': 'شكراً لك!',
  'reviewSubmitted': 'تم إرسال تقييمك.',
  'wannaRateUs': 'هل تريد تقييمنا؟',
  'reviewSubtitle': 'مدخلاتك قيمة وتساعدنا على فهم احتياجاتك بشكل أفضل وتخصيص خدماتنا وفقاً لذلك.',
  'addComment': 'أضف تعليقاً . . .',
  'thankYouTitle': 'شكراً لك!',
  'thankYouSubtitle': 'تم إرسال تقييمك، ملاحظاتك مهمة لنا وللمجتمع.',

  // ── Activity Log ──
  'activityLog': 'سجل النشاطات',
  'matchPlayed': 'تم لعب المباراة',
  'reviewWritten': 'تم كتابة تقييم',
  'invitationAccepted': 'تم قبول الدعوة',
  'new': 'جديد',

  // ── Explore ──
  'all': 'الكل',
  'nearby': 'القريبة',
  'topRated': 'الأعلى تقييماً',
  'loadingPleaseWait': 'يرجى الانتظار',
  'couldNotLoadCourts': 'تعذر تحميل الملاعب',
  'tapToRetry': 'اضغط لإعادة المحاولة',
  'noCourtsNearby': 'لا توجد ملاعب قريبة',
  'zoomOutToSeeMore': 'صغّر الخريطة لرؤية المزيد',

  // ── Search Results ──
  'searchResults': 'نتائج البحث',
  'courtsTab': 'ملاعب',
  'coachesTab': 'مدربون',
  'recent': 'الأخيرة',

  // ── Profile ──
  'myProfile': 'ملفي الشخصي',
  'update': 'تحديث',
  'follower': 'متابعون',
  'myMoments': 'لحظاتي',
  'courtsPlayed': 'ملاعب لعبها',
  'courtTimes': 'ساعات اللعب',
  'amateur': 'مبتدئ',
  'advanced': 'متقدم',
  'defaultBio': 'رياضي محترف وعاشق للرياضة. أحب المنافسة واستكشاف ملاعب جديدة حول العالم.',

  // ── Update Profile ──
  'updateProfile': 'تحديث الملف الشخصي',
  'save': 'حفظ',
  'userName': 'اسم المستخدم',
  'mobileNumber': 'رقم الجوال',
  'userNotAuthenticated': 'المستخدم غير موثق',

  // ── Settings ──
  'settingsAndActivity': 'الإعدادات والنشاطات',
  'saved': 'المحفوظات',
  'settings': 'الإعدادات',
  'notifications': 'الإشعارات',
  'language': 'اللغة',
  'howCourtPlusWorks': 'كيف يعمل كورت+',
  'legalInformation': 'معلومات قانونية',
  'termsOfUse': 'شروط الاستخدام',
  'privacyPolicy': 'سياسة الخصوصية',
  'logOut': 'تسجيل الخروج',
  'version': 'الإصدار 1.0.0',
  'selectLanguage': 'اختر اللغة',
  'logout': 'تسجيل الخروج',
  'areYouSureLogout': 'هل أنت متأكد من تسجيل الخروج؟',
  'cancel': 'إلغاء',

  // ── Match ──
  'startAMatch': 'ابدأ مباراة',
  'continue': 'متابعة',
  'chooseDate': 'اختر تاريخاً لمباراتك',
  'chooseLocation': 'اختر موقعك',
  'setMatchPreference': 'حدد تفضيلات المباراة',
  'availableSlots': 'المواعيد المتاحة',
  'beginner': 'مبتدئ',
  'intermediate': 'متوسط',
  'openToAll': 'مفتوح للجميع',
  'createMatch': 'إنشاء مباراة',
  'sportAndCourt': 'الرياضة والملعب',
  'chooseYourCourt': 'اختر ملعبك',
  'dateAndTime': 'التاريخ والوقت',
  'pickDateAndTime': 'اختر تاريخاً ووقتاً',
  'matchLevel': 'مستوى المباراة',
  'whatSkillLevel': 'ما مستوى المهارة؟',
  'privacyAndFormat': 'الخصوصية والصيغة',
  'whoCanJoin': 'من يمكنه الانضمام؟',
  'step1of2': 'الخطوة 1 من 2',
  'step2of2': 'الخطوة 2 من 2',
  'selectCourt': 'اختر الملعب',

  // ── Invite Players ──
  'invitePlayers': 'دعوة لاعبين',
  'searchPlayers': 'ابحث عن لاعبين بالاسم أو الهاتف...',
  'suggestedPlayers': 'اللاعبون المقترحون',
  'shareInviteLink': 'مشاركة رابط الدعوة',
  'sendInviteLink': 'أرسل رابط الدعوة لأصدقائك',
  'linkCopied': 'تم نسخ رابط المشاركة',
  'invited': 'تمت الدعوة',
  'invite': '+ دعوة',
  'playersAdded': 'لاعب مضاف',

  // ── Invitation ──
  'invitationDetails': 'تفاصيل الدعوة',
  'pending': 'قيد الانتظار',
  'accepted': 'مقبول',
  'declined': 'مرفوض',
  'sender': 'المرسل',
  'message': 'الرسالة',
  'matchId': 'رقم المباراة',
  'viewBookingTicket': 'عرض تذكرة الحجز',
  'acceptAndPayShare': 'قبول ودفع الحصة',
  'invitations': 'الدعوات',
  'failedToLoadInvitations': 'فشل تحميل الدعوات',
  'noInvitationsYet': 'لا توجد دعوات بعد',

  // ── Open Matches ──
  'openMatches': 'مباريات مفتوحة',
  'filter': 'تصفية',
  'sort': 'ترتيب',
  'spots': 'مقاعد',
  'person': '/للشخص',

  // ── Match Filter ──
  'time': 'الوقت',
  'showResults': 'عرض النتائج',
  'searchLocation': 'ابحث عن موقع…',

  // ── Coach ──
  'searchCoaches': 'ابحث عن مدربين...',
  'sortBy': 'ترتيب حسب',
  'noCoachesFound': 'لا يوجد مدربون',
  'failedToLoadCoaches': 'فشل تحميل بيانات المدربين',
  'coachProfile': 'ملف المدرب',
  'coachNotFound': 'المدرب غير موجود',
  'failedToLoadCoach': 'فشل تحميل بيانات المدرب',
  'about': 'عن المدرب',
  'noBioAvailable': 'لا توجد سيرة ذاتية.',
  'bookSession': 'احجز جلسة — SR ',
  'experience': 'الخبرة',
  'perSession': 'للجلسة',

  // ── Moments ──
  'latest': 'الأحدث',
  'popular': 'الأكثر شهرة',
  'noMomentsYet': 'لا توجد لحظات بعد',
  'shareYourFirstMoment': 'شارك لحظتك الأولى!',
  'createMoment': 'إنشاء لحظة',
  'failedToLoadMoments': 'فشل تحميل اللحظات',

  // ── Add Players ──
  'addPlayers': 'إضافة لاعبين',
  'added': 'تمت الإضافة',
  'add': '+ إضافة',
  'selected': 'المختارون',

  // ── Booking Card ──
  'friends': 'الأصدقاء',
  'coach': 'المدرب',

  // ── Weekday labels ──
  'mon': 'الإثنين',
  'tue': 'الثلاثاء',
  'wed': 'الأربعاء',
  'thu': 'الخميس',
  'fri': 'الجمعة',
  'sat': 'السبت',
  'sun': 'الأحد',
  'tomorrow': 'غداً',

  // ── Error messages ──
  'failed': 'فشل: ',
  'noInvitationData': 'لا توجد بيانات دعوة',

  // ── Month names ──
  'jan': 'يناير',
  'feb': 'فبراير',
  'mar': 'مارس',
  'apr': 'أبريل',
  'may': 'مايو',
  'jun': 'يونيو',
  'jul': 'يوليو',
  'aug': 'أغسطس',
  'sep': 'سبتمبر',
  'oct': 'أكتوبر',
  'nov': 'نوفمبر',
  'dec': 'ديسمبر',
};