# Phase 2: Data Layer - Mock Data Sources & Repository Implementation

**Status:** ⏳ Pending  
**Priority:** P0  
**Estimated Duration:** 1-2 hours

## Context Links

- [Main Plan](plan.md)
- [Phase 1: Domain Layer](phase-01-domain-layer.md)
- [Project CLAUDE.md](../../CLAUDE.md)

## Overview

The data layer is responsible for implementing the repository interfaces defined in the domain layer and managing data from various sources (mock, network, or local). This phase focuses on:

1. **Mock Data Source** - Hardcoded conversation data for testing
2. **Local Data Source** - Sembast database persistence (optional for MVP)
3. **Repository Implementation** - Concrete implementation of ChatRepository interface

This layer bridges domain logic with actual data retrieval mechanisms.

## Key Insights

- Mock data source provides immediate testability without backend
- Easy transition from mock to real API by changing one parameter
- Repository implementation handles Either/error mapping
- Local storage uses Sembast (project standard)
- Dependency injection happens at data layer registration

## Requirements

### Functional Requirements

- FR1: Create mock chat messages and conversations
- FR2: Implement repository with mock data support
- FR3: Support switching between mock and real data
- FR4: Handle empty conversations gracefully
- FR5: Generate realistic chat scenarios

### Non-Functional Requirements

- NFR1: Mock data is easily identifiable and replaceable
- NFR2: Error handling consistent with domain layer
- NFR3: Repository properly implements Either pattern
- NFR4: Follows project data layer conventions

## Architecture

### Data Layer Structure

```
lib/data/datasource/
├── local/
│   └── chat_local_datasource.dart      # Sembast persistence
└── remote/
    └── chat_mock_datasource.dart       # Mock data provider

lib/data/repository/
└── chat_repository_impl.dart           # Concrete implementation

lib/data/di/module/
└── chat_data_module.dart               # DI registration (optional)
```

### Mock Data Categories

1. **System Assistant Messages** - Pre-generated responses
2. **User Messages** - Sample user queries
3. **Sample Conversations** - Complete conversation threads
4. **Edge Cases** - Empty, long, special character messages

## Related Code Files

### Files to Create

```
lib/data/datasource/remote/chat_mock_datasource.dart
lib/data/datasource/local/chat_local_datasource.dart
lib/data/repository/chat_repository_impl.dart
lib/data/di/module/chat_data_module.dart  # If separate module
```

### Files to Modify

```
lib/data/di/module/repository_module.dart  # Register ChatRepositoryImpl
lib/di/service_locator.dart                # Add data module registration
```

## Implementation Steps

### Step 1: Create Chat Mock Data Source

**File:** `lib/data/datasource/remote/chat_mock_datasource.dart`

Create mock data provider with:

**Methods:**
- `Future<List<ChatMessage>> getMessages(String conversationId)` - Return mock messages
- `Future<ChatMessage> sendMessage(String conversationId, ChatMessage msg)` - Add to mock storage
- `Future<ChatConversation> getConversation(String conversationId)` - Return mock conversation
- `Future<ChatConversation> createConversation()` - Create new mock conversation

**Mock Data Samples:**

```dart
// Sample conversations
const SAMPLE_CONVERSATION_ID = 'conv_mock_001';
const SAMPLE_USER_ID = 'user_001';

// Mock messages structure
List<ChatMessage> mockMessages = [
  ChatMessage(
    id: 'msg_001',
    conversationId: SAMPLE_CONVERSATION_ID,
    sender: 'assistant',
    content: 'Hello! I\'m your AI Assistant. How can I help you optimize your brand visibility today?',
    timestamp: DateTime.now().subtract(Duration(minutes: 5)),
  ),
  ChatMessage(
    id: 'msg_002',
    conversationId: SAMPLE_CONVERSATION_ID,
    sender: 'user',
    content: 'What is Ask Engine Optimization?',
    timestamp: DateTime.now().subtract(Duration(minutes: 4)),
  ),
  ChatMessage(
    id: 'msg_003',
    conversationId: SAMPLE_CONVERSATION_ID,
    sender: 'assistant',
    content: 'Ask Engine Optimization (AEO) is the practice of optimizing your content...',
    timestamp: DateTime.now().subtract(Duration(minutes: 3)),
  ),
];

// Suggestion responses for mock data
Map<String, String> suggestionResponses = {
  'How to improve visibility?': 'To improve visibility in AI engines...',
  'What are AI engines?': 'AI engines like ChatGPT, Gemini, and Perplexity...',
  'Best practices': 'Here are the best practices for AEO...',
  'Technical SEO tips': 'Technical SEO is crucial for AEO...',
};
```

**Key Features:**
- In-memory storage of messages (Map or List)
- Realistic delays using Future with Duration
- Incremental ID generation for new messages
- Support for multiple conversations
- Clear comments marking mock data

### Step 2: Create Chat Local Data Source (Optional for MVP)

**File:** `lib/data/datasource/local/chat_local_datasource.dart`

Implement local persistence using Sembast:

**Methods:**
- `Future<List<ChatMessage>> getStoredMessages(String conversationId)`
- `Future<void> saveMessage(ChatMessage message)`
- `Future<void> saveConversation(ChatConversation conversation)`
- `Future<ChatConversation?> loadConversation(String id)`

**Implementation Notes:**
- Use SembastClient from project core
- Store messages under 'conversations' collection
- Support XXTEA encryption for sensitive data
- Handle database initialization properly

### Step 3: Create Chat Repository Implementation

**File:** `lib/data/repository/chat_repository_impl.dart`

Implement ChatRepository interface from domain:

```dart
class ChatRepositoryImpl implements ChatRepository {
  final ChatMockDataSource _mockDataSource;
  final ChatLocalDataSource _localDataSource;

  ChatRepositoryImpl(
    this._mockDataSource,
    this._localDataSource,
  );

  @override
  Future<Either<Exception, List<ChatMessage>>> getMessages(
    String conversationId,
    {bool useMockData = false}
  ) async {
    try {
      final source = useMockData ? _mockDataSource : _localDataSource;
      final messages = await source.getMessages(conversationId);
      return Right(messages);
    } catch (e) {
      return Left(Exception('Failed to fetch messages: $e'));
    }
  }

  @override
  Future<Either<Exception, ChatMessage>> sendMessage(
    String conversationId,
    ChatMessage message,
    {bool useMockData = false}
  ) async {
    try {
      final source = useMockData ? _mockDataSource : _localDataSource;
      final savedMessage = await source.sendMessage(conversationId, message);
      return Right(savedMessage);
    } catch (e) {
      return Left(Exception('Failed to send message: $e'));
    }
  }

  // Similar implementation for getConversation, createConversation
}
```

**Key Features:**
- Proper Either error mapping
- Datasource abstraction/switching
- Mock flag propagation
- Exception wrapping with context

### Step 4: Enhance Mock Data with Realistic Scenarios

**Add to mock datasource:**

1. **Multiple Conversations** - Different topics/sessions
2. **Message Variants** - Short, long, code snippets, lists
3. **Timestamp Realism** - Spread across days/hours
4. **Sender Variety** - Mix of user and assistant
5. **Error Scenarios** - Timeout simulation, empty results

**Example:**
```dart
// Realistic assistant responses
const assistantResponses = [
  'Here\'s what I found...',
  'Based on your query, I recommend...',
  'Let me break this down for you...',
  'I\'d suggest focusing on...',
  'Consider these options...',
];
```

### Step 5: Create Data DI Module (If Separate)

**File:** `lib/data/di/module/chat_data_module.dart` (Optional)

```dart
class ChatDataModule {
  static void register() {
    // Register data sources
    getIt.registerSingleton<ChatMockDataSource>(
      ChatMockDataSource(),
    );
    
    getIt.registerSingleton<ChatLocalDataSource>(
      ChatLocalDataSource(
        sembastClient: getIt<SembastClient>(),
      ),
    );

    // Register repository
    getIt.registerSingleton<ChatRepository>(
      ChatRepositoryImpl(
        getIt<ChatMockDataSource>(),
        getIt<ChatLocalDataSource>(),
      ),
    );
  }
}
```

Or update `repository_module.dart` directly if using existing module.

### Step 6: Register in service_locator

**File:** `lib/di/service_locator.dart`

Update the setupServiceLocator function:

```dart
Future<void> setupServiceLocator() async {
  // ... existing code ...
  
  // Data Layer
  _dataLayerSetup();
  
  // Domain Layer
  _domainLayerSetup();
  
  // Presentation Layer
  _presentationLayerSetup();
}

void _dataLayerSetup() {
  // Register chat data sources and repository
  ChatDataModule.register();
  // or directly:
  getIt.registerSingleton<ChatRepository>(
    ChatRepositoryImpl(/* deps */),
  );
}
```

## Todo List

- [ ] Create `lib/data/datasource/remote/` directory
- [ ] Implement `ChatMockDataSource` with sample data
- [ ] Create realistic mock conversation scenarios (5+ messages)
- [ ] Create `lib/data/datasource/local/` directory
- [ ] Implement `ChatLocalDataSource` (or skip for MVP)
- [ ] Create `lib/data/repository/` directory
- [ ] Implement `ChatRepositoryImpl` with proper Either handling
- [ ] Add mock/real datasource switching logic
- [ ] Create data DI module or update repository_module
- [ ] Register in service_locator.dart
- [ ] Test repository with mock data flag
- [ ] Verify error handling paths
- [ ] Run `flutter analyze` and fix issues
- [ ] Document mock data replacement guide

## Success Criteria

- ✅ Mock data sources provide realistic conversations
- ✅ Repository properly implements ChatRepository interface
- ✅ Either pattern correctly used for error handling
- ✅ DI registration complete and functional
- ✅ Can switch between mock and local data
- ✅ All exceptions properly caught and wrapped
- ✅ No compile errors
- ✅ Mock data easily identifiable for replacement
- ✅ Timestamps realistic and varied

## Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|-----------|
| Either type not imported | Low | Import from package (use dartz or custom) |
| Mock data too simplistic | Low | Add variety in messages, timestamps, lengths |
| Datasource switching logic error | Medium | Test both mock and local paths |
| Memory leaks in mock storage | Low | Use proper cleanup in dispose methods |

## Security Considerations

- ✅ Mock data clearly labeled (not to be deployed)
- ✅ No real sensitive data in mock messages
- ✅ Local datasource supports encryption
- ✅ Error messages sanitized

## Migration Guide: Mock to Real

To replace mock data with real API:

1. Create `ChatNetworkDataSource` implementing same interface
2. Update `ChatRepositoryImpl` to accept `ChatNetworkDataSource`
3. Modify datasource selection logic: `useMockData` → `useNetworkData`
4. Update DI registration to use network source
5. Add API client setup in network module

## Next Steps

After completing Phase 2:
1. Move to [Phase 3: Presentation Layer](phase-03-presentation-layer.md)
2. Create MobX stores for state management
3. Build UI widgets and screens
4. Integrate with dashboard

---

**Phase 2 Status:** Ready for Implementation  
**Last Updated:** 2026-05-09
