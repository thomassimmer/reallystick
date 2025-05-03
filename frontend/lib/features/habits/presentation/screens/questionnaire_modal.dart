import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/presentation/widgets/global_snack_bar.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/profile/domain/entities/profile.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_events.dart';
import 'package:reallystick/features/profile/presentation/widgets/activity_selection_widget.dart';
import 'package:reallystick/features/profile/presentation/widgets/age_selection_widget.dart';
import 'package:reallystick/features/profile/presentation/widgets/financial_situation_selection_widget.dart';
import 'package:reallystick/features/profile/presentation/widgets/gender_selection_widget.dart';
import 'package:reallystick/features/profile/presentation/widgets/has_children_selection_widget.dart';
import 'package:reallystick/features/profile/presentation/widgets/level_of_education_selection_widget.dart';
import 'package:reallystick/features/profile/presentation/widgets/living_in_urban_area_selection_widget.dart';
import 'package:reallystick/features/profile/presentation/widgets/location_selection_widget.dart';
import 'package:reallystick/features/profile/presentation/widgets/relation_status_selection_widget.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class QuestionnaireModal extends StatefulWidget {
  final ScrollController scrollController;
  final Profile profile;

  const QuestionnaireModal(
      {super.key, required this.scrollController, required this.profile});

  @override
  QuestionnaireModalState createState() => QuestionnaireModalState();
}

class QuestionnaireModalState extends State<QuestionnaireModal> {
  int _currentStep = 0;

  void _skip() {
    Navigator.of(context).pop();
  }

  void updateProfile(BuildContext context, Profile profile) {
    BlocProvider.of<ProfileBloc>(context).add(
        ProfileUpdateEvent(newProfile: profile, displayNotification: false));
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    final List<String> questions = [
      "",
      AppLocalizations.of(context)!.questionAge,
      AppLocalizations.of(context)!.questionGender,
      AppLocalizations.of(context)!.questionLocation,
      AppLocalizations.of(context)!.questionLivingInUrbanArea,
      AppLocalizations.of(context)!.questionActivity,
      AppLocalizations.of(context)!.questionLevelOfEducation,
      AppLocalizations.of(context)!.questionFinancialSituation,
      AppLocalizations.of(context)!.questionRelationStatus,
      AppLocalizations.of(context)!.questionHasChildren,
    ];

    final List<IconData?> icons = [
      null,
      Icons.cake,
      Icons.wc,
      Icons.public,
      Icons.location_city,
      Icons.work,
      Icons.school,
      Icons.account_balance_wallet,
      Icons.favorite,
      Icons.escalator_warning
    ];

    final List<Widget> widgets = [
      _buildIntroductionWidget(context),
      AgeSelectionWidget(profile: profile, updateProfile: updateProfile),
      GenderSelectionWidget(
        profile: profile,
        updateProfile: updateProfile,
      ),
      LocationSelectionWidget(profile: profile, updateProfile: updateProfile),
      LivingInUrbanAreaSelectionWidget(
          profile: profile, updateProfile: updateProfile),
      ActivitySelectionWidget(profile: profile, updateProfile: updateProfile),
      LevelOfEducationSelectionWidget(
          profile: profile, updateProfile: updateProfile),
      FinancialSituationSelectionWidget(
          profile: profile, updateProfile: updateProfile),
      RelationStatusSelectionWidget(
          profile: profile, updateProfile: updateProfile),
      HasChildrenSelectionWidget(
          profile: profile, updateProfile: updateProfile),
    ];

    void nextStep() {
      setState(() {
        if (_currentStep < questions.length - 1) {
          _currentStep++;
        } else {
          Navigator.of(context).pop();

          GlobalSnackBar.show(
              context: context, message: SuccessMessage('questionsAnswered'));
        }
      });
    }

    void previousStep() {
      setState(() {
        if (_currentStep > 0) {
          _currentStep--;
        }
      });
    }

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(icons[_currentStep]),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  questions[_currentStep],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: widgets[_currentStep],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: nextStep,
                  style: context.styles.buttonMedium,
                  child: Text(AppLocalizations.of(context)!.next),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: previousStep,
                      child: Text(AppLocalizations.of(context)!.previous),
                    ),
                  TextButton(
                    onPressed: _skip,
                    child: Text(AppLocalizations.of(context)!.skip),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroductionWidget(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.welcome,
          style: context.typographies.heading,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        Text(
          AppLocalizations.of(context)!.introductionToQuestions,
          style:
              context.typographies.body.copyWith(fontWeight: FontWeight.w400),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
