# Skyrat-tg Quirk Additions Module

This module is the receptacle for adding new Quirks (and their dependencies) which don't directly override the pre-existing TG Quirks.

If you want to override a stock TG quirk or one of it's vars/procs/behaviors, see the [Skyrat-tg Quirk Overrides Module](/modular_skyrat/master_files/code/modules/quirks/README.md)

### Policy Guidelines
- **All Quirks** must be explicitly balanced to provide *minimal-at-best* advantages.
- **Positive Quirks** *may* alter the experience of the game, but *must never* provide any strong advantages.
- **Negative Quirks** *may* provide heavy disadvantages, and are intended to add challenge to playing a character.

## Guide to Adding Quirks on Skyrat-tg

This module should contain any additional Quirks, and their unique dependencies such as new icons and components, which are completely seperate from TG quirks.

Your added Quirk should NOT distribute it's added dependencies across the folders of other modules or exist anywhere in `master_files`. Please implement your changes inside this module as much as possible. If some stock TG behavior/implementation is to be overridden, please use the (Skyrat-tg Quirk Overrides Module)[/modular_skyrat/master_files/code/modules/quirks/README.md]

### Quirk Balancing

Skyrat has a unique combat and roleplaying environment, and it can be influenced by Quirks. Quirks *may* give any degree of mechanical disadvantage to the Quirk holder. Quirks *must not provide* significant mechanical advantage to the Quirk holder. On Skyrat, Quirks can easily be used to construct more unique characters, but may also sometimes cause a substantial balance-shift to the game if they are implemented incorrectly; for that reason, some Quirks are incompatible with each other, and are also blacklisted from certain jobs with some unique exceptions.

### Quirk Incompatability

If adding a new Quirk, please also consider that it may influence the intended balance provided by other Quirks; for instance, selecting both the Mute and Social Anxiety Quirks at-once is not allowed because they disrupt each other's balance. Social Anxiety stops you from speaking, and so does Mute, removing much of the disadvantageous balance provided by the Social Anxiety Quirk.

The Quirk incompatability list is located within the file `code/controllers/subsystem/processing/quirks.dm`

The `quirk_blacklist` list associates Quirks which are incompatible with one another. Any Quirks listed adjacently to each other in the same list will conflict, and become un-selectable by the player if they attempt to add incompatible quirks. For example, the Quirks "No Guns", "Chunky Fingers", and "Stormtrooper Aim" are listed as incompatible with each other; selecting any Quirk in the list (such as "Chunky Fingers") will cause the rest of the Quirks in the list to become un-selectable by the player.

### Job Blacklisting

If your added Quirk provides a significant mechanical disadvantage to the player, you should blacklist it from Security/Command jobs which that player would not be able to perform at an ample proficiency.

The defines for the Skyrat-tg Quirk-Job blacklist are located within the file `code/DEFINES/~skyrat_defines/jobs.dm`

The `RESTRICTED_QUIRKS_EXCEPTIONS` list associates a blacklisted Quirk with another Quirk which whitelists it. For instance the Mute Quirk may be blacklisted from a job, and the Signer Quirk will undo this and whitelist the Mute Quirk for that job, making it possible to play the game as a Captain who is mute but also proficient at sign-language.
