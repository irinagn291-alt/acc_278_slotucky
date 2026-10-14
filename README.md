# Relaysheet

A couple shares one phone and posts tonight in order. The first half is written alone. The reply stays closed until that half is posted. Then the reply is written, the night stitches, and it stays on this device.

That order is the reason to pick this app. It is not a shared notes list and not a couple chat. One person posts, the other half opens, and only a finished pair is filed.

## Architecture

Today's spread is a relay fold: Idle, PostedA, or Stitched. The fold is the product. Posting the first half is the only way to open the reply, and posting the reply is the only way to file the pair. A one-sided night is not archived. It stays home until both halves land. An early reply and a second post of the first half are refused and kept, so the rule can be tested. Bond days are calendar days from the start of the bonded day to the start of today. Milestones at 7, 30, 90, and 365 count stitched nights.

Home is the split. Filed nights sit on the filmstrip. Names, the night list, how posting works, and settings arrive as sheets. There is no tab bar.

## Art

16-bit pixel art driven by photographic subjects. Hard pixel edges, no anti-aliasing, indexed dither, chunky sprites of split photo frames, shutter blades, and film sprockets. A real photograph reduced to a solid central sprite. Contact-sheet density, dark void around the subject, one bright accent cluster. No letters.

Each image set uses that base, then its own line: a split frame for the icon, a quiet tall field for the splash, cutout figures for onboarding, a closed folio and an empty sleeve for empty states, grain for the card backdrop, a solid shutter button, two frames in sequence for the posting hero, a sprocket pin for success, and a sprocket band for the header.

## Build

```
xcodegen generate
xcodebuild -scheme Relaysheet -destination 'generic/platform=iOS' build
```

How this differs from the batch: Pugillar waits until both sides seal. Sinopia draws on one leaf together. Relaysheet is a relay. The reply cannot be read until the first half is posted.
