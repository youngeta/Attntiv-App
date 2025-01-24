# Attntiv App Structure

## Navigation Flow
```mermaid
graph TD
    A[App Entry] --> B{Authentication}
    B -->|Not Authenticated| C[AuthenticationView]
    B -->|Authenticated| D[MainTabView]
    
    D -->|Tab 1| E[CognitiveFeedView]
    D -->|Tab 2| F[GamificationBoardView]
    D -->|Tab 3| G[ProfileView]
    
    E --> E1[FeedItemView]
    E --> E2[FeedItemDetailView]
    
    F --> F1[Daily Challenges]
    F --> F2[Achievements]
    
    F1 --> H[Exercise Views]
    
    H --> H1[MemoryExerciseView]
    H --> H2[PatternRecognitionView]
    H --> H3[FocusExerciseView]
    H --> H4[ProblemSolvingView]
    H --> H5[SpeedProcessingView]
```

## Core Features

### Authentication
- Sign In/Sign Up
- Email authentication
- Profile creation

### Cognitive Feed
- TikTok-style vertical scrolling
- AI-generated content
- Like and share functionality
- Offline support

### Gamification
- Daily challenges
- Achievement system
- Points and streaks
- Progress tracking

### Exercise Types
1. **Memory Training**
   - Sequence recall
   - Pattern memorization
   - Adaptive difficulty

2. **Pattern Recognition**
   - Visual patterns
   - Number sequences
   - Multiple choice answers

3. **Focus Training**
   - N-Back challenges
   - Concentration exercises
   - Time-based scoring

4. **Problem Solving**
   - Math problems
   - Logic puzzles
   - Time bonuses

5. **Speed Processing**
   - Visual processing
   - Quick decision making
   - Reaction time tracking

## Services

### Core Services
```mermaid
graph LR
    A[CognitiveExerciseService] --> B[Exercise Generation]
    A --> C[Score Calculation]
    A --> D[Difficulty Management]
    
    E[MLContentGenerator] --> F[Content Generation]
    E --> G[Sentiment Analysis]
    E --> H[Keyword Extraction]
    
    I[FirebaseService] --> J[Authentication]
    I --> K[Data Sync]
    I --> L[Social Features]
    
    M[NotificationService] --> N[Push Notifications]
    M --> O[Local Notifications]
    M --> P[Reminders]
    
    Q[OfflineStorage] --> R[Core Data]
    Q --> S[Data Sync]
    Q --> T[Cache Management]
```

## UI Components

### Common Components
- ScoreView
- StreakView
- TimerView
- ResultsOverlay
- CountdownOverlay

### Theme Colors
- Primary: Purple (#9966FA)
- Background: Dark (#141414)
- Accent colors for different exercise types

## Data Models

### Core Models
```mermaid
graph TD
    A[User] --> B[Profile]
    A --> C[Preferences]
    A --> D[Statistics]
    
    E[FeedItem] --> F[Content]
    E --> G[Interactions]
    
    H[Challenge] --> I[Progress]
    H --> J[Rewards]
    
    K[Achievement] --> L[Conditions]
    K --> M[Rewards]
```

## File Structure
```
Attntiv/
├── App/
│   ├── AttntivApp.swift
│   └── ContentView.swift
├── Features/
│   ├── Authentication/
│   ├── Feed/
│   ├── Gamification/
│   ├── Exercises/
│   └── Profile/
├── Core/
│   ├── Services/
│   ├── Models/
│   └── Utils/
└── Resources/
    ├── Assets.xcassets
    └── AttntivData.xcdatamodeld
``` 