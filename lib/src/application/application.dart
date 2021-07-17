library application;

import 'package:args/args.dart';
import 'package:meta/meta.dart';
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import 'package:teledart_app/src/application/message_deleter.dart';
import 'package:teledart_app/src/complex_command.dart';

part 'core_command.dart';
part 'middleware.dart';
part 'router.dart';
part 'telegram.dart';

/// Main App class. Should be subclassed to create custom application
///
/// Call [run] to init application flow
///
/// TODO: implement an alternative of long polling
abstract class TeledartApp {
  TeledartApp(String token) : telegram = TelegramEx(token);

  final TelegramEx telegram;

  /// List of commands to handle user's commands and actions like callback_query
  ///
  /// Use classes inherited from [Command] to create simple commands
  ///
  /// Use classes inherited from [ComplexCommand] to create commands with different
  /// behavior, depending on user-input parameters
  ///
  /// See https://core.telegram.org/bots/api#callbackquery
  List<CommandConstructor> get commands;

  /// List of middleware to handle raw [Update] object
  List<MiddlewareConstructor> get middleware;

  /// Catches all uncaught exceptions from custom commands and library itself
  void onError(Object exception, Update data, TelegramEx telegram);

  /// Main application flow
  ///
  /// Could be overridden to add custom initialisation cycle.
  @mustCallSuper
  void run() async {
    final polling = LongPolling(telegram);
    var stream = polling.onUpdate();

    final router = _Router(telegram);
    router.asyncErrorHandler = onError;
    for (var cmdBuilder in commands) {
      router.registerCommand(cmdBuilder);
    }
    print('${commands.length} commands registered.');

    for (var cmdBuilder in middleware) {
      router.registerMiddleware(cmdBuilder);
    }
    print('${middleware.length} middleware registered.');

    stream.listen((Update data) {
      try {
        router.dispatch(data);
      } catch (exception) {
        onError(exception, data, telegram);
      }
    });
    print('Listening for updates from Telegram...');
    await polling.start();
  }
}
