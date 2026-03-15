You are a senior iOS engineer, senior SwiftUI architect, and senior product designer. Build a production-quality iOS application in Swift using SwiftUI only. The app must be clean, premium, elegant, highly polished, and App Store quality. The codebase must be modular, scalable, and compile-ready. Do not use any backend. Do not use Firebase. Do not require authentication. Everything must work with a public meals API plus local on-device persistence.

========================
PROJECT OVERVIEW
========================

Build a Tinder-like meal discovery app for iPhone.

The app fetches meals from a public meals API such as TheMealDB and presents them as swipeable cards.

Core interaction:
- Swipe LEFT: add meal to the user's "Try List" and allow viewing meal details
- Swipe RIGHT: add meal to the user's "Disliked" list
- Tap card: open full meal detail
- Meals already swiped must not appear again unless the user resets history

There is no backend. All user decisions are stored locally on device.

The app must feel premium, smooth, modern, elegant, and very well designed.

========================
CORE PRODUCT RULES
========================

1. Meals come from a public meals API.
2. Main experience is a swipe deck similar to Tinder.
3. Each meal card must show:
   - large meal image
   - meal title
   - category
   - area / cuisine
   - short ingredient preview
4. Swipe LEFT:
   - save meal into local "Try List"
   - mark as swiped
   - allow transition to detail screen
5. Swipe RIGHT:
   - save meal into local "Disliked" list
   - mark as swiped
6. Same meal must not be processed twice.
7. Same meal must not be shown again in the swipe deck after a swipe.
8. Tapping a card opens detail screen.
9. Detail screen must show:
   - hero image
   - title
   - category
   - cuisine / area
   - all ingredients with measurements
   - instructions
   - source link if available
   - YouTube link if available
10. App must include:
   - Home Swipe Screen
   - Meal Detail Screen
   - Try List Screen
   - Disliked Screen
   - Settings Screen
11. App must support local persistence.
12. App must support loading, empty, and error states.
13. App must support dark mode and light mode.
14. App must feel like a premium native iOS product, not a demo.

========================
TECH STACK
========================

Use:
- Swift
- SwiftUI
- MVVM
- async/await
- URLSession
- NavigationStack
- SwiftData preferred for local persistence
- if SwiftData becomes too heavy, use a lightweight repository abstraction with UserDefaults, but keep architecture clean

Do NOT use:
- UIKit-heavy architecture
- Storyboards
- Firebase
- backend
- fake static production data
- giant single-file architecture
- unfinished placeholders or TODO stubs

========================
DESIGN DIRECTION
========================

The visual design must be elite, premium, modern, minimal, and elegant.

Design goals:
- Apple-like quality
- beautiful spacing
- refined typography
- elegant card hierarchy
- subtle gradients
- warm food-oriented color palette
- rounded corners
- layered shadows
- smooth motion
- clean alignment
- immersive detail screen
- polished tab navigation or custom navigation structure

The app must not look generic, cheap, cluttered, or developer-made.

The swipe screen must be the hero experience.

The meal cards must feel luxurious:
- stacked deck effect
- depth
- subtle rotation while dragging
- swipe threshold feedback
- graceful spring animation
- nice overlays and legibility over meal images
- premium shadows and corner radius
- smooth transitions

The detail screen must feel editorial:
- large hero image
- immersive layout
- elegant ingredient section
- beautifully formatted instructions
- clear section spacing
- source buttons if available

Saved and disliked screens must also look premium:
- not plain raw tables
- use elegant cards or polished list cells
- consistent spacing and typography
- visually curated feel

========================
USER EXPERIENCE FLOW
========================

STEP 1:
App launches into a beautiful home screen with a meal swipe deck.

STEP 2:
App fetches meal list from public API.

STEP 3:
Cards are shown one by one with stacked deck visuals.

STEP 4:
User swipes LEFT:
- meal is saved to Try List
- meal is removed from deck
- meal is marked as swiped
- user may open details

STEP 5:
User swipes RIGHT:
- meal is saved to Disliked
- meal is removed from deck
- meal is marked as swiped

STEP 6:
User can tap card for full meal detail.

STEP 7:
Try List screen shows saved meals.

STEP 8:
Disliked screen shows rejected meals.

STEP 9:
Settings screen allows resetting local history and clearing saved/disliked meals.

========================
API REQUIREMENTS
========================

Use TheMealDB or equivalent public meals API.

Support:
- meal list fetching
- meal detail lookup by id
- correct parsing of ingredients and measures

Important:
The API may use fields like:
- strIngredient1 ... strIngredient20
- strMeasure1 ... strMeasure20

Create a clean parser that transforms this raw structure into a typed array:
- IngredientItem(name, measure)

Do not leave raw parsing logic scattered across views.
Create proper mapping and transformation layers.

========================
ARCHITECTURE REQUIREMENTS
========================

Use strict MVVM.

Suggested folder structure:

- App
- Core
  - Network
  - Persistence
  - Theme
  - Utilities
  - Extensions
- Shared
  - Models
  - Components
- Features
  - Home
  - MealDetail
  - TryList
  - Disliked
  - Settings

Each feature should have:
- View
- ViewModel
- Components if needed

Networking must be isolated.
Persistence must be isolated.
Views must stay clean.
Business rules must not be mixed into UI code.

========================
SCREENS TO BUILD
========================

1. HOME / SWIPE SCREEN
- premium title area
- subtitle text
- top-level content hierarchy
- swipeable card deck
- stacked card effect
- optional action buttons at bottom
- empty state when deck finishes
- reload action
- loading state
- error state

2. MEAL DETAIL SCREEN
- large hero image
- title and metadata
- ingredient list
- instructions
- external links if available
- save/disliked state visibility
- clean scrolling experience
- editorial layout style

3. TRY LIST SCREEN
- elegant grid or vertical premium cards
- searchable if reasonable
- tap to open detail
- remove from saved list

4. DISLIKED SCREEN
- elegant list/grid
- tap to inspect if needed
- remove / undo capability

5. SETTINGS SCREEN
- reset swipe history
- clear try list
- clear disliked list
- simple about section

========================
ANIMATION + INTERACTION
========================

The swipe interaction must feel excellent.

Implement:
- drag gesture
- threshold-based swipe decision
- card rotation based on drag amount
- smooth spring animation
- clear removal behavior
- clean deck update after swipe
- optional visual badges for SAVE / DISLIKE
- polished transition into detail

Interaction quality matters a lot.
This must feel like a real app, not a tutorial project.

========================
LOCAL PERSISTENCE RULES
========================

Persist locally:
- try list
- disliked list
- swiped meal ids

Goals:
- same meal should not reappear after swipe
- app state should survive relaunch
- logic should be clean and reusable

Use repositories or service abstractions.
Do not directly spread persistence logic across screens.

========================
QUALITY BAR
========================

Code quality must be high:
- compile-ready
- modular
- reusable components
- meaningful naming
- no dead code
- no giant files
- no pseudo-code
- no fake unfinished architecture
- no ugly quick demo UI
- no placeholder production logic

Everything should be structured as if this app may later scale.

========================
DELIVERABLES
========================

Generate the project in this order:

1. Architecture overview
2. Folder structure
3. Data models
4. Theme system
5. Networking layer
6. Persistence layer
7. Home swipe feature
8. Meal detail feature
9. Try List feature
10. Disliked feature
11. Settings feature
12. Reusable shared UI components
13. README.md

Do not skip steps.
Do not dump everything into one file.
Generate real code file by file.

========================
EXTRA DESIGN INSTRUCTION
========================

The app must look elite and beautiful.
Do not use generic tutorial UI.
Do not use boring default list styling as final design.
Do not create weak hierarchy.
Do not create inconsistent spacing.
Do not create amateur layout.
Make every screen feel intentionally designed.

This must look like an App Store-ready premium food discovery app.