# livesplit_asl_mgs2
A LiveSplit autosplitter for Metal Gear Solid 2 Substance on PC

This autosplitter is early in development, and may not be well-tested (or even working).

Bug reports are welcomed so they can be stamped out, as is discussion of locations you would like to be able to split (or not split) that are not currently made available.

# Right now...
* A small amount of split logic is untested, and it's missing some split options that some players may want to set
* The ARMSTREN ASL Var Viewer variable only works for Raiden.

# Features
* Automatic splitting for Tanker, Plant, Snake Tales, and VR Missions (per-category)
* Instant splitting when you defeat a boss
* ASL Var Viewer support for room names, game stats, and live information including boss health
* Big Boss (or equivalent) Tanker-Plant rank status for ASL Var Viewer

![Screenshot](README.png)

# Notes
* The LSL files included here will work with the default split location settings. See the mouseover tooltips on each split-related setting in Advanced Options for advice on what to add or remove from your splits.
  * If you want to only show major splits (bosses etc.) in your LiveSplit layout, use a Subsplits component and select "Always Hide Subsplits".
* There are two modes for boss splits. If you would like to use the simpler mode that splits on fadeout, disable the autosplitter setting for it.
* VR Missions splitting is done per-category, when you exit back to the missions menu. Visiting a mission (not beating it!) is usually sufficient to log it, so it's possible to trigger accidentally if you give up on a mission and exit out.
* Raiden (Ninja), Pliskin, Tuxedo Snake and Snake (MGS1) have Variety categories that are entirely contained within the larger Variety mission set the other characters have. To avoid accidentally triggering the smaller categories, they're disabled in settings.
  * If you're doing a character run with one of those characters, you'll need to enable them in the settings.
  * If doing an all-characters run, enable them all, but make sure to start every character's Variety category at Variety 1 and choose Next Stage at each results screen. This is not necessary in any other category.

# ASL Var Viewer
The following variables are available in the Variables category:
* **ASL_Alerts** Number of Alerts
* **ASL_BestCodeName** Shows the best codename available on the current difficulty (except for Very Easy). If you have already failed the requirements, it will instead show the first requirement missed. This can be used to keep track of Big Boss runs.
* **ASL_Continues** Number of Continues
* **ASL_CurrentRoom** The current game location
* **ASL_CurrentRoomCode** The game's internal code for the current location
* **ASL_DamageTaken** Amount of Damage taken [More info](https://metalgearspeedrunners.com/wiki/doku.php?id=mgs2_difficulty_differences#health_values)
* **ASL_Difficulty** The name of the current difficulty
* **ASL_Info** Shows info relevant to your current situation, including boss health values, and information on your grip (when hanging) and O2 (when swimming). Can also be set to show your location (as *ASL_CurrentRoom*) when no contextual info is available.
* **ASL_MechsDestroyed** Number of mechs (Cyphers, etc.) destroyed. This was previously thought to contribute to your codename, but is not actually relevant.
* **ASL_Kills** Number of people Killed
* **ASL_Rations** Number of Rations used
* **ASL_RoomTimer** The number of frames (60/sec) spent in the current room. This can be used to aid in strategy finding.
* **ASL_Saves** Number of Saves
* **ASL_Shots** Number of Shots fired
* **ASL_Strength** Your current character's Arm Strength. Grip Up occurs at 100 and 200.
