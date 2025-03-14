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

class UnauthenticatedHomeScreen extends StatefulWidget {
  @override
  UnauthenticatedHomeScreenState createState() =>
      UnauthenticatedHomeScreenState();
}

class UnauthenticatedHomeScreenState extends State<UnauthenticatedHomeScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  double _scrollPosition = 0;
  double screenHeight = 0;
  double maxScrollExtent = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _scrollPosition = _scrollController.position.pixels;
        maxScrollExtent = _scrollController.position.maxScrollExtent;
      });
    });

    // Setup animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800), // Change opacity every 0.8 sec
    )..repeat(reverse: true); // Makes the animation loop

    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollTo(double position) {
    _scrollController.animateTo(
      position,
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  void _scrollBy(double offset) {
    _scrollController.animateTo(
      _scrollPosition + offset,
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;

    bool isAtTop = _scrollPosition == 0 || _scrollPosition == screenHeight;
    bool isAtBottom = _scrollPosition == maxScrollExtent;

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
            NotificationListener<ScrollUpdateNotification>(
              onNotification: (notification) {
                setState(() {
                  _scrollPosition = _scrollController.position.pixels;
                });
                return true;
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    _buildFullScreenSection(
                      context,
                      _buildUnauthenticatedHomeScreen(context),
                      0.0,
                    ),
                    _buildFullScreenSection(
                      context,
                      _buildPresentationScreen(
                          "Become the best version of yourself."),
                      screenHeight,
                    ),
                    _buildFullScreenSection(
                      context,
                      _buildPresentationScreen("Try the beta version now."),
                      screenHeight * 2,
                    ),
                  ],
                ),
              ),
            ),

            if (isAtTop)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _opacityAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: isAtTop ? _opacityAnimation.value : 0.0,
                      child: child,
                    );
                  },
                  child: InkWell(
                    onTap: () => _scrollBy(screenHeight),
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
                  ),
                ),
              ),

            // Upward arrows (when at the bottom)
            if (isAtBottom)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _opacityAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: isAtBottom ? _opacityAnimation.value : 0.0,
                      child: child,
                    );
                  },
                  child: InkWell(
                    onTap: () => _scrollTo(0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.keyboard_arrow_up,
                          size: 35,
                          color: context.colors.background,
                        ),
                        Transform.translate(
                          offset: Offset(0, -30),
                          child: Icon(
                            Icons.keyboard_arrow_up,
                            size: 40,
                            color: context.colors.background,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullScreenSection(
      BuildContext context, Widget child, double scrollThreshold) {
    return AnimatedOpacity(
      opacity: _scrollPosition >= scrollThreshold * 0.5 &&
              _scrollPosition < (scrollThreshold + screenHeight)
          ? 1.0
          : 0.0,
      duration: Duration(milliseconds: 500),
      child: Container(
        height: screenHeight,
        width: double.infinity,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _buildUnauthenticatedHomeScreen(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
          child: Text(AppLocalizations.of(context)!.logIn),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            context.goNamed('signup');
          },
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(context.colors.secondary),
          ),
          child: Text(AppLocalizations.of(context)!.signUp),
        ),
      ],
    );
  }

  Widget _buildPresentationScreen(String title) {
    return Center(
      child: Text(
        title,
        style: context.typographies.heading.copyWith(
          color: context.colors.background,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
