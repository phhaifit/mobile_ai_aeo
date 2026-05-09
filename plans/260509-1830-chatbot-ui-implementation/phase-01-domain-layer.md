# Phase 1: Domain Layer - Entities, Repositories, Use Cases

**Status:** ⏳ Pending  
**Priority:** P0  
**Estimated Duration:** 1-2 hours

## Context Links

- [Main Plan](plan.md)
- [Architecture Overview](plan.md#architecture-overview)
- [Project CLAUDE.md](../../CLAUDE.md)

## Overview

The domain layer is the core business logic layer that is independent of any framework or platform. This phase focuses on creating:

1. **Chat Message Entity** - Immutable data structure for individual messages
2. **Chat Conversation Entity** - Immutable structure for conversations
3. **Chat Repository Interface** - Abstract repository definition
4. **Use Cases** - Business logic for getting messages and sending messages

This layer contains NO Flutter imports and serves as the foundation for all other layers.

## Key Insights

- Domain layer must be Flutter-agnostic (pure Dart)
- Entities should be immutable for predictable state management
- Repository interfaces define the contract for data sources
- Use cases encapsulate single business operations
- All domain entities extend from base classes in core/

## Requirements

### Functional Requirements

- FR1: Define chat message structure with sender, content, timestamp
- FR2: Create conversation tracking structure
- FR3: Define repository contract for CRUD operations
- FR4: Create use cases for fetching and sending messages
- FR5: Support mock data parameters in use cases

### Non-Functional Requirements

- NFR1: All classes follow immutable patterns (const constructors, final fields)
- NFR2: No Flutter dependencies in domain layer
- NFR3: Proper null safety across all code
- NFR4: Follows project naming conventions and structure

## Architecture

### Entity Hierarchy

```
lib/domain/entity/
├── chat/
│   ├── chat_message.dart      # Single message
│   └── chat_conversation.dart # Conversation model
```

### Repository & UseCase Pattern

```
lib/domain/repository/
└── chat/
    └── chat_repository.dart   # Abstract interface

lib/domain/usecase/
└── chat/
    ├── get_chat_messages_usecase.dart
    └── send_chat_message_usecase.dart
```

### DI Registration

```
lib/domain/di/module/
└── usecase_module.dart        # Register ChatUseCases
```

## Related Code Files

### Files to Create

```
lib/domain/entity/chat/chat_message.dart
lib/domain/entity/chat/chat_conversation.dart
lib/domain/repository/chat/chat_repository.dart
lib/domain/usecase/chat/get_chat_messages_usecase.dart
lib/domain/usecase/chat/send_chat_message_usecase.dart
lib/domain/di/module/chat_usecase_module.dart  # If separate module
```

### Files to Modify

```
lib/domain/di/module/usecase_module.dart       # Register new use cases
```

## Implementation Steps

### Step 1: Create Chat Message Entity

**File:** `lib/domain/entity/chat/chat_message.dart`

Create an immutable entity representing a single chat message with:
- `id`: Unique identifier (String)
- `conversationId`: Reference to parent conversation (String)
- `sender`: Who sent it - 'user' or 'assistant' (String)
- `content`: Message text (String)
- `timestamp`: Creation time (DateTime)
- `metadata`: Optional additional data (Map<String, dynamic>?)

Requirements:
- Use `const` constructor for immutability
- Include `copyWith` method for state updates
- Override `toString()` for debugging
- Use `List.generate()` pattern if needed for equality checks

### Step 2: Create Chat Conversation Entity

**File:** `lib/domain/entity/chat/chat_conversation.dart`

Create an immutable entity for conversations with:
- `id`: Unique conversation ID (String)
- `title`: Conversation title/summary (String)
- `messages`: List of messages (List<ChatMessage>)
- `createdAt`: Creation timestamp (DateTime)
- `updatedAt`: Last update timestamp (DateTime)
- `isActive`: Conversation status (bool)

Requirements:
- Similar immutable pattern as ChatMessage
- Include `copyWith` for updates
- Support empty conversation initialization

### Step 3: Create Chat Repository Interface

**File:** `lib/domain/repository/chat/chat_repository.dart`

Define abstract repository with methods:

```dart
abstract class ChatRepository {
  // Fetch existing messages
  Future<Either<Exception, List<ChatMessage>>> getMessages(
    String conversationId,
    {bool useMockData = false}
  );
  
  // Send new message
  Future<Either<Exception, ChatMessage>> sendMessage(
    String conversationId,
    ChatMessage message,
    {bool useMockData = false}
  );
  
  // Get conversation
  Future<Either<Exception, ChatConversation>> getConversation(
    String conversationId,
    {bool useMockData = false}
  );
  
  // Create new conversation
  Future<Either<Exception, ChatConversation>> createConversation(
    {bool useMockData = false}
  );
}
```

Use `Either<Exception, T>` pattern for error handling (from package:dartz or similar).

### Step 4: Create Get Chat Messages Use Case

**File:** `lib/domain/usecase/chat/get_chat_messages_usecase.dart`

Extend `UseCase<List<ChatMessage>, GetChatMessagesParams>` with:
- Parameter class containing conversationId and useMockData flag
- Business logic: validate params, call repository
- Error handling through Either pattern
- Supports both real and mock data

### Step 5: Create Send Chat Message Use Case

**File:** `lib/domain/usecase/chat/send_chat_message_usecase.dart`

Extend `UseCase<ChatMessage, SendChatMessageParams>` with:
- Parameter class: conversationId, message content, sender
- Generates message with timestamp
- Calls repository to persist/send
- Returns created message or error

### Step 6: Register Use Cases in DI

**File:** `lib/domain/di/module/usecase_module.dart`

Update or create module to register:
- `GetChatMessagesUseCase`
- `SendChatMessageUseCase`

Pattern:
```dart
class UseCaseModule {
  static void register() {
    final chatRepository = getIt<ChatRepository>();
    
    getIt.registerSingleton<GetChatMessagesUseCase>(
      GetChatMessagesUseCase(chatRepository),
    );
    getIt.registerSingleton<SendChatMessageUseCase>(
      SendChatMessageUseCase(chatRepository),
    );
  }
}
```

## Todo List

- [ ] Create `lib/domain/entity/chat/` directory
- [ ] Implement `ChatMessage` entity (immutable, const constructor)
- [ ] Implement `ChatConversation` entity
- [ ] Create `lib/domain/repository/chat/` directory
- [ ] Define `ChatRepository` abstract interface
- [ ] Create `lib/domain/usecase/chat/` directory
- [ ] Implement `GetChatMessagesUseCase` with proper error handling
- [ ] Implement `SendChatMessageUseCase` with message creation logic
- [ ] Create/Update usecase module for DI registration
- [ ] Add use cases to service_locator.dart
- [ ] Verify no Flutter imports in domain layer
- [ ] Run `flutter analyze` to check for errors
- [ ] Create comprehensive documentation

## Success Criteria

- ✅ All entities compile without errors
- ✅ Repository interface properly abstracted
- ✅ Both use cases follow UseCase base pattern
- ✅ DI registration complete and functional
- ✅ No Flutter imports in domain layer
- ✅ Code passes `flutter analyze`
- ✅ All classes follow immutable patterns
- ✅ Error handling via Either pattern
- ✅ Mock data flag properly propagated

## Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|-----------|
| Missing Either import | Low | Use `package:dartz` or create custom Either |
| Null safety violations | Medium | Use proper null checks, final fields |
| Circular imports | Low | Keep domain isolated, no platform imports |
| UseCase base class mismatch | Low | Reference existing LoginUseCase pattern |

## Security Considerations

- ✅ All inputs validated in use cases
- ✅ No sensitive data hardcoded
- ✅ Repository abstraction prevents data layer leaks
- ✅ Error messages don't expose implementation details

## Next Steps

After completing Phase 1:
1. Move to [Phase 2: Data Layer](phase-02-data-layer.md)
2. Implement mock data sources
3. Create repository implementations
4. Register data layer in service_locator

---

**Phase 1 Status:** Ready for Implementation  
**Last Updated:** 2026-05-09
