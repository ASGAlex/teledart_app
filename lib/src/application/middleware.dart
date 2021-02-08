part of application;

typedef MiddlewareConstructor = Middleware Function();

/// Should be applied to every class witch intended to be used as middleware
///
/// A new class instance will be created on every [Update] receive.
/// [isCallbackQuery] helps to distinguish [callback_query] message from direct user input
/// [isCmd] indicates, if user message is a command?
mixin Middleware {
  void handle(Update data, TelegramEx telegram);

  bool isCallbackQuery = false;
  bool isCmd = false;
}
