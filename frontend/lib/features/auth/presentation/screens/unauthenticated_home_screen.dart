import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/constants/screen_size.dart';
import 'package:reallystick/core/presentation/widgets/app_logo.dart';
import 'package:reallystick/core/presentation/widgets/global_snack_bar.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_states.dart';
import 'package:reallystick/features/auth/presentation/widgets/background.dart';
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
      PageController(initialPage: 0, viewportFraction: 0.6);
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
                  habitImages,
                  "${AppLocalizations.of(context)!.createHabitsThatStick}\n🌱",
                  _pageControllerHabits,
                ),
                _buildScreenshotsScreen(
                  context,
                  challengeImages,
                  "${AppLocalizations.of(context)!.joinChallengeReachYourGoals}\n🚀",
                  _pageControllerChallenges,
                ),
                _buildScreenshotsScreen(
                  context,
                  discussionImages,
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
        AppLogo(size: 200),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Really',
              style: context.typographies.heading.copyWith(
                color: context.colors.background,
              ),
            ),
            Text(
              'Stick',
              style: context.typographies.heading.copyWith(
                color: context.colors.background,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.pleaseLoginOrSignUp,
          style: TextStyle(
            fontSize: 18,
            color: context.colors.background,
          ),
          textAlign: TextAlign.center,
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
          style: context.typographies.bodySmall.copyWith(
            color: context.colors.background,
          ),
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
                color: context.colors.background,
              ),
              Transform.translate(
                offset: Offset(0, -30),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 35,
                  color: context.colors.background,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildScreenshotContainer(String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black, width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imageUrl,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScreenshotsScreen(
    BuildContext context,
    List<String> images,
    String title,
    PageController pageController,
  ) {
    final bool isLargeScreen = checkIfLargeScreen(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Spacer(),
        Spacer(),
        Text(
          title,
          style: context.typographies.heading.copyWith(
            color: context.colors.background,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        if (isLargeScreen) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images
                  .map(
                    (img) => SizedBox(
                      height: 575,
                      child: _buildScreenshotContainer(img),
                    ),
                  )
                  .toList(),
            ),
          ),
        ] else ...[
          SizedBox(
            height: 500,
            width: 800,
            child: PageView(
              controller: pageController,
              children:
                  images.map((img) => _buildScreenshotContainer(img)).toList(),
            ),
          ),
          const SizedBox(height: 16),
          SmoothPageIndicator(
            controller: pageController,
            count: images.length,
            effect: ExpandingDotsEffect(
              activeDotColor: Colors.white,
              dotColor: Colors.grey,
              dotHeight: 8,
              dotWidth: 8,
              spacing: 8,
            ),
          ),
        ],
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
                color: context.colors.background,
              ),
              Transform.translate(
                offset: Offset(0, -30),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 35,
                  color: context.colors.background,
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
          AppLogo(size: 200),
          Text(
            "✅ ${AppLocalizations.of(context)!.noEmailOfIdentifiableDataRequired}\n\n"
            "✅ ${AppLocalizations.of(context)!.personalizedNotificationsToStayOnTrack}\n\n"
            "✅ ${AppLocalizations.of(context)!.endToEndEncryptedPrivateMessages}\n\n"
            "✅ ${AppLocalizations.of(context)!.availableOnIosAndroidWebIn}",
            textAlign: TextAlign.center,
            style: TextStyle(color: context.colors.background, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Text(
            "🇬🇧 🇫🇷 🇪🇸 🇵🇹 🇮🇹 🇩🇪 🇷🇺",
            style: TextStyle(fontSize: 30),
          ),
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
        ],
      ),
    );
  }
}
