# Skyrat-tg Quirk Additions Module

This module is the receptacle for adding new Quirks (and their dependencies) which don't directly override the pre-existing TG Quirks.

If you want to override a stock TG quirk or one of it's vars/procs/behaviors, see the (Skyrat-tg Quirk Overrides Module)[/modular_skyrat/master_files/code/modules/quirks/README.md]

## Guide to Adding Quirks on Skyrat-tg

This module should contain any additional Quirks, and their unique dependencies such as new icons and components, which are completely seperate from TG quirks.

Your added Quirk should NOT distribute it's added dependencies across the folders of other modules or exist anywhere in `master_files`. Please implement your changes inside this module as much as possible. If some stock TG behavior/implementation is to be overridden, please use the (Skyrat-tg Quirk Overrides Module)[/modular_skyrat/master_files/code/modules/quirks/README.md]

### Job Blacklisting

If your added Quirk provides a significant mechanical disadvantage to the player, you should blacklist it from Security/Command jobs which that player would not be able to perform at an ample proficiency.

The defines for the Skyrat-tg Quirk-Job blacklist are located within the file `code/DEFINES/~skyrat_defines/jobs.dm`

The `RESTRICTED_QUIRKS_EXCEPTIONS` list associates a blacklisted Quirk with another Quirk which whitelists it. For instance the Mute Quirk may be blacklisted from a job, and the Signer Quirk will undo this and whitelist the Mute Quirk for that job, making it possible to play the game as a Captain who is mute but also proficient at sign-language.

### Quirk Incompatability

If adding a new Quirk, please also consider that it may influence the intended balance provided by other Quirks; for instance, selecting both the Mute and Social Anxiety Quirks at-once is not allowed because they disrupt each other's balance. Social Anxiety stops you from speaking, and so does Mute, removing much of the disadvantageous balance provided by the Social Anxiety Quirk.

### Quirk Balancing

Skyrat has a unique combat and roleplaying environment, and it can be influenced by Quirks. Quirks can give mechanical disadvantages to the player using them, or provide heavy advantage. On Skyrat, Quirks can easily be used to construct more unique characters, but may also sometimes cause a substantial balance-shift to the game; for that reason, some Quirks are blacklisted from certain jobs, with some unique exceptions.
