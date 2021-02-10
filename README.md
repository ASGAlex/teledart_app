# teledart_app
API written on top of teledart, aimed to simplify work with commands and callbacks

# Purpose

This API should be useful to build interactive bots to perform different actions depending on user input either command, plain text or button push

# Basic usage

1. Inherit new command inherited from `Command` class:
``` dart
class ExampleCommand extends Command {
  @override
  ArgParser? getParser() => null;

  @override
  String get name => 'example';

  @override
  void run(Message message, TelegramEx telegram) {
    telegram.sendMessage(message.chat.id, 'Hello, World!');
  }
}
```
2. Create application class, inherited from `TeledartApp` class:
```dart

class ExampleApp extends TeledartApp {
  ExampleApp(String token) : super(token);

  @override
  List<CommandConstructor> get commands => [];

  @override
  List<MiddlewareConstructor> get middleware => [];

  @override
  void onError(Object exception, Update data, TelegramEx telegram) {
    print('Hello, Error!');
  }
}
```
3. List your command in `commands` getter of application class:
```dart
  @override
  List<CommandConstructor> get commands => [() => ExampleCommand()];
```
4. Run application in `main` function. Don't forget to pass valid bot key into constructor.
```dart
void main() {
  final app = ExampleApp('bot key here');
  app.run();
}
```
5. Type command "/example" into chat with bot. And see "Hello, World!" as an answer.

See full working example at [simple_command.dart](example/simple_command.dart)

# Handling multiple actions in one command

Suppose, you have sent a message to user and put three `InlineKeyboardButton` to make choice. How would you handle user's click to every button?
 1. You can create separate command for each button.
 2. You can create one command and call it with different options depending on what button has been clicked

The first solution fill generate a lot of boilerplate code. The second is more preferable. This class just simplify creating commands with option, indicating different actions.

Create your's application class as in basic example. But create new command, extending `ComplexCommand` class instead of `Command`:

```dart

class ExampleComplexCommand extends ComplexCommand {
  @override
  String get name => 'complex';

  @override
  Map<String, CmdAction> get actionMap => {
        'first': onFirstButton,
        'second': onSecondButton
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
          ]
        ]));
  }

  void onFirstButton(Message message, TelegramEx telegram) {
    telegram.sendMessage(message.chat.id, 'onFirstButton pressed!');
  }

  void onSecondButton(Message message, TelegramEx telegram) {
    telegram.sendMessage(message.chat.id, 'onSecondButton pressed!');
  }
```

At `actionMap` we defined two actions: "first" and "second", and each refers to function wich will handle corresponding action. At `noAction` function we specified, what to do if no action passed, for example if only "/complex" command had been typed or passed through `callback_query`, withought additional parameters. 

Using `buildAction` we created string representation of our command with action specified. 

If different actions are not enouth, we could use additional parameters. First, we need to describe parameters using `getParser` getter of command class:

```dart
  @override
  ArgParser getParser() => super.getParser()..addOption('param1')..addOption('param2');
```
Then, we could create additional button, witch calls new action:
```dart
InlineKeyboardButton(
    text: 'onButtonWithParameters call',
    callback_data: buildAction('with-parameters', {
        'param1': 'value1', 
        'param2': 'value2'
    })
)
```
Define new action in `actionMap`:
```dart
'with-parameters': onButtonWithParameters,
```
And implement new action function: 
```dart

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
```
We can access custom parameters, using `arguments` variable. 

See full example at [complex_command.dart](example/complex_command.dart)

# Middleware

In case you need access raw `Update` object before any command will happen, use separate middleware class.

See working example at [middleware.dart](example/middleware.dart)

# Troubleshooting

Library was made using new null-safety functionality, but TeleDart and args packages does not use it. So `--no-sound-null-safety` VM option is needed to make this code work. 