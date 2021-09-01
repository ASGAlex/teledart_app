import '../../teledart_app.dart';

/// Helper mixin to clean chat from temporary messages
mixin MessageDeleter {
  static final Map<int, Map<int, List<String>>> _messagesToDelete = {};

  /// Mark message to be deleted with next call of [deleteScheduledMessages]
  ///
  /// Sometimes we send some messages to notify about temporary progress or to make
  /// any choice. Sometimes it would be useful to delete such messages after operation
  /// is complete.
  ///
  /// Use [tag] to mark message for future filtering
  void scheduleMessageDelete(int chatId, int messageId, {String? tag}) {
    var chatMessages = _messagesToDelete[chatId];
    if (chatMessages == null) {
      _messagesToDelete[chatId] = {};
      chatMessages = _messagesToDelete[chatId];
    }
    if (chatMessages == null) {
      throw ArgumentError.value(chatMessages, 'Unexpected null');
    }

    var existingTags = chatMessages[messageId];
    if (existingTags == null) {
      chatMessages[messageId] = [];
      existingTags = chatMessages[messageId];
    }
    if (existingTags == null) {
      throw ArgumentError.value(existingTags, 'Unexpected null');
    }

    if (tag != null) {
      existingTags.add(tag);
    }
  }

  /// Delete messages, previously marked by [scheduleMessageDelete]
  ///
  /// Optionally could be filtered by [chatId] or by list of [tags] or both.
  int deleteScheduledMessages(TelegramEx telegram,
      {int? chatId, List<String>? tags}) {
    var found = 0;
    if (chatId == null && (tags == null || tags.isEmpty)) {
      _messagesToDelete.forEach((key, value) {
        found += value.entries.length;
      });
      _clearAll(telegram);
      return found;
    }

    var filteredMessages = <int, Map<int, List<String>>>{};
    if (chatId == null) {
      _messagesToDelete.forEach((key, value) {
        filteredMessages[key] = Map.from(value);
      });
    } else if (_messagesToDelete[chatId] != null) {
      filteredMessages[chatId] = Map.from(_messagesToDelete[chatId]!);
    }

    if (tags != null) {
      filteredMessages.forEach((chatId, messageItems) {
        messageItems.removeWhere((msgId, assignedTags) =>
            !assignedTags.any((element) => tags.contains(element)));
      });
    }

    filteredMessages.forEach((chatId, messageItems) {
      final store = _messagesToDelete[chatId];
      if (store == null) return;
      messageItems.forEach((messageId, tags) {
        store.remove(messageId);
        found++;
        telegram.deleteMessage(chatId, messageId).catchError((error) {
          print(error);
        });
      });
      if (store.isEmpty) {
        _messagesToDelete.remove(chatId);
      }
    });
    return found;
  }

  void _clearAll(TelegramEx telegram) {
    for (var chatMessages in _messagesToDelete.entries) {
      final chatId = chatMessages.key;
      for (var msgItem in chatMessages.value.entries) {
        telegram.deleteMessage(chatId, msgItem.key).catchError((error) {
          print(error);
        });
      }
    }
    _messagesToDelete.clear();
  }
}
