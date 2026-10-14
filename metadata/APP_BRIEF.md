<!-- gf-brief source=b0943f344ca2815228392d8e9deb005bb6d1800a81e845f44f3523458875027b written=2026-10-14T14:44:06+03:00 -->
# Slotucky

## What it is
Slotucky is for two people who share one phone and take turns on a nightly prompt. One person writes the first half; the reply stays closed until that half is posted; then the other person writes the reply and the night stitches onto a list of filed nights. Everything they write stays on this device.

## Launch and onboarding
On a new device the system launch screen has no title. If opening takes a moment, a spinner reads **“Opening the spread”**.

The introduction is four swipeable pages with page dots. **“Next”** and **“Skip”** sit on every page. **“Skip”** names the seats from the fields (or **“Ada”** and **“Ren”** if a field is blank) and opens the spread.

1. Title **“Two seats, one phone”**. Line **“A nightly prompt with a first half and a reply.”** Buttons **“Next”**, **“Skip”**.
2. Title **“Post the first half”**. Line **“The reply stays closed until the first half is posted.”** Buttons **“Next”**, **“Skip”**.
3. Title **“Then it stitches”**. Line **“Both halves land on the shelf as one spread.”** Buttons **“Next”**, **“Skip”**.
4. Title **“Name the seats”**. Line **“You can change these names later.”** Field **“Your name”** (starts as **“Ada”**). Field **“Their name”** (starts as **“Ren”**). Buttons **“Continue”**, **“Skip”**.

**“Continue”** and **“Skip”** both finish the introduction and open the home spread with those names. A blank name becomes **“Ada”** or **“Ren”**.

After that, the home spread is waiting on the first half: title **“Write the first half.”** Line **“Ada writes first. Ren stays closed until that post.”** (the names are whatever was just saved). The reply half shows **“Closed until the first half is posted.”**

If the introduction is already done and there is still no bond, a full page reads **“Start the bond”**, **“Two halves. Write the first line.”**, button **“Start together”**. That button opens **“Together”**. If both people are still unnamed there, **“Together”** repeats **“Name both people”**, **“Two halves. Write the first line.”**, **“Start together”**, and that second tap names them **“Ada”** and **“Ren”**.

On the iOS Simulator, a first launch with no saved nights can skip the introduction and open already mid-night: seats **“Ada”** and **“Ren”**, four filed nights on **“Nights”**, and tonight’s first half already posted so the next tap is **“Post”** on the reply. A physical device does not get that sample.

## Screens

### Home spread
There is no tab bar. The word **“Slotucky”** sits at the top left. Four icon buttons sit at the top right. They have no visible titles. VoiceOver reads **“Days together”**, **“Filed nights”**, **“How posting works”**, and **“Settings”**.

- **“Days together”** opens the **“Together”** sheet.
- **“Filed nights”** opens the **“Nights”** sheet.
- **“How posting works”** opens the **“Posting”** sheet.
- **“Settings”** opens the **“Settings”** sheet.

Under the icons, a job title and a job line change with the night:

| When | Title | Line |
| --- | --- | --- |
| Names are missing | **“Name both people.”** | **“Two halves. Write the first line.”** |
| Waiting on the first half | **“Write the first half.”** | **“{first name} writes first. {reply name} stays closed until that post.”** |
| First half is posted | **“Post the reply.”** | **“{first name} posted. {reply name} answers next.”** |
| Both halves are filed tonight | **“Tonight is filed.”** | **“Both halves are filed. A new night starts after midnight.”** |
| A past night is open | **“A filed night”** | **“Back to tonight when you want the open half.”** |

If a past night is open, **“Back to tonight”** returns to the open half. If tonight’s first half is posted and you are not looking at a past night, **“Peel”** drops that post (VoiceOver: **“Peel the last post”**). The reply closes again and the first-half field is cleared.

A notice can appear above the two halves:

- **“Write a line before you post.”**
- **“Name both people before you post.”**
- **“This half is already posted. Peel it if you want a rewrite.”**
- **“The first half posts first. This reply was not filed.”**

If the spread cannot be read: **“The spread could not be read.”**, a recovery line (see Behaviours), and **“Try again”**.

The page is two halves with a thin rule between them. The open half is wide; the closed half is narrow. On iPhone the **“Nights”** list sits under the halves. On iPad it sits beside them.

Each half shows a name and a status chip. The first half is titled with the first seat’s name, or **“First half”** if that name is empty. The reply is titled with the reply seat’s name, or **“Reply”** if that name is empty. Status words are **“Waiting”**, **“Posted”**, or **“Stitched”**.

- Waiting on the first half: first half **“Waiting”**, reply **“Waiting”** and closed.
- After the first post: first half **“Posted”**, reply **“Waiting”** and open.
- After both posts: first half **“Posted”**, reply **“Stitched”**.
- A past night: first half **“Posted”**, reply **“Stitched”**.

The closed reply shows decorative art and **“Closed until the first half is posted.”** It has no field and no **“Post”**.

The open half shows that half’s prompt, a frame, a drawing strip, **“Add frame photo”**, the field **“Write this half”**, and **“Post”**.

**“Add frame photo”** opens the system photo picker for images. The drawing strip has no label; a finger or stylus can mark the frame. **“Post”** files the open half. While it is working, **“Post”** shows a spinner and will not take a second tap. A short overlay then reads **“Posted”** or **“Stitched”** and fades on its own.

The field **“Write this half”** on the reply already contains **“I would say come home. I kept the light on.”** so **“Post”** on the reply can be tapped without typing. The first-half field starts empty.

The keyboard toolbar has **“Done”**. Tapping outside the field dismisses the keyboard.

Tonight’s prompt is one of these pairs (the pair follows the calendar day of that night). The first half sees the first line while it is open; the reply sees the second line once it is open. A past night shows that night’s pair on both halves.

- **“What did the light look like when you got home?”** / **“What did you want to tell them first?”**
- **“Name one thing still on the table from yesterday.”** / **“What would you clear, and what would you keep?”**
- **“Where did your feet take you today?”** / **“Where would you walk them next?”**
- **“What stayed quiet that usually does not?”** / **“What did that quiet make room for?”**
- **“What did your hands finish today?”** / **“What do you want their hands to know?”**
- **“What was outside the window at dusk?”** / **“What did you hope they noticed too?”**
- **“What did you actually eat, not what you planned?”** / **“What would you cook for them tomorrow?”**
- **“Who did you think of without meaning to?”** / **“What would you say if they walked in right now?”**

The list titled **“Nights”** is newest first. If it is empty: **“Filed nights show up here.”** Each row shows the day-of-month number, the date in the device’s medium date format, the first-half text, and **“Selected”** when that night is open. Tapping a row opens that night on the spread (VoiceOver: **“Open night {date}”**).

### Together
Sheet title **“Together”**. Toolbar **“Close”** (VoiceOver: **“Close”**) returns to the spread.

If the bond cannot be read: **“The file could not be read”**, the recovery line, **“Try again”**.

If both people are unnamed: **“Name both people”**, **“Two halves. Write the first line.”**, **“Start together”**. That button names them **“Ada”** and **“Ren”** and shows the filled sheet.

Filled sheet:

- **“{first name} and {reply name}”**
- **“{n} days together”** (whole days from the start date to today, in the device’s number format; **0** on the first day)
- **“Started {date}”** (medium date, no time)
- **“Save a name change, or close to return to tonight.”**

Section **“Names”**. The current first name, then field **“First name”**. The current reply name, then field **“Reply name”**. **“Save names”** keeps both names if neither field is blank. **“Close”** without **“Save names”** leaves the old names.

**“First color”**: **“Warm”**, **“Paper”**. **“Reply color”**: **“Warm”**, **“Paper”**. The current choice is selected (VoiceOver: **“Warm, selected”** / **“Warm, not selected”**, and the same for **“Paper”**). A tap saves the color at once.

Section **“Nights kept”**. Line **“Stitched spreads that have lasted this long.”** Four rows, always: **“7 days”**, **“30 days”**, **“90 days”**, **“365 days”**, each with **“{n} nights”** for how many filed nights are at least that old.

### Nights
Sheet title **“Nights”**. Toolbar **“Close”** (VoiceOver: **“Close shelf”**) returns to the spread.

If the list cannot open: **“The shelf could not open”**, the recovery line, **“Try again”**.

If nothing is filed: **“Nothing stitched yet”**, **“Two halves. Write the first line.”**, **“Back to the spread”**.

If there are filed nights, each row shows the medium date, the first-half text, the reply text, and **“Open this night”**. A tap opens that night on the spread and closes the sheet (VoiceOver: **“Open night {date}”**). Newest first. There is no delete on a single night.

### Posting
Sheet title **“Posting”**. Toolbar **“Close”** returns to the spread.

Title **“Post the first half, then the reply.”** A status line:

- **“Name both people, then write the first half.”**
- **“Tonight is waiting on the first half.”**
- **“The first half is posted. The reply can be written now.”**
- **“Tonight is stitched.”**

Then three steps:

- **“Waiting”** — **“The first half is written alone. The reply stays closed.”**
- **“Posted”** — **“After that post, the reply and the answer both show.”**
- **“Stitched”** — **“The reply is posted, and the night is filed.”**

**“A one-sided night stays on the spread until both halves land.”**

**“Back to the spread”** dismisses the sheet.

### Settings
Sheet title **“Settings”**. Toolbar **“Close”** (VoiceOver: **“Close settings”**) returns to the spread.

If the spread cannot be read and there is nothing to show: **“Settings could not read the spread”**, the recovery line (or **“Try again.”**), **“Try again”**.

If there are no filed nights: **“No spreads to export”**, **“Two halves. Write the first line.”**, **“Back to the spread”**, then the same three links as below.

If there are filed nights, section **“Export”**: **“{n} stitched spreads are ready as a PDF.”** **“Export PDF”** writes a PDF of every filed night (date plus both texts). If that fails: **“The PDF could not be written. Try again.”** After a successful export, **“Share PDF”** opens the system share sheet.

Always (except the hard read-failure page):

- **“Show the introduction again”** closes Settings and returns to the four introduction pages. The name fields show **“Ada”** and **“Ren”** again. **“Continue”** or **“Skip”** writes whatever is in those fields over the current names. Filed nights stay.
- **“Reset all data”** opens a confirmation titled **“Reset all data”** with **“Stitched spreads on this device are removed.”** **“Reset all data”** clears the bond and every filed night and returns to the introduction. **“Keep the spreads”** cancels.
- **“Contact”** opens the support page.

## Features
- Two seats on one phone, a first half and a reply
- A nightly two-line prompt; the reply stays closed until the first half is posted
- **“Post”** on the open half
- **“Peel”** to drop tonight’s first half before the reply is posted
- A night **stitches** only when both halves are posted
- A one-sided night stays on the spread until both halves land
- A new night starts after local midnight, and only after tonight is stitched
- Filed nights on the **“Nights”** list and on **“Nights”** in the sheet
- Open a past night, then **“Back to tonight”**
- Name the seats and change them later
- **“First color”** and **“Reply color”**: **“Warm”** or **“Paper”**
- **“{n} days together”** and **“Started {date}”**
- **“Nights kept”** at **7**, **30**, **90**, and **365** days
- Optional frame photo and frame marks on the open half
- **“Export PDF”** and **“Share PDF”** of stitched spreads
- **“Show the introduction again”**
- **“Reset all data”**
- **“Contact”**

## Behaviours that can look like bugs
- The reply shows **“Closed until the first half is posted.”** and has no **“Post”** until the first half is posted. Write a line in **“Write this half”** on the first half and tap **“Post”**.
- **“Post”** with an empty first half shows **“Write a line before you post.”** Type at least one character that is not only spaces. The reply field is already filled, so that half can be posted without editing.
- After the first half is posted, that half has no **“Post”**. To rewrite it, tap **“Peel”**. **“Peel”** clears the first-half field and closes the reply again.
- After **“Stitched”**, neither half has **“Post”**. The line **“Both halves are filed. A new night starts after midnight.”** is the wait. The next first half opens after local midnight.
- If only the first half is posted, that night does not move to **“Nights”** and does not roll at midnight. **“A one-sided night stays on the spread until both halves land.”** Post the reply, or **“Peel”**.
- Opening a past night hides **“Post”** and **“Peel”**. Tap **“Back to tonight”**.
- **“Save names”** does nothing if **“First name”** or **“Reply name”** is blank. There is no extra message. Type both names.
- **“Close”** on **“Together”** discards unsaved name typing. Colors already tapped are kept.
- **“Show the introduction again”** then **“Continue”** or **“Skip”** can rename the seats back to **“Ada”** and **“Ren”** unless the fields are edited.
- **“Nights”** empty copy: **“Filed nights show up here.”** / sheet **“Nothing stitched yet”**. File both halves of a night.
- **“No spreads to export”** until at least one night is stitched.
- **“{n} days together”** is **0** on the day the bond starts.
- **“Nights kept”** can show **“0 nights”** on every row until filed nights are old enough.
- **“Post”** greys and spins while a post is in flight.
- Slow open: **“Opening the spread”**.
- Read or save problems show **“The spread could not be read.”** plus one of: **“The spread file was unreadable. Restored the previous copy.”**, **“The spread file was unreadable. Restored the saved copy.”**, **“The spread file was unreadable. Started from a blank bond.”**, **“The spread could not be saved.”**, **“Reset could not remove the spread file.”** Use **“Try again”** where it is offered.
- A frame photo and an unsent drawing vanish if the app is left before **“Post”**. After **“Post”**, frame marks stay; the photo does not come back after a relaunch. Past nights show text and saved marks, not the photo.
- Typed lines that were not posted do not come back after a relaunch. The reply field shows **“I would say come home. I kept the light on.”** again.
- There is no way to delete one night. Only **“Reset all data”** clears the list.
- On the Simulator, **“Reset all data”** then a fresh launch can bring the sample nights back. On a physical device the reset stays empty.

## Starter content and resume
On every launch the reply field starts as **“I would say come home. I kept the light on.”** The introduction fields start as **“Ada”** and **“Ren”**.

On the Simulator only, a first launch can also seed seats **“Ada”** and **“Ren”**, a start date 40 days back, tonight’s first half **“I thought of you on the stairs, before I meant to.”**, and four filed nights (12, 9, 5, and 2 days ago):

- **“The porch light was already on when I turned the corner.”** / **“I wanted you to see it before I said anything.”**
- **“Your cup was still on the table this morning.”** / **“I left it there. It can stay.”**
- **“I walked past the river instead of the hill.”** / **“Next time we stop where the ducks were.”**
- **“The window went blue and I did not turn a lamp on.”** / **“I hoped you were watching that blue too.”**

A posted first half that is still waiting for a reply comes back after a relaunch and after the date changes. A stitched night stays on **“Nights”**. Unsent typing, unsent drawings, and frame photos do not resume.

## Permissions
None. **“Add frame photo”** uses the system photo picker. The app does not ask for camera, photos, microphone, or tracking, and there is no usage-description string.

## Absent
Genuinely absent: login or accounts, in-app purchase, ads, analytics, public user-generated content (no feed, no report or block), account deletion flow, App Tracking Transparency prompt.

## Data and support
Posted halves, names, colors, and filed nights stay on this device. **“Contact”** in **“Settings”** is the on-screen support control and opens the support page. **“Share PDF”** is the only way those nights leave the device, and only if the person shares the file.

## Scanning and health
None. The app does not scan barcodes or QR codes. It does not show health, medical, or product-health information. The meal prompt is only a personal question, not advice, and there are no citations.

## Platform
The on-screen language is English. Dates and counts follow the device locale (medium date, no time; grouped whole numbers). The night boundary is local midnight, including short and long daylight-saving days. There is no region lock. Portrait only, full screen, dark appearance. iPhone and iPad. Minimum iOS 17.0.

## Category
Lifestyle
