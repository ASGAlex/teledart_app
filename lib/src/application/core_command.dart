// ignore_for_file: import_of_legacy_library_into_null_safe
part of application;

typedef CommandConstructor = Command Function();

/// Base class for telegram command handler
///
/// Use to implement handler for some telegram command like "/start" and so on.
/// Each command in application is treated as linux cli command. It means that each
/// command can have number of options. For example, "/start" could be called with
/// additional arguments like "/start --arg1=value1 --arg2=value2" and so on.
///
/// This mechanics will work either when user send command into chat explicitly as text
/// message and when command is extracted from callback_query, when user push any
/// inline button
///
/// To make command to handle [InlineKeyboardButton] action, pass command string in format
/// "/start --arg1=value1 --arg2=value2" to the [callback_data] parameter
/// of [InlineKeyboardButton] constructor.
/// See https://core.telegram.org/bots/api#inlinekeyboardbutton
/// Keep in mind that [callback_data] is limited to 1-64 bytes, so don't make your's
/// commands string representations too long!
///
/// To declare list of arguments which can be processed, implement [getParser].
/// See https://pub.dev/packages/args for details
///
/// To get string representation of command use [buildCommandCall] method. It also allows
/// to pass arguments you need.
///
/// To create new command instance with arguments, use [Command.withArguments]
/// constructor. Usually you needn't that, application will create all commands for you
/// automatically
///
/// [run] function should implement business logic of application: process user input,
/// send next messages, create inline buttons and so on.
///
/// Each command instance is created before processing user's request. New command call
/// will create new instance. If you want to keep one instance between command calls,
/// use []
///
/// Functions [scheduleMessageDelete] and [deleteScheduledMessages] should be useful
/// to control message flow.
///
abstract class Command with MessageDeleter {
  Command();

  /// Build command with arguments
  ///
  /// [args] can contain arguments, only supported by [getParser].
  /// If [getParser] return null, new command instance will have null [arguments]
  ///
  /// Throws [ArgParserException]
  factory Command.withArguments(
      CommandConstructor cmdBuilder, Map<String, String> args) {
    final cmd = cmdBuilder();
    final parser = cmd.getParser();
    if (parser != null) {
      final cmdForParse =
          ('/${cmd.name} ' + _buildCommandArgs(args)).split(' ');
      cmd.arguments = parser.parse(cmdForParse);
    }
    return cmd;
  }

  /// "Copy constructor" allows to clone arguments from existing command to new one
  factory Command.withArgumentsFrom(
      CommandConstructor cmdBuilder, Command other) {
    final cmd = cmdBuilder();
    cmd.arguments = other.arguments;
    return cmd;
  }

  @override
  String toString() {
    var str = '/$name';
    var options = arguments?.options;
    if (options != null) {
      for (var optName in options) {
        str += ' --$optName ' + arguments?[optName];
      }
    }
    return str;
  }

  /// Additional options for command
  ///
  /// Useful if you command's behavior should be different depending on some circumstances.
  /// Usually you don't need to populate this class yourself, at worst you will just copy
  /// it from already populated instance.
  /// Variable usually filled automatically using [Command.withArguments] and [getParser]
  @protected
  ArgResults? arguments;

  /// Reset all arguments
  void reset() {
    arguments = null;
  }

  /// Configured parser instance to parse [arguments] from string
  ArgParser? getParser();

  /// The name of command
  ///
  /// The name should be specified without slash, for example the name of "/start" command
  /// should be "start".
  String get name;

  /// Should be command called by user directly, or it is only for internal use?
  ///
  /// Each command could be used in 2 ways:
  /// 1. To handle command, explicitly sent by user to the chat
  /// 2. To handle command, parsed from callback_query, for example when user pushes
  /// any button.
  ///
  /// In first case [system] should be true, and library will run it, if it would be
  /// explicitly written to chat.
  /// In second case [system] should be false. Thus command would be handled normally when
  /// parsed from callback_query, but will be ignored when user send it to chat
  /// as text message
  bool get system => false;

  /// Main function for your business logic
  dynamic run(Message message, TelegramEx telegram);

  /// Builds string representation of command call
  @mustCallSuper
  String buildCommandCall([Map<String, String> parameters = const {}]) =>
      '/$name ' + _buildCommandArgs(parameters);

  static String _buildCommandArgs(Map<String, String> parameters) {
    var command = '';
    parameters.forEach((key, value) {
      if (key.contains(' ')) throw 'Invalid command key!';
      command += ' --' + key + ' ' + value;
    });
    return command;
  }

  /// Preserve command instance till next message in specified chat.
  ///
  /// When user will send next message in specified chat, would it be another command
  /// or simple text or anything else, the preserved command will intercept this user
  /// action and handle it instead of any other commands. Also the instance will be
  /// automatically deleted from array of preserved commands. So if you need to intercept
  /// more than one message, call this function again and again.
  @protected
  void callMeOnNextMessage(int chatId) {
    _CommandStorage().saveInstanceForNextMessage(chatId, this);
  }
}

class _CommandStorage {
  static final _controller = _CommandStorage._instance();

  factory _CommandStorage() => _controller;

  _CommandStorage._instance();

  final Map<int, Command> _scheduledCommands = {};

  void saveInstanceForNextMessage(int chatId, Command cmd) {
    _scheduledCommands[chatId] = cmd;
  }

  Command? popSavedInstance(int chatId) => _scheduledCommands.remove(chatId);
}

enum MarkdownV2EntityType { pre, code, textLink, none }

extension MarkdownV2 on String {
  String escapeMarkdownV2(
      [MarkdownV2EntityType type = MarkdownV2EntityType.none]) {
    String whatToEscape;
    if ([MarkdownV2EntityType.code, MarkdownV2EntityType.pre].contains(type)) {
      whatToEscape = '\\`';
    } else if (type == MarkdownV2EntityType.textLink) {
      whatToEscape = '\\';
    } else {
      whatToEscape = '_*[]()`>#+-=|{}.!';
    }
    var escapedString = this;
    for (var i = 0; i < whatToEscape.length; i++) {
      escapedString =
          escapedString.replaceAll(whatToEscape[i], '\\${whatToEscape[i]}');
    }
    return escapedString;
  }
}
