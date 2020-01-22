# livesplit_asl_mgs2
A LiveSplit autosplitter for Metal Gear Solid 2 Substance on PC

This autosplitter is early in development, and may not be well-tested (or even working).

Bug reports are welcomed so they can be stamped out, as is discussion of locations you would like to be able to split (or not split) that are not currently made available.

# Features
* Tanker, Plant and Tanker-Plant
* Snake Tales
* VR Missions (per-category)
* Instant splitting when you defeat a boss
* ASL Var Viewer support for room names and some game stats
* Big Boss (or equivalent) Tanker-Plant rank status for ASL Var Viewer

![Screenshot](README.png)

# Notes
* There are two modes for boss splits. The default is to split on the next room change. The more complex version which watches boss health (and bombs) and splits instantly should be enabled via an ASL setting.
* VR Missions splitting is done per-category, when you exit back to the missions menu. Visiting a mission (not beating it!) is usually sufficient to log it, so it's possible to trigger accidentally if you give up on a mission and exit out.
* Raiden (Ninja), Pliskin, Tuxedo Snake and Snake (MGS1) have Variety categories that are entirely contained within the larger Variety mission set the other characters have. To avoid accidentally triggering the smaller categories, they're disabled in settings.
  * If you're doing a character run with one of those characters, you'll need to enable them in the settings.
  * If doing an all-characters run, enable them all, but make sure to start every character's Variety category at Variety 1 and choose Next Stage at each results screen. This is not necessary in any other category.
