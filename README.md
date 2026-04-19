# No Portrait Combat Text

A World of Warcraft addon that disables combat feedback (damage/heal text) on the player, target, focus, and party portrait frames.

- **Author:** Mythris
- **Interface:** 12.0.1 (retail)
- **Category:** Unit Frames

## How it works

On `PLAYER_ENTERING_WORLD`, the addon unregisters the `UNIT_COMBAT` event from `PlayerFrame`, `TargetFrame`, `FocusFrame`, and `PartyMemberFrame1`–`PartyMemberFrame4`, which stops the floating combat text that normally appears over those portraits.
