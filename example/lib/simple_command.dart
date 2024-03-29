import 'package:args/args.dart';
import 'package:teledart/model.dart';
import 'package:teledart_app/teledart_app.dart';

class ExampleApp extends TeledartApp {
  ExampleApp(String token) : super(token);

  @override
  List<CommandConstructor> get commands => [() => ExampleCommand()];

  @override
  List<MiddlewareConstructor> get middleware => [];

  @override
  void onError(Object exception, dynamic trace, dynamic data) {
    print('Hello, Error!');
  }
}

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

void main() {
  final app = ExampleApp('bot key here');
  app.run();
}
