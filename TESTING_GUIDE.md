# Court+ Testing Guide

> **App:** Court+ — Sports court booking, match creation, coaching & social platform  
> **Platform:** Flutter (Android / iOS / Web)  
> **Version:** 1.0.0  
> **Last Updated:** July 2026

---

## Setup

### Prerequisites
- Flutter SDK (ensure `flutter` is accessible in PATH)
- Dart SDK (bundled with Flutter)
- An Android emulator, iOS simulator, or physical device
- Supabase project (local or cloud) — see `supabase/` directory

### How to Run the App
```bash
# Navigate to project root
cd C:/Users/ahmed/flutter_court_plus

# Get dependencies
flutter pub get

# Run the app
flutter run

# Run with specific device
flutter run -d chrome       # Web
flutter run -d emulator-5554 # Android emulator
flutter run -d ios           # iOS simulator (macOS only)
```

### Supabase / Mock Data Setup
The app uses **mock data** by default via `MockDataService` (6 courts, 4 coaches, 6 moments). No Supabase connection is required for basic manual QA.

If testing against a live Supabase backend:
1. Configure your Supabase URL and anon key in a `.env` file at the project root (see `.env.example`)
2. Ensure the following tables exist in your Supabase project:
   - `users`
   - `courts`
   - `bookings`
   - `matches`
   - `match_invitations`
   - `reviews`
   - `moments`
   - `notifications`
   - `payments`
3. Seed test data or use the Supabase dashboard

### Running Tests & Analysis
```bash
# Static analysis — checks for lint errors and warnings
dart analyze lib/

# Run Flutter widget/unit tests
flutter test

# Run tests with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html

# Format code
dart format lib/
```

---

## Feature Test Matrix

---

### 1. Auth & Onboarding

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 1.1 | **Splash → Language** | Launch the app fresh (no stored session) | 2-second splash screen showing Court+ logo on dark background → auto-navigates to language selection screen via fade transition |
| 1.2 | **Language selection — English** | On language screen, tap "English" radio, then tap "Done" | Proceeds to onboarding screen; English locale saved to SharedPreferences |
| 1.3 | **Language selection — Arabic** | On language screen, tap "العربية" radio, then tap "تم" | Proceeds to onboarding screen; Arabic locale saved; app should prepare for RTL layout |
| 1.4 | **Onboarding flow** | Swipe left through 3 onboarding pages with illustrations, tap "Get Started" on last page | Navigates to Signup screen |
| 1.5 | **Signup — fill all fields** | Enter: Full name, Email, Username, Phone number (5X XXX XXXX), Date of Birth (DD/MM/YYYY), Gender; tap "Sign up" | Validates all fields (non-empty); sends email OTP via Supabase auth; navigates to OTP screen |
| 1.6 | **Signup — validation errors** | Tap "Sign up" with empty fields | Shows inline error messages; does NOT navigate |
| 1.7 | **Signup — invalid email** | Enter invalid email format, tap "Sign up" | Shows validation error for email field |
| 1.8 | **OTP verification** | Enter the 6-digit code received via email into the 6 individual boxes | Code auto-advances focus to next box; on complete entry, verifies OTP; creates user profile; navigates to Profile Setup screen |
| 1.9 | **OTP — auto-focus** | Tap first OTP box | Keyboard appears; first box focused; typing auto-moves to next box |
| 1.10 | **OTP — resend timer** | After OTP screen loads | Shows "Resend OTP code in 00:30" countdown; countdown reaches 0 → button becomes tappable "Resend OTP code" |
| 1.11 | **OTP — resend** | Wait for timer to expire, tap "Resend OTP code" | Timer resets to 30 seconds; new OTP sent |
| 1.12 | **OTP — wrong code** | Enter 6 incorrect digits | Shows error snackbar: "Invalid OTP code" |
| 1.13 | **Profile Setup** | After OTP verification, fill: Your name, @username, Bio, optionally add sports | Profile saved; navigates to Home screen |
| 1.14 | **Login** | From signup screen, tap "Already have an account? Sign In" → navigate to Login screen; enter phone number and password; tap "Login" | Validates credentials; sends OTP to email; navigates to OTP screen |
| 1.15 | **Login — forgot password** | On Login screen, tap "Forgot Password?" | Shows password reset flow |
| 1.16 | **Google OAuth** | On Signup or Login screen, tap Google button (G icon) | Opens Google OAuth sheet; after successful auth, returns to app authenticated; navigates to home |
| 1.17 | **Apple OAuth** | On Signup or Login screen, tap Apple button | Opens Apple Sign In flow; after successful auth, returns to app authenticated |
| 1.18 | **Guest mode** | On onboarding/login screen, tap "Continue as Guest" | Skips all auth; navigates to Home screen with limited feature set |
| 1.19 | **Persistent session** | Complete signup/login, close app, reopen | App should skip splash → language → onboarding and go straight to Home (session persisted) |
| 1.20 | **Logout** | Go to Settings → tap "log out" → confirm in dialog | Signs out via Supabase; navigates to Login screen; session cleared |

---

### 2. Home Screen

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 2.1 | **Location header — guest** | Launch app as guest or logged-in user | Shows "Location" label above "Riyadh, Saudi Arabia" with location pin icon and dropdown arrow |
| 2.2 | **Location header — logged in** | Log in and go to Home | Shows "Hi, {user's full name}" above "Riyadh, Saudi Arabia" |
| 2.3 | **Sport filter chips** | Tap each chip: "All courts (6)", "Tennis (4)", "Football (2)", "Padel", "Basketball" | Active chip highlights in green; filters the courts horizontal list (counts in parentheses update) |
| 2.4 | **Courts horizontal list** | Scroll the courts section left/right | Shows court cards with: image, court name, center name, distance, star rating |
| 2.5 | **See all link** | Tap "See all" next to "Courts" section header | Navigates to full Courts screen |
| 2.6 | **Open Match card** | Tap the "Open match" action card (left card in Play amazing Match section) | Navigates to Start Match screen |
| 2.7 | **Coaches card** | Tap the "Coaches" action card (right card) | Navigates to Coaches screen |
| 2.8 | **Search bar** | Tap the search field at top | Keyboard appears; can type in search text; currently navigates nowhere from Home search |
| 2.9 | **Notification bell** | Tap the bell icon in top-right | Navigates to Notifications screen; red dot badge visible |
| 2.10 | **Bottom nav — Courts** | Tap "Courts" icon (1st position) | Navigates to Courts screen |
| 2.11 | **Bottom nav — Explore** | Tap "Explore" icon (2nd position) | Navigates to Explore screen with map |
| 2.12 | **Bottom nav — Home** | Tap "Home" icon (3rd position — center) | Stays on Home (already active) |
| 2.13 | **Bottom nav — Activity** | Tap "Activity" icon (4th position) | Navigates to Activity screen |
| 2.14 | **Bottom nav — Profile** | Tap "Profile" icon (5th position) | Navigates to Profile screen |
| 2.15 | **Bottom nav — active indicator** | Check each tab | Active tab shows green top bar indicator and green-highlighted icon |

---

### 3. Courts & Booking

#### 3.1 Courts Screen

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 3.1.1 | **Courts screen — load** | Navigate to Courts from Home "See all" or bottom nav | Shows header "Courts" with Riyadh location chip and notification bell; search bar; category chips (All courts, Tennis, Football); sort dropdown (Nearest / Highest Rated / Price Low / Price High); list of court cards |
| 3.1.2 | **Courts — search** | Type in search bar (e.g., "Tennis", "Eagle") | List filters in real-time to matching courts |
| 3.1.3 | **Courts — category filter** | Tap "Tennis" chip | List filters to show only tennis courts |
| 3.1.4 | **Courts — sort** | Change sort to "Highest Rated" / "Price Low" | List re-sorts accordingly |
| 3.1.5 | **Courts — filter bottom sheet** | Tap filter icon | Opens bottom sheet with: Rating chips (All/4+/4.5+/5), Location text field, Surface dropdown (Any/Clay/Grass/Hard), "Apply Filters" button |
| 3.1.6 | **Courts — apply filters** | Select rating "4+", tap "Apply Filters" | List filters to courts with rating >= 4.0 |
| 3.1.7 | **Courts — court card tap** | Tap any court card | Navigates to Court Details screen with that court's ID |
| 3.1.8 | **Courts — empty state** | Search for a non-existent court name | Shows "No courts found" message |
| 3.1.9 | **Courts — star rating display** | Check court cards | Each card shows star icons (filled/half/empty) matching the court's rating value |

#### 3.2 Court Details Screen

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 3.2.1 | **Court details — load** | Navigate to a court | Shows: app bar with "Court Details", back button, heart icon, more options (⋯); court name, center name; rating stars + review count + likes count + sport type badge; location chip; 4 tabs: Details / Availability / Specs / Moments |
| 3.2.2 | **Details tab** | View the first tab | Shows: hero image carousel (3 images, swipable), dot indicators, stats row (Rate per hour, Min time, Sessions) |
| 3.2.3 | **Hero image carousel** | Swipe left/right on images | Slides between 3 images; active dot indicator updates |
| 3.2.4 | **Availability tab** | Tap "Availability" tab | Shows: calendar view (April 2024), days with availability (green numbers), time slots based on selected day |
| 3.2.5 | **Availability — select day** | Tap an available day | Day highlights in green; time slots appear below |
| 3.2.6 | **Availability — select time** | Tap a time slot | Slot highlights green; "Book Now" button becomes active |
| 3.2.7 | **Availability — Book Now** | Select day + time, tap "Book Now" | Navigates to Booking Step 1 |
| 3.2.8 | **Specs tab** | Tap "Specs" tab | Shows court specifications (surface type, dimensions, lighting, etc.) |
| 3.2.9 | **Moments tab** | Tap "Moments" tab | Shows moments/photos related to this court |
| 3.2.10 | **Reviews link** | On details header, tap "{n} reviews" text | Navigates to Reviews screen for this court |
| 3.2.11 | **Court details — loading state** | Navigate while data is loading | Shows spinner with app bar |
| 3.2.12 | **Court details — error state** | Force network failure | Shows warning icon + "Failed to load court" + error message |

#### 3.3 Booking Step 1 — Date & Time

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 3.3.1 | **Booking Step 1 — load** | From Court Details "Book Now" | Shows: "Booking" title, court name + center, "Select Date" with calendar, "Select Time" with time slot grid, "Next" button (disabled initially) |
| 3.3.2 | **Calendar — month navigation** | Tap left/right arrows on calendar | Month label changes; days re-render |
| 3.3.3 | **Calendar — select day** | Tap a day number | Day highlights in green circle |
| 3.3.4 | **Time slot — select** | Tap a time slot | Slot highlights green; can proceed |
| 3.3.5 | **Time slots — weekday vs weekend** | Select a weekday vs Friday/Saturday | Weekdays show afternoon/evening slots (14:00-22:00); weekends show full-day slots (08:00-20:00) |
| 3.3.6 | **Next button** | Select a day + time, tap "Next" | Navigates to Booking Step 2; booking state (court, date, time) saved in provider |

#### 3.4 Booking Step 2 — Duration

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 3.4.1 | **Booking Step 2 — select duration** | Select duration option (e.g., 1 hour, 1.5 hours, 2 hours) | Option highlights; fee updates dynamically |
| 3.4.2 | **Step 2 — Next** | Select duration, tap "Next" | Navigates to Booking Step 3 |

#### 3.5 Booking Step 3 — Extras & Equipment

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 3.5.1 | **Add-ons display** | View the Extras page | Shows list: Racket Rental (SR 20), Ball Pack (SR 15), Water Bottle (SR 5), Towel (SR 10), Wristband (SR 8) — each with +/- quantity controls |
| 3.5.2 | **Add quantity** | Tap + on any add-on | Quantity increases; subtotal updates at bottom |
| 3.5.3 | **Remove quantity** | Tap - on an item with qty >= 1 | Quantity decreases; subtotal updates |
| 3.5.4 | **Step 3 — Next** | Adjust quantities, tap "Next" | Navigates to Booking Step 4; add-ons data passed via arguments |

#### 3.6 Booking Step 4 — Review Booking

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 3.6.1 | **Review summary** | View Review Booking screen | Shows: step indicator (all 4 dots green), "Booking Summary" card with Court, Center, Duration, Court Fee; Add-ons section (if any); Price breakdown (Court Fee, Add-ons, Total — highlighted in green); cancellation policy note |
| 3.6.2 | **Price accuracy** | Verify total | Total = Court Fee + Add-ons subtotal; displayed correctly |
| 3.6.3 | **Proceed to Pay** | Tap "Proceed to Pay — SR {total}" | Calls `createBooking()`; on success → navigates to Payment Gateway |

#### 3.7 Payment Gateway

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 3.7.1 | **Payment — load** | Navigate from Review Booking | Shows: "Payment" title, Order Summary card (Court Fee, Add-ons, Total), "Select Payment Method" section with 4 options: Apple Pay, Google Pay, Credit Card, STC Pay |
| 3.7.2 | **Payment method — selection** | Tap each payment method | Selected method shows green border + check circle; only Credit Card shows additional card form (Card Number, Expiry, CVV fields) |
| 3.7.3 | **Credit card form** | Select Credit Card | Card number, expiry (MM/YY), CVV fields appear with labels and hints |
| 3.7.4 | **Pay button** | Select a method, tap "Pay SR {total}" | Processes payment via Supabase; on success → navigates to Booking Success screen |
| 3.7.5 | **Secure notice** | Scroll to bottom | Shows lock icon + "Secure payment via SSL encryption" |

#### 3.8 Booking Success

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 3.8.1 | **Success animation** | After payment | Animated green checkmark scales in (elastic animation); "Booking Successful!" text and "Your court has been reserved successfully." fade in |
| 3.8.2 | **Booking details card** | View success screen | Card shows: Booking ID (#BK-2025-0042), Court, Date (Sat, 15 Nov 2025), Time (10:00 — 11:00 AM), Duration (1 hour), Payment Method (Apple Pay), Amount Paid (SR {total}) |
| 3.8.3 | **View Ticket button** | Tap "View Ticket" | Navigates to Booking Ticket screen |
| 3.8.4 | **Back to Home button** | Tap "Back to Home" | Navigates to Home screen and clears navigation stack |

#### 3.9 Booking Ticket

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 3.9.1 | **Ticket card** | View ticket | Shows styled ticket card with: booking ID, court name, date, time, duration, payment method, player name, QR code placeholder |
| 3.9.2 | **Share button** | Tap share icon in app bar | Shows snackbar: "Share functionality coming soon" |
| 3.9.3 | **Add to Calendar** | Tap "Add to Calendar" button | Shows snackbar: "Added to calendar" |

---

### 4. Match Creation & Invitations

#### 4.1 Start Match (Legacy)

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 4.1.1 | **Start Match — load** | Navigate from Home "Open match" card | Shows: "Start a Match" title, 5-step indicator (Date → Time → Loc. → Gender → Level), continue button (disabled initially) |
| 4.1.2 | **Step 1 — Date** | View first step | Shows "Select Date" with 14-day calendar chips; select a date |
| 4.1.3 | **Step 2 — Time** | Tap Continue after date | Shows "Select Time Slot" with 18 time slots (06:00 AM — 10:00 PM); select a time |
| 4.1.4 | **Step 3 — Court/Location** | Continue | Shows 4 court options (Grand Slam Court, Pro Tennis Arena, Elite Padel Court, Squash Pro Court); select one |
| 4.1.5 | **Step 4 — Gender** | Continue | Shows gender selector: Male / Female / Any with icons |
| 4.1.6 | **Step 5 — Level** | Continue | Shows skill level: Beginner / Intermediate / Advanced |

#### 4.2 Create Match (New Flow)

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 4.2.1 | **Create Match — load** | Navigate to Create Match | Shows: "Create Match" title, two-step form |
| 4.2.2 | **Step 1 — Sport & Court** | Select sport, then select court from list | Selection highlights |
| 4.2.3 | **Step 2 — Date & Time + Level + Privacy** | Select date, time, match level (Beginner/Intermediate/Advanced), privacy (Open to All / Friends Only) | All selections reflected in UI |
| 4.2.4 | **Create Match — submit** | Complete all steps, tap "Create Match" | Match created; navigates to Invite Players screen |

#### 4.3 Invite Players

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 4.3.1 | **Invite Players — load** | After creating a match | Shows: "Invite Players" title, Search field ("Search players by name or phone..."), Suggested Players list, "Share Invite Link" section, "Players Added" count |
| 4.3.2 | **Search players** | Type in search field | Filters suggested players list |
| 4.3.3 | **Invite a player** | Tap "+ Invite" on a player | Button changes to "Invited" (disabled); player added to "Players Added" list |
| 4.3.4 | **Share invite link** | Tap "Share Invite Link" | Shows snackbar: "Share link copied to clipboard" |

#### 4.4 Invitations

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 4.4.1 | **Receive invitation** | Navigate to Receive Invitation screen | Shows invitation details: Sender, Court Name, Date, Time, Message, status |
| 4.4.2 | **Accept invitation** | Tap "Accept & Pay Share" | Invitation accepted; navigates to payment for share |
| 4.4.3 | **Decline invitation** | Tap decline (if available) | Invitation declined; status updates |
| 4.4.4 | **Invitation Details** | Navigate to invitation details | Shows full invitation info with status (Pending/Accepted/Declined) |
| 4.4.5 | **View Booking Ticket from invitation** | Tap "View Booking Ticket" link | Navigates to booking ticket |

#### 4.5 Activity Tab — Match Related

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 4.5.1 | **Activity tab — match cards** | Check Activity screen | Current bookings tab shows match/booking cards with countdown |
| 4.5.2 | **Enter Court from booking** | Tap "Enter Court" on a current booking | Navigates to court entry / check-in |
| 4.5.3 | **Capture Moment** | Tap "📷 Capture a Court+ Moment" | Navigates to Create Moment screen |

---

### 5. Explore & Search

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 5.1 | **Explore — map load** | Navigate to Explore tab | Shows Google Maps centered on Riyadh (24.7136, 46.6753) with green markers for each court |
| 5.2 | **Explore — search bar overlay** | Check top of explore | Shows search bar "Find a courts, coaches + more"; tapping navigates to Recent Search screen |
| 5.3 | **Explore — filter chips** | View filter chips below search | Shows: All / Nearby / Top Rated chips |
| 5.4 | **Nearby filter** | Tap "Nearby" | Map filters to 5 nearest courts; bottom card updates |
| 5.5 | **Top Rated filter** | Tap "Top Rated" | Map filters to 5 highest-rated courts |
| 5.6 | **Explore — bottom card** | Check bottom of map | Card shows nearest/first court name, center, rating, distance; close (✕) button dismisses card |
| 5.7 | **Explore — marker tap** | Tap a green marker on map | Info window shows court name, center, rating, price |
| 5.8 | **Explore — bottom nav** | Tap navigation items | Each bottom tab navigates correctly |
| 5.9 | **Search Results screen** | Navigate to Search Results | Shows: Courts tab (filtered results) and Coaches tab |
| 5.10 | **Recent Search screen** | Navigate to Recent Search | Shows recent searches list (empty state if none) |
| 5.11 | **Explore — loading state** | While courts load | Map shows with no markers; bottom card shows "Loading... Please wait" |
| 5.12 | **Explore — error state** | Force network failure | Map shows; bottom card shows "Could not load courts — Tap to retry" |

---

### 6. Profile & Settings

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 6.1 | **Profile — load** | Navigate to Profile tab | Shows: cover photo area (or placeholder), circular avatar, name (@username), bio, interest pills (🎾 Tennis • Amateur, ⚽ Football • Advanced, 🚲 Pedal • Amateur), play stats (courts played, court times, sessions), "My Moments" section with a moment card |
| 6.2 | **Profile — stats** | Check stats row | Shows: Following / Followers count with labels; courts played / court times / sessions with icons |
| 6.3 | **Profile — follower count formatting** | Check follower numbers | Numbers >= 1000 display as "1K", "1.6K", etc. |
| 6.4 | **Update profile button** | Tap "Update" on cover photo | Navigates to Update Profile screen |
| 6.5 | **Update Profile — edit** | Change name, username, bio, mobile number; tap "Save" | Updates saved; navigates back to Profile |
| 6.6 | **Settings — navigate** | Tap settings icon/menu | Navigates to Settings screen |
| 6.7 | **Settings — Saved** | Tap "Saved" row | Navigates to saved items (placeholder) |
| 6.8 | **Settings — Notifications toggle** | Tap the Notifications switch | Toggles notifications on/off; setting persists |
| 6.9 | **Settings — Language picker** | Tap "Language" row | Dialog shows: English 🇬🇧 / العربية 🇸🇦 radio options; selecting one changes app locale immediately |
| 6.10 | **Settings — How Court+ works** | Tap "How Court+ work" | Navigates to info page (placeholder) |
| 6.11 | **Settings — Terms of use** | Tap "Terms of use" | Navigates to terms (placeholder) |
| 6.12 | **Settings — Privacy policy** | Tap "Privacy policy" | Navigates to privacy policy (placeholder) |
| 6.13 | **Settings — Logout** | Tap "log out" | Confirmation dialog: "Are you sure you want to logout?" with Cancel / Logout buttons |
| 6.14 | **Logout — cancel** | Tap "Cancel" in logout dialog | Dialog dismissed; stays on Settings |
| 6.15 | **Logout — confirm** | Tap "Logout" | Logs out; navigates to Login screen |
| 6.16 | **App version** | Scroll to bottom of Settings | Shows "Version 1.0.0" |

---

### 7. Activity Tab

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 7.1 | **Activity — load** | Navigate to Activity tab | Shows: "Activity" title with stack icon, notification bell, two tabs: "Current bookings" and "Booking History" |
| 7.2 | **Current bookings tab** | View first tab | Shows list of upcoming/active bookings with countdown timer, court info, "Enter Court" and "Capture Moment" action buttons |
| 7.3 | **Booking history tab** | Tap "Booking History" tab | Shows past bookings with "Add Review" or "✅ Reviewed" status |
| 7.4 | **Empty state — no bookings** | View Activity without any bookings | Shows: calendar icon + "No bookings yet" centered message |
| 7.5 | **Countdown timer** | View a current booking card | Shows time remaining until match starts |
| 7.6 | **Add Review flow** | On a completed booking, tap "✏️ Add Review" | Navigates to Add Review bottom sheet / screen |
| 7.7 | **Add Review — rate** | Tap stars (1-5) | Rating selected; visual feedback |
| 7.8 | **Add Review — submit** | Write a comment, tap "Submit Review" | Review submitted; navigates to Thank You screen |
| 7.9 | **Thank You screen** | After submitting review | Shows "Thank You!" with success message |
| 7.10 | **Enter Court** | Tap "Enter Court" on current booking | Navigates to court entry flow (if implemented) |
| 7.11 | **Capture Moment from Activity** | Tap "📷 Capture a Court+ Moment" | Navigates to Create Moment screen with booking context |

---

### 8. Coaches

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 8.1 | **Coaches — list load** | Navigate to Coaches screen | Shows: "Coaches" title, search bar, sort dropdown (Highest Rated / Price Low / Price High), list of coach cards with: name, sport type, rating, price per session, experience |
| 8.2 | **Coaches — search** | Type in search bar | Filters coach list by name or sport |
| 8.3 | **Coaches — sort** | Change sort option | List re-sorts by selected criteria |
| 8.4 | **Coaches — coach card tap** | Tap a coach card | Navigates to Coach Detail screen |
| 8.5 | **Coach Detail — load** | Navigate to a coach | Shows: name, @username, sport type, rating, price per session, experience, bio, "Book Session — SR {price}" button |
| 8.6 | **Coach Detail — book** | Tap "Book Session" | Navigates to booking flow for coaching session |
| 8.7 | **Coaches — empty state** | Search non-existent coach | Shows "No coaches found" |
| 8.8 | **Coaches — error state** | Force failure | Shows "Failed to load coaches" |

---

### 9. Moments

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 9.1 | **Moments — list load** | Navigate to Moments screen | Shows: "Moments" title, Latest / Popular tabs, grid/list of moment cards with: image, caption, likes count, timestamp |
| 9.2 | **Moments — Latest vs Popular** | Toggle between tabs | Tabs switch sort order |
| 9.3 | **Create Moment — load** | Navigate to Create Moment | Shows: "Create Moment" title, image picker area (tap to add photo), caption text field (max 200 chars), character counter, "Publish Moment" button (disabled until image selected) |
| 9.4 | **Create Moment — pick image** | Tap the image area | Opens device image picker; selected image preview shown |
| 9.5 | **Create Moment — upload indicator** | After picking image | Shows "Uploading..." spinner until image uploads to Supabase |
| 9.6 | **Create Moment — add caption** | Type a caption | Character counter updates in real-time (/200) |
| 9.7 | **Create Moment — publish** | Select image + caption, tap "Publish" | Uploads moment to Supabase; navigates back with result; moment added to timeline |
| 9.8 | **Create Moment — validation** | Tap "Publish" without image | Shows error: "Please select an image first" |
| 9.9 | **Moments — empty state** | View moments when none exist | Shows "No moments yet" |
| 9.10 | **Moments — error state** | Force failure | Shows "Failed to load moments" |
| 9.11 | **Moments on Profile** | Check Profile screen "My Moments" section | Shows latest moment card with image, caption, time ago, like/comment counts |

---

### 10. Arabic Localization

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 10.1 | **Language switch to Arabic** | On language screen, select "العربية", tap "تم" | App language switches to Arabic |
| 10.2 | **Arabic — onboarding** | View onboarding in Arabic | All text shown in Arabic; "ابدأ الآن" for Get Started, "المتابعة كزائر" for Guest |
| 10.3 | **Arabic — signup** | Navigate to signup in Arabic | Labels: "الاسم الكامل", "البريد الإلكتروني", "اسم المستخدم", "رقم الهاتف", "تاريخ الميلاد", "الجنس" |
| 10.4 | **Arabic — home screen** | Go to Home in Arabic | "الملاعب", "عرض الكل", "العب مباراة رائعة", "مباراة مفتوحة", "المدربين" |
| 10.5 | **Arabic — RTL layout** | Verify text alignment | UI should flip to Right-to-Left layout for Arabic |
| 10.6 | **Arabic — settings** | Open Settings in Arabic | "الإعدادات والنشاط", "محفوظ", "الإشعارات", "اللغة", "تسجيل الخروج" |
| 10.7 | **Language persistence** | Switch to Arabic, restart app | App should retain Arabic locale on restart |
| 10.8 | **Settings — language change** | Change language from Settings (not initial screen) | Dialog shows "English" and "العربية"; selecting changes locale immediately |
| 10.9 | **Arabic — courts** | Verify courts screen in Arabic | "بحث عن ملاعب...", "الأقرب", "الأعلى تقييماً" |

---

### 11. Guest Mode

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 11.1 | **Continue as Guest — from onboarding** | Tap "Continue as Guest" on onboarding | Navigates to Home without any auth |
| 11.2 | **Guest — home screen** | View Home as guest | Shows "Location" greeting (not user name); all court/coach cards visible |
| 11.3 | **Guest — profile tab** | Tap Profile tab | Shows sign-in prompt or limited profile view (no user data) |
| 11.4 | **Guest — booking restriction** | Try to book a court | Shows "Sign in to book" prompt or navigates to login |
| 11.5 | **Guest — match creation** | Try to start/create a match | Shows sign-in prompt |
| 11.6 | **Guest — exploring** | Browse courts, coaches, explore map | All public browsing available without restrictions |
| 11.7 | **Guest — upgrade to full account** | From guest mode, tap sign-in prompt | Navigates to Login screen normally |

---

### 12. Image Upload

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 12.1 | **Profile picture upload** | In Update Profile, tap avatar area | Opens image picker; selected image uploads to Supabase `avatars` bucket; new avatar shows on profile |
| 12.2 | **Cover/banner photo upload** | In Update Profile, tap cover area | Opens image picker; image uploads to `headers` bucket; new cover shown |
| 12.3 | **Moment photo upload** | In Create Moment, tap image area | Opens image picker; selected image previews in area; uploads to `moments` bucket on publish |
| 12.4 | **Upload — loading indicator** | After picking image | Shows spinner during upload |
| 12.5 | **Upload — error handling** | Force upload failure (e.g., no network) | Error message displayed; upload aborted |
| 12.6 | **Upload — cancel** | Pick an image, then close/pop | No image saved; returns to previous screen |

---

### 13. Edge Cases

| # | Test Case | Steps | Expected Result |
|---|-----------|-------|----------------|
| 13.1 | **Empty state — no courts** | Search or filter to show no results | Shows "No courts found" with empty state icon |
| 13.2 | **Empty state — no bookings** | View Activity with 0 bookings | Shows "No bookings yet" with calendar icon |
| 13.3 | **Empty state — no notifications** | View Notifications with no items | Shows "No notifications" (or similar) |
| 13.4 | **Empty state — no coaches** | Search non-existent coach | Shows "No coaches found" |
| 13.5 | **Empty state — no moments** | View Moments when empty | Shows "No moments yet" |
| 13.6 | **Empty state — no invitations** | View Invitations when empty | Shows "No invitations yet" |
| 13.7 | **Network error — timeout** | Disable network, perform any network action | Graceful error message; no crash |
| 13.8 | **Network error — offline mode** | Go offline, launch app | Shows cached data or error state; doesn't crash |
| 13.9 | **Network error — retry** | After error, restore network, tap retry | Data loads successfully |
| 13.10 | **Invalid form — empty required** | Tap Signup/Login with empty required fields | Inline validation errors shown |
| 13.11 | **Invalid form — email format** | Enter "notanemail" in email field | Validation error: "Please enter a valid email" |
| 13.12 | **Invalid form — phone format** | Enter alphabetic chars in phone field | Input rejected or error shown |
| 13.13 | **Rapid tapping** | Rapidly tap "Next", "Book Now", "Sign up" buttons | Action triggered only once; prevents duplicate submissions |
| 13.14 | **Double submit prevention** | Tap "Pay" twice quickly | Button disabled after first tap; shows loading spinner |
| 13.15 | **Back navigation — booking flow** | Go Booking Step 1 → 2 → 3 → 4, then press back repeatedly | Each back goes to previous step; no skipped states or crashes |
| 13.16 | **Back navigation — OTP** | Enter OTP screen, press back | Goes back to signup/login |
| 13.17 | **Back navigation — from success** | On Booking Success, press Android back | Should NOT go back to payment; should go to Home |
| 13.18 | **Session expiry** | Keep app open > 1 hour, then perform action | Token refresh handled gracefully or user prompted to re-login |
| 13.19 | **Calendar overflow** | Select day 31 in April (30 days) | Day cells correctly capped at 30; no out-of-range errors |
| 13.20 | **Screen rotation** | Rotate device during booking flow | Layout reflows correctly; no clipped content |
| 13.21 | **Keyboard handling** | Open keyboard on any text field, especially in bottom sheets | UI scrolls up; fields not hidden behind keyboard; dismiss keyboard works |
| 13.22 | **Long text input** | Enter very long text in bio/caption fields | Character limit respected (200 for caption); no overflow |
| 13.23 | **Special characters** | Enter special chars in name/username fields | Handled safely; no crashes |

---

## Quick Reference: Route Map

| Route | Screen | Notes |
|-------|--------|-------|
| `/` | SplashScreen | 2s delay → Language |
| `/language` | LanguageScreen | EN/AR selection |
| `/onboarding` | OnboardingScreen | 3 swipeable pages |
| `/signup` | SignUpScreen | Full form + OAuth |
| `/login` | LoginScreen | Phone + password |
| `/otp` | OtpScreen | 6-digit code entry |
| `/profile-setup` | ProfileSetupScreen | Name, bio, sports |
| `/home` | HomeScreen | Main hub |
| `/courts` | CourtsScreen | List + search + filters |
| `/court-details` | CourtDetailsScreen | 4 tabs (Details/Availability/Specs/Moments) |
| `/booking-step1` | BookingStep1Screen | Date & time selection |
| `/booking-step2` | BookingStep2Screen | Duration selection |
| `/booking-step3` | BookingStep3Screen | Add-ons/equipment |
| `/booking-step4` | BookingStep4Screen | Review and confirm |
| `/payment` | PaymentGatewayScreen | Apple Pay / Google Pay / Card / STC Pay |
| `/booking-success` | BookingSuccessScreen | Animated confirmation |
| `/booking-ticket` | BookingTicketScreen | Ticket + add to calendar |
| `/start-match` | StartMatchScreen | 5-step match creation |
| `/create-match` | CreateMatchScreen | 2-step match creation |
| `/invite-players` | InvitePlayersScreen | Search + invite |
| `/open-matches` | OpenMatchesScreen | Browse open matches |
| `/match-filter` | MatchFilterScreen | Filter matches |
| `/receive-invitation` | ReceiveInvitationScreen | Accept/decline |
| `/invitation-details` | InvitationDetailsScreen | Full invitation info |
| `/explore` | ExploreScreen | Map + search + filters |
| `/search-results` | SearchResultsScreen | Courts + Coaches tabs |
| `/recent-search` | RecentSearchScreen | Search history |
| `/reviews` | ReviewsScreen | Court reviews |
| `/add-review` | AddReviewScreen | Rate + comment |
| `/notifications` | NotificationsScreen | Activity feed |
| `/activity` | ActivityScreen | Current bookings + history |
| `/activity-log` | ActivityLogScreen | Past activity timeline |
| `/profile` | ProfileScreen | User profile + moments |
| `/update-profile` | UpdateProfileScreen | Edit profile info |
| `/settings` | SettingsScreen | Notifications, language, logout |
| `/coaches` | CoachesScreen | Coach list + search |
| `/coach-details` | CoachDetailScreen | Coach profile + book |
| `/moments` | MomentsScreen | Community moments |
| `/create-moment` | CreateMomentScreen | Upload photo + caption |

---

## Bug Reporting Template

When reporting a bug, include:

```
**Screen:** [Screen name]
**Route:** [/route-name]
**Test Case Ref:** [e.g., 3.3.6]
**Steps:**
1. ...
2. ...
3. ...

**Expected:** ...
**Actual:** ...

**Device/OS:** [e.g., Pixel 7 / Android 14]
**App Version:** 1.0.0
**Screenshot/Video:** [attached]
```

---

## QA Checklist Summary

- [ ] Splash screen displays correctly and transitions on schedule
- [ ] Language selection persists across app restarts
- [ ] Onboarding flow completes without errors
- [ ] Signup validates all fields and sends OTP
- [ ] OTP entry works with auto-advance and resend
- [ ] Profile setup saves user data
- [ ] Login works with phone + password
- [ ] Google/Apple OAuth works (if configured)
- [ ] Guest mode allows browsing but restricts actions
- [ ] Home screen loads courts, chips filter correctly
- [ ] Court list/search/filters work on Courts screen
- [ ] Court Details 4 tabs render correctly
- [ ] Full booking flow (Steps 1–4 → Payment → Success) completes
- [ ] Booking ticket displays and share/add-to-calendar work
- [ ] Match creation flow completes (both legacy and new)
- [ ] Invite players search and invite works
- [ ] Explore map shows markers and filters correctly
- [ ] Profile displays correct user data
- [ ] Settings toggles persist; language switch works
- [ ] Activity tab shows bookings with correct status
- [ ] Add Review flow submits successfully
- [ ] Coaches list, detail, and book session work
- [ ] Moments create/publish works with image upload
- [ ] All empty states display correctly (no crashes)
- [ ] Network errors handled gracefully
- [ ] Back navigation never crashes or gets stuck
- [ ] Arabic localization applied across all screens
- [ ] RTL layout does not break any UI
- [ ] Rapid tapping does not trigger duplicate actions