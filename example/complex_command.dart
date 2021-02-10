import 'package:args/args.dart';
import 'package:teledart/model.dart';
import 'package:teledart_app/teledart_app.dart';

class ExampleApp extends TeledartApp {
  ExampleApp(String token) : super(token);

  @override
  List<CommandConstructor> get commands => [() => ExampleComplexCommand()];

  @override
  List<MiddlewareConstructor> get middleware => [];

  @override
  void onError(Object exception, Update data, TelegramEx telegram) {
    print('Hello, Error!');
  }
}

class ExampleComplexCommand extends ComplexCommand {
  @override
  String get name => 'complex';

  @override
  ArgParser getParser() => super.getParser()..addOption('param1')..addOption('param2');

  @override
  Map<String, CmdAction> get actionMap => {
        'first': onFirstButton,
        'second': onSecondButton,
        'with-parameters': onButtonWithParameters,
      };

  @override
  void onNoAction(Message message, TelegramEx telegram) {
    telegram.sendMessage(message.chat.id, 'onNoAction function',
        reply_markup: InlineKeyboardMarkup(inline_keyboard: [
          [
            InlineKeyboardButton(
                text: 'onFirstButton call', callback_data: buildAction('first'))
          ],
          [
            InlineKeyboardButton(
                text: 'onSecondButton call', callback_data: buildAction('second'))
          ],
          [
            InlineKeyboardButton(
                text: 'onButtonWithParameters call',
                callback_data: buildAction(
                    'with-parameters', {'param1': 'value1', 'param2': 'value2'}))
          ],
        ]));
  }

  void onFirstButton(Message message, TelegramEx telegram) {
    telegram.sendMessage(message.chat.id, 'onFirstButton pressed!');
  }

  void onSecondButton(Message message, TelegramEx telegram) {
    telegram.sendMessage(message.chat.id, 'onSecondButton pressed!');
  }

  void onButtonWithParameters(Message message, TelegramEx telegram) {
    final txtParameters = 'param1: ' +
        arguments?['param1'] +
        '\r\n' +
        'param2: ' +
        arguments?['param2'] +
        '\r\n';
    telegram.sendMessage(
        message.chat.id,
        'onButtonWithParameters pressed!\r\n'
                'parameters are:\r\n' +
            txtParameters);
  }
}

void main() {
  final app = ExampleApp('bot key here');
  app.run();
}
