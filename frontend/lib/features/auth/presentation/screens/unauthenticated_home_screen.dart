import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/presentation/widgets/app_logo.dart';
import 'package:reallystick/core/presentation/widgets/global_snack_bar.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_states.dart';
import 'package:reallystick/features/auth/presentation/widgets/background.dart';
import 'package:reallystick/features/auth/presentation/widgets/challenge_details_screen_screenshot.dart';
import 'package:reallystick/features/auth/presentation/widgets/challenges_screen_screenshot.dart';
import 'package:reallystick/features/auth/presentation/widgets/habit_details_screen_screenshot.dart';
import 'package:reallystick/features/auth/presentation/widgets/habits_screen_screenshot.dart';
import 'package:reallystick/features/auth/presentation/widgets/language_selector.dart';
import 'package:reallystick/features/auth/presentation/widgets/private_discussion_screenshot.dart';
import 'package:reallystick/features/auth/presentation/widgets/public_discussion_thread_screenshot.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class UnauthenticatedHomeScreen extends StatefulWidget {
  @override
  UnauthenticatedHomeScreenState createState() =>
      UnauthenticatedHomeScreenState();
}

class UnauthenticatedHomeScreenState extends State<UnauthenticatedHomeScreen>
    with SingleTickerProviderStateMixin {
  final _controller = PageController();
  final PageController _pageControllerHabits =
      PageController(initialPage: 0, viewportFraction: 0.7);
  final PageController _pageControllerChallenges =
      PageController(initialPage: 0, viewportFraction: 0.7);
  final PageController _pageControllerDiscussions =
      PageController(initialPage: 0, viewportFraction: 0.7);

  final List<String> habitImages = [
    'assets/images/mobile-habits.png',
    'assets/images/habit-detail.png',
    'assets/images/habit-detail-list.png',
  ];

  final List<String> challengeImages = [
    'assets/images/challenges.png',
    'assets/images/challenge-detail.png',
    'assets/images/challenge-daily-list.png',
  ];

  final List<String> discussionImages = [
    'assets/images/challenge-detail-with-discussion.png',
    'assets/images/public-discussion.png',
    'assets/images/private-discussion.png',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        GlobalSnackBar.show(context: context, message: state.message);
        if (state is AuthAuthenticatedState) {
          context.goNamed('home');
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Background(),
            PageView(
              controller: _controller,
              scrollDirection: Axis.vertical,
              children: [
                _buildUnauthenticatedHomeScreen(context),
                _buildScreenshotsScreen(
                  context,
                  [
                    HabitsScreenScreenshot(),
                    HabitDetailsScreenScreenshot(previewForChart: false),
                    HabitDetailsScreenScreenshot(previewForChart: true),
                  ],
                  "${AppLocalizations.of(context)!.createHabitsThatStick}\n🌱",
                  _pageControllerHabits,
                ),
                _buildScreenshotsScreen(
                  context,
                  [
                    ChallengesScreenScreenshot(),
                    ChallengeDetailsScreenScreenshot(
                      previewForDailyObjectives: false,
                      previewForDiscussion: false,
                    ),
                    ChallengeDetailsScreenScreenshot(
                      previewForDailyObjectives: true,
                      previewForDiscussion: false,
                    ),
                  ],
                  "${AppLocalizations.of(context)!.joinChallengeReachYourGoals}\n🚀",
                  _pageControllerChallenges,
                ),
                _buildScreenshotsScreen(
                  context,
                  [
                    ChallengeDetailsScreenScreenshot(
                      previewForDailyObjectives: false,
                      previewForDiscussion: true,
                    ),
                    PublicDiscussionThreadScreenshot(),
                    PrivateDiscussionScreenshot(),
                  ],
                  "${AppLocalizations.of(context)!.youAreNotAlone}\n🤝",
                  _pageControllerDiscussions,
                ),
                _buildFinalPage(_controller),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedHomeScreen(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Spacer(),
        Spacer(),
        AppLogo(size: 200),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Really',
              style: context.typographies.heading.copyWith(color: Colors.white),
            ),
            Text(
              'Stick',
              style: context.typographies.heading.copyWith(color: Colors.white),
            ),
          ],
        ),
        SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 50),
          child: Text(
            AppLocalizations.of(context)!.pleaseLoginOrSignUp,
            style: TextStyle(fontSize: 18, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            context.goNamed('login');
          },
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(context.colors.primary),
          ),
          child: Text(
            AppLocalizations.of(context)!.logIn,
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            context.goNamed('signup');
          },
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(context.colors.secondary),
          ),
          child: Text(
            AppLocalizations.of(context)!.signUp,
          ),
        ),
        Spacer(),
        Text(
          AppLocalizations.of(context)!.whatIsThis,
          style: TextStyle(color: Colors.white),
        ),
        InkWell(
          onTap: () {
            _controller.animateToPage(
              1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.keyboard_arrow_down,
                size: 40,
                color: Colors.white,
              ),
              Transform.translate(
                offset: Offset(0, -30),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 35,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildScreenshotsScreen(
    BuildContext context,
    List<Widget> screens,
    String title,
    PageController pageController,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Spacer(),
        Spacer(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            title,
            style: context.typographies.heading.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Spacer(),
        SizedBox(
          height: screenHeight * 0.55,
          child: PageView(
            controller: _pageControllerHabits,
            children: screens,
          ),
        ),
        const SizedBox(height: 16),
        SmoothPageIndicator(
          controller: _pageControllerHabits,
          count: 3,
          effect: ExpandingDotsEffect(
            activeDotColor: Colors.white,
            dotColor: Colors.grey,
            dotHeight: 8,
            dotWidth: 8,
            spacing: 8,
          ),
        ),
        Spacer(),
        InkWell(
          onTap: () {
            _controller.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.keyboard_arrow_down,
                size: 40,
                color: Colors.white,
              ),
              Transform.translate(
                offset: Offset(0, -30),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 35,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildFinalPage(PageController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          const SizedBox(height: 40),
          AppLogo(size: 100),
          const SizedBox(height: 40),
          Text(
            "· ${AppLocalizations.of(context)!.noEmailOfIdentifiableDataRequired}\n\n"
            "· ${AppLocalizations.of(context)!.personalizedNotificationsToStayOnTrack}\n\n"
            "· ${AppLocalizations.of(context)!.endToEndEncryptedPrivateMessages}\n\n"
            "· ${AppLocalizations.of(context)!.availableOnIosAndroidWebIn}",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          const SizedBox(height: 20),
          LanguageSelector(),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              controller.animateToPage(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(AppLocalizations.of(context)!.jumpOnTop),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TextButton(
                  onPressed: () => context.goNamed('privacy-policy'),
                  child: Text(
                    AppLocalizations.of(context)!.privacyPolicy,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
              Flexible(
                child: TextButton(
                  onPressed: () => context.goNamed('terms-of-use'),
                  child: Text(
                    AppLocalizations.of(context)!.termsOfUse,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Text(
            AppLocalizations.of(context)!.copyright,
            style: TextStyle(fontSize: 13, color: Colors.white),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
