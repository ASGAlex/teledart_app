// ignore_for_file: invalid_use_of_protected_member
import 'package:teledart_app/teledart_app.dart';
import 'package:test/test.dart';

class TestDeleter with MessageDeleter {}

void main() {
  final tg = TelegramEx('token');

  test('Simple delete all scheduled messages', () {
    final deleter = TestDeleter();

    deleter.scheduleMessageDelete(0, 0);
    deleter.scheduleMessageDelete(0, 1);
    deleter.scheduleMessageDelete(1, 2);
    deleter.scheduleMessageDelete(1, 3);
    final found = deleter.deleteScheduledMessages(tg);
    expect(found, 4);
  });

  test('Delete scheduled messages by chatId', () {
    final deleter = TestDeleter();

    deleter.scheduleMessageDelete(0, 0);
    deleter.scheduleMessageDelete(0, 1);
    deleter.scheduleMessageDelete(1, 2);
    deleter.scheduleMessageDelete(1, 3);
    final found = deleter.deleteScheduledMessages(tg, chatId: 1);
    expect(found, 2);
  });

  test('Delete scheduled messages by chatId and tag', () {
    final deleter = TestDeleter();

    deleter.scheduleMessageDelete(0, -1, tag: 'special');
    deleter.scheduleMessageDelete(0, 0);
    deleter.scheduleMessageDelete(0, 1);
    deleter.scheduleMessageDelete(1, 2);
    deleter.scheduleMessageDelete(1, 3);
    deleter.scheduleMessageDelete(1, 4, tag: 'special');
    deleter.scheduleMessageDelete(1, 5, tag: 'special');
    deleter.scheduleMessageDelete(2, 6, tag: 'non special');
    deleter.scheduleMessageDelete(2, 7);
    deleter.scheduleMessageDelete(3, 8, tag: 'non special');
    final found = deleter.deleteScheduledMessages(tg,
        chatId: 1, tags: ['special', 'non special']);
    expect(found, 2);
  });

  test('Delete scheduled messages by tag from different chats', () {
    final deleter = TestDeleter();

    deleter.scheduleMessageDelete(0, -1, tag: 'special');
    deleter.scheduleMessageDelete(0, 0);
    deleter.scheduleMessageDelete(0, 1);
    deleter.scheduleMessageDelete(1, 2);
    deleter.scheduleMessageDelete(1, 3);
    deleter.scheduleMessageDelete(1, 4, tag: 'special');
    deleter.scheduleMessageDelete(1, 5, tag: 'special');
    deleter.scheduleMessageDelete(2, 6, tag: 'non special');
    deleter.scheduleMessageDelete(2, 7);
    deleter.scheduleMessageDelete(3, 8, tag: 'non special');
    final found = deleter.deleteScheduledMessages(tg, tags: ['special']);
    expect(found, 3);
  });

  test('Delete scheduled messages by multiple tags from different chats', () {
    final deleter = TestDeleter();

    deleter.scheduleMessageDelete(0, -1, tag: 'special');
    deleter.scheduleMessageDelete(0, 0);
    deleter.scheduleMessageDelete(0, 1);
    deleter.scheduleMessageDelete(1, 2);
    deleter.scheduleMessageDelete(1, 3);
    deleter.scheduleMessageDelete(1, 4, tag: 'special');
    deleter.scheduleMessageDelete(1, 5, tag: 'special');
    deleter.scheduleMessageDelete(2, 6, tag: 'non special');
    deleter.scheduleMessageDelete(2, 7);
    deleter.scheduleMessageDelete(3, 8, tag: 'non special');
    final found =
        deleter.deleteScheduledMessages(tg, tags: ['special', 'non special']);
    expect(found, 5);
  });
}
