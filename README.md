# No Portrait Combat Text

A World of Warcraft (retail) addon that hides combat feedback (the floating damage/heal numbers) on the **player** and **pet** portrait frames.

- **Author:** Mythris
- **Category:** Unit Frames
- **Supported version:** see `## Interface` in the `.toc`

## Settings

Options are in **Esc → Options → AddOns → No Portrait Combat Text**:

- **Hide combat text on Player frame** (on by default)
- **Hide combat text on Pet frame** (on by default)
- **Use Character-Specific Settings**: off by default, so every character follows the account-wide toggles. Turn it on to give the current character its own toggles, which start as a copy of the account values.

## How it works

The addon unregisters the `UNIT_COMBAT` event from `PlayerFrame` and `PetFrame`, which stops the portrait combat text. It applies the settings on load, on `PLAYER_ENTERING_WORLD`, and on `UNIT_PET`, because the pet frame can change when you summon or dismiss a pet. Turning a toggle off registers the event again.
