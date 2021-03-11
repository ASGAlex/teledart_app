import '../../teledart_app.dart';

/// Helper mixin to clean chat from temporary messages
mixin MessageDeleter {
  static final Map<int, List> _messagesToDelete = {};

  /// Mark message to be deleted with next call of [deleteScheduledMessages]
  ///
  /// Sometimes we send some messages to notify about temporary progress or to make
  /// any choice. Sometimes it would be useful to delete such messages after operation
  /// is complete.
  static void scheduleMessageDelete(int chatId, int messageId) {
    if (_messagesToDelete[chatId] == null) {
      _messagesToDelete[chatId] = [];
    }
    _messagesToDelete[chatId]?.add(messageId);
  }

  /// Delete messages, previously marked by [scheduleMessageDelete]
  static void deleteScheduledMessages(TelegramEx telegram) {
    for (var msg in _messagesToDelete.entries) {
      for (var message_id in msg.value) {
        telegram.deleteMessage(msg.key, message_id).catchError((error) {
          print(error);
        });
      }
    }
    _messagesToDelete.clear();
  }
}
