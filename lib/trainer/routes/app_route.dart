import 'package:get/get.dart';

import '../announcement/screen/announcement_list.dart';
import '../auth/screen/club_list_screen.dart';
import '../auth/screen/login_screen.dart';
import '../auth/screen/otp_screen.dart';
import '../auth/screen/premium_screen.dart';
import '../auth/screen/reset_password_screen.dart';
import '../chat/screen/chat_list_screen.dart';
import '../chat/screen/chat_screen.dart';
import '../chat/screen/my_teams_screen.dart';
import '../chat/screen/profile_update_screen.dart';
import '../home/screen/club_profile_screen.dart';
import '../home/screen/main_screen.dart';
import '../home/screen/main_screen1.dart';
import '../home/screen/more_screen.dart';
import '../home/screen/notification_screen.dart';
import '../home/screen/schedule_screen.dart';
import '../home/screen/scheduler_screen.dart';
import '../home/screen/team_screen.dart';
import '../home/screen/top_class_screen.dart';
import '../profile/screen/faq_screen.dart';
import '../profile/screen/privacy_policy_screen.dart';
import '../profile/screen/terms_and_condition_screen.dart';
import '../welcome/screen/welcome_screen1.dart';
import '../welcome/screen/welcome_screen2.dart';
import '../welcome/screen/welcome_screen3.dart';
import 'route_name.dart';

class AppRoute {
  static final pages = [
    GetPage(name: RouteName.wellcome1, page: () => const WelcomeScreen()),
    GetPage(name: RouteName.wellcome2, page: () => const NameInputScreen()),
    GetPage(name: RouteName.selectClub, page: () => const ClubListScreen()),
    GetPage(name: RouteName.login, page: () => const LoginScreen()),
    GetPage(name: RouteName.announcements, page: () => const AnnouncementListScreen()
    ),
    GetPage(name: RouteName.forgotPassword, page: () => const ResetPasswordScreen()),
    GetPage(name: RouteName.otp, page: () => const OtpScreen()),
    GetPage(name: RouteName.premium, page: () => const PremiumUpgradeScreen()),
    GetPage(name: RouteName.notifications, page: () => const NotificationsScreen()), // duplicate removed
    GetPage(name: RouteName.onboarding, page: () => const RoleSelectionScreen()),
    GetPage(name: RouteName.main, page: () => const MainScreen()),
    GetPage(name: RouteName.main1, page: () => const MainScreen1()),
    GetPage(name: RouteName.myteam, page: () => const MyTeamsScreen()),
    GetPage(name: RouteName.schedule, page: () => const ScheduleScreen(activeTabIndex: 0)),
    GetPage(name: RouteName.team, page: () => const TeamScreen()),
    GetPage(name: RouteName.topClubs, page: () => const TopClubsScreen()),
    GetPage(name: RouteName.clubProfile, page: () => const ClubProfileScreen()),
    GetPage(name: RouteName.more, page: () => const MoreScreen()),
    GetPage(name: RouteName.chat, page: () => const ChatListScreen()),
    GetPage(name: RouteName.scheduler, page: () => const NewTrainingPlanScreen()),
    GetPage(name: RouteName.updateprofile, page: () => const ProfileUpdateScreen()),
    GetPage(name: RouteName.terms, page: () => const TermsScreen()),
    GetPage(name: RouteName.privacy, page: () => const PrivacyPolicyScreen()),
    GetPage(name: RouteName.faq, page: () => const FaqScreen()),
  ];
}
