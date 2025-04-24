import 'dart:collection';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_participation.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_statistic.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';
import 'package:reallystick/features/habits/domain/entities/habit.dart';
import 'package:reallystick/features/habits/domain/entities/habit_category.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/domain/entities/habit_participation.dart';
import 'package:reallystick/features/habits/domain/entities/habit_statistic.dart';
import 'package:reallystick/features/habits/domain/entities/unit.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/notifications/presentation/blocs/notifications/notifications_states.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_discussion.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_message.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_states.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message/private_message_states.dart';
import 'package:reallystick/features/profile/domain/entities/profile.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_states.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/thread/thread_states.dart';
import 'package:reallystick/features/users/domain/entities/user_public_data.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_states.dart';

ProfileAuthenticated getProfileAuthenticatedForPreview(BuildContext context) {
  final profileState = context.watch<ProfileBloc>().state;

  String locale = profileState is ProfileAuthenticated
      ? profileState.profile.locale
      : profileState is ProfileUnauthenticated
          ? profileState.locale ?? "en"
          : "en";

  return ProfileAuthenticated(
    profile: Profile(
        id: "1",
        username: "username",
        locale: locale,
        theme: "dark",
        timezone: "paris",
        otpBase32: "otpBase32",
        otpAuthUrl: "otpAuthUrl",
        otpVerified: true,
        passwordIsExpired: false,
        isAdmin: false,
        hasSeenQuestions: true,
        publicKey: "publicKey",
        privateKeyEncrypted: "privateKeyEncrypted",
        saltUsedToDerivateKeyFromPassword: "",
        notificationsEnabled: true,
        notificationsForPrivateMessagesEnabled: true,
        notificationsForPublicMessageLikedEnabled: true,
        notificationsForPublicMessageRepliesEnabled: true,
        notificationsUserJoinedYourChallengeEnabled: true,
        notificationsUserDuplicatedYourChallengeEnabled: true),
    devices: [],
    statistics: null,
    shouldReloadData: false,
  );
}

HabitsLoaded getHabitsLoadedForPreview(BuildContext context) {
  final profileState = context.watch<ProfileBloc>().state;

  String locale = profileState is ProfileAuthenticated
      ? profileState.profile.locale
      : profileState is ProfileUnauthenticated
          ? profileState.locale ?? "en"
          : "en";

  final random1 = Random(1);
  final random2 = Random(2);
  final random3 = Random(3);

  return HabitsLoaded(
    habitParticipations: [
      HabitParticipation(
        id: '1',
        userId: '1',
        habitId: '1',
        color: 'red',
        toGain: true,
        notificationsReminderEnabled: false,
        reminderTime: null,
        reminderBody: null,
      ),
      HabitParticipation(
        id: '1',
        userId: '1',
        habitId: '2',
        color: 'lightGreen',
        toGain: true,
        notificationsReminderEnabled: false,
        reminderTime: null,
        reminderBody: null,
      ),
      HabitParticipation(
        id: '1',
        userId: '1',
        habitId: '3',
        color: 'lightBlue',
        toGain: true,
        notificationsReminderEnabled: false,
        reminderTime: null,
        reminderBody: null,
      ),
    ],
    habits: {
      '1': Habit(
        id: '1',
        name: locale == 'en'
            ? {
                "de": "Französisch",
                "en": "French",
                "es": "Francés",
                "fr": "Français",
                "it": "Francese",
                "pt": "Francês",
                "ru": "Французский"
              }
            : {
                "de": "Englisch",
                "en": "English",
                "es": "Inglés",
                "fr": "Anglais",
                "it": "Inglese",
                "pt": "Inglês",
                "ru": "Английский"
              },
        categoryId: '1',
        reviewed: true,
        description: locale == 'en'
            ? {
                "de":
                    "Verfolge dein tägliches Französischlernen, um stetige Fortschritte zu machen und motiviert zu bleiben.",
                "en":
                    "Track your French learning every day to make steady progress and stay motivated.",
                "es":
                    "Controla tu aprendizaje de francés cada día para avanzar con constancia y mantenerte motivado.",
                "fr":
                    "Suivez votre apprentissage du français chaque jour pour progresser régulièrement et rester motivé(e).",
                "it":
                    "Tieni traccia del tuo apprendimento del francese ogni giorno per fare progressi costanti e restare motivato.",
                "pt":
                    "Acompanhe seu aprendizado de francês todos os dias para progredir com consistência e manter-se motivado.",
                "ru":
                    "Отслеживайте изучение французского каждый день, чтобы стабильно продвигаться и сохранять мотивацию."
              }
            : {
                "de":
                    "Verfolge dein tägliches Englischlernen, um stetige Fortschritte zu machen und motiviert zu bleiben.",
                "en":
                    "Track your English learning every day to make steady progress and stay motivated.",
                "es":
                    "Controla tu aprendizaje de inglés cada día para avanzar con constancia y mantenerte motivado.",
                "fr":
                    "Suivez votre apprentissage de l’anglais chaque jour pour progresser régulièrement et rester motivé(e).",
                "it":
                    "Tieni traccia del tuo apprendimento dell’inglese ogni giorno per fare progressi costanti e restare motivato.",
                "pt":
                    "Acompanhe seu aprendizado de inglês todos os dias para progredir com consistência e manter-se motivado.",
                "ru":
                    "Отслеживайте изучение английского каждый день, чтобы стабильно продвигаться и сохранять мотивацию."
              },
        icon: locale == 'en' ? "🇫🇷" : "🇬🇧",
        unitIds: HashSet.from(['1']),
      ),
      '2': Habit(
        id: '2',
        name: {
          "en": "Squats",
          "fr": "Squats",
          "es": "Sentadillas",
          "it": "Squat",
          "pt": "Agachamentos",
          "de": "Kniebeugen",
          "ru": "Приседания"
        },
        categoryId: '2',
        reviewed: true,
        description: {
          "en":
              "Track your efforts in squats daily to improve strength, endurance, and technique.",
          "fr":
              "Suivez vos efforts en squats chaque jour pour améliorer votre force, endurance et technique.",
          "es":
              "Sigue tus esfuerzos en sentadillas diariamente para mejorar fuerza, resistencia y técnica.",
          "it":
              "Monitora i tuoi progressi nei squat ogni giorno per migliorare forza, resistenza e tecnica.",
          "pt":
              "Acompanhe seus esforços em agachamentos diariamente para melhorar força, resistência e técnica.",
          "de":
              "Verfolge deine Bemühungen bei Kniebeugen täglich, um Kraft, Ausdauer und Technik zu verbessern.",
          "ru":
              "Отслеживай свои усилия в приседаниях ежедневно, чтобы улучшать силу, выносливость и технику."
        },
        icon: "🏋️‍♀️",
        unitIds: HashSet.from(['1']),
      ),
      '3': Habit(
        id: '3',
        name: {
          "de": "Hydration",
          "en": "Hydration",
          "es": "Hidratación",
          "fr": "Hydratation",
          "it": "Idratazione",
          "pt": "Hidratação",
          "ru": "Гидратация"
        },
        categoryId: '3',
        reviewed: true,
        description: {
          "de":
              "Verfolge deine tägliche Wasseraufnahme, um hydratisiert zu bleiben und deine Gesundheit zu verbessern.",
          "en":
              "Track your water intake every day to stay hydrated and improve your health.",
          "es":
              "Controla tu ingesta de agua cada día para mantenerte hidratado y mejorar tu salud.",
          "fr":
              "Suivez votre consommation d’eau chaque jour pour rester hydraté(e) et améliorer votre santé.",
          "it":
              "Tieni traccia della tua assunzione di acqua ogni giorno per rimanere idratato e migliorare la tua salute.",
          "pt":
              "Acompanhe a ingestão de água todos os dias para manter-se hidratado e melhorar sua saúde.",
          "ru":
              "Отслеживайте потребление воды каждый день, чтобы поддерживать уровень гидратации и улучшать здоровье."
        },
        icon: "💦",
        unitIds: HashSet.from(['1']),
      ),
    },
    habitDailyTrackings: [
      ...List.generate(14, (index) {
        final date = DateTime.now().subtract(Duration(days: index, hours: 2));
        final duration = random1.nextInt(5) * 5;

        return HabitDailyTracking(
          id: '${index + 1}',
          userId: '1',
          habitId: '1',
          datetime:
              DateTime(date.year, date.month, date.day, date.hour, date.minute),
          quantityPerSet: duration,
          quantityOfSet: 1,
          unitId: '2',
          weight: 0,
          weightUnitId: '1',
        );
      }),
      ...List.generate(2, (index) {
        final date = DateTime.now().subtract(Duration(days: 1));

        final duration = random1.nextInt(10) * 5;

        return HabitDailyTracking(
          id: '${index + 1}',
          userId: '1',
          habitId: '1',
          datetime:
              DateTime(date.year, date.month, date.day, 8 + index * 13, 30),
          quantityPerSet: duration,
          quantityOfSet: 1,
          unitId: '2',
          weight: 0,
          weightUnitId: '1',
        );
      }),
      ...List.generate(14, (index) {
        final date = DateTime.now().subtract(Duration(days: index, hours: 2));
        final duration = random2.nextInt(21);

        return HabitDailyTracking(
          id: '${index + 1}',
          userId: '1',
          habitId: '2',
          datetime:
              DateTime(date.year, date.month, date.day, date.hour, date.minute),
          quantityPerSet: duration,
          quantityOfSet: 1,
          unitId: '2',
          weight: 0,
          weightUnitId: '1',
        );
      }),
      ...List.generate(14, (index) {
        final date = DateTime.now().subtract(Duration(days: index, hours: 2));
        final duration = random3.nextInt(21);

        return HabitDailyTracking(
          id: '${index + 1}',
          userId: '1',
          habitId: '3',
          datetime:
              DateTime(date.year, date.month, date.day, date.hour, date.minute),
          quantityPerSet: duration,
          quantityOfSet: 1,
          unitId: '2',
          weight: 0,
          weightUnitId: '1',
        );
      })
    ],
    habitCategories: {
      '1': HabitCategory(
        id: '1',
        name: {
          "en": "Learning languages",
          "fr": "Apprentissage des langues",
          "ru": "Изучение языков",
          "it": "Apprendimento lingue",
          "es": "Aprender idiomas",
          "de": "Sprachen lernen",
          "pt": "Aprender línguas"
        },
        icon: '🗣️',
      ),
      '2': HabitCategory(
        id: '2',
        name: {
          "en": "Sport",
          "fr": "Sport",
          "ru": "Спорт",
          "it": "Sport",
          "es": "Deporte",
          "de": "Sport",
          "pt": "Esporte"
        },
        icon: '🏋️‍♀️',
      ),
      '3': HabitCategory(
        id: '3',
        name: {
          "en": "Health",
          "fr": "Santé",
          "ru": "Здоровье",
          "it": "Salute",
          "es": "Salud",
          "de": "Gesundheit",
          "pt": "Saúde"
        },
        icon: '🏥',
      ),
    },
    units: {
      '1': Unit(
        id: '1',
        shortName: {
          "en": "s",
          "fr": "s",
          "ru": "с",
          "it": "s",
          "es": "s",
          "de": "s",
          "pt": "s"
        },
        longName: {
          "en": {"one": "second", "other": "seconds"},
          "fr": {"one": "seconde", "other": "secondes"},
          "ru": {"one": "секунда", "other": "секунды"},
          "it": {"one": "secondo", "other": "secondi"},
          "es": {"one": "segundo", "other": "segundos"},
          "de": {"one": "Sekunde", "other": "Sekunden"},
          "pt": {"one": "segundo", "other": "segundos"}
        },
      ),
      '2': Unit(
        id: '2',
        shortName: {
          "en": "min",
          "fr": "min",
          "ru": "мин",
          "it": "min",
          "es": "min",
          "de": "min",
          "pt": "min"
        },
        longName: {
          "en": {"one": "minute", "other": "minutes"},
          "fr": {"one": "minute", "other": "minutes"},
          "ru": {"one": "минута", "other": "минуты"},
          "it": {"one": "minuto", "other": "minuti"},
          "es": {"one": "minuto", "other": "minutos"},
          "de": {"one": "Minute", "other": "Minuten"},
          "pt": {"one": "minuto", "other": "minutos"}
        },
      ),
      '3': Unit(
        id: '3',
        shortName: {
          "en": "h",
          "fr": "h",
          "ru": "ч",
          "it": "h",
          "es": "h",
          "de": "h",
          "pt": "h"
        },
        longName: {
          "en": {"one": "hour", "other": "hours"},
          "fr": {"one": "heure", "other": "heures"},
          "ru": {"one": "час", "other": "часа"},
          "it": {"one": "ora", "other": "ore"},
          "es": {"one": "hora", "other": "horas"},
          "de": {"one": "Stunde", "other": "Stunden"},
          "pt": {"one": "hora", "other": "horas"}
        },
      )
    },
    habitStatistics: {
      '1': HabitStatistic(
        habitId: '1',
        participantsCount: 2302,
        topAges: {
          MapEntry('25-30', 1020),
          MapEntry('30-35', 451),
          MapEntry('35-40', 179),
        },
        topCountries: {
          MapEntry("France", 753),
          MapEntry("England", 632),
          MapEntry("Germany", 540),
        },
        topRegions: {
          MapEntry("Europe", 1253),
          MapEntry("Oceania", 503),
          MapEntry("Americas", 159),
        },
        topHasChildren: {
          MapEntry("Yes", 1853),
          MapEntry("No", 105),
        },
        topLivesInUrbanArea: {
          MapEntry("Yes", 1053),
          MapEntry("No", 1004),
        },
        topGender: {
          MapEntry("female", 1303),
          MapEntry("male", 953),
        },
        topActivities: {
          MapEntry("student", 623),
          MapEntry("unemployed", 403),
          MapEntry("worker", 303),
        },
        topFinancialSituations: {
          MapEntry("average", 803),
          MapEntry("wealthy", 603),
          MapEntry("poor", 303),
        },
        topRelationshipStatuses: {
          MapEntry("single", 1723),
          MapEntry("couple", 402),
        },
        topLevelsOfEducation: {
          MapEntry("highSchoolOrLess", 1203),
          MapEntry("highSchoolPlusOneOrTwoYears", 803),
          MapEntry("highSchoolPlusThreeOrFourYears", 403),
          MapEntry("highSchoolPlusFiveOrMoreYears", 103),
        },
        challenges: ['1', '2'],
      ),
    },
  );
}

NotificationState getNotificationStateForPreview(BuildContext context) {
  return NotificationState(
    notifications: [],
    notification: null,
    notificationScreenIsVisible: false,
    isConnected: true,
  );
}

ChallengesLoaded getChallengeStateForPreview(BuildContext context) {
  final profileState = context.watch<ProfileBloc>().state;

  String locale = profileState is ProfileAuthenticated
      ? profileState.profile.locale
      : profileState is ProfileUnauthenticated
          ? profileState.locale ?? "en"
          : "en";

  final Map<String, String> pronunciationInstructions = {
    'en':
        "-Study the French alphabet and practice spelling your name.\n\n-Watch [this video](https://youtu.be/4PvBkp-4bmc?si=DYnxRu0C18Saoy2F) on French pronunciation basics.",
    'fr':
        "-Étudiez l'alphabet anglais et entraînez-vous à épeler votre nom.\n\n-Regardez [cette vidéo](https://youtu.be/4PvBkp-4bmc?si=DYnxRu0C18Saoy2F) sur les bases de la prononciation en anglais.",
    'de':
        "-Lernen Sie das englische Alphabet und üben Sie, Ihren Namen zu buchstabieren.\n\n-Sehen Sie sich [dieses Video](https://youtu.be/4PvBkp-4bmc?si=DYnxRu0C18Saoy2F) zu den Grundlagen der englischen Aussprache an.",
    'it':
        "-Studia l'alfabeto inglese e esercitati a fare lo spelling del tuo nome.\n\n-Guarda [questo video](https://youtu.be/4PvBkp-4bmc?si=DYnxRu0C18Saoy2F) sulle basi della pronuncia inglese.",
    'es':
        "-Estudia el alfabeto inglés y practica deletrear tu nombre.\n\n-Mira [este video](https://youtu.be/4PvBkp-4bmc?si=DYnxRu0C18Saoy2F) sobre los fundamentos de la pronunciación en inglés.",
    'pt':
        "-Estude o alfabeto inglês e pratique soletrar seu nome.\n\n-Assista a [este vídeo](https://youtu.be/4PvBkp-4bmc?si=DYnxRu0C18Saoy2F) sobre os fundamentos da pronúncia em inglês.",
    'ru':
        "-Изучите английский алфавит и потренируйтесь произносить своё имя по буквам.\n\n-Посмотрите [это видео](https://youtu.be/4PvBkp-4bmc?si=DYnxRu0C18Saoy2F) об основах английского произношения.",
  };

  return ChallengesLoaded(
    challengeParticipations: [
      ChallengeParticipation(
        id: '1',
        userId: '1',
        challengeId: '1',
        color: 'red',
        startDate: DateTime.now().subtract(Duration(days: 2)),
        notificationsReminderEnabled: false,
        reminderTime: null,
        reminderBody: null,
        finished: false,
      ),
      ChallengeParticipation(
        id: '2',
        userId: '1',
        challengeId: '3',
        color: 'lightGreen',
        startDate: DateTime.now().subtract(Duration(days: 200)),
        notificationsReminderEnabled: false,
        reminderTime: null,
        reminderBody: null,
        finished: true,
      )
    ],
    challenges: {
      '1': Challenge(
        id: '1',
        creator: '2',
        name: {
          "en": "French in 60: From Bonjour to Baguette",
          "fr": "60 jours d'anglais pour débutants",
          "de": "60 Tage Englisch für Anfänger",
          "it": "60 giorni di inglese per principianti",
          "es": "60 días de inglés para principiantes",
          "pt": "60 dias de inglês para iniciantes",
          "ru": "60 дней английского для начинающих",
        },
        description: {
          "en":
              "Go from beginner (A1) to intermediate (B1) in 60 days by practicing French daily for a set amount of time.",
          "fr":
              "Passez du niveau débutant (A1) au niveau intermédiaire (B1) en 60 jours en pratiquant l'anglais chaque jour pendant un temps défini.",
          "de":
              "Lerne in 60 Tagen von Anfänger (A1) bis Mittelstufe (B1), indem du täglich Englisch für eine bestimmte Zeit übst.",
          "it":
              "Passa da principiante (A1) a intermedio (B1) in 60 giorni praticando l'inglese ogni giorno per un tempo prestabilito.",
          "es":
              "Pasa de principiante (A1) a intermedio (B1) en 60 días practicando inglés todos los días durante un tiempo determinado.",
          "pt":
              "Passe de iniciante (A1) para intermediário (B1) em 60 dias praticando inglês diariamente por um tempo determinado.",
          "ru":
              "Пройди путь от новичка (A1) до среднего уровня (B1) за 60 дней, ежедневно практикуя английский в течение определённого времени.",
        },
        icon: locale == 'en' ? '🇫🇷' : '🇬🇧',
        startDate: null,
        deleted: false,
      ),
      '2': Challenge(
        id: '2',
        creator: '2',
        name: {
          "en": "French in 90 Days for Intermediate Learners",
          "fr": "90 jours d'anglais : niveau intermédiaire",
          "de": "90 Tage Englisch für fortgeschrittene Anfänger",
          "it": "90 giorni di inglese per studenti intermedi",
          "es": "90 días de inglés para estudiantes intermedios",
          "pt": "90 dias de inglês para alunos intermediários",
          "ru": "90 дней английского для учащихся со средним уровнем",
        },
        description: {
          "en":
              "Go from intermediate (B1) to advanced (C1) in 60 days by practicing French daily for a set amount of time.",
          "fr":
              "Passez de B1 à C1 en 90 jours en pratiquant l'anglais chaque jour pendant un certain temps.",
          "de":
              "Erreiche von B1 auf C1 in 90 Tagen durch tägliches Englischüben für eine festgelegte Zeit.",
          "it":
              "Passa da B1 a C1 in 90 giorni praticando l'inglese ogni giorno per un tempo stabilito.",
          "es":
              "Pasa de B1 a C1 en 90 días practicando inglés diariamente durante un tiempo determinado.",
          "pt":
              "Passe de B1 para C1 em 90 dias praticando inglês todos os dias por um tempo definido.",
          "ru":
              "Перейдите с уровня B1 на C1 за 90 дней, ежедневно практикуя английский в течение определенного времени.",
        },
        icon: locale == 'en' ? '🇫🇷' : '🇬🇧',
        startDate: null,
        deleted: false,
      ),
      '3': Challenge(
        id: '3',
        creator: '2',
        name: {
          "en": "Marathon in 6 months",
          "fr": "Marathon en 6 mois",
          "de": "Marathon in 6 Monaten",
          "it": "Maratona in 6 mesi",
          "es": "Maratón en 6 meses",
          "pt": "Maratona em 6 meses",
          "ru": "Марафон за 6 месяцев",
        },
        description: {
          "en": "Run a marathon in 6 months with this program!",
          "fr": "Courez un marathon en 6 mois grâce à ce programme !",
          "de": "Laufen Sie mit diesem Programm in 6 Monaten einen Marathon!",
          "it": "Corri una maratona in 6 mesi con questo programma!",
          "es": "¡Corre una maratón en 6 meses con este programa!",
          "pt": "Corra uma maratona em 6 meses com este programa!",
          "ru": "Пробегите марафон за 6 месяцев с помощью этой программы!",
        },
        icon: '🏃‍♀️',
        startDate: null,
        deleted: false,
      )
    },
    challengeDailyTrackings: {
      '1': List.generate(60, (index) {
        return ChallengeDailyTracking(
          id: index.toString(),
          habitId: '1',
          challengeId: '1',
          dayOfProgram: index,
          quantityPerSet: 30,
          quantityOfSet: 1,
          unitId: '2',
          weight: 0,
          weightUnitId: '1',
          note: pronunciationInstructions[locale],
        );
      }),
      '2': List.generate(90, (index) {
        return ChallengeDailyTracking(
          id: index.toString(),
          habitId: '1',
          challengeId: '2',
          dayOfProgram: index,
          quantityPerSet: 30,
          quantityOfSet: 1,
          unitId: '2',
          weight: 0,
          weightUnitId: '1',
          note: pronunciationInstructions[locale],
        );
      }),
      '3': List.generate(180, (index) {
        return ChallengeDailyTracking(
          id: index.toString(),
          habitId: '1',
          challengeId: '3',
          dayOfProgram: index,
          quantityPerSet: 0,
          quantityOfSet: 1,
          unitId: '2',
          weight: 0,
          weightUnitId: '1',
          note: null,
        );
      }),
    },
    challengeStatistics: {
      '1': ChallengeStatistic(
        challengeId: '1',
        participantsCount: 3401,
        topAges: {
          MapEntry('25-30', 1020),
          MapEntry('30-35', 451),
          MapEntry('35-40', 179),
        },
        topCountries: {
          MapEntry("France", 753),
          MapEntry("England", 632),
          MapEntry("Germany", 540),
        },
        topRegions: {
          MapEntry("Europe", 1253),
          MapEntry("Oceania", 503),
          MapEntry("Americas", 159),
        },
        topHasChildren: {
          MapEntry("Yes", 1853),
          MapEntry("No", 105),
        },
        topLivesInUrbanArea: {
          MapEntry("Yes", 1053),
          MapEntry("No", 1004),
        },
        topGender: {
          MapEntry("female", 1303),
          MapEntry("male", 953),
        },
        topActivities: {
          MapEntry("student", 623),
          MapEntry("unemployed", 403),
          MapEntry("worker", 303),
        },
        topFinancialSituations: {
          MapEntry("average", 803),
          MapEntry("wealthy", 603),
          MapEntry("poor", 303),
        },
        topRelationshipStatuses: {
          MapEntry("single", 1723),
          MapEntry("couple", 402),
        },
        topLevelsOfEducation: {
          MapEntry("highSchoolOrLess", 1203),
          MapEntry("highSchoolPlusOneOrTwoYears", 803),
          MapEntry("highSchoolPlusThreeOrFourYears", 403),
          MapEntry("highSchoolPlusFiveOrMoreYears", 103),
        },
        creatorUsername: 'reallystick',
      ),
      '2': ChallengeStatistic(
        challengeId: '2',
        participantsCount: 2325,
        topAges: {
          MapEntry('25-30', 1020),
          MapEntry('30-35', 451),
          MapEntry('35-40', 179),
        },
        topCountries: {
          MapEntry("France", 753),
          MapEntry("England", 632),
          MapEntry("Germany", 540),
        },
        topRegions: {
          MapEntry("Europe", 1253),
          MapEntry("Oceania", 503),
          MapEntry("Americas", 159),
        },
        topHasChildren: {
          MapEntry("Yes", 1853),
          MapEntry("No", 105),
        },
        topLivesInUrbanArea: {
          MapEntry("Yes", 1053),
          MapEntry("No", 1004),
        },
        topGender: {
          MapEntry("female", 1303),
          MapEntry("male", 953),
        },
        topActivities: {
          MapEntry("student", 623),
          MapEntry("unemployed", 403),
          MapEntry("worker", 303),
        },
        topFinancialSituations: {
          MapEntry("average", 803),
          MapEntry("wealthy", 603),
          MapEntry("poor", 303),
        },
        topRelationshipStatuses: {
          MapEntry("single", 1723),
          MapEntry("couple", 402),
        },
        topLevelsOfEducation: {
          MapEntry("highSchoolOrLess", 1203),
          MapEntry("highSchoolPlusOneOrTwoYears", 803),
          MapEntry("highSchoolPlusThreeOrFourYears", 403),
          MapEntry("highSchoolPlusFiveOrMoreYears", 103),
        },
        creatorUsername: 'reallystick',
      ),
      '3': ChallengeStatistic(
        challengeId: '3',
        participantsCount: 3401,
        topAges: {
          MapEntry('25-30', 1020),
          MapEntry('30-35', 451),
          MapEntry('35-40', 179),
        },
        topCountries: {
          MapEntry("France", 753),
          MapEntry("England", 632),
          MapEntry("Germany", 540),
        },
        topRegions: {
          MapEntry("Europe", 1253),
          MapEntry("Oceania", 503),
          MapEntry("Americas", 159),
        },
        topHasChildren: {
          MapEntry("Yes", 1853),
          MapEntry("No", 105),
        },
        topLivesInUrbanArea: {
          MapEntry("Yes", 1053),
          MapEntry("No", 1004),
        },
        topGender: {
          MapEntry("female", 1303),
          MapEntry("male", 953),
        },
        topActivities: {
          MapEntry("student", 623),
          MapEntry("unemployed", 403),
          MapEntry("worker", 303),
        },
        topFinancialSituations: {
          MapEntry("average", 803),
          MapEntry("wealthy", 603),
          MapEntry("poor", 303),
        },
        topRelationshipStatuses: {
          MapEntry("single", 1723),
          MapEntry("couple", 402),
        },
        topLevelsOfEducation: {
          MapEntry("highSchoolOrLess", 1203),
          MapEntry("highSchoolPlusOneOrTwoYears", 803),
          MapEntry("highSchoolPlusThreeOrFourYears", 403),
          MapEntry("highSchoolPlusFiveOrMoreYears", 103),
        },
        creatorUsername: 'reallystick',
      ),
    },
  );
}

UsersLoaded getUserStateForPreview(BuildContext context) {
  return UsersLoaded(
    users: {
      '2': UserPublicData(
        id: '2',
        username: 'reallystick',
        publicKey: 'publicKey',
      ),
      '3': UserPublicData(
        id: '3',
        username: 'thomas',
        publicKey: 'publicKey',
      ),
      '4': UserPublicData(
        id: '4',
        username: 'tatiana',
        publicKey: 'publicKey',
      ),
    },
    user: UserPublicData(
      id: '2',
      username: 'reallystick',
      publicKey: 'publicKey',
    ),
  );
}

PublicMessagesLoaded getPublicMessagesLoadedForPreview(BuildContext context) {
  return PublicMessagesLoaded(
    challengeId: '1',
    habitId: null,
    threads: [
      PublicMessage(
        id: '1',
        habitId: null,
        challengeId: '2',
        threadId: '1',
        creator: '3',
        repliesTo: null,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        updateAt: null,
        content:
            "Hey everyone! I just signed up for the Paris Marathon and I’m super excited (and a little nervous 😅). Just wondering—are there any others here who are running it too? Would love to connect, share training tips, or even plan a meetup!",
        likeCount: 73,
        replyCount: 1,
        deletedByCreator: false,
        deletedByAdmin: false,
        languageCode: null,
      )
    ],
    likedMessages: [
      PublicMessage(
        id: '1',
        habitId: null,
        challengeId: '2',
        threadId: '1',
        creator: '3',
        repliesTo: null,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        updateAt: null,
        content:
            "Hey everyone! I just signed up for the Paris Marathon and I’m super excited (and a little nervous 😅). Just wondering—are there any others here who are running it too? Would love to connect, share training tips, or even plan a meetup!",
        likeCount: 73,
        replyCount: 1,
        deletedByCreator: false,
        deletedByAdmin: false,
        languageCode: null,
      )
    ],
    writtenMessages: [],
    userReportedMessages: [],
    allReportedMessages: [],
    userReports: [],
    allReports: [],
  );
}

ThreadLoaded getThreadStateForPreview(BuildContext context) {
  return ThreadLoaded(
    replies: [
      PublicMessage(
        id: '2',
        habitId: null,
        challengeId: '2',
        threadId: '1',
        creator: '4',
        repliesTo: '1',
        createdAt: DateTime.now().subtract(Duration(hours: 20)),
        updateAt: null,
        content:
            "Hey! I’m running the Paris Marathon too! 🏃‍♂️ Super excited for it. How’s your training going? Feel free to DM me—we could exchange tips or even plan a pre-race meetup!",
        likeCount: 1,
        replyCount: 0,
        deletedByCreator: false,
        deletedByAdmin: false,
        languageCode: null,
      )
    ],
    threadId: '1',
  );
}

PrivateDiscussionState getPrivateDiscussionStateForPreview(
    BuildContext context) {
  return PrivateDiscussionState(
    discussions: {
      '1': PrivateDiscussion(
        id: '1',
        color: 'yellow',
        hasBlocked: false,
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        lastMessage: null,
        recipientId: '4',
        unseenMessages: 0,
      )
    },
  );
}

PrivateMessageState getPrivateMessageStateForPreview(BuildContext context) {
  return PrivateMessageState(
    discussionId: '1',
    messagesByDiscussion: {
      '1': {
        '1': PrivateMessage(
          id: '1',
          discussionId: '1',
          creator: '1',
          createdAt: DateTime.now().subtract(Duration(hours: 2)),
          updateAt: null,
          content:
              'Hey Tatiana! Saw your post about the Paris Marathon—so cool that you’re doing it too! How’s your training going so far? Are you following a specific plan?',
          creatorEncryptedSessionKey: 'creatorEncryptedSessionKey',
          recipientEncryptedSessionKey: 'recipientEncryptedSessionKey',
          deleted: false,
          seen: true,
        ),
        '2': PrivateMessage(
          id: '2',
          discussionId: '1',
          creator: '4',
          createdAt: DateTime.now().subtract(Duration(hours: 1, minutes: 24)),
          updateAt: null,
          content:
              'Hey! Yeah, I’m really pumped for it! Training’s going pretty well so far—I’m following a 16-week plan I found online. Trying to stay consistent, but some days are definitely tougher than others 😅 What about you? Got a plan you’re sticking to?',
          creatorEncryptedSessionKey: 'creatorEncryptedSessionKey',
          recipientEncryptedSessionKey: 'recipientEncryptedSessionKey',
          deleted: false,
          seen: true,
        ),
      }
    },
    lastPrivateMessageReceivedEvent: null,
  );
}
