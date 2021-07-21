part of application;

class _Router with AsyncErrorHandler {
  _Router(TelegramEx telegram) : _telegram = telegram;
  final TelegramEx _telegram;
  final Map<String, CommandConstructor> _commands = {};
  final List<MiddlewareConstructor> _middleware = [];

  void registerCommand(CommandConstructor commandConstructor) {
    final cmd = commandConstructor();
    _commands[cmd.name] = commandConstructor;
  }

  void registerMiddleware(MiddlewareConstructor commandConstructor) {
    _middleware.add(commandConstructor);
  }

  Command? _buildCommand(String name) {
    var builder = _commands[name];
    if (builder == null) return null;
    final cmd = builder();
    cmd.asyncErrorHandler ??= asyncErrorHandler;
    return cmd;
  }

  void dispatch(Update data) {
    final commandName = _discoverCommandName(data);
    for (var builder in _middleware) {
      final cmd = builder();
      cmd.isCallbackQuery = data.callback_query != null;
      cmd.isCmd = commandName.isNotEmpty;
      cmd.handle(data, _telegram);
    }

    var message = data.message ?? data.callback_query?.message;
    if (message == null) return;

    Command? cmd;
    cmd = _CommandStorage().popSavedInstance(message.chat.id);

    if (cmd != null) {
      cmd.runWithErrorHandler(message, _telegram, additionalData: data);
    } else {
      cmd = _buildCommand(commandName);
      if (cmd != null) {
        if (!(data.callback_query == null && cmd.system)) {
          // FIXME: dirty hack?
          if (data.callback_query?.from != null) {
            message.from = data.callback_query?.from;
          }
          if (data.callback_query != null) {
            final strData = data.callback_query?.data;
            if (strData != null) {
              var arguments = strData.split(' ');
              final parser = cmd.getParser();
              cmd.arguments = parser?.parse(arguments);
            }
          }
          cmd.runWithErrorHandler(message, _telegram, additionalData: data);
          return;
        }
      }
    }
  }

  String _discoverCommandName(Update data) {
    var commandEntity = data.message?.entityOf('bot_command');
    var command = '';
    final query = data.callback_query;
    if (commandEntity == null && query != null) {
      final queryData = query.data;
      if (queryData != null) {
        command = queryData.split(' ').first.replaceFirst('/', '');
      }
    } else if (commandEntity != null) {
      final dataMessageText = data.message?.text;
      if (dataMessageText != null) {
        command = dataMessageText.split('@').first.replaceFirst('/', '');
      }
    }
    return command;
  }
}
