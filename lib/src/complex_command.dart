import 'package:args/args.dart';
import 'package:meta/meta.dart';
import 'package:teledart/model.dart';
import 'package:teledart/src/telegram/model.dart';

import 'application/application.dart';

typedef CmdAction = Function(Message message, TelegramEx telegram);

/// Special command type, allows to separate business logic into different functions
///
/// Suppose, you have sent a message to user and put three [InlineKeyboardButton] to make
/// choice. How would you handle user's click to every button?
/// 1. You can create separate command for each button.
/// 2. You can create one command and call it with different options depending on what
///    button has been clicked
/// The first solution fill generate a lot of boilerplate code. The second is more
/// preferable. This class just simplify creating commands with option, indicating
/// different actions.
///
/// In new class specify a number of functions, representing different actions. The type
/// of functions must be [CmdAction].
///
/// In [actionMap] specify list of action names and corresponding [CmdAction] functions
/// for each action.
///
/// Use [buildAction] to create command's string representation and pass it into
/// [InlineKeyboardButton] call, to the [callback_data] property.
///
/// As result, when user press a button, command instance will be created and [CmdAction]
/// function, corresponding to button's action, will be called. If no valid function
/// wil be found or action parameter will be omitted - [onNoAction] function
/// will be called.
///
/// There is no more need to reimplement [run] function, but you still can do it in some
/// specific cases. You also no more need to reimplement [getParser], unless you want to
/// add additional parameters to your's action.
///
/// Use [action] to determine current action, if you are not into [CmdAction] function.
///
/// Try to keep action names as short as possible due to Telegram limitation on
/// [callback_data] length: 1-64 bytes.
/// See https://core.telegram.org/bots/api#inlinekeyboardbutton
///
abstract class ComplexCommand extends Command {
  ComplexCommand();

  static const ACTION = 'act';

  factory ComplexCommand.withAction(CommandConstructor cmdBuilder, String act,
      AsyncErrorHandlerFunction? asyncErrorHandler,
      [Map<String, String>? args]) {
    args ??= {};
    args[ACTION] = act;
    return Command.withArguments(cmdBuilder, args, asyncErrorHandler)
        as ComplexCommand;
  }

  @override
  @mustCallSuper
  ArgParser getParser() {
    var parser = ArgParser();
    parser.addOption(ACTION);
    return parser;
  }

  Map<String, CmdAction> get actionMap;

  String get action {
    try {
      return arguments?[ACTION];
    } catch (_) {
      return '';
    }
  }

  late final Message message;
  late final TelegramEx telegram;

  @override
  @mustCallSuper
  void run(Message message, TelegramEx telegram) {
    try {
      this.message = message;
      this.telegram = telegram;
    } catch (e) {
      print(e);
    }

    final actionFunc = actionMap[action];
    if (actionFunc != null && actionFunc is Function) {
      catchAsyncError(actionFunc(message, telegram), additionalData: this);
    } else {
      onNoAction(message, telegram);
    }
  }

  /// Like 404 page in web
  void onNoAction(Message message, TelegramEx telegram);

  @mustCallSuper
  String buildAction(String actionName, [Map<String, String>? parameters]) {
    parameters ??= {};
    parameters[ACTION] = actionName;
    return buildCommandCall(parameters);
  }
}
