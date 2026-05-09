# Phase 4: Dashboard Integration & Navigation

**Status:** ⏳ Pending  
**Priority:** P1  
**Estimated Duration:** 1 hour

## Context Links

- [Main Plan](plan.md)
- [Phase 3: Presentation Layer](phase-03-presentation-layer.md)
- [Project CLAUDE.md](../../CLAUDE.md)

## Overview

This phase focuses on integrating the chat UI with the existing dashboard screen. The goal is to:

1. Add "Assistant" floating action button (FAB) to dashboard
2. Implement chat bubble window overlay modal
3. Handle navigation and state management
4. Ensure smooth user experience

## Key Insights

- FAB positioned in bottom-right corner of dashboard
- Chat window opens as modal dialog (not screen navigation)
- Assistant button appears on all dashboard sections
- State persists when opening/closing chat window
- Use existing MaterialApp navigation setup

## Requirements

### Functional Requirements

- FR1: Assistant FAB visible on dashboard
- FR2: Clicking FAB opens chat bubble window
- FR3: Chat window can be closed
- FR4: Messages persist across open/close cycles
- FR5: FAB state reflects if chat is open
- FR6: Proper back button behavior in modal

### Non-Functional Requirements

- NFR1: Smooth animations on FAB and modal
- NFR2: No layout shifts when opening chat
- NFR3: Accessible for screen readers
- NFR4: Works on all supported platforms

## Architecture

### Navigation Structure

```
Dashboard
├── Scaffold with FAB
│   ├── AppBar
│   ├── Body (various navigation options)
│   └── FloatingActionButton (Assistant)
│       ↓ (onPressed)
│       ChatBubbleWindow (Modal Dialog)
│           ├── Header
│           ├── Chat UI
│           └── Close Button
```

### State Management

```
DashboardScreen
├── _isAssistantOpen: bool (local state)
└── _showChatWindow() (callback)

ChatBubbleWindow
├── onClose callback
└── Calls Navigator.pop()
```

## Related Code Files

### Files to Modify

```
lib/presentation/dashboard/dashboard.dart    # Add FAB
lib/utils/routes/routes.dart                 # Add chat route (if needed)
```

### Files to Reference

```
lib/presentation/chat/chat.dart              # Imported widgets/screens
lib/presentation/chat/store/chat_store.dart  # State management
```

## Implementation Steps

### Step 1: Understand Current Dashboard Structure

**File:** `lib/presentation/dashboard/dashboard.dart`

Review the existing dashboard:
- Analyze current Scaffold structure
- Identify where to add FAB
- Check for existing FAB implementations
- Note navigation pattern for screens

### Step 2: Add Assistant FAB to Dashboard

**File:** `lib/presentation/dashboard/dashboard.dart`

Modify `_DashboardScreenState` to add FAB:

```dart
class _DashboardScreenState extends State<DashboardScreen> {
  bool _isChatOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigation'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        // ... existing body ...
      ),
      // ... existing FAB for other features (if any) ...
      
      // Add Chat Assistant FAB
      floatingActionButton: FloatingActionButton(
        onPressed: _showChatWindow,
        tooltip: 'Chat Assistant',
        backgroundColor: Colors.blue,
        child: Icon(Icons.assistant),
        heroTag: 'chat_assistant_fab',
      ),
    );
  }

  void _showChatWindow() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ChatBubbleWindowWidget(
          onClose: () {
            Navigator.of(context).pop();
            setState(() => _isChatOpen = false);
          },
        );
      },
    ).then((_) {
      setState(() => _isChatOpen = false);
    });

    setState(() => _isChatOpen = true);
  }

  // ... rest of existing code ...
}
```

**Key Features:**
- FAB with unique heroTag
- Dialog shows ChatBubbleWindowWidget
- Proper state cleanup on close
- Accessible tooltip

### Step 3: Update Imports

**File:** `lib/presentation/dashboard/dashboard.dart`

Add imports at top of file:

```dart
import 'package:boilerplate/presentation/chat/chat.dart';
```

Make sure `chat.dart` barrel export includes:
- ChatBubbleWindowWidget
- ChatScreen (if used directly)

### Step 4: Handle FAB on Multiple Dashboard Sections

If dashboard has navigation to sub-screens:

**Option A: Floating FAB Above Navigation**
```dart
Stack(
  children: [
    // Body content with sub-screens
    Scaffold(
      body: /* sub-screens */,
      bottomNavigationBar: /* if exists */,
    ),
    // FAB overlay
    Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(
        onPressed: _showChatWindow,
        child: Icon(Icons.assistant),
      ),
    ),
  ],
)
```

**Option B: FAB Per Screen**
Add FAB to each dashboard sub-screen with same callback.

### Step 5: Add Route Entry (Optional)

If you want to support deep linking to chat:

**File:** `lib/utils/routes/routes.dart`

Add route definition:

```dart
class Routes {
  // ... existing routes ...
  static const String chat = '/chat';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ... existing cases ...
      case Routes.chat:
        return MaterialPageRoute(
          builder: (_) => ChatScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => DashboardScreen(),
        );
    }
  }
}
```

### Step 6: Handle Chat State Persistence

Ensure ChatStore persists state:

```dart
// In ChatStore
@action
void setConversation(String conversationId) {
  selectedConversationId = conversationId;
  if (messages.isEmpty) {
    fetchMessages();  // Only fetch if not already loaded
  }
}
```

### Step 7: Add Accessibility Features

**File:** `lib/presentation/dashboard/dashboard.dart`

Ensure accessibility:

```dart
floatingActionButton: Semantics(
  label: 'Open Chat Assistant',
  child: FloatingActionButton(
    onPressed: _showChatWindow,
    tooltip: 'Chat Assistant - Ask questions about AEO',
    child: Icon(Icons.assistant),
  ),
),
```

## Todo List

- [ ] Review current `dashboard.dart` structure
- [ ] Understand existing FAB pattern (if any)
- [ ] Add imports for chat module
- [ ] Implement `_showChatWindow()` method
- [ ] Add ChatBubbleWindowWidget as modal dialog
- [ ] Update Scaffold with floatingActionButton
- [ ] Test FAB visibility on dashboard
- [ ] Test modal opens on FAB tap
- [ ] Test modal closes properly
- [ ] Verify state persistence
- [ ] Add accessibility labels
- [ ] Add hero animations (optional)
- [ ] Test on different screen sizes
- [ ] Run `flutter analyze` and fix issues
- [ ] Manual testing on device/emulator

## Success Criteria

- ✅ Assistant FAB visible on dashboard
- ✅ FAB is positioned in bottom-right corner
- ✅ Chat window opens as modal on FAB tap
- ✅ Chat window closes on close button tap
- ✅ Messages persist when opening/closing
- ✅ No layout shifts or visual glitches
- ✅ Smooth animations/transitions
- ✅ Works on all device sizes
- ✅ No compile errors
- ✅ Follows project patterns

## Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|-----------|
| Multiple FAB conflicts | Low | Use unique heroTag |
| Modal doesn't close | Medium | Test Navigator.pop() |
| State loss on modal close | Medium | Verify ChatStore persistence |
| Layout overflow | Low | Test on small screens |

## Integration Checklist

- ✅ ChatStore is registered in DI
- ✅ All chat widgets compile
- ✅ Dashboard imports chat module correctly
- ✅ build_runner has been run
- ✅ No breaking changes to existing features
- ✅ FAB doesn't interfere with other UI elements

## Accessibility Considerations

- ✅ FAB has tooltip and semantic label
- ✅ Modal can be dismissed with back button
- ✅ Chat input field is keyboard accessible
- ✅ Messages have proper contrast
- ✅ Large enough touch targets (48+ dp)

## Performance Notes

- ✅ Chat window loaded on-demand (lazy)
- ✅ Dialog uses barrierDismissible for efficiency
- ✅ Store reused across open/close cycles
- ✅ No memory leaks with proper cleanup

## Platform-Specific Considerations

### Android
- FAB properly positioned above system nav
- Back button closes modal correctly
- Keyboard shows without issues

### iOS
- FAB safe area respected
- Modal presentation smooth
- Swipe-to-dismiss supported

## Next Steps

After completing Phase 4:
1. Move to [Phase 5: Testing & Review](phase-05-testing-and-review.md)
2. Run comprehensive tests
3. Code review with team
4. Prepare for deployment

---

**Phase 4 Status:** Ready for Implementation  
**Last Updated:** 2026-05-09
