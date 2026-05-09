# Phase 5: Testing & Code Review

**Status:** ⏳ Pending  
**Priority:** P1  
**Estimated Duration:** 1-2 hours

## Context Links

- [Main Plan](plan.md)
- [Phase 4: Dashboard Integration](phase-04-dashboard-integration.md)
- [Project CLAUDE.md](../../CLAUDE.md)

## Overview

This phase focuses on ensuring code quality, functionality, and adherence to project standards. Activities include:

1. **Compilation & Analysis** - Verify no compile errors
2. **Widget & Unit Tests** - Test individual components
3. **Integration Tests** - Test feature flow
4. **Code Review** - Verify architecture and patterns
5. **Performance Testing** - Check responsiveness
6. **Manual Testing** - User experience validation

## Key Insights

- Build runner must be executed to generate MobX code
- Testing should follow project conventions
- Code review focuses on SOLID principles
- Performance critical for chat message rendering
- Mock data must be properly documented

## Requirements

### Functional Requirements

- FR1: All code compiles without errors
- FR2: MobX observables properly generated
- FR3: Chat UI renders correctly
- FR4: Messages display in chronological order
- FR5: Suggestion chips respond to taps
- FR6: Send button works and disables during send
- FR7: Mock data seamlessly integrates

### Non-Functional Requirements

- NFR1: Code analysis shows no issues
- NFR2: High code coverage for critical logic
- NFR3: Follows SOLID principles
- NFR4: Performance acceptable for 100+ messages
- NFR5: Error handling is comprehensive

## Architecture

### Test Structure

```
test/
├── presentation/
│   └── chat/
│       ├── store/
│       │   └── chat_store_test.dart
│       └── widgets/
│           ├── chat_bubble_test.dart
│           ├── suggestion_chips_test.dart
│           └── chat_input_field_test.dart
├── domain/
│   └── usecase/
│       └── chat/
│           ├── get_chat_messages_test.dart
│           └── send_chat_message_test.dart
└── integration/
    └── chat_flow_test.dart
```

## Related Code Files

### Files to Test

```
lib/presentation/chat/store/chat_store.dart
lib/presentation/chat/widgets/chat_bubble_widget.dart
lib/presentation/chat/widgets/suggestion_chips.dart
lib/presentation/chat/widgets/chat_input_field.dart
lib/presentation/chat/screens/chat_screen.dart

lib/domain/usecase/chat/get_chat_messages_usecase.dart
lib/domain/usecase/chat/send_chat_message_usecase.dart
lib/data/repository/chat_repository_impl.dart
```

## Implementation Steps

### Step 1: Build Runner & Code Generation

**Command:**
```bash
# Clean previous builds
flutter clean

# Run pub get
flutter pub get

# Generate MobX and JSON serializable code
flutter packages pub run build_runner build --delete-conflicting-outputs

# Watch mode for development
flutter packages pub run build_runner watch --delete-conflicting-outputs
```

**Verification:**
- Check `.g.dart` files are generated for stores
- No build errors in output
- Generated code compiles successfully

### Step 2: Compile & Analyze

**Commands:**
```bash
# Analyze code for issues
flutter analyze

# Check code format (optional)
dart format lib/presentation/chat lib/domain/usecase/chat lib/data/repository

# Compile to catch errors
flutter build appbundle --analyze-size  # Android
# or
flutter build ios --analyze-size  # iOS
```

**Expected Output:**
- No analyzer errors (only warnings acceptable)
- All files formatted consistently
- No undefined symbols or imports

### Step 3: Unit Tests - Chat Store

**File:** `test/presentation/chat/store/chat_store_test.dart`

Create comprehensive store tests:

```dart
void main() {
  late ChatStore chatStore;
  late GetChatMessagesUseCase getChatMessagesUseCase;
  late SendChatMessageUseCase sendChatMessageUseCase;
  late ErrorStore errorStore;
  late FormStore formStore;

  setUp(() {
    // Mock dependencies
    getChatMessagesUseCase = MockGetChatMessagesUseCase();
    sendChatMessageUseCase = MockSendChatMessageUseCase();
    errorStore = ErrorStore();
    formStore = FormStore();

    chatStore = ChatStore(
      getChatMessagesUseCase,
      sendChatMessageUseCase,
      errorStore,
      formStore,
    );
  });

  tearDown(() {
    chatStore.dispose();
  });

  group('ChatStore', () {
    test('fetchMessages updates messages list', () async {
      // Arrange
      chatStore.setConversation('test_conv');
      
      // Act
      await chatStore.fetchMessages();

      // Assert
      expect(chatStore.hasMessages, true);
      expect(chatStore.messages, isNotEmpty);
    });

    test('sendMessage clears input after success', () async {
      // Arrange
      chatStore.setConversation('test_conv');
      chatStore.messageInput = 'Test message';

      // Act
      await chatStore.sendMessage('Test message');

      // Assert
      expect(chatStore.messageInput, isEmpty);
    });

    test('isSending is true during message send', () async {
      // Arrange
      chatStore.setConversation('test_conv');

      // Act
      final future = chatStore.sendMessage('Test');
      expect(chatStore.isSending, true);

      await future;
      expect(chatStore.isSending, false);
    });

    test('canSendMessage is false with empty input', () {
      // Arrange
      chatStore.messageInput = '';

      // Assert
      expect(chatStore.canSendMessage, false);
    });

    test('clearMessages empties state', () {
      // Arrange
      chatStore.messageInput = 'test';

      // Act
      chatStore.clearMessages();

      // Assert
      expect(chatStore.messages, isEmpty);
      expect(chatStore.messageInput, isEmpty);
    });
  });
}
```

**Test Cases:**
- [ ] Fetch messages populates list
- [ ] Send message clears input
- [ ] Loading state updates correctly
- [ ] Error handling works
- [ ] Can send validation
- [ ] Conversation selection
- [ ] Message input updates

### Step 4: Widget Tests

**File:** `test/presentation/chat/widgets/chat_bubble_test.dart`

Test chat bubble rendering:

```dart
void main() {
  group('ChatBubbleWidget', () {
    testWidgets('renders user message on right', (WidgetTester tester) async {
      final message = ChatMessage(
        id: '1',
        conversationId: 'conv_1',
        sender: 'user',
        content: 'Hello',
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatBubbleWidget(
              message: message,
              isUser: true,
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
      expect(find.byType(Align), findsOneWidget);
    });

    testWidgets('renders assistant message on left', (WidgetTester tester) async {
      final message = ChatMessage(
        id: '1',
        conversationId: 'conv_1',
        sender: 'assistant',
        content: 'Hi there',
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatBubbleWidget(
              message: message,
              isUser: false,
            ),
          ),
        ),
      );

      expect(find.text('Hi there'), findsOneWidget);
    });

    testWidgets('displays timestamp', (WidgetTester tester) async {
      final now = DateTime.now();
      final message = ChatMessage(
        id: '1',
        conversationId: 'conv_1',
        sender: 'user',
        content: 'Test',
        timestamp: now,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatBubbleWidget(
              message: message,
              isUser: true,
            ),
          ),
        ),
      );

      final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
      expect(find.text(timeStr), findsOneWidget);
    });
  });
}
```

**Test Cases:**
- [ ] User message aligned right
- [ ] Assistant message aligned left
- [ ] Message content displays
- [ ] Timestamp formats correctly
- [ ] Proper colors applied

### Step 5: Integration Tests

**File:** `test/integration/chat_flow_test.dart`

Test complete chat flow:

```dart
void main() {
  group('Chat Flow Integration', () {
    testWidgets('User can send message', (WidgetTester tester) async {
      // Setup DI
      setupServiceLocator();

      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Navigate to chat (or open from FAB)
      await tester.tap(find.byIcon(Icons.assistant));
      await tester.pumpAndSettle();

      // Type message
      await tester.enterText(
        find.byType(TextField),
        'Test message',
      );
      await tester.pumpAndSettle();

      // Send message
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify message appears
      expect(find.text('Test message'), findsWidgets);
    });

    testWidgets('Suggestion chips work', (WidgetTester tester) async {
      setupServiceLocator();
      await tester.pumpWidget(MyApp());

      await tester.tap(find.byIcon(Icons.assistant));
      await tester.pumpAndSettle();

      // Tap suggestion
      await tester.tap(find.text('How to improve visibility?'));
      await tester.pumpAndSettle();

      // Verify input filled
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
```

### Step 6: Manual Testing Checklist

**Platform Testing:**

**Mobile (Android/iOS):**
- [ ] App launches without crashes
- [ ] Dashboard displays correctly
- [ ] Assistant FAB visible and clickable
- [ ] Chat window opens smoothly
- [ ] Messages display in correct order
- [ ] Suggestion chips are clickable
- [ ] Send button works
- [ ] Keyboard shows/hides correctly
- [ ] Close button works
- [ ] No memory leaks

**Web/Desktop:**
- [ ] Responsive layout on different sizes
- [ ] Mouse/keyboard interaction works
- [ ] Touch simulation works (web)
- [ ] Performance acceptable

**User Interactions:**
- [ ] Send empty message (should fail)
- [ ] Send very long message (100+ chars)
- [ ] Rapid message sending
- [ ] Switch between suggestion and typing
- [ ] Open/close chat multiple times
- [ ] Navigation away and back

### Step 7: Code Review Checklist

**Architecture:**
- [ ] Clean Architecture properly applied
- [ ] SOLID principles followed
- [ ] No circular dependencies
- [ ] Proper layer separation

**Code Quality:**
- [ ] Immutable entities used
- [ ] Null safety throughout
- [ ] Meaningful variable names
- [ ] DRY principle applied
- [ ] No hardcoded values (except config)

**Pattern Compliance:**
- [ ] MobX stores follow project pattern
- [ ] Repository pattern correctly implemented
- [ ] Use case base class extended
- [ ] DI registration complete

**Error Handling:**
- [ ] Try-catch where needed
- [ ] Either pattern used properly
- [ ] User-friendly error messages
- [ ] Graceful degradation

**Performance:**
- [ ] Lazy loading implemented
- [ ] Observables minimize rebuilds
- [ ] Message list pagination ready
- [ ] No unnecessary widget rebuilds

## Todo List

- [ ] Run `flutter clean && flutter pub get`
- [ ] Execute build runner: `build_runner build --delete-conflicting-outputs`
- [ ] Run `flutter analyze` and fix all issues
- [ ] Create unit tests for ChatStore
- [ ] Create widget tests for all components
- [ ] Create integration tests for chat flow
- [ ] Run all tests: `flutter test`
- [ ] Verify test coverage > 80%
- [ ] Manual testing on Android device/emulator
- [ ] Manual testing on iOS device/simulator
- [ ] Manual testing on web (if applicable)
- [ ] Performance testing with large message lists
- [ ] Accessibility testing (screen reader, font sizes)
- [ ] Code review with team lead
- [ ] Security review (no hardcoded data leaks)
- [ ] Fix any reported issues
- [ ] Final compile check
- [ ] Documentation update

## Success Criteria

- ✅ `flutter analyze` reports no errors
- ✅ All tests pass
- ✅ Test coverage ≥ 80% for critical logic
- ✅ No build warnings
- ✅ MobX code properly generated
- ✅ App runs on Android without crashes
- ✅ App runs on iOS without crashes
- ✅ App runs on web without crashes
- ✅ Manual testing all passed
- ✅ Code review approved
- ✅ Security review approved
- ✅ Performance acceptable

## Test Coverage Goals

```
Domain Layer:
├── Entities: 100% coverage
├── Repositories: 90%+ coverage
└── Use Cases: 90%+ coverage

Data Layer:
├── Mock Data Source: 100% coverage
├── Local Data Source: 80%+ coverage
└── Repository Impl: 90%+ coverage

Presentation Layer:
├── Store: 85%+ coverage
├── Widgets: 80%+ coverage
└── Screens: 70%+ coverage
```

## Performance Benchmarks

- Chat screen load time: < 500ms
- Message send round-trip: < 2s (with mock)
- List scroll FPS: > 50 fps
- Memory usage: < 50 MB baseline

## Known Issues & Mitigations

| Issue | Severity | Mitigation |
|-------|----------|-----------|
| MobX codegen slowness | Low | Use watch mode during dev |
| Test mocking complexity | Medium | Use mockito package |
| Performance with 1000+ messages | Medium | Implement pagination |
| Platform-specific bugs | Low | Test all platforms |

## Sign-Off Checklist

Before marking as complete:
- [ ] All phases completed
- [ ] All tests passing
- [ ] Code review approved
- [ ] No blockers or critical issues
- [ ] Ready for deployment

## Deployment Considerations

- ✅ Mock data flag clearly marked
- ✅ Easy to switch to real API
- ✅ No debug prints in release build
- ✅ Proper logging for production
- ✅ Analytics tracking ready

## Rollback Plan

If issues found in production:
1. Disable Assistant FAB via feature flag
2. Revert to previous version
3. Investigate root cause
4. Fix and test thoroughly
5. Deploy fix

## Next Steps

After completing Phase 5:
1. **Deployment** - Follow project deployment process
2. **Monitoring** - Set up crash reporting for chat feature
3. **Enhancement** - Plan for API integration
4. **User Feedback** - Collect feedback on UI/UX

---

**Phase 5 Status:** Ready for Testing  
**Last Updated:** 2026-05-09

## Quick Reference Commands

```bash
# Setup
flutter clean
flutter pub get

# Generate code
flutter packages pub run build_runner build --delete-conflicting-outputs

# Analyze
flutter analyze

# Test
flutter test
flutter test --coverage

# Run
flutter run
flutter run -d chrome  # Web
```
