// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get about => 'Acerca de';

  @override
  String get aboutText => 'Esta aplicación es presentada por Tanya Simmer.';

  @override
  String get account => 'Cuenta';

  @override
  String get accountDeletionSuccessful => 'Su cuenta ha sido eliminada correctamente.';

  @override
  String get activity => 'Actividad';

  @override
  String get addActivity => 'Agregar una actividad';

  @override
  String get addDailyObjective => 'Agregar un objetivo diario';

  @override
  String get addNewChallenge => 'Agregar un nuevo desafío';

  @override
  String get addNewDiscussion => 'Agregar una nueva discusión';

  @override
  String get addNewHabit => 'Agregar un nuevo hábito';

  @override
  String get admin => 'Administrador';

  @override
  String get ageCategory => 'Categoría de edad';

  @override
  String allActivitiesOnThisDay(int count) {
    return 'Todas sus actividades en esta fecha ($count)';
  }

  @override
  String get allHabits => 'Todos los hábitos';

  @override
  String get allReportedMessages => 'Todos los mensajes reportados';

  @override
  String get alreadyAnAccountLogin => '¿Ya tienes una cuenta? Inicia sesión';

  @override
  String get analytics => 'Estadísticas';

  @override
  String get analyticsInfoTooltip => 'Estas estadísticas se actualizan cada hora.';

  @override
  String get and => 'y';

  @override
  String get answers => 'Respuestas';

  @override
  String get atLeastOneTranslationNeededError => 'Se requiere al menos una traducción.';

  @override
  String get availableOnIosAndroidWebIn => 'Disponible en iOS, Android, Web en';

  @override
  String get average => 'Promedio';

  @override
  String get blockThisUser => 'Bloquear este usuario';

  @override
  String get bySigningUpYouAgree => 'Al crear una cuenta, aceptas nuestros';

  @override
  String get cancel => 'Cancelar';

  @override
  String get category => 'Categoría';

  @override
  String get challengeCreated => 'Su desafío ha sido creado con éxito';

  @override
  String get challengeDailyTracking => 'Objetivos diarios';

  @override
  String get challengeDailyTrackingCreated => 'Su objetivo diario ha sido creado con éxito.';

  @override
  String get challengeDailyTrackingDeleted => 'Su objetivo diario ha sido eliminado con éxito.';

  @override
  String get challengeDailyTrackingNotFoundError => 'Esta actividad no existe.';

  @override
  String get challengeDailyTrackingNoteTooLong => 'La nota debe tener menos de 10,000 caracteres.';

  @override
  String get challengeDailyTrackingUpdated => 'Sus cambios han sido guardados correctamente.';

  @override
  String get challengeDeleted => 'Su desafío ha sido eliminado con éxito.';

  @override
  String get challengeDescriptionWrongSize => 'La descripción del desafío debe tener menos de 2.000 caracteres.';

  @override
  String get challengeDuplicated => 'Este desafío ha sido copiado con éxito.';

  @override
  String get challengeFinished => 'Desafío terminado';

  @override
  String get challengeName => 'Nombre del desafío';

  @override
  String get challengeNameWrongSizeError => 'El nombre del desafío no debe estar vacío y debe contener menos de 100 caracteres.';

  @override
  String get challengeNotFoundError => 'Este desafío no existe.';

  @override
  String get challengeParticipationCreated => 'Te has unido a este desafío con éxito.';

  @override
  String get challengeParticipationDeleted => 'Tu participación en este desafío ha sido eliminada correctamente.';

  @override
  String get challengeParticipationNotFoundError => 'Parece que no estás participando en este hábito';

  @override
  String get challengeParticipationStartDate => 'Desafío unido el:';

  @override
  String get challengeParticipationUpdated => 'Sus cambios han sido guardados correctamente.';

  @override
  String get challengeUpdated => 'Sus cambios han sido guardados correctamente.';

  @override
  String get challengeWasDeletedByCreator => 'Este desafío ha sido eliminado por su creador';

  @override
  String get challenges => 'Desafíos';

  @override
  String get challengesInfoTooltip => 'Esta información se actualiza cada hora.';

  @override
  String get changeChallengeParticipationStartDate => 'Cambiar la fecha de inicio de participación';

  @override
  String get changeColor => 'Cambiar color';

  @override
  String get changePassword => 'Cambiar mi contraseña';

  @override
  String get changeRecoveryCode => 'Cambiar mi código de recuperación';

  @override
  String get chooseAnIcon => 'Elige un ícono';

  @override
  String get comeBack => 'Volver atrás';

  @override
  String get comingSoon => 'Disponible en breve...';

  @override
  String get confirm => 'Confirmar';

  @override
  String get confirmDelete => 'Confirmación de eliminación de cuenta';

  @override
  String get confirmDeleteMessage => 'Al hacer clic en \"Confirmar\", tu cuenta y toda la actividad asociada se programarán para su eliminación definitiva en 3 días.\n\nSi vuelves a iniciar sesión antes de que expire este plazo, la eliminación será cancelada.';

  @override
  String get confirmDeletion => 'Confirmar eliminación';

  @override
  String get confirmDeletionQuestion => '¿Confirma la eliminación de la sesión en este dispositivo?';

  @override
  String get confirmDuplicateChallenge => '¿Desea crear una copia de este desafío con los objetivos diarios asociados?';

  @override
  String get confirmMessageDeletion => 'Al hacer clic en \"Confirmar\", su mensaje y todas las respuestas asociadas serán eliminadas permanentemente.';

  @override
  String get connected => 'Conectado';

  @override
  String get continent => 'Continente';

  @override
  String get copyright => '© Copyright 2025. Todos los derechos reservados.';

  @override
  String get country => 'País';

  @override
  String get create => 'Crear';

  @override
  String get createANewChallenge => 'Crear un nuevo desafío';

  @override
  String get createANewHabit => 'Crear un nuevo hábito';

  @override
  String get createChallenge => 'Crear el desafío';

  @override
  String get createHabit => 'Crear el hábito';

  @override
  String get createHabitsThatStick => 'Crea hábitos que perduren';

  @override
  String createdBy(String creator) {
    return 'Creado por $creator';
  }

  @override
  String createdByStartsOn(String creator, String startDate) {
    return 'Creado por $creator, comienza el: $startDate';
  }

  @override
  String get createdChallenges => 'Mis desafíos creados';

  @override
  String get creatorMissingPublicKey => 'Aún no tienes claves secretas. Vuelve a conectarte para crearlas.';

  @override
  String get currentPassword => 'Contraseña actual';

  @override
  String get dark => 'Oscuro';

  @override
  String get date => 'Fecha';

  @override
  String get dateTimeIsInTheFutureError => 'La fecha no puede estar en el futuro.';

  @override
  String get dateTimeIsInThePastError => 'La fecha no puede estar en el pasado.';

  @override
  String get dayOfProgram => 'Día en el programa';

  @override
  String get defaultError => 'Ha ocurrido un error. Por favor, inténtalo de nuevo.';

  @override
  String defaultReminderChallenge(String challenge) {
    return 'No olvides hacer tu desafío: $challenge';
  }

  @override
  String defaultReminderHabit(String habit) {
    return 'No olvides seguir tu hábito: $habit';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteAccount => 'Eliminar mi cuenta';

  @override
  String get deleteChallenge => 'Eliminar este desafío';

  @override
  String get deleteChallengeParticipation => 'Eliminar esta participación';

  @override
  String get deleteMessage => 'Eliminar este mensaje';

  @override
  String get description => 'Descripción';

  @override
  String descriptionWithTwoPoints(String description) {
    return 'Descripción: $description';
  }

  @override
  String get deviceDeleteSuccessful => 'Has cerrado la sesión en este dispositivo con éxito.';

  @override
  String deviceInfo(String browser, String isMobile, String model, String os) {
    String _temp0 = intl.Intl.selectLogic(
      isMobile,
      {
        'true': 'Dispositivo móvil',
        'false': 'Ordenador',
        'other': 'Desconocido',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      os,
      {
        'null': '. ',
        'other': ' ejecutando $os. ',
      },
    );
    String _temp2 = intl.Intl.selectLogic(
      browser,
      {
        'null': 'Aplicación',
        'other': 'Navegador: $browser',
      },
    );
    String _temp3 = intl.Intl.selectLogic(
      model,
      {
        'null': '',
        'other': 'Modelo: $model.',
      },
    );
    return '$_temp0$_temp1$_temp2. $_temp3';
  }

  @override
  String get devices => 'Dispositivos';

  @override
  String get disableTwoFA => 'Desactivar';

  @override
  String get disconnected => 'Desconectado.';

  @override
  String get discussion => 'Discusión';

  @override
  String get discussions => 'Discusiones';

  @override
  String get discussionsComingSoon => 'Discusiones interesantes llegarán pronto...';

  @override
  String get duplicate => 'Crear una copia';

  @override
  String get duplicateChallenge => 'Copia de desafío';

  @override
  String get duplicationsOfMyChallenges => 'Duplicaciones de mis desafíos';

  @override
  String get edit => 'Editar';

  @override
  String get editActivity => 'Editar esta actividad';

  @override
  String get editChallenge => 'Editar este desafío';

  @override
  String editedAt(String time) {
    return 'Editado el $time';
  }

  @override
  String get enable => 'Activar';

  @override
  String get enableNotifications => 'Activar notificaciones';

  @override
  String get enableNotificationsReminder => 'Activar notificaciones de recordatorio';

  @override
  String get endDate => 'Fecha de finalización';

  @override
  String get endToEndEncryptedPrivateMessages => 'Mensajes privados cifrados de extremo a extremo';

  @override
  String get enterOneTimePassword => 'Introduce el código de 6 dígitos generado por tu aplicación para confirmar tu autenticación.';

  @override
  String get enterPassword => 'Introduce tu contraseña.';

  @override
  String get enterRecoveryCode => 'Introduce tu código de recuperación.';

  @override
  String get enterUsername => 'Introduce tu nombre de usuario.';

  @override
  String get enterValidationCode => 'Introduce el código de tu aplicación de autenticación.';

  @override
  String get failedToLoadChallenges => 'Ha ocurrido un error al recuperar tus desafíos.';

  @override
  String get failedToLoadHabits => 'Ha ocurrido un error al recuperar tus hábitos.';

  @override
  String get failedToLoadProfile => 'No se pudo cargar el perfil.';

  @override
  String get female => 'Mujer';

  @override
  String get females => 'Mujeres';

  @override
  String get financialSituation => 'Situación financiera';

  @override
  String get finished => 'Terminado';

  @override
  String get fixedDates => 'Fechas fijas';

  @override
  String get forbiddenError => 'No estás autorizado para realizar esta acción.';

  @override
  String get gender => 'Género';

  @override
  String get generateNewQrCode => 'Generar un nuevo código QR';

  @override
  String get generateNewRecoveryCode => 'Generar un nuevo código de recuperación';

  @override
  String get goToTwoFASetup => 'Activar';

  @override
  String get habit => 'Hábito';

  @override
  String get habitCategoryNotFoundError => 'Esta categoría de hábito no existe.';

  @override
  String get habitCreated => 'Tu hábito ha sido creado con éxito';

  @override
  String get habitDailyTracking => 'Seguimiento diario';

  @override
  String get habitDailyTrackingCreated => 'Tu actividad ha sido creada con éxito.';

  @override
  String get habitDailyTrackingDeleted => 'Tu actividad ha sido eliminada con éxito.';

  @override
  String get habitDailyTrackingNotFoundError => 'Esta actividad no existe.';

  @override
  String get habitDailyTrackingUpdated => 'Tus cambios han sido guardados correctamente.';

  @override
  String get habitDescriptionWrongSize => 'La descripción no debe estar vacía y debe contener menos de 2.000 caracteres.';

  @override
  String get habitIsEmptyError => 'Debe seleccionarse un hábito.';

  @override
  String get habitName => 'Nombre del hábito';

  @override
  String get habitNameWrongSizeError => 'El nombre del hábito no debe estar vacío y debe contener menos de 100 caracteres.';

  @override
  String get habitNotFoundError => 'Este hábito no existe.';

  @override
  String get habitParticipationCreated => 'Te has unido a este hábito con éxito.';

  @override
  String get habitParticipationDeleted => 'Tu participación en este hábito ha sido eliminada correctamente.';

  @override
  String get habitParticipationNotFoundError => 'Parece que no estás participando en este hábito';

  @override
  String get habitParticipationUpdated => 'Tus cambios han sido guardados correctamente.';

  @override
  String get habitUpdated => 'Tus cambios han sido guardados correctamente.';

  @override
  String get habits => 'Hábitos';

  @override
  String get habitsConcerned => 'Hábitos relacionados';

  @override
  String get habitsNotMergedError => 'Estos dos hábitos no pudieron ser fusionados';

  @override
  String get hasChildren => 'Soy padre/madre';

  @override
  String hello(String userName) {
    return 'Hola $userName';
  }

  @override
  String get highSchoolOrLess => 'Bachillerato o menos';

  @override
  String get highSchoolPlusFiveOrMoreYears => 'Bachillerato + 5 años de estudio o más';

  @override
  String get highSchoolPlusOneOrTwoYears => 'Bachillerato + 1 o 2 años de estudio';

  @override
  String get highSchoolPlusThreeOrFourYears => 'Bachillerato + 3 o 4 años de estudio';

  @override
  String get home => 'Inicio';

  @override
  String get icon => 'Icono';

  @override
  String get iconEmptyError => 'Se requiere un icono.';

  @override
  String get iconNotFoundError => 'Icono del hábito no encontrado.';

  @override
  String get internalServerError => 'Ha ocurrido un error interno del servidor. Por favor, inténtalo de nuevo.';

  @override
  String get introductionToQuestions => 'Para ofrecerte la mejor experiencia posible y compartir contigo estadísticas interesantes, tenemos algunas preguntas rápidas para ti.\n\nTus respuestas honestas nos ayudarán a crear estadísticas significativas a nivel mundial.\n\nTus respuestas a las preguntas no revelarán tu identidad.';

  @override
  String get invalidOneTimePasswordError => 'Contraseña de un solo uso inválida. Por favor, inténtalo de nuevo.';

  @override
  String get invalidRequestError => 'La solicitud que realizaste no fue aceptada por el servidor.';

  @override
  String get invalidResponseError => 'La respuesta del servidor no pudo ser procesada.';

  @override
  String get invalidUsernameOrCodeOrRecoveryCodeError => 'Nombre de usuario, contraseña de un solo uso o código de recuperación inválido. Por favor, inténtalo de nuevo.';

  @override
  String get invalidUsernameOrPasswordError => 'Nombre de usuario o contraseña inválido. Por favor, inténtalo de nuevo.';

  @override
  String get invalidUsernameOrPasswordOrRecoveryCodeError => 'Nombre de usuario, contraseña o código de recuperación inválido. Por favor, inténtalo de nuevo.';

  @override
  String get invalidUsernameOrRecoveryCodeError => 'Nombre de usuario o código de recuperación inválido. Por favor, inténtalo de nuevo.';

  @override
  String get joinChallengeReachYourGoals => 'Únete a desafíos,\nAlcanza tus objetivos';

  @override
  String get joinThisChallenge => 'Unirse a este desafío';

  @override
  String joinedByXPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Unido por $count personas',
      one: 'Unido por $count persona',
      zero: 'Unido por nadie',
    );
    return '$_temp0';
  }

  @override
  String joinedOn(String startDate) {
    return 'Unido el: $startDate';
  }

  @override
  String get jumpOnTop => 'Subir arriba';

  @override
  String get keepRecoveryCodeSafe => 'Por favor, guarda este código de recuperación en un lugar seguro.\n\nLo necesitarás si pierdes tu contraseña o el acceso a tu aplicación de autenticación.';

  @override
  String get language => 'Idioma';

  @override
  String get lastActivity => 'Última actividad:';

  @override
  String get lastActivityDate => 'Fecha de la última actividad:';

  @override
  String lastActivityDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count días',
      one: 'hace $count día',
    );
    return '$_temp0';
  }

  @override
  String lastActivityHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count horas',
      one: 'hace $count hora',
    );
    return '$_temp0';
  }

  @override
  String lastActivityMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count minutos',
      one: 'hace $count minuto',
    );
    return '$_temp0';
  }

  @override
  String lastActivityMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count meses',
      one: 'hace $count mes',
    );
    return '$_temp0';
  }

  @override
  String lastActivitySeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count segundos',
      one: 'hace $count segundo',
      zero: 'En este momento',
    );
    return '$_temp0';
  }

  @override
  String lastActivityYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count años',
      one: 'hace $count año',
    );
    return '$_temp0';
  }

  @override
  String get levelOfEducation => 'Nivel de estudios';

  @override
  String get light => 'Claro';

  @override
  String get likedMessages => 'Mensajes que te gustan';

  @override
  String get likesOnMyPublicMessages => 'Me gusta en mis mensajes públicos';

  @override
  String get livesInUrbanArea => 'Vivo en una zona urbana';

  @override
  String get livingInRuralArea => 'Zona rural';

  @override
  String get livingInUrbanArea => 'Zona urbana';

  @override
  String get logIn => 'Iniciar sesión';

  @override
  String get loginSuccessful => 'Has iniciado sesión correctamente.';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutSuccessful => 'Has cerrado sesión correctamente.';

  @override
  String get longName => 'Nombre (versión larga)';

  @override
  String get male => 'Hombre';

  @override
  String get males => 'Hombres';

  @override
  String get markChallengeAsFinished => 'Has terminado este desafío, ¡felicidades! \nMárcalo como terminado para poder repetirlo más tarde sin perder los detalles de esta participación.';

  @override
  String get markedAsFinishedChallenges => 'Desafíos terminados';

  @override
  String get mergeHabit => 'Fusionar hábitos';

  @override
  String get message => 'Mensaje';

  @override
  String get messageDeletedError => 'Este mensaje ha sido eliminado.';

  @override
  String get messageNotFoundError => 'Este mensaje no ha sido encontrado.';

  @override
  String get messages => 'Mensajes';

  @override
  String get messagesAreEncrypted => 'Los mensajes están cifrados de extremo a extremo.\nNadie fuera de esta discusión, ni siquiera nuestro equipo, puede leerlos.';

  @override
  String get missingDateTimeError => 'La fecha no puede dejarse vacía.';

  @override
  String get newDiscussion => 'Nueva Discusión';

  @override
  String get newParticipantsToMyChallenges => 'Nuevos participantes en mis desafíos';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get next => 'Siguiente';

  @override
  String get no => 'No';

  @override
  String get noAccountCreateOne => '¿No tienes cuenta? Créala aquí.';

  @override
  String get noActivityRecordedYet => 'Aún no hay actividad registrada.';

  @override
  String get noAnswer => 'Prefiero no responder';

  @override
  String get noAnswerForThisMessageYet => 'Aún no hay respuesta para este mensaje.';

  @override
  String get noChallengeDailyTrackingYet => 'Aún no hay seguimiento diario registrado.';

  @override
  String get noChallengesForHabitYet => 'Aún no hay desafíos para este hábito.\n¡Crea el primero!';

  @override
  String get noChallengesYet => 'Aún no tienes desafíos.';

  @override
  String get noConcernedHabitsYet => 'Aún no hay hábitos relacionados con este desafío.';

  @override
  String get noConnection => 'Actualmente no podemos conectarnos a nuestros servidores. Por favor, revisa tu conexión o inténtalo de nuevo en unos momentos.';

  @override
  String get noContent => 'No hay contenido para mostrar';

  @override
  String get noDeviceInfo => 'No hay información del dispositivo para mostrar';

  @override
  String get noDevices => 'No hay dispositivos para mostrar';

  @override
  String get noDiscussionsForChallengeYet => 'Aún no hay discusiones para este desafío.\n¡Crea la primera!';

  @override
  String get noDiscussionsForHabitYet => 'Aún no hay discusiones para este hábito.\n¡Crea la primera!';

  @override
  String get noEmailOfIdentifiableDataRequired => 'No se requiere correo electrónico ni datos identificables';

  @override
  String get noHabitsYet => 'Aún no tienes hábitos.';

  @override
  String get noLikedMessages => 'Aún no has marcado ningún mensaje como favorito.';

  @override
  String get noMessagesYet => 'Aún no hay mensajes en esta discusión.';

  @override
  String get noNotification => 'Aún no tienes notificaciones.';

  @override
  String get noPrivateDiscussionsYet => 'Aún no tienes discusiones privadas.';

  @override
  String get noRecoveryCodeAvailable => 'No hay código de recuperación disponible.';

  @override
  String get noReportedMessages => 'Aún no has reportado ningún mensaje.';

  @override
  String get noResultsFound => 'No se encontraron resultados.';

  @override
  String get noWrittenMessages => 'Aún no has escrito ningún mensaje.';

  @override
  String get note => 'Nota';

  @override
  String get noteWithNote => 'Nota:';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get numberOfDaysToRepeatThisObjective => 'Número de días para repetir este objetivo';

  @override
  String numberOfParticipantsInChallenge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas siguen este desafío.',
      one: '$count persona sigue este desafío.',
      zero: 'Nadie sigue este desafío.',
    );
    return '$_temp0';
  }

  @override
  String get numberOfParticipantsInChallengeTitle => 'Número de participantes';

  @override
  String numberOfParticipantsInHabit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas siguen este hábito.',
      one: '$count persona sigue este hábito.',
      zero: 'Nadie sigue este hábito.',
    );
    return '$_temp0';
  }

  @override
  String get numberOfParticipantsInHabitTitle => 'Número de participantes';

  @override
  String get ongoingChallenges => 'Desafíos en curso';

  @override
  String get other => 'Otro';

  @override
  String get otherChallenges => 'Otros desafíos';

  @override
  String get participateAgain => 'Participar de nuevo';

  @override
  String get password => 'Contraseña';

  @override
  String get passwordForgotten => '¿Olvidaste tu contraseña?';

  @override
  String get passwordMustBeChangedError => 'Debes cambiar tu contraseña para poder iniciar sesión.';

  @override
  String get passwordNotComplexEnough => 'Tu contraseña debe contener al menos una letra, un número y un carácter especial.';

  @override
  String get passwordNotExpiredError => 'Tu contraseña no ha expirado. No puedes cambiarla de esta manera.';

  @override
  String get passwordTooShortError => 'Tu contraseña debe contener al menos 8 caracteres.';

  @override
  String get passwordUpdateSuccessful => 'Tu contraseña ha sido actualizada correctamente';

  @override
  String get peopleWithChildren => 'Personas con hijos';

  @override
  String get peopleWithoutChildren => 'Personas sin hijos';

  @override
  String get personalizedNotificationsToStayOnTrack => 'Notificaciones personalizadas para mantenerte motivado';

  @override
  String get pleaseLoginOrSignUp => 'Por favor, inicia sesión o regístrate para continuar.';

  @override
  String get poor => 'Pobre';

  @override
  String get previous => 'Anterior';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get privacyPolicyMarkdown => '# Política de Privacidad\n\n**Fecha de entrada en vigor:** 5 de abril de 2025\n**Última actualización:** 5 de abril de 2025\n\nBienvenido a **ReallyStick**, una plataforma social de seguimiento de hábitos que permite a los usuarios seguir su progreso diario, participar en desafíos y conversar en discusiones públicas o privadas, todo mientras mantienen el control de sus datos personales.\n\n## 1. Información que recopilamos\n\n### Datos obligatorios\n- Nombre de usuario\n- Contraseña (cifrada de manera segura)\n- Código de recuperación\n- Información del dispositivo (sistema operativo, plataforma, tipo de dispositivo)\n- Dirección IP\n- Tokens de sesión\n\n### Datos demográficos opcionales\n- Continente\n- País\n- Rango de edad\n- Género\n- Nivel educativo\n- Nivel de riqueza\n- Estado profesional\n\n## 2. Mensajería privada y cifrado\n\n- Los mensajes privados están cifrados de extremo a extremo\n- Su clave privada se almacena únicamente en su dispositivo\n- No podemos leer sus mensajes privados\n\n## 3. Uso de sus datos\n\nUtilizamos sus datos para:\n- Proporcionar las funcionalidades de la aplicación\n- Gestionar las sesiones en sus dispositivos\n- Generar estadísticas anónimas\n- Enviar notificaciones push (a través de Google Firebase)\n- Prevenir abusos y garantizar la seguridad\n\nNo **vendemos ni compartimos** sus datos con fines publicitarios.\n\n## 4. Compartición de datos\n\nServicio externo utilizado:\n- **Google Firebase** – para el envío de notificaciones push\n\n## 5. Interacciones públicas\n\n- Solo los nombres de usuario son visibles públicamente\n- Los mensajes públicos pueden ser reportados y moderados\n\n## 6. Conservación y eliminación de datos\n\nLos usuarios pueden eliminar su cuenta y todos sus datos asociados desde su página de perfil.\n\n## 7. Medidas de seguridad\n\n- Contraseñas cifradas\n- Almacenamiento local de tokens de acceso\n- Cifrado de extremo a extremo\n- Registro de direcciones IP para prevenir abusos\n\n## 8. Anonimato e identidad\n\n- No se requiere dirección de correo electrónico ni nombre real\n- Las cuentas son pseudónimas por defecto\n\n## 9. Protección de menores\n\nNuestra aplicación está abierta a todos. Sin embargo, puede ser necesario el consentimiento parental según las leyes locales vigentes.\n\n## 10. Derechos de los usuarios (RGPD)\n\nTiene el derecho de:\n- Acceder a sus datos\n- Eliminar sus datos\n- Rechazar proporcionar los campos opcionales\n\n## 11. Modificaciones de la política\n\nPodemos actualizar esta política de privacidad. En caso de cambios importantes, se le informará a través de la aplicación.\n\n## 12. Contactarnos\n\nUtilice el formulario de contacto integrado en la aplicación.\n\nPara consultas relacionadas con la privacidad, también puede enviarnos un correo electrónico a: **[support@reallystick.com](support@reallystick.com)**';

  @override
  String get privateDiscussionNotFoundError => 'No se pudo encontrar la conversación privada.';

  @override
  String get privateMessageContentEmpty => 'El contenido del mensaje privado no puede estar vacío.';

  @override
  String get privateMessageContentTooLong => 'El contenido del mensaje privado debe tener menos de 10.000 caracteres.';

  @override
  String get privateMessageNotFoundError => 'No se pudo encontrar el mensaje privado.';

  @override
  String get privateMessagesReceived => 'Mensajes privados recibidos';

  @override
  String get profile => 'Perfil';

  @override
  String get profileInformation => 'Información del perfil';

  @override
  String get profileSettings => 'Configuración del perfil';

  @override
  String get profileUpdateSuccessful => 'Su información ha sido guardada correctamente.';

  @override
  String get publicMessageContentEmpty => 'El contenido del mensaje público no puede estar vacío.';

  @override
  String get publicMessageContentTooLong => 'El contenido del mensaje público debe tener menos de 10.000 caracteres.';

  @override
  String get publicMessageDeletionSuccessful => 'Su mensaje ha sido eliminado correctamente.';

  @override
  String get publicMessageNotFoundError => 'No se pudo encontrar el mensaje público.';

  @override
  String get publicMessageReportCreationSuccessful => 'Su reporte ha sido enviado correctamente.';

  @override
  String get publicMessageReportNotFoundError => 'No se pudo encontrar el reporte del mensaje público.';

  @override
  String get publicMessageReportReasonEmpty => 'El motivo del reporte no debe estar vacío.';

  @override
  String get publicMessageReportReasonTooLong => 'El motivo del reporte debe tener menos de 10.000 caracteres.';

  @override
  String get qrCodeSecretKeyCopied => 'La clave secreta del código QR ha sido copiada al portapapeles.';

  @override
  String get quantity => 'Cantidad';

  @override
  String get quantityIsNotANumberError => 'La cantidad debe ser un número.';

  @override
  String get quantityOfSet => 'Número de series';

  @override
  String get quantityOfSetIsNegativeError => 'El número de series no puede ser negativo.';

  @override
  String get quantityOfSetIsNullError => 'El número de series no puede ser cero.';

  @override
  String quantityOfSetWithQuantity(int quantity) {
    return 'Número de series: $quantity';
  }

  @override
  String get quantityPerSet => 'Número de repeticiones';

  @override
  String get quantityPerSetIsNegativeError => 'La cantidad no puede ser negativa.';

  @override
  String get quantityPerSetIsNullError => 'La cantidad no puede estar vacía.';

  @override
  String quantityPerSetWithQuantity(String quantity) {
    return 'Número de repeticiones: $quantity';
  }

  @override
  String quantityWithQuantity(String quantity) {
    return 'Cantidad: $quantity';
  }

  @override
  String get questionActivity => '¿Cuál es su actividad actualmente?';

  @override
  String get questionAge => '¿Qué edad tiene?';

  @override
  String get questionFinancialSituation => '¿Cómo describiría su situación financiera?';

  @override
  String get questionGender => '¿Es usted hombre o mujer?';

  @override
  String get questionHasChildren => '¿Tiene hijos?';

  @override
  String get questionLevelOfEducation => '¿Cuál es su nivel de educación?';

  @override
  String get questionLivingInUrbanArea => '¿Vive en una zona urbana?';

  @override
  String get questionLocation => '¿Dónde vive?';

  @override
  String get questionRelationStatus => '¿Está actualmente en una relación?';

  @override
  String get questionsAnswered => 'Sus respuestas han sido guardadas. ¡Gracias!';

  @override
  String get quitThisChallenge => 'Salir de este desafío';

  @override
  String get quitThisHabit => 'Salir de este hábito';

  @override
  String get reason => 'Razón';

  @override
  String get recipientMissingPublicKey => 'Este destinatario aún no tiene claves secretas.';

  @override
  String get recoverAccount => 'Recuperación de cuenta';

  @override
  String get recoveryCode => 'Código de recuperación';

  @override
  String get recoveryCodeCopied => 'El código de recuperación ha sido copiado al portapapeles.';

  @override
  String get recoveryCodeDescription => 'Su código de recuperación sirve para recuperar el acceso a su cuenta si olvida su contraseña.\n\nPor favor, manténgalo confidencial.\n\nSi ha olvidado este código, puede generar uno nuevo.\n\nEsto desactivará el código de verificación actual.';

  @override
  String get refreshTokenExpiredError => 'Su sesión ha expirado. Por favor, vuelva a conectarse.';

  @override
  String get regenerateQrCode => 'Regenerar un código QR';

  @override
  String get region => 'Región';

  @override
  String get relatedChallenges => 'Desafíos relacionados';

  @override
  String get relationshipStatus => 'Estado de relación';

  @override
  String get relationshipStatusCouple => 'En una relación';

  @override
  String get relationshipStatusSingle => 'Soltero';

  @override
  String get repeatOnMultipleDaysAfter => 'Repetir en varios días después de este';

  @override
  String get repetitionNumberIsNegativeError => 'El número de repeticiones no puede ser negativo.';

  @override
  String get repetitionNumberIsNullError => 'El número de repeticiones no puede ser cero.';

  @override
  String get repliesOnMyPublicMessages => 'Respuestas a mis mensajes públicos';

  @override
  String get reply => 'Respuesta';

  @override
  String replyTo(String user) {
    return 'Responder a $user...';
  }

  @override
  String get reportMessage => 'Reportar mensaje';

  @override
  String get reportedMessages => 'Mensajes reportados';

  @override
  String get retry => 'Reintentar';

  @override
  String get reviewHabit => 'Revisión de hábito';

  @override
  String get save => 'Guardar';

  @override
  String get saveHabit => 'Guardar cambios';

  @override
  String get searchChallenges => 'Buscar desafíos';

  @override
  String get searchHabits => 'Buscar hábitos';

  @override
  String get searchUser => 'Buscar un usuario';

  @override
  String get selectIcon => 'Selección del ícono';

  @override
  String get selectLanguage => 'Selección del idioma';

  @override
  String get selectLanguageToAddTranslation => 'Selecciona un idioma para añadir una traducción';

  @override
  String get selectTheme => 'Selección del tema';

  @override
  String get selectUnits => 'Seleccione unidades de medida para este hábito';

  @override
  String get setNewPassword => 'Introduzca su nueva contraseña.';

  @override
  String get share => 'Compartir';

  @override
  String get shareChallengeSubject => 'Únete a este desafío';

  @override
  String shareChallengeText(String link) {
    return '¡Hola! Este desafío podría interesarte: $link';
  }

  @override
  String get shortName => 'Nombre (versión corta)';

  @override
  String get signUp => 'Registrarse';

  @override
  String get skip => 'Omitir';

  @override
  String get startDate => 'Fecha de inicio';

  @override
  String get startHabitShort => 'Comenzar';

  @override
  String get startTrackingThisHabit => 'Comenzar a seguir este hábito';

  @override
  String startsOn(String startDate) {
    return 'Comienza el: $startDate';
  }

  @override
  String get statistics => 'Estadísticas';

  @override
  String get student => 'Estudiante';

  @override
  String get tapForMoreDetails => 'Más detalles';

  @override
  String get tapToSeeLess => 'Ver menos';

  @override
  String get termsOfUse => 'Condiciones de uso';

  @override
  String get termsOfUseMarkdown => '# Condiciones de Uso\n\n**Fecha de entrada en vigor:** 5 de abril de 2025\n**Última actualización:** 5 de abril de 2025\n\nBienvenido a **ReallyStick**, una plataforma social de seguimiento de hábitos diseñada para ayudarte a seguir y mejorar tus hábitos diarios. Al acceder o utilizar la aplicación, aceptas estar sujeto a las presentes Condiciones de Uso. Si no estás de acuerdo con estas condiciones, por favor no utilices la aplicación.\n\n## 1. Cuentas de Usuario\n\nPara utilizar ciertas funcionalidades de la aplicación, debes crear una cuenta. Aceptas:\n- Proporcionar información exacta y completa durante el registro.\n- Mantener la confidencialidad de tu información de cuenta (nombre de usuario, contraseña, código de recuperación).\n- Informarnos inmediatamente si sospechas de un acceso no autorizado a tu cuenta.\n\nEres responsable de todas las actividades que ocurran bajo tu cuenta, incluyendo todos los datos compartidos o acciones realizadas a través de tu cuenta.\n\n## 2. Uso de la Aplicación\n\nAceptas utilizar **ReallyStick** únicamente para fines legales y de acuerdo con las presentes Condiciones de Uso. No debes:\n- Violar las leyes o regulaciones aplicables.\n- Publicar, compartir o participar en cualquier actividad dañina, ofensiva o ilegal.\n- Utilizar la aplicación para enviar mensajes no solicitados o spam.\n- Intentar hackear, dañar o acceder de manera no autorizada a la aplicación o sus funcionalidades.\n\nNos reservamos el derecho de suspender o terminar tu cuenta si violas estas condiciones.\n\n## 3. Privacidad y Recopilación de Datos\n\nTu privacidad es importante para nosotros. Recopilamos ciertos datos como se describe en nuestra **Política de Privacidad**. Al utilizar la aplicación, consientes la recopilación y uso de tus datos conforme a nuestra Política de Privacidad.\n\n## 4. Contenido y Propiedad\n\n- Todo el contenido proporcionado por **ReallyStick** (incluyendo la aplicación, el sitio web y cualquier material relacionado) es propiedad de **ReallyStick** o de nuestros licenciantes y está protegido por leyes de derechos de autor, marcas registradas y otras leyes de propiedad intelectual.\n- No puedes copiar, modificar, distribuir o crear obras derivadas de cualquier contenido sin nuestro permiso.\n- Conservas la propiedad de cualquier contenido que publiques en la aplicación, pero al publicar contenido, nos otorgas una licencia para usar, mostrar y distribuir ese contenido en la aplicación y con fines promocionales.\n\n## 5. Contenido Generado por el Usuario\n\nEres responsable del contenido que publicas o compartes en **ReallyStick**, incluyendo textos, imágenes y cualquier otro medio. Aceptas no publicar:\n- Contenido dañino, acosador, ofensivo o discriminatorio.\n- Contenido que infrinja los derechos de propiedad intelectual de otros.\n- Contenido que viole cualquier ley aplicable.\n\nNos reservamos el derecho de eliminar cualquier contenido que infrinja estas condiciones.\n\n## 6. Notificaciones Push\n\nPodemos enviarte notificaciones push para actualizaciones, recordatorios e información importante relacionada con la aplicación. Puedes gestionar o desactivar estas notificaciones en la configuración de la aplicación.\n\n## 7. Terminación\n\nNos reservamos el derecho de suspender o terminar tu acceso a **ReallyStick** en cualquier momento, por cualquier razón, incluyendo si violas estas Condiciones de Uso. En caso de terminación, tu cuenta será eliminada y perderás el acceso a la aplicación.\n\n## 8. Exención de Responsabilidad\n\n- La aplicación se proporciona \"tal cual\" sin garantía de ningún tipo, expresa o implícita.\n- No garantizamos que la aplicación esté libre de errores, sea segura o esté disponible en todo momento.\n\n## 9. Limitación de Responsabilidad\n\nEn la máxima medida permitida por la ley, no seremos responsables de los daños resultantes de tu uso o incapacidad para usar **ReallyStick**, incluyendo, pero no limitado a, la pérdida de datos, errores del sistema o cualquier otro daño indirecto o consecuente.\n\n## 10. Indemnización\n\nAceptas indemnizar, defender y eximir de responsabilidad a **ReallyStick** y sus afiliados de cualquier reclamación, daño, responsabilidad y gasto (incluyendo honorarios legales) resultantes de tu uso de la aplicación, tu violación de estas Condiciones de Uso o cualquier contenido que publiques o compartas en la aplicación.\n\n## 11. Ley Aplicable\n\nEstas Condiciones de Uso se rigen por las leyes del país o jurisdicción donde resides. Cualquier disputa será resuelta ante los tribunales competentes de tu región.\n\n## 12. Modificaciones de las Condiciones\n\nPodemos actualizar estas Condiciones de Uso de vez en cuando. Si hacemos cambios significativos, te informaremos a través de la aplicación. La versión más reciente de estas condiciones siempre estará disponible en la aplicación.\n\n## 13. Contactarnos\n\nSi tienes preguntas o inquietudes sobre estas Condiciones de Uso, por favor contáctanos a través del formulario de contacto integrado en la aplicación.';

  @override
  String get theme => 'Tema';

  @override
  String get time => 'Hora';

  @override
  String timeWithTime(String time) {
    return 'Hora: $time';
  }

  @override
  String get topActivityCardTitle => 'Actividad';

  @override
  String get topAgesCardTitle => 'Categorías de edad';

  @override
  String get topCountriesCardTitle => 'Países';

  @override
  String get topFinancialSituationsCardTitle => 'Situación financiera';

  @override
  String get topGenderCardTitle => 'Género';

  @override
  String get topHasChildrenCardTitle => 'Hijos';

  @override
  String get topLevelsOfEducationCardTitle => 'Nivel de estudios';

  @override
  String get topLivesInUrbanAreaCardTitle => 'Zona de residencia';

  @override
  String get topRegionsCardTitle => 'Regiones';

  @override
  String get topRelationshipStatusesCardTitle => 'Estado de relación';

  @override
  String translationForLanguage(String language) {
    return 'Traducción en: $language';
  }

  @override
  String get twoFA => 'Autenticación de dos factores';

  @override
  String get twoFAInvitation => 'La seguridad y la privacidad son nuestras principales prioridades.\n\nPor favor, active la autenticación de dos factores para proteger su cuenta de ataques de fuerza bruta.';

  @override
  String get twoFAIsWellSetup => 'La autenticación de dos factores está configurada correctamente en su cuenta.';

  @override
  String get twoFAScanQrCode => 'Escanee este código QR en su aplicación de autenticación.';

  @override
  String twoFASecretKey(String secretKey) {
    return 'Su clave secreta de QR-code es: $secretKey';
  }

  @override
  String get twoFASetup => 'Active la autenticación de dos factores para asegurar su cuenta.';

  @override
  String get twoFactorAuthenticationNotEnabledError => 'La autenticación de dos factores no está activada en su cuenta.';

  @override
  String get unableToLoadRecoveryCode => 'No se puede cargar el código de recuperación.';

  @override
  String get unauthorizedError => 'No está autorizado para realizar esta operación.';

  @override
  String get unblockThisUser => 'Desbloquear a este usuario';

  @override
  String get unemployed => 'Desempleado';

  @override
  String get unit => 'Unidad';

  @override
  String get unitNotFoundError => 'Esta unidad no existe.';

  @override
  String get unknown => 'Desconocido';

  @override
  String get unknownError => 'Ha ocurrido un error inesperado. Por favor, intente de nuevo.';

  @override
  String get updateChallenge => 'Modificar el desafío';

  @override
  String get updateNow => 'Actualizar';

  @override
  String get updatePassword => 'Ingrese su contraseña actual y la nueva.';

  @override
  String get updateRequired => 'Se requiere una nueva versión para seguir usando la aplicación.';

  @override
  String get userAlreadyExistingError => 'Ya existe un usuario con este nombre de usuario. Por favor, elija otro.';

  @override
  String get userNotFoundError => 'Usuario no encontrado.';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get usernameNotRespectingRulesError => 'Su nombre de usuario debe cumplir con estas reglas:\n - comenzar y terminar con una letra o un número\n - los caracteres especiales permitidos son . _ -\n - no se permiten caracteres especiales consecutivos.';

  @override
  String get usernameWrongSizeError => 'La longitud de su nombre de usuario debe estar entre 3 y 20 caracteres.';

  @override
  String get validationCode => 'Código de validación';

  @override
  String get validationCodeCorrect => '¡Su código de validación es correcto!';

  @override
  String get verify => 'Verificar';

  @override
  String get wealthy => 'Rico';

  @override
  String get weight => 'Peso';

  @override
  String get weightIsNegativeError => 'El peso no puede ser negativo.';

  @override
  String get weightUnit => 'Unidad de peso';

  @override
  String weightWithQuantity(int quantity, String unit) {
    return 'Peso: $quantity $unit';
  }

  @override
  String get welcome => 'Bienvenido a ReallyStick';

  @override
  String get whatIsThis => '¿De qué se trata?';

  @override
  String get worker => 'Trabajador';

  @override
  String writeTo(String user) {
    return 'Escriba a $user...';
  }

  @override
  String get writtenMessages => 'Mensajes escritos';

  @override
  String get yes => 'Sí';

  @override
  String get youAreNotAlone => 'No están solos. Conversen, intercambien, crezcan.';

  @override
  String get youAreNotTheCreatorOfThisChallenge => 'Usted no es el creador de este desafío.';

  @override
  String get youBlockedThisUser => 'Usted ha bloqueado a este usuario.';
}
