# Employee Management App - Complete Documentation

## App Ki Korbe? (App er Uddeshyo)

Ei app ta ekta **Employee Management System** - mane office er employee ra ei app use kore:
- Office e dhukle check-in korbe
- Office theke berole check-out korbe
- Daily ki ki kaj korche seta task hisebe add korbe
- Nijer profile dekhte parbe

Basically office er HR department er kaj ta easy kore dei ei app.

---

## App e Ki Ki Feature Ache?

### 1. Login System (Login Kora)

Employee ra nijer **Employee ID** ar **Password** diye login korbe.

**Demo te 2 jon employee ache:**

| Employee ID | Password | Naam | Designation |
|------------|----------|------|-------------|
| L3T2077 | password123 | Kaniz Fatima | Senior Executive |
| L3T2088 | password456 | Rahim Uddin | Software Engineer |

- Ekbar login korle app ta remember rakhe (next time automatic login hobe)
- Logout korle abar notun kore login korte hobe

---

### 2. Home Page (Main Screen)

Login korar por ei page ta dekha jay. Ekhane 2 ta main jinis thake:

**A. Attendance Section (Uporer dike)**
- Aaj check-in korecho ki na
- Check-in korar button
- Check-out korar button
- Kon type e kaj korcho (Office theke, bari theke, tour e)

**B. Today's Task (Nicher dike)**
- Ajker top 3 ta task dekha jay
- "View All Tasks" button diye sob task dekhte parba

**Navigation:**
- Profile icon (upor right e) - Profile page e jabe
- Tasks icon - Task list page e jabe
- Attendance icon - Attendance history dekhte parbe

---

### 3. Attendance System (Hajira)

**Check-In Korte:**
1. Home page e "Check In" button e click koro
2. Work type select koro:
   - **WFH** = Work From Home (bari theke kaj)
   - **Field** = Field work (baire giye kaj)
   - **Tour** = Business tour (office er tour e)
3. Automatic time record hoye jabe

**Check-Out Korte:**
1. "Check Out" button e click koro
2. Time automatic save hobe

**Attendance History Dekhte:**
1. Attendance page e jao
2. Month select koro (Dropdown theke)
3. Table te dekhte parbe:
   - Date
   - Kibar (Saturday, Sunday, etc.)
   - Check-in time
   - Check-out time
   - Work type

---

### 4. Task Management (Daily Kaj er List)

Employee ra daily ki ki kaj korche seta record kore rakhte pare.

**Notun Task Add Korte:**
1. Plus (+) button e click koro
2. Form fill up koro:
   - **Time Slot**: Kon somoy kaj ta korcho
     - 9:00 AM - 10:30 AM
     - 10:30 AM - 12:00 PM
     - 12:00 PM - 1:00 PM
     - 2:00 PM - 3:30 PM
     - 3:30 PM - 5:00 PM
     - 5:00 PM - 6:00 PM
     - 6:00 PM - 6:30 PM
   - **Status**: Kaj er obostha
     - **Completed** (Shesh hoyeche) - Green color
     - **In Progress** (Cholche) - Blue color
     - **Next** (Porer kaj) - Orange color
     - **Blocking** (Atke geche) - Red color
   - **Task**: Ki kaj korcho (description)
   - **Remarks**: Extra kono comment

**Task Edit Korte:**
- Task card e click koro
- Information update koro
- Save koro

**Task Delete Korte:**
- Task card e red delete icon e click koro

---

### 5. Profile Page

Employee er sob information ekhane dekha jay:
- **Photo** (profile picture)
- **Name** (naam)
- **Employee ID**
- **Designation** (ki post e ache)
- **Department** (kon department e kaj kore)
- **Location** (office location)
- **Joining Date** (kokhon join koreche)
- **Confirmation Date** (kokhon confirm hoyeche)
- **Service Length** (koto din dhore kaj korche)

---

## Technology Ki Use Hoyeche?

Keu jiggesh korle bolo:

### Frontend (App er Design Part)
- **Flutter** - Google er framework, ekbar code likhe Android ar iOS dui jaygar app banano jay

### Backend (Data Save er Part)
- **Back4App** - Cloud database, Parse Server use kore
- Sob data (attendance, task, profile) ekhane save hoy

### State Management
- **Provider** - App er moddhe data manage korar jonno

### Local Storage
- **SharedPreferences** - Login session save rakhte (offline e o remember thake)

---

## App er Structure (Folder Ki Ki Ache)

```
lib/ (main code folder)
│
├── core/ (settings ar config)
│   ├── config/ - Back4App er connection settings
│   ├── constants/ - Color ar API address
│   └── theme/ - App er design theme
│
├── data/ (data model)
│   └── models/
│       ├── user_model.dart - Employee er data structure
│       ├── attendance_model.dart - Attendance er data structure
│       └── task_model.dart - Task er data structure
│
└── presentation/ (UI - jeta user dekhe)
    ├── pages/ - Sob screen/page
    │   ├── login/ - Login page
    │   ├── home/ - Main dashboard
    │   ├── profile/ - Profile page
    │   ├── attendance/ - Attendance history
    │   └── task_list/ - Task list
    │
    ├── providers/ - Data management logic
    │   ├── auth_provider.dart - Login/Logout handle
    │   ├── attendance_provider.dart - Attendance handle
    │   └── task_provider.dart - Task handle
    │
    └── widgets/ - Reusable UI components
        ├── attendance_section.dart
        ├── task_card.dart
        └── create_task_dialog.dart
```

---

## Kivabe Data Flow Hoy?

```
User Login kore
      ↓
App check kore Employee ID thik ki na
      ↓
Back4App e connection hoy
      ↓
Home Page load hoy
      ↓
Employee er Task ar Attendance fetch hoy database theke
      ↓
User dekhte pare ar update korte pare
      ↓
Save korle Back4App e data save hoy
```

---

## Future e Ki Add Kora Jabe?

1. **Admin Panel** - Admin ra sob employee er data dekhte parbe
2. **GPS Tracking** - Automatic location based attendance
3. **Leave Management** - Chuti apply korar system
4. **Notification** - Reminder ar alert
5. **Report Generation** - Monthly attendance ar task report
6. **Biometric Integration** - Fingerprint diye attendance

---

## Summary (Shonkhepe)

Ei app ta basically ekta **Employee Self-Service Portal**:

| Feature | Ki Kore |
|---------|---------|
| Login | Employee ID diye login |
| Attendance | Check-in/Check-out kore hajira dei |
| Task | Daily kaj record kore |
| Profile | Nijer information dekhe |

**Tech Stack:**
- Flutter (Frontend)
- Back4App/Parse Server (Backend/Database)
- Provider (State Management)

**Key Points Remember Korar Jonno:**
1. Ei ta mobile app - Flutter diye banano
2. Data cloud e save hoy - Back4App use kori
3. Employee ra nije nijer attendance ar task manage kore
4. Clean architecture follow kora hoyeche
5. Future e easily feature add kora jabe

---

## Development Info

- **Framework:** Flutter 3.x
- **Language:** Dart
- **Backend:** Back4App (Parse Server)
- **State Management:** Provider Pattern
- **Local Storage:** SharedPreferences

---

*Ei documentation ta non-technical person er jonno banano hoyeche jate tara easily app ta bujhte pare ar onno ke explain korte pare.*
