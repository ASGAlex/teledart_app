// ignore_for_file: import_of_legacy_library_into_null_safe
part of application;

/// Token is needed for some operations like file downloading, but original class
/// save it to private variable, so we need this class only to make token accessible.
class TelegramEx extends Telegram {
  TelegramEx(String token)
      : _token = token,
        super(token);

  final String _token;

  String get token => _token;
}
