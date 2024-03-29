// ignore_for_file: invalid_use_of_protected_member
import 'package:args/args.dart';
import 'package:teledart/src/telegram/model.dart';
import 'package:teledart_app/src/application/application.dart';
import 'package:teledart_app/src/complex_command.dart';
import 'package:test/test.dart';

class TestCommand extends Command {
  @override
  ArgParser? getParser() {
    var parser = ArgParser();
    parser.addOption('opt1');
    parser.addOption('opt2');
    return parser;
  }

  @override
  String get name => 'test';

  @override
  void run(Message message, TelegramEx telegram) {}
}

class TestActionCommand extends ComplexCommand {
  @override
  Map<String, CmdAction> get actionMap => {'testAction': onTestAction};

  void onTestAction(Message message, TelegramEx telegram) {}

  @override
  String get name => 'testAction';

  @override
  ArgParser getParser() {
    return super.getParser()
      ..addOption('opt1')
      ..addOption('opt2');
  }

  @override
  void onNoAction(Message message, TelegramEx telegram) {}
}

void main() {
  test('Arguments Factory test', () {
    final cmd = Command.withArguments(
        () => TestCommand(),
        {'opt1': 'option_1_Data', 'opt2': 'option_2_Data'},
        (exception, _, __) => print('async exception:' + exception.toString()));
    expect(cmd.arguments?['opt1'], 'option_1_Data');
    expect(cmd.arguments?['opt2'], 'option_2_Data');
  });

  test('Action Command Arguments Factory test', () {
    final cmd = ComplexCommand.withAction(
        () => TestActionCommand(),
        'testAction',
        (exception, _, __) => print('async exception:' + exception.toString()),
        {'opt1': 'option_1_Data', 'opt2': 'option_2_Data'});

    expect(cmd.arguments?[ComplexCommand.ACTION], 'testAction');
    expect(cmd.arguments?['opt1'], 'option_1_Data');
    expect(cmd.arguments?['opt2'], 'option_2_Data');
  });
}
