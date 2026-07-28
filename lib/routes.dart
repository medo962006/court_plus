import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/language_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/login_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/profile_setup_screen.dart';
import '../screens/home_screen.dart';
import '../screens/courts_screen.dart';
import '../screens/court_details_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/reviews_screen.dart';
import '../screens/booking_step1_screen.dart';
import '../screens/booking_step2_screen.dart';
import '../screens/booking_step3_screen.dart';
import '../screens/booking_step4_screen.dart';
import '../screens/payment_gateway_screen.dart';
import '../screens/booking_success_screen.dart';
import '../screens/start_match_screen.dart';
import '../screens/add_players_screen.dart';
import '../screens/open_matches_screen.dart';
import '../screens/match_filter_screen.dart';
import '../screens/receive_invitation_screen.dart';
import '../screens/invitation_details_screen.dart';
import '../screens/activity_screen.dart';
import '../screens/add_review_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/search_results_screen.dart';
import '../screens/recent_search_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/update_profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/activity_log_screen.dart';
import '../screens/booking_ticket_screen.dart';

class Routes {
  static const splash = '/';
  static const language = '/language';
  static const onboarding = '/onboarding';
  static const signup = '/signup';
  static const login = '/login';
  static const otp = '/otp';
  static const profileSetup = '/profile-setup';
  static const home = '/home';
  static const courts = '/courts';
  static const courtDetails = '/court-details';
  static const notifications = '/notifications';
  static const reviews = '/reviews';
  static const bookingStep1 = '/booking-step1';
  static const bookingStep2 = '/booking-step2';
  static const bookingStep3 = '/booking-step3';
  static const bookingStep4 = '/booking-step4';
  static const paymentGateway = '/payment';
  static const bookingSuccess = '/booking-success';
  static const startMatch = '/start-match';
  static const addPlayers = '/add-players';
  static const openMatches = '/open-matches';
  static const matchFilter = '/match-filter';
  static const receiveInvitation = '/receive-invitation';
  static const invitationDetails = '/invitation-details';
  static const activity = '/activity';
  static const addReview = '/add-review';
  static const explore = '/explore';
  static const searchResults = '/search-results';
  static const recentSearch = '/recent-search';
  static const profile = '/profile';
  static const updateProfile = '/update-profile';
  static const settings = '/settings';
  static const activityLog = '/activity-log';
  static const bookingTicket = '/booking-ticket';

  static Map<String, WidgetBuilder> get map => {
        splash: (_) => const SplashScreen(),
        language: (_) => const LanguageScreen(),
        onboarding: (_) => const OnboardingScreen(),
        signup: (_) => const SignUpScreen(),
        login: (_) => const LoginScreen(),
        otp: (_) => const OtpScreen(),
        profileSetup: (_) => const ProfileSetupScreen(),
        home: (_) => const HomeScreen(),
        courts: (_) => const CourtsScreen(),
        courtDetails: (_) => const CourtDetailsScreen(),
        notifications: (_) => const NotificationsScreen(),
        reviews: (_) => const ReviewsScreen(),
        bookingStep1: (_) => const BookingStep1Screen(),
        bookingStep2: (_) => const BookingStep2Screen(),
        bookingStep3: (_) => const BookingStep3Screen(),
        bookingStep4: (_) => const BookingStep4Screen(),
        paymentGateway: (_) => const PaymentGatewayScreen(),
        bookingSuccess: (_) => const BookingSuccessScreen(),
        startMatch: (_) => const StartMatchScreen(),
        addPlayers: (_) => const AddPlayersScreen(),
        openMatches: (_) => const OpenMatchesScreen(),
        matchFilter: (_) => const MatchFilterScreen(),
        receiveInvitation: (_) => const ReceiveInvitationScreen(),
        invitationDetails: (_) => const InvitationDetailsScreen(),
        activity: (_) => const ActivityScreen(),
        addReview: (_) => const AddReviewScreen(),
        explore: (_) => const ExploreScreen(),
        searchResults: (_) => const SearchResultsScreen(),
        recentSearch: (_) => const RecentSearchScreen(),
        profile: (_) => const ProfileScreen(),
        updateProfile: (_) => const UpdateProfileScreen(),
        settings: (_) => const SettingsScreen(),
        activityLog: (_) => const ActivityLogScreen(),
        bookingTicket: (_) => const BookingTicketScreen(),
      };

  /// Smooth cross-fade transition used from splash.
  static Route<T> fade<T>(Widget page) => PageRouteBuilder<T>(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, a1, a2) => page,
        transitionsBuilder: (context, animation, a2, child) =>
            FadeTransition(opacity: animation, child: child),
      );
}