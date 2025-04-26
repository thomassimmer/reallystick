// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get about => 'Sobre';

  @override
  String get aboutText => 'Este aplicativo é oferecido por Tanya Simmer.';

  @override
  String get account => 'Conta';

  @override
  String get accountDeletionSuccessful => 'Sua conta foi excluída com sucesso.';

  @override
  String get activity => 'Atividade';

  @override
  String get addActivity => 'Adicionar uma atividade';

  @override
  String get addDailyObjective => 'Adicionar um objetivo diário';

  @override
  String get addNewChallenge => 'Adicionar um novo desafio';

  @override
  String get addNewDiscussion => 'Adicionar uma nova discussão';

  @override
  String get addNewHabit => 'Adicionar um novo hábito';

  @override
  String get admin => 'Admin';

  @override
  String get ageCategory => 'Categoria de idade';

  @override
  String allActivitiesOnThisDay(int count) {
    return 'Todas as suas atividades nesta data ($count)';
  }

  @override
  String get allHabits => 'Todos os hábitos';

  @override
  String get allReportedMessages => 'Todas as mensagens relatadas';

  @override
  String get alreadyAnAccountLogin => 'Já tem uma conta? Faça login';

  @override
  String get analytics => 'Estatísticas';

  @override
  String get analyticsInfoTooltip => 'Essas estatísticas são atualizadas a cada hora.';

  @override
  String get and => 'e';

  @override
  String get answers => 'Respostas';

  @override
  String get atLeastOneTranslationNeededError => 'Pelo menos uma tradução é necessária.';

  @override
  String get availableOnIosAndroidWebIn => 'Disponível no iOS, Android, Web em';

  @override
  String get average => 'Média';

  @override
  String get blockThisUser => 'Bloquear este usuário';

  @override
  String get bySigningUpYouAgree => 'Ao criar uma conta, você concorda com nossos';

  @override
  String get cancel => 'Cancelar';

  @override
  String get category => 'Categoria';

  @override
  String get challengeCreated => 'Seu desafio foi criado com sucesso';

  @override
  String get challengeDailyTracking => 'Objetivos diários';

  @override
  String get challengeDailyTrackingCreated => 'Seu objetivo diário foi criado com sucesso.';

  @override
  String get challengeDailyTrackingDeleted => 'Seu objetivo diário foi excluído com sucesso.';

  @override
  String get challengeDailyTrackingNotFoundError => 'Esta atividade não existe.';

  @override
  String get challengeDailyTrackingNoteTooLong => 'A nota deve ter menos de 10.000 caracteres.';

  @override
  String get challengeDailyTrackingUpdated => 'Suas alterações foram salvas com sucesso.';

  @override
  String get challengeDeleted => 'Seu desafio foi excluído com sucesso.';

  @override
  String get challengeDuplicated => 'Este desafio foi copiado com sucesso.';

  @override
  String get challengeFinished => 'Desafio concluído';

  @override
  String get challengeName => 'Nome do desafio';

  @override
  String get challengeNameWrongSizeError => 'O nome do desafio não pode estar vazio e deve ter menos de 100 caracteres.';

  @override
  String get challengeNotFoundError => 'Este desafio não existe.';

  @override
  String get challengeParticipationCreated => 'Você entrou neste desafio com sucesso.';

  @override
  String get challengeParticipationDeleted => 'Sua participação neste desafio foi excluída com sucesso.';

  @override
  String get challengeParticipationNotFoundError => 'Você não parece estar participando deste hábito.';

  @override
  String get challengeParticipationStartDate => 'Desafio iniciado em:';

  @override
  String get challengeParticipationUpdated => 'Suas alterações foram salvas com sucesso.';

  @override
  String get challengeUpdated => 'Suas alterações foram salvas com sucesso.';

  @override
  String get challengeWasDeletedByCreator => 'Este desafio foi excluído pelo criador.';

  @override
  String get challenges => 'Desafios';

  @override
  String get challengesInfoTooltip => 'Essas informações são atualizadas a cada hora.';

  @override
  String get changeChallengeParticipationStartDate => 'Alterar a data de início da participação';

  @override
  String get changeColor => 'Alterar cor';

  @override
  String get changePassword => 'Alterar minha senha';

  @override
  String get changeRecoveryCode => 'Alterar meu código de recuperação';

  @override
  String get comeBack => 'Voltar';

  @override
  String get comingSoon => 'Disponível em breve...';

  @override
  String get confirm => 'Confirmar';

  @override
  String get confirmDelete => 'Confirmação de exclusão de conta';

  @override
  String get confirmDeleteMessage => 'Ao clicar em \"Confirmar\", a sua conta e todas as atividades associadas serão agendadas para exclusão permanente em 3 dias.\n\nSe voltar a iniciar sessão antes do fim deste prazo, a exclusão será cancelada.';

  @override
  String get confirmDeletion => 'Confirmar exclusão';

  @override
  String get confirmDeletionQuestion => 'Você confirma a exclusão da sessão neste dispositivo?';

  @override
  String get confirmDuplicateChallenge => 'Deseja criar uma cópia deste desafio com os objetivos diários associados?';

  @override
  String get confirmMessageDeletion => 'Ao clicar em \'Confirmar\', sua mensagem e todas as respostas associadas serão excluídas permanentemente.';

  @override
  String get connected => 'Conectado';

  @override
  String get continent => 'Continente';

  @override
  String get copyright => '© Copyright 2025. Todos os direitos reservados.';

  @override
  String get country => 'País';

  @override
  String get create => 'Criar';

  @override
  String get createANewChallenge => 'Criar um novo desafio';

  @override
  String get createANewHabit => 'Criar um novo hábito';

  @override
  String get createChallenge => 'Criar desafio';

  @override
  String get createHabit => 'Criar hábito';

  @override
  String get createHabitsThatStick => 'Crie hábitos que durem';

  @override
  String createdBy(String creator) {
    return 'Criado por $creator';
  }

  @override
  String createdByStartsOn(String creator, String startDate) {
    return 'Criado por $creator, começa em: $startDate';
  }

  @override
  String get createdChallenges => 'Meus desafios criados';

  @override
  String get creatorMissingPublicKey => 'Você ainda não tem chaves secretas. Refaça o login para criar uma.';

  @override
  String get currentPassword => 'Senha atual';

  @override
  String get dark => 'Escuro';

  @override
  String get date => 'Data';

  @override
  String get dateTimeIsInTheFutureError => 'A data não pode ser no futuro.';

  @override
  String get dateTimeIsInThePastError => 'A data não pode ser no passado.';

  @override
  String get dayOfProgram => 'Dia no programa';

  @override
  String get defaultError => 'Ocorreu um erro. Tente novamente.';

  @override
  String defaultReminderChallenge(String challenge) {
    return 'Não se esqueça de fazer seu desafio: $challenge';
  }

  @override
  String defaultReminderHabit(String habit) {
    return 'Não se esqueça de seguir seu hábito: $habit';
  }

  @override
  String get delete => 'Excluir';

  @override
  String get deleteAccount => 'Excluir minha conta';

  @override
  String get deleteChallenge => 'Excluir este desafio';

  @override
  String get deleteChallengeParticipation => 'Excluir esta participação';

  @override
  String get deleteMessage => 'Excluir esta mensagem';

  @override
  String get description => 'Descrição';

  @override
  String descriptionWithTwoPoints(String description) {
    return 'Descrição: $description';
  }

  @override
  String get deviceDeleteSuccessful => 'Você saiu com sucesso deste dispositivo.';

  @override
  String deviceInfo(String browser, String isMobile, String model, String os) {
    String _temp0 = intl.Intl.selectLogic(
      isMobile,
      {
        'true': 'Dispositivo móvel',
        'false': 'Computador',
        'other': 'Desconhecido',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      os,
      {
        'null': '. ',
        'other': ' executando $os. ',
      },
    );
    String _temp2 = intl.Intl.selectLogic(
      browser,
      {
        'null': 'Aplicativo',
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
  String get disableTwoFA => 'Desativar';

  @override
  String get disconnected => 'Desconectado.';

  @override
  String get discussion => 'Discussão';

  @override
  String get discussions => 'Discussões';

  @override
  String get discussionsComingSoon => 'Discussões interessantes estarão disponíveis em breve...';

  @override
  String get duplicate => 'Criar uma cópia';

  @override
  String get duplicateChallenge => 'Cópia do desafio';

  @override
  String get edit => 'Editar';

  @override
  String get editActivity => 'Editar esta atividade';

  @override
  String get editChallenge => 'Editar este desafio';

  @override
  String editedAt(String time) {
    return 'Editado em $time';
  }

  @override
  String get enable => 'Ativar';

  @override
  String get enableNotificationsReminder => 'Ativar notificações de lembrete';

  @override
  String get endDate => 'Data de término';

  @override
  String get endToEndEncryptedPrivateMessages => 'Mensagens privadas criptografadas de ponta a ponta';

  @override
  String get enterOneTimePassword => 'Digite o código de 6 dígitos gerado pelo seu aplicativo para confirmar sua autenticação.';

  @override
  String get enterPassword => 'Digite sua senha.';

  @override
  String get enterRecoveryCode => 'Digite seu código de recuperação.';

  @override
  String get enterUsername => 'Digite seu nome de usuário.';

  @override
  String get enterValidationCode => 'Digite o código do seu aplicativo de autenticação.';

  @override
  String get failedToLoadChallenges => 'Ocorreu um erro ao recuperar seus desafios.';

  @override
  String get failedToLoadHabits => 'Ocorreu um erro ao recuperar seus hábitos.';

  @override
  String get failedToLoadProfile => 'Não foi possível carregar o perfil.';

  @override
  String get female => 'Feminino';

  @override
  String get females => 'Feminino';

  @override
  String get financialSituation => 'Situação financeira';

  @override
  String get finished => 'Concluído';

  @override
  String get fixedDates => 'Datas fixas';

  @override
  String get forbiddenError => 'Você não tem permissão para realizar esta ação.';

  @override
  String get gender => 'Gênero';

  @override
  String get generateNewQrCode => 'Gerar um novo QR-code';

  @override
  String get generateNewRecoveryCode => 'Gerar um novo código de recuperação';

  @override
  String get goToTwoFASetup => 'Ativar';

  @override
  String get habit => 'Hábito';

  @override
  String get habitCategoryNotFoundError => 'Esta categoria de hábito não existe.';

  @override
  String get habitCreated => 'Seu hábito foi criado com sucesso';

  @override
  String get habitDailyTracking => 'Acompanhamento diário';

  @override
  String get habitDailyTrackingCreated => 'Sua atividade foi criada com sucesso.';

  @override
  String get habitDailyTrackingDeleted => 'Sua atividade foi excluída com sucesso.';

  @override
  String get habitDailyTrackingNotFoundError => 'Esta atividade não existe.';

  @override
  String get habitDailyTrackingUpdated => 'Suas alterações foram salvas com sucesso.';

  @override
  String get habitDescriptionWrongSizeError => 'A descrição não pode estar vazia e deve ter menos de 200 caracteres.';

  @override
  String get habitIsEmptyError => 'Um hábito deve ser selecionado.';

  @override
  String get habitName => 'Nome do hábito';

  @override
  String get habitNameWrongSizeError => 'O nome do hábito não pode estar vazio e deve ter menos de 100 caracteres.';

  @override
  String get habitNotFoundError => 'Este hábito não existe.';

  @override
  String get habitParticipationCreated => 'Você entrou neste hábito com sucesso.';

  @override
  String get habitParticipationDeleted => 'Sua participação neste hábito foi excluída com sucesso.';

  @override
  String get habitParticipationNotFoundError => 'Você não parece estar participando deste hábito';

  @override
  String get habitParticipationUpdated => 'Suas alterações foram salvas com sucesso.';

  @override
  String get habitUpdated => 'Suas alterações foram salvas com sucesso.';

  @override
  String get habits => 'Hábitos';

  @override
  String get habitsConcerned => 'Hábitos relacionados';

  @override
  String get habitsNotMergedError => 'Esses dois hábitos não puderam ser mesclados';

  @override
  String get hasChildren => 'Eu sou pai/mãe';

  @override
  String hello(String userName) {
    return 'Olá $userName';
  }

  @override
  String get highSchoolOrLess => 'Ensino médio ou menos';

  @override
  String get highSchoolPlusFiveOrMoreYears => 'Ensino superior + 5 anos ou mais';

  @override
  String get highSchoolPlusOneOrTwoYears => 'Ensino superior + 1 ou 2 anos';

  @override
  String get highSchoolPlusThreeOrFourYears => 'Ensino superior + 3 ou 4 anos';

  @override
  String get home => 'Início';

  @override
  String get icon => 'Ícone';

  @override
  String get iconEmptyError => 'Um ícone é necessário.';

  @override
  String get iconNotFoundError => 'Ícone do hábito não encontrado.';

  @override
  String get internalServerError => 'Ocorreu um erro interno no servidor. Tente novamente.';

  @override
  String get introductionToQuestions => 'Para oferecer a melhor experiência possível e compartilhar com você estatísticas interessantes, temos algumas perguntas rápidas para você.\n\nSuas respostas sinceras nos ajudarão a criar estatísticas significativas globalmente.\n\nSuas respostas às perguntas não revelarão sua identidade.';

  @override
  String get invalidOneTimePasswordError => 'Senha de uso único inválida. Tente novamente.';

  @override
  String get invalidRequestError => 'A solicitação que você fez não foi aceita pelo servidor.';

  @override
  String get invalidResponseError => 'A resposta do servidor não pôde ser processada.';

  @override
  String get invalidUsernameOrCodeOrRecoveryCodeError => 'Nome de usuário, senha de uso único ou código de recuperação inválido. Tente novamente.';

  @override
  String get invalidUsernameOrPasswordError => 'Nome de usuário ou senha inválidos. Tente novamente.';

  @override
  String get invalidUsernameOrPasswordOrRecoveryCodeError => 'Nome de usuário, senha ou código de recuperação inválido. Tente novamente.';

  @override
  String get invalidUsernameOrRecoveryCodeError => 'Nome de usuário ou código de recuperação inválido. Tente novamente.';

  @override
  String get joinChallengeReachYourGoals => 'Junte-se aos desafios,\nAlcance seus objetivos';

  @override
  String get joinThisChallenge => 'Participar deste desafio';

  @override
  String joinedByXPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Junto por $count pessoas',
      one: 'Junto por $count pessoa',
      zero: 'Junto por ninguém',
    );
    return '$_temp0';
  }

  @override
  String joinedOn(String startDate) {
    return 'Participou em: $startDate';
  }

  @override
  String get jumpOnTop => 'Voltar ao topo';

  @override
  String get keepRecoveryCodeSafe => 'Por favor, mantenha este código de recuperação em segurança.\n\nEle será necessário se você perder sua senha ou o acesso ao seu aplicativo de autenticação.';

  @override
  String get language => 'Idioma';

  @override
  String get lastActivity => 'Última atividade:';

  @override
  String get lastActivityDate => 'Data da última atividade:';

  @override
  String lastActivityDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count dias',
      one: 'há $count dia',
    );
    return '$_temp0';
  }

  @override
  String lastActivityHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count horas',
      one: 'há $count hora',
    );
    return '$_temp0';
  }

  @override
  String lastActivityMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count minutos',
      one: 'há $count minuto',
    );
    return '$_temp0';
  }

  @override
  String lastActivityMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count meses',
      one: 'há $count mês',
    );
    return '$_temp0';
  }

  @override
  String lastActivitySeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count segundos',
      one: 'há $count segundo',
      zero: 'Agora mesmo',
    );
    return '$_temp0';
  }

  @override
  String lastActivityYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count anos',
      one: 'há $count ano',
    );
    return '$_temp0';
  }

  @override
  String get levelOfEducation => 'Nível de escolaridade';

  @override
  String get light => 'Claro';

  @override
  String get likedMessages => 'Mensagens curtidas';

  @override
  String get livesInUrbanArea => 'Eu vivo em área urbana';

  @override
  String get livingInRuralArea => 'Área rural';

  @override
  String get livingInUrbanArea => 'Área urbana';

  @override
  String get logIn => 'Entrar';

  @override
  String get loginSuccessful => 'Você está conectado com sucesso.';

  @override
  String get logout => 'Sair';

  @override
  String get logoutSuccessful => 'Você saiu com sucesso.';

  @override
  String get longName => 'Nome (versão longa)';

  @override
  String get male => 'Homem';

  @override
  String get males => 'Homens';

  @override
  String get markChallengeAsFinished => 'Você terminou este desafio, parabéns!\nMarque como finalizado para poder reiniciá-lo mais tarde sem perder os detalhes desta participação.';

  @override
  String get markedAsFinishedChallenges => 'Desafios finalizados';

  @override
  String get mergeHabit => 'Mesclar hábitos';

  @override
  String get message => 'Mensagem';

  @override
  String get messageDeletedError => 'Esta mensagem foi deletada.';

  @override
  String get messageNotFoundError => 'Esta mensagem não foi encontrada.';

  @override
  String get messages => 'Mensagens';

  @override
  String get messagesAreEncrypted => 'As mensagens são criptografadas de ponta a ponta.\nNinguém fora desta conversa, nem mesmo nossa equipe, pode lê-las.';

  @override
  String get missingDateTimeError => 'A data não pode ser deixada em branco.';

  @override
  String get newDiscussion => 'Nova Discussão';

  @override
  String get newPassword => 'Nova senha';

  @override
  String get next => 'Próximo';

  @override
  String get no => 'Não';

  @override
  String get noAccountCreateOne => 'Não tem conta? Crie uma aqui.';

  @override
  String get noActivityRecordedYet => 'Ainda não há atividade registrada.';

  @override
  String get noAnswer => 'Prefiro não responder';

  @override
  String get noAnswerForThisMessageYet => 'Ainda não há resposta para esta mensagem.';

  @override
  String get noChallengeDailyTrackingYet => 'Ainda não há objetivo diário registrado.';

  @override
  String get noChallengesForHabitYet => 'Ainda não há desafio para este hábito.\nCrie o primeiro!';

  @override
  String get noChallengesYet => 'Você ainda não tem desafios.';

  @override
  String get noConcernedHabitsYet => 'Ainda não há hábitos relacionados a este desafio.';

  @override
  String get noConnection => 'Não foi possível conectar aos nossos servidores no momento. Verifique sua conexão ou tente novamente em breve.';

  @override
  String get noContent => 'Nenhum conteúdo para exibir';

  @override
  String get noDeviceInfo => 'Nenhuma informação sobre o dispositivo para exibir';

  @override
  String get noDevices => 'Nenhum dispositivo para exibir';

  @override
  String get noDiscussionsForChallengeYet => 'Ainda não há discussão para este desafio.\nCrie a primeira!';

  @override
  String get noDiscussionsForHabitYet => 'Ainda não há discussão para este hábito.\nCrie a primeira!';

  @override
  String get noEmailOfIdentifiableDataRequired => 'Nenhum e-mail ou dado identificável necessário';

  @override
  String get noHabitsYet => 'Você ainda não tem hábitos.';

  @override
  String get noLikedMessages => 'Você ainda não curtiu nenhuma mensagem.';

  @override
  String get noMessagesYet => 'Ainda não há mensagens nesta discussão.';

  @override
  String get noNotification => 'Você ainda não tem notificações.';

  @override
  String get noPrivateDiscussionsYet => 'Você ainda não tem discussões privadas.';

  @override
  String get noRecoveryCodeAvailable => 'Nenhum código de recuperação disponível.';

  @override
  String get noReportedMessages => 'Você ainda não reportou nenhuma mensagem.';

  @override
  String get noResultsFound => 'Nenhum resultado encontrado.';

  @override
  String get noWrittenMessages => 'Você ainda não escreveu nenhuma mensagem.';

  @override
  String get note => 'Nota';

  @override
  String get noteWithNote => 'Nota:';

  @override
  String get notifications => 'Notificações';

  @override
  String get numberOfDaysToRepeatThisObjective => 'Número de dias para repetir este objetivo';

  @override
  String numberOfParticipantsInChallenge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas seguem este desafio.',
      one: '$count pessoa segue este desafio.',
      zero: 'Ninguém segue este desafio.',
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
      other: '$count pessoas seguem este hábito.',
      one: '$count pessoa segue este hábito.',
      zero: 'Ninguém segue este hábito.',
    );
    return '$_temp0';
  }

  @override
  String get numberOfParticipantsInHabitTitle => 'Número de participantes';

  @override
  String get ongoingChallenges => 'Desafios em andamento';

  @override
  String get other => 'Outro';

  @override
  String get otherChallenges => 'Outros desafios';

  @override
  String get participateAgain => 'Participar novamente';

  @override
  String get password => 'Senha';

  @override
  String get passwordForgotten => 'Esqueceu sua senha?';

  @override
  String get passwordMustBeChangedError => 'Sua senha precisa ser alterada para que você possa se conectar.';

  @override
  String get passwordNotComplexEnough => 'Sua senha deve conter pelo menos uma letra, um número e um caractere especial.';

  @override
  String get passwordNotExpiredError => 'Sua senha não expirou. Você não pode alterá-la dessa forma.';

  @override
  String get passwordTooShortError => 'Sua senha deve ter pelo menos 8 caracteres.';

  @override
  String get passwordUpdateSuccessful => 'Sua senha foi atualizada com sucesso';

  @override
  String get peopleWithChildren => 'Pessoas com filhos';

  @override
  String get peopleWithoutChildren => 'Pessoas sem filhos';

  @override
  String get personalizedNotificationsToStayOnTrack => 'Notificações personalizadas para manter-se motivado';

  @override
  String get pleaseLoginOrSignUp => 'Por favor, faça login ou se inscreva para continuar.';

  @override
  String get poor => 'Pobre';

  @override
  String get previous => 'Anterior';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get privacyPolicyMarkdown => '# Política de Privacidade\n\n**Data de entrada em vigor:** 5 de abril de 2025  \n**Última atualização:** 5 de abril de 2025\n\nBem-vindo ao **ReallyStick**, uma plataforma social de acompanhamento de hábitos que permite aos usuários monitorar seu progresso diário, participar de desafios e interagir em discussões públicas ou privadas — tudo enquanto mantém o controle sobre seus dados pessoais.\n\n## 1. Informações que coletamos\n\n### Dados obrigatórios\n- Nome de usuário\n- Senha (armazenada de forma segura)\n- Código de recuperação\n- Informações sobre o dispositivo (sistema operacional, plataforma, tipo de dispositivo)\n- Endereço IP\n- Tokens de sessão\n\n### Dados demográficos opcionais\n- Continente\n- País\n- Faixa etária\n- Gênero\n- Nível educacional\n- Nível de riqueza\n- Status profissional\n\n## 2. Mensagens privadas & criptografia\n\n- As mensagens privadas são criptografadas de ponta a ponta  \n- Sua chave privada é armazenada apenas em seu dispositivo  \n- Não podemos ler suas mensagens privadas\n\n## 3. Uso dos seus dados\n\nUsamos seus dados para:\n- Fornecer as funcionalidades do aplicativo\n- Gerenciar sessões em seus dispositivos\n- Gerar estatísticas anônimas\n- Enviar notificações push (via Google Firebase)\n- Prevenir abusos e garantir a segurança\n\nNós **não vendemos nem compartilhamos** seus dados para fins publicitários.\n\n## 4. Compartilhamento de dados\n\nServiço externo utilizado:\n- **Google Firebase** – para envio de notificações push\n\n## 5. Interações públicas\n\n- Apenas os nomes de usuário são visíveis publicamente  \n- As mensagens públicas podem ser denunciadas e moderadas\n\n## 6. Retenção e exclusão de dados\n\nOs usuários podem excluir sua conta e todos os dados associados na página de perfil.\n\n## 7. Medidas de segurança\n\n- Senhas criptografadas  \n- Armazenamento local de tokens de acesso  \n- Criptografia de ponta a ponta  \n- Registro de endereços IP para prevenir abusos\n\n## 8. Anonimato & identidade\n\n- Nenhum e-mail ou nome real é necessário  \n- As contas são pseudônimas por padrão\n\n## 9. Proteção infantil\n\nNosso aplicativo está aberto a todos. No entanto, o consentimento dos pais pode ser necessário de acordo com as leis locais em vigor.\n\n## 10. Direitos dos usuários (LGPD)\n\nVocê tem o direito de:\n- Acessar seus dados\n- Excluir seus dados\n- Recusar fornecer os campos opcionais\n\n## 11. Alterações na política\n\nPodemos atualizar esta política de privacidade. Em caso de mudanças significativas, você será informado através do aplicativo.\n\n## 12. Entre em contato\n\nUse o formulário de contato integrado no aplicativo.\n\nPara questões relacionadas com a privacidade, também pode enviar-nos um e-mail para: **[support@reallystick.com](support@reallystick.com)**';

  @override
  String get profile => 'Perfil';

  @override
  String get profileInformation => 'Informações do perfil';

  @override
  String get profileSettings => 'Configurações do perfil';

  @override
  String get profileUpdateSuccessful => 'As suas informações foram salvas com sucesso.';

  @override
  String get publicMessageDeletionSuccessful => 'A sua mensagem foi apagada com sucesso.';

  @override
  String get publicMessageReportCreationSuccessful => 'O seu relatório foi enviado com sucesso.';

  @override
  String get qrCodeSecretKeyCopied => 'A chave secreta do QR-code foi copiada para a área de transferência.';

  @override
  String get quantity => 'Quantidade';

  @override
  String get quantityOfSet => 'Número de sets';

  @override
  String get quantityOfSetIsNegativeError => 'O número de sets não pode ser negativo.';

  @override
  String get quantityOfSetIsNullError => 'O número de sets não pode ser nulo.';

  @override
  String quantityOfSetWithQuantity(int quantity) {
    return 'Número de sets: $quantity';
  }

  @override
  String get quantityPerSet => 'Número de repetições';

  @override
  String get quantityPerSetIsNegativeError => 'A quantidade não pode ser negativa.';

  @override
  String get quantityPerSetIsNullError => 'A quantidade não pode ser vazia.';

  @override
  String quantityPerSetWithQuantity(int quantity) {
    return 'Número de repetições: $quantity';
  }

  @override
  String quantityWithQuantity(int quantity) {
    return 'Quantidade: $quantity';
  }

  @override
  String get questionActivity => 'Qual é a sua atividade atualmente?';

  @override
  String get questionAge => 'Quantos anos você tem?';

  @override
  String get questionFinancialSituation => 'Como você descreveria a sua situação financeira?';

  @override
  String get questionGender => 'Você é homem ou mulher?';

  @override
  String get questionHasChildren => 'Você tem filhos?';

  @override
  String get questionLevelOfEducation => 'Qual é o seu nível de educação?';

  @override
  String get questionLivingInUrbanArea => 'Você mora em uma área urbana?';

  @override
  String get questionLocation => 'Onde você mora?';

  @override
  String get questionRelationStatus => 'Você está atualmente em um relacionamento?';

  @override
  String get questionsAnswered => 'As suas respostas foram salvas. Obrigado!';

  @override
  String get quitThisChallenge => 'Sair deste desafio';

  @override
  String get quitThisHabit => 'Sair deste hábito';

  @override
  String get reason => 'Razão';

  @override
  String get recipientMissingPublicKey => 'Este destinatário ainda não tem chaves secretas.';

  @override
  String get recoverAccount => 'Recuperação de conta';

  @override
  String get recoveryCode => 'Código de recuperação';

  @override
  String get recoveryCodeCopied => 'O código de recuperação foi copiado para a área de transferência.';

  @override
  String get recoveryCodeDescription => 'O seu código de recuperação serve para recuperar o acesso à sua conta caso esqueça a sua senha.\n\nPor favor, mantenha-o confidencial.\n\nSe você esquecer este código, pode gerar um novo.\n\nIsso desativará o código de verificação atual.';

  @override
  String get refreshTokenExpiredError => 'Sua sessão expirou. Por favor, faça login novamente.';

  @override
  String get regenerateQrCode => 'Regenerar QR-code';

  @override
  String get region => 'Região';

  @override
  String get relatedChallenges => 'Desafios relacionados';

  @override
  String get relationshipStatus => 'Status de relacionamento';

  @override
  String get relationshipStatusCouple => 'Em um relacionamento';

  @override
  String get relationshipStatusSingle => 'Solteiro';

  @override
  String get repeatOnMultipleDaysAfter => 'Repetir em vários dias após este';

  @override
  String get repetitionNumberIsNegativeError => 'O número de repetições não pode ser negativo.';

  @override
  String get repetitionNumberIsNullError => 'O número de repetições não pode ser nulo.';

  @override
  String get reply => 'Resposta';

  @override
  String replyTo(String user) {
    return 'Responder a $user...';
  }

  @override
  String get reportMessage => 'Reportar mensagem';

  @override
  String get reportedMessages => 'Mensagens reportadas';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get reviewHabit => 'Revisão de hábito';

  @override
  String get save => 'Salvar';

  @override
  String get saveHabit => 'Salvar alterações';

  @override
  String get searchChallenges => 'Buscar desafios';

  @override
  String get searchHabits => 'Buscar hábitos';

  @override
  String get searchUser => 'Buscar usuário';

  @override
  String get selectIcon => 'Selecionar ícone';

  @override
  String get selectLanguage => 'Selecionar idioma';

  @override
  String get selectTheme => 'Selecionar tema';

  @override
  String get selectUnits => 'Selecionar unidades de medida para este hábito';

  @override
  String get setNewPassword => 'Informe sua nova senha.';

  @override
  String get share => 'Compartilhar';

  @override
  String get shareChallengeSubject => 'Junte-se a este desafio';

  @override
  String shareChallengeText(String link) {
    return 'Ei! Este desafio pode ser interessante para você: $link';
  }

  @override
  String get shortName => 'Nome (versão curta)';

  @override
  String get signUp => 'Cadastrar-se';

  @override
  String get skip => 'Pular';

  @override
  String get startDate => 'Data de início';

  @override
  String get startHabitShort => 'Começar';

  @override
  String get startTrackingThisHabit => 'Começar a monitorar este hábito';

  @override
  String startsOn(String startDate) {
    return 'Começa em: $startDate';
  }

  @override
  String get statistics => 'Estatísticas';

  @override
  String get student => 'Estudante';

  @override
  String get tapForMoreDetails => 'Toque para mais detalhes';

  @override
  String get tapToSeeLess => 'Ver menos';

  @override
  String get termsOfUse => 'Termos de uso';

  @override
  String get termsOfUseMarkdown => '# Termos de Uso\n\n**Data de vigência:** 5 de abril de 2025  \n**Última atualização:** 5 de abril de 2025\n\nBem-vindo ao **ReallyStick**, uma plataforma social de monitoramento de hábitos criada para ajudá-lo a acompanhar e melhorar seus hábitos diários. Ao acessar ou usar o aplicativo, você concorda em estar vinculado a estes Termos de Uso. Se você não concorda com estes termos, não utilize o aplicativo.\n\n## 1. Contas de Usuário\n\nPara utilizar algumas funcionalidades do aplicativo, você deve criar uma conta. Você concorda em:\n- Fornecer informações precisas e completas durante o registro.\n- Manter suas informações de conta (nome de usuário, senha, código de recuperação) em sigilo.\n- Nos informar imediatamente caso suspeite de acesso não autorizado à sua conta.\n\nVocê é responsável por todas as atividades que ocorrem sob sua conta, incluindo todos os dados compartilhados ou ações realizadas por meio de sua conta.\n\n## 2. Uso do aplicativo\n\nVocê concorda em usar o **ReallyStick** apenas para fins legais e de acordo com estes Termos de Uso. Você não deve:\n- Violação de leis ou regulamentos aplicáveis.\n- Publicar, compartilhar ou participar de qualquer atividade prejudicial, ofensiva ou ilegal.\n- Usar o aplicativo para enviar mensagens não solicitadas ou spam.\n- Tentar hackear, danificar ou acessar de maneira não autorizada o aplicativo ou suas funcionalidades.\n\nReservamo-nos o direito de suspender ou encerrar sua conta se você violar estes termos.\n\n## 3. Privacidade e Coleta de Dados\n\nSua privacidade é importante para nós. Coletamos certos dados como descrito em nossa **Política de Privacidade**. Ao usar o aplicativo, você consente com a coleta e o uso de seus dados de acordo com nossa Política de Privacidade.\n\n## 4. Conteúdo e Propriedade\n\n- Todo o conteúdo fornecido pelo **ReallyStick** (incluindo o aplicativo, o site e todo o material relacionado) é propriedade do **ReallyStick** ou de nossos licenciados e é protegido por leis de direitos autorais, marcas registradas e outras leis de propriedade intelectual.\n- Você não pode copiar, modificar, distribuir ou criar obras derivadas de qualquer conteúdo sem nossa permissão.\n- Você mantém a propriedade de todo o conteúdo que publica no aplicativo, mas ao publicar conteúdo, concede-nos uma licença para usar, exibir e distribuir esse conteúdo no aplicativo e para fins promocionais.\n\n## 5. Conteúdo Gerado pelo Usuário\n\nVocê é responsável pelo conteúdo que publica ou compartilha no **ReallyStick**, incluindo textos, imagens e qualquer outro tipo de mídia. Você concorda em não publicar:\n- Conteúdo prejudicial, assediante, ofensivo ou discriminatório.\n- Conteúdo que infrinja os direitos de propriedade intelectual de terceiros.\n- Conteúdo que viole qualquer lei aplicável.\n\nReservamo-nos o direito de remover qualquer conteúdo que viole estes termos.\n\n## 6. Notificações Push\n\nPodemos enviar notificações push para atualizações, lembretes e informações importantes relacionadas ao aplicativo. Você pode gerenciar ou desativar essas notificações nas configurações do aplicativo.\n\n## 7. Rescisão\n\nReservamo-nos o direito de suspender ou encerrar seu acesso ao **ReallyStick** a qualquer momento, por qualquer motivo, incluindo a violação destes Termos de Uso. Em caso de rescisão, sua conta será excluída e você perderá o acesso ao aplicativo.\n\n## 8. Isenção de Responsabilidade\n\n- O aplicativo é fornecido \"como está\", sem garantias de qualquer tipo, expressas ou implícitas.\n- Não garantimos que o aplicativo esteja livre de erros, seguro ou disponível a qualquer momento.\n\n## 9. Limitação de Responsabilidade\n\nNa medida máxima permitida por lei, não seremos responsáveis por danos decorrentes de seu uso ou incapacidade de usar o **ReallyStick**, incluindo, mas não se limitando a, perda de dados, erros de sistema ou qualquer outro dano indireto ou consequencial.\n\n## 10. Indenização\n\nVocê concorda em indenizar, defender e isentar o **ReallyStick** e seus afiliados de qualquer reclamação, dano, responsabilidade e despesa (incluindo honorários advocatícios) decorrentes do seu uso do aplicativo, da violação destes Termos de Uso ou de qualquer conteúdo que você publique ou compartilhe no aplicativo.\n\n## 11. Direito Aplicável\n\nEstes Termos de Uso são regidos pelas leis do país ou jurisdição em que você reside. Qualquer disputa será resolvida perante as jurisdições competentes de sua região.\n\n## 12. Modificações dos Termos\n\nPodemos atualizar estes Termos de Uso de tempos em tempos. Se fizermos alterações significativas, informaremos você por meio do aplicativo. A versão mais recente destes termos estará sempre disponível no aplicativo.\n\n## 13. Contate-nos\n\nSe você tiver dúvidas ou preocupações sobre estes Termos de Uso, entre em contato conosco por meio do formulário de contato integrado no aplicativo.';

  @override
  String get theme => 'Tema';

  @override
  String get time => 'Hora';

  @override
  String timeWithTime(String time) {
    return 'Hora: $time';
  }

  @override
  String get topActivityCardTitle => 'Atividade';

  @override
  String get topAgesCardTitle => 'Faixas etárias';

  @override
  String get topCountriesCardTitle => 'Países';

  @override
  String get topFinancialSituationsCardTitle => 'Situação financeira';

  @override
  String get topGenderCardTitle => 'Sexo';

  @override
  String get topHasChildrenCardTitle => 'Filhos';

  @override
  String get topLevelsOfEducationCardTitle => 'Nível de educação';

  @override
  String get topLivesInUrbanAreaCardTitle => 'Área urbana';

  @override
  String get topRegionsCardTitle => 'Regiões';

  @override
  String get topRelationshipStatusesCardTitle => 'Status de relacionamento';

  @override
  String get twoFA => 'Autenticação de dois fatores';

  @override
  String get twoFAInvitation => 'A segurança e a privacidade são nossas principais prioridades.\n\nPor favor, ative a autenticação de dois fatores para proteger sua conta contra ataques de força bruta.';

  @override
  String get twoFAIsWellSetup => 'A autenticação de dois fatores está configurada corretamente em sua conta.';

  @override
  String get twoFAScanQrCode => 'Escaneie este código QR no seu aplicativo de autenticação.';

  @override
  String twoFASecretKey(String secretKey) {
    return 'Sua chave secreta do QR-code é: $secretKey';
  }

  @override
  String get twoFASetup => 'Ative a autenticação de dois fatores para proteger sua conta.';

  @override
  String get twoFactorAuthenticationNotEnabledError => 'A autenticação de dois fatores não está ativada em sua conta.';

  @override
  String get unableToLoadRecoveryCode => 'Não foi possível carregar o código de recuperação.';

  @override
  String get unauthorizedError => 'Você não tem permissão para realizar esta operação.';

  @override
  String get unblockThisUser => 'Desbloquear este usuário';

  @override
  String get unemployed => 'Desempregado';

  @override
  String get unit => 'Unidade';

  @override
  String get unitNotFoundError => 'Esta unidade não existe.';

  @override
  String get unknown => 'Desconhecido';

  @override
  String get unknownError => 'Ocorreu um erro inesperado. Tente novamente.';

  @override
  String get updateChallenge => 'Atualizar desafio';

  @override
  String get updateNow => 'Atualizar agora';

  @override
  String get updatePassword => 'Informe sua senha atual e a nova.';

  @override
  String get updateRequired => 'É necessária uma nova versão para continuar usando o aplicativo.';

  @override
  String get userAlreadyExistingError => 'Já existe um usuário com este nome de usuário. Por favor, escolha outro.';

  @override
  String get userNotFoundError => 'Usuário não encontrado.';

  @override
  String get username => 'Nome de usuário';

  @override
  String get usernameNotRespectingRulesError => 'Seu nome de usuário deve seguir estas regras:\n - começar e terminar com uma letra ou número\n - caracteres especiais permitidos: . _ -\n - sem caracteres especiais consecutivos.';

  @override
  String get usernameWrongSizeError => 'O comprimento do seu nome de usuário deve estar entre 3 e 20 caracteres.';

  @override
  String get validationCode => 'Código de validação';

  @override
  String get validationCodeCorrect => 'Seu código de validação está correto!';

  @override
  String get verify => 'Verificar';

  @override
  String get wealthy => 'Rico';

  @override
  String get weight => 'Peso';

  @override
  String get weightIsNegativeError => 'O peso não pode ser negativo.';

  @override
  String get weightUnit => 'Unidade de peso';

  @override
  String weightWithQuantity(int quantity, String unit) {
    return 'Peso: $quantity $unit';
  }

  @override
  String get welcome => 'Bem-vindo ao ReallyStick';

  @override
  String get whatIsThis => 'O que é isso?';

  @override
  String get worker => 'Trabalhador';

  @override
  String writeTo(String user) {
    return 'Escreva para $user...';
  }

  @override
  String get writtenMessages => 'Mensagens escritas';

  @override
  String get yes => 'Sim';

  @override
  String get youAreNotAlone => 'Você não está sozinho. Converse, troque, cresça.';

  @override
  String get youAreNotTheCreatorOfThisChallenge => 'Você não é o criador deste desafio.';

  @override
  String get youBlockedThisUser => 'Você bloqueou este usuário.';
}
