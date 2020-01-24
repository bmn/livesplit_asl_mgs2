/*
  MGS2 Autosplitter
  Main room configuration starts around line 115
*/

state("mgs2_sse") {
  uint      GameTime: 0xD8AEF8;
  int       RoomTimer: 0x3E315E, 0x17;
  
  string10  RoomCode: 0x601F34, 0x2C;

  byte2     Shots: 0x3E315E, 0x73;
  byte2     Alerts: 0x3E315E, 0x75;
  byte2     Continues: 0x3E315E, 0x65;
  byte2     Rations: 0xF80DB, 0x4C3;
  byte2     Kills: 0x3E315E, 0x77;
  byte2     Damage: 0x3E315E, 0x79;
  byte2     Saves: 0x3E315E, 0x69;
  byte2     Mechs: 0x3E315E, 0x8B;
  byte2     StrengthRaiden: 0x3E315E, 0x63;
  byte2     StrengthSnake: 0xD8AEEE;
  
  byte      CurrentHealth: 0x3E315E, 0x2D;
  byte      MaxHealth: 0x3E315E, 0x2F;
  byte2     CurrentO2: 0x3E315E, 0x31;
  byte2     CurrentGrip: 0x618BAC, 0x80;
  byte2     GripMultiplier: 0xD8F500;
  byte      RadarOn: 0xF80DB, 0x4CA;

  uint      STCompletionCheck: 0x4A6C20, 0xB01; // This is a random offset that works well for Snake Tales

  int       OlgaStamina: 0xAD4F6C, 0x0, 0x1E0, 0x44, 0x1F8, 0x13C;

  byte2     FatmanHealth: 0xB6DEC4, 0x24E;
  int       FatmanStamina: 0x664E78, 0x88;
  byte      FatmanBombsActive: 0x664E7C, 0x280;

  byte2     HarrierHealth: 0x619BB0, 0x5C;

  byte2     VampStamina: 0x664EA0, 0x15A;
  byte2     VampHealth: 0x664EA0, 0x158;

  byte      SolidusHealth: 0x664E7C, 0xB8;
  byte      SolidusStamina: 0x664E78, 0xC8;

  byte2     Vamp2Health: 0x61FBB8, 0x2AE;
  byte2     Vamp2Stamina: 0x664E7C, 0x48;

  byte2     RaysHealth: 0xAD4EA4, 0x54, 0x10, 0x10, 0x170, 0x7E0;
}

reset {
  string CurrentRoomName, OldRoomName;
  
  if (!settings["resets"]) return false; // resets not enabled anyway!
  
  if (current.RoomCode == old.RoomCode) return false; // room is unchanged
  
  // reset right away if we're going to main menu from missions
  if ( (current.RoomCode == "n_title") && (old.RoomCode == "mselect") ) {
    vars.VRMissions = false;
    return true;
  }
  
  // otherwise... was the old room NOT a menu?
  if (vars.Menus.TryGetValue(old.RoomCode, out OldRoomName)) return false;
  
  // is the new room a menu?
  if (!vars.Menus.TryGetValue(current.RoomCode, out CurrentRoomName)) return false;
  
  // just to be sure, we didn't just complete a Snake Tales mission, did we?
  if (old.RoomCode == "tales") return false;
  
  // and we're not currently on the missions menu?
  if (current.RoomCode == "mselect") return false;
  
  OldRoomName = vars.GetRoomName(old.RoomCode);
  if (CurrentRoomName == "") CurrentRoomName = vars.GetRoomName(current.RoomCode);
  
  vars.Debug("In-game [" + old.RoomCode + "] " + OldRoomName + " > Menu [" + current.RoomCode + "] " + CurrentRoomName);
  vars.ResetBossData(); // resetting on an unbeaten boss can cause some really bad things to happen in insta
  vars.ResetBigBossData(); // this is our 3 allowed alerts
  return true;
}

start {
  int i;
  string CurrentRoomName, OldRoomName;
  
  if (old.RoomCode == "") return false;
  
  if (current.RoomCode == old.RoomCode) return false; // room is unchanged
    
  // was the old room a menu?
  if (!vars.Menus.TryGetValue(old.RoomCode, out OldRoomName)) return false;
  
  // is the new room NOT a menu?
  if (vars.Menus.TryGetValue(current.RoomCode, out CurrentRoomName)) return false;
  
  CurrentRoomName = vars.GetRoomName(current.RoomCode);
  if (OldRoomName == "") OldRoomName = vars.GetRoomName(old.RoomCode);
  
  vars.Debug("Menu [" + old.RoomCode + "] " + OldRoomName + " > In-game [" + current.RoomCode + "] " + CurrentRoomName);
  
  // Enable VR Missions mode if coming from the missions menu
  if (old.RoomCode == "mselect") vars.VRMissionsEnable();
  
  // Might as well!
  vars.UpdateBigBoss();
  
  return true;
} 

startup {
  vars.Initialised = false;
  
  // Debug message handler
  //settings.Add ("debug", false, "Log debug messages to " + vars.DebugPath);
  string DebugPath = System.IO.Path.GetDirectoryName(Application.ExecutablePath) + "\\mgs2_sse_debug.log";
  vars.DebugTimer = 0;
  vars.InfoTimer = 0;
  vars.DebugTimerStart = 120;
  Action<string> Debug = delegate(string message) {
    //if ( (Convert.ToString(settings.GetType()) != "LiveSplit.ASL.ASLSettingsBuilder") && (settings["debug"]) ) {
      using(System.IO.StreamWriter stream = new System.IO.StreamWriter(DebugPath, true)) {
        stream.WriteLine(message);
        stream.Close();
      }
    //}
    print("[MGS2AS] " + message);
    vars.ASL_Debug = message;
    // also overwrite the previous message if we're already showing the "splitting now" message
    if (vars.DebugTimer != vars.DebugTimerStart) vars.PrevDebug = message;
  };
  vars.Debug = Debug;
  
  Action<string> Info = delegate(string message) {
    vars.ASL_Info = message;
  };
  vars.Info = Info;
  
  Action<string> DebugInfo = delegate(string message) {
    Debug(message);
    Info(message);
  };
  vars.DebugInfo = DebugInfo;
  
  
  /* MAIN CONFIGURATION STARTS */
  
  vars.Menus = new Dictionary<string, string> {
    { "init", "init" }, // TODO define
    { "select", "select" },
    { "n_title", "Main Menu" },
    { "mselect", "VR Mission select" },
    { "sselect", "Snake Tales episode select" }
  };
  
  List<string> Areas = new List<string>() {
    "tanker", "Tanker",
    "plant", "Plant",
    "snaketales", "Snake Tales"
  };
  
  
  // The room codes and names are done in this weird way for a mix of performance
  // (after the slower initial load) and ease of editing.
  // The dictionary vars.Rooms will be auto-populated from this
  // and should be used by other parts of the script
  Dictionary< string, List<string> > Rooms = new Dictionary< string, List<string> >() {
    { "tanker", new List<string> {
      "w00a", "Aft Deck",
      "w00b", "Navigational Deck, port wing (vs Olga)",
      "d05t", "Navigational Deck, port wing cutscenes",
      "w00c", "Navigational Deck, wing",
      "w01a", "Deck-A, crew's quarters",
      "w01b", "Deck-B, crew's quarters",
      "w01c", "Deck-C, crew's quarters, port",
      "w01d", "Deck-D, crew's quarters",
      "d04t", "Deck-E cutscene",
      "w01e", "Deck-E, the bridge",
      "w01f", "Deck-A, crew's lounge",
      "w02a", "Engine Room",
      "w03a", "Deck-2, port",
      "w03b", "Deck-2, starboard",
      "d10t", "Hold No.1 cutscene", // this isn't a great guard rush split as the 1st cutscene isn't splittable
      "w04a", "Hold No.1",
      "w04b", "Hold No.2",
      "d11t", "Hold No.3 cutscene",
      "w04c", "Hold No.3",
      "d12t", "Tanker ending: confrontation" // ending 1
    } },
    { "plant", new List<string> {
      "w11a", "Strut A Deep Sea Dock",
      "d005p01", "Strut A elevator cutscene",
      "w11b", "Strut A Deep Sea Dock (with bomb)",
      "w11c", "Strut A Deep Sea Dock (vs Fortune)",
      "w12a", "Strut A roof (before Stillman)",
      "w12c", "Strut A roof",
      "w12b", "Strut A Pump Room",
      "w13a", "AB connecting bridge (before Stillman)",
      "w13b", "AB connecting bridge",
      "w14a", "Strut B Transformer Room",
      "d012p01", "BC connecting bridge cutscene",
      "w15a", "BC connecting bridge (before Stillman)",
      "w15b", "BC connecting bridge",
      "w16a", "Strut C Dining Hall (before Stillman)",
      "w16b", "Strut C Dining Hall",
      "w17a", "CD connecting bridge",
      "w18a", "Strut D Sediment Pool",
      "w19a", "DE connecting bridge",
      "w20a", "Strut E Parcel Room",
      "w20b", "Strut E heliport",
      "w20c", "Strut E heliport (vs Fatman)",
      "d021p01", "Strut E heliport cutscenes",
      "w20d", "Strut E heliport (after Ninja)",
      "w21a", "EF connecting bridge",
      "w21b", "EF connecting bridge (finale)",
      "w22a", "Strut F warehouse",
      "w23a", "FA connecting bridge",
      "w23b", "FA connecting bridge",
      "w24a", "Shell 1 Core, 1F",
      "d070p01", "Shell 1 Core B2 cutscenes",
      "w24b", "Shell 1 Core, B1",
      "d036p03", "Shell 1 Core, B1 Hall cutscenes",
      "w24d", "Shell 1 Core, B2 Computer Room",
      "w24c", "Shell 1 Core, B1 Hall",
      "w25a", "Shell 1-2 connecting bridge",
      "d045p01", "Shell 1-2 connecting bridge Harrier intro",
      "d046p01", "Shell 1-2 connecting bridge Harrier outro",
      "w25b", "Shell 1-2 connecting bridge (after Harrier)",
      "w25c", "Strut L perimeter",
      "w25d", "KL connecting bridge",
      "d063p01", "KL connecting bridge cutscene",
      "w28a", "Strut L Sewage Treatment Facility",
      "d065p02", "Strut L Oil Fence cutscene",
      "w31a", "Shell 2 Core, 1F Air Purification Room",
      "w31b", "Shell 2 Core, B1 Filtration Chamber No.1",
      "d055p01", "Shell 2 Core, B1 Filtration Chamber No.2 cutscenes",
      "w31c", "Shell 2 Core, B1 Filtration Chamber No.2 (vs Vamp)",
      "w31d", "Shell 2 Core, 1F Air Purification Room (with Emma)",
      "w31f", "Shell 2 Core, B1 Filtration Chamber No.2",
      "d053p01", "Strut 2 Core, B1 Filtration Chamber No.1 cutscenes",
      "w32a", "Strut L Oil Fence",
      "w32b", "Strut L Oil Fence (vs Vamp 2)",
      "w41a", "Arsenal Gear - Stomach",
      "w42a", "Arsenal Gear - Jejunum",
      "w43a", "Arsenal Gear - Ascending Colon",
      "w44a", "Arsenal Gear - Ileum (vs Tengus 1)",
      "w45a", "Arsenal Gear - Sigmoid Colon (vs Tengus 2)",
      "d078p01", "Arsenal Gear - Sigmoid Colon cutscene",
      "w46a", "Arsenal Gear - Rectum (vs Rays)",
      "d080p01", "Arsenal Gear - Rectum cutscene",
      "w51a", "Arsenal Gear (after Rays)",
      "w61a", "Federal Hall (vs Solidus)",
      "d082p01", "Plant ending"
    } },
    { "snaketales", new List<string>() {
      // Tanker
      "a00a", "Aft Deck",
      "a01f", "Deck-A, crew's quarters",
      "a01a", "Deck-A, crew's lounge",
      "a01b", "Deck-B, crew's quarters, starboard",
      "a01c", "Deck-C, crew's quarters",
      "a01d", "Deck-D, crew's quarters",
      "a01e", "Deck-E, the bridge",
      "a02a", "Engine Room",
      "a03a", "Deck-2, port",
      "a03b", "Deck-2, starboard",
      "a00b", "Navigational Deck, port wing (vs Meryl)",
      // Plant
      "a12a", "Strut A roof",
      "a12b", "Strut A Pump Room",
      "a13b", "AB connecting bridge",
      "a13c", "AB connecting bridge (EG)",
      "a14a", "Strut B Transformer Room (BSE)",
      "a14b", "Strut B Transformer Room (AW/DMW)",
      "a15b", "BC connecting bridge",
      "a16a", "Strut C Dining Hall",
      "a17a", "CD connecting bridge",
      "a18a", "Strut D Sediment Pool",
      "a19a", "DE connecting bridge",
      "a20a", "Strut E Parcel Room, 1F (AW)",
      "a20c", "Strut E heliport",
      "a20e", "Strut E Parcel Room, 1F (BSE)",
      "a21a", "EF connecting bridge",
      "a22a", "Strut F warehouse (AW/DMW)",
      "a22b", "Strut F warehouse (BSE)",
      "a23b", "FA connecting bridge",
      "a24a", "Shell 1 Core, 1F",
      "a24b", "Shell 1 Core, B1",
      "a24c", "Shell 1 Core, B1 Hall",
      "a24d", "Shell 1 Core, B2 Computer Room",
      "a25a", "Shell 1-2 connecting bridge (vs Harrier)",
      "a25d", "Strut L Sewage Treatment Facility",
      "a28a", "KL connecting bridge",
      "a31a", "Shell 2 Core, 1F Air Purification Room",
      "a31c", "Shell 2 Core, B1 Filtration Chamber No.2 (vs Vamp)",
      "a46a", "Arsenal Gear - Rectum (vs Rays)",
      "a61a", "Federal Hall (vs Solidus)",
      // External Gazer VR missions
      "ta24a", "Elimination Level 6",
      "tsp03a", "2",
      "tvs03a", "Sneaking Level 3",
      "twp03a", "Handgun Level 3",
      "tvs05a", "Sneaking Level 5",
      "tvs08a", "Sneaking Level 8",
      "ta31a", "7"
    } }
  };
  
  
  // Old rooms to exclude splitting (typically cutscenes)
  // Even if not necessary (more cutscenes immediately after, for example) this also keeps them out of the settings
  List<string> ExcludeOldRoom = new List<string>() {
    "d04t", // Deck E
    "d05t", // Post-Olga
    "d10t", // Post-Guard Rush
    "d11t", // Hold 3
    "d005p01", // Strut A elevator
    "d012p01", // fortune bridge cutscene
    "d021p01", // fatman cutscenes
    "d036p03", // hostage room
    "d045p01", // harrier intro
    "d046p01", // harrier outro
    "d055p01", // vamp intro
    "d053p01", // before emma swim 2
    "d063p01", // emma with card
    "d065p02", // emma climbing
    "d070p01", // emma ded
    "d078p01", // after tengus 2
    "d080p01", // after rays
    "d082p01" // after solidus
  };
  // and new
  List<string> ExcludeCurrentRoom = new List<string>() {
  };
  
  // Old rooms to explicitly include a split at, even when the next room is unknown
  List<string> IncludeOldRoom = new List<string>() {
    //"d13t" // Final Tanker cutscene (not any more)
  };
  // and new
  List<string> IncludeCurrentRoom = new List<string>() {
    "museum", // end of tanker in tanker-plant
    "ending" // results screen in tanker and plant
  };
  
  
  // VR Missions room sets
  // The basic idea: You go to every room in a set, then it splits when you exit to mselect
  Dictionary< string, List<string> > VRMissionRoomSets = new Dictionary< string, List<string> >() {
    // Sneaking and Elim All
    { "vr_sneaking", new List<string>() { "vs01a", "vs02a", "vs03a", "vs04a", "vs05a", "vs06a", "vs07a", "vs08a", "vs09a", "vs10a" } },
    // Handgun
    { "vr_handgun", new List<string>() { "wp01a", "wp02a", "wp03a", "wp04a", "wp05a" } },
    // Rifle
    { "vr_rifle", new List<string>() { "wp11a", "wp12a", "wp13a", "wp14a", "wp15a" } },
    // C4
    { "vr_c4", new List<string>() { "wp21a", "wp22a", "wp23a", "wp24a", "wp25a" } },
    // Grenade
    { "vr_grenade", new List<string>() { "wp31a", "wp32a", "wp33a", "wp34a", "wp35a" } },
    // Stinger
    { "vr_stinger", new List<string>() { "wp41a", "wp42a", "wp43a", "wp44a", "wp45a" } },
    // Nikita
    { "vr_nikita", new List<string>() { "wp51a", "wp52a", "wp53a", "wp54a", "wp55a" } },
    // HF Blade
    { "vr_hf_blade", new List<string>() { "wp61a", "wp62a", "wp63a", "wp64a", "wp65a" } },
    // No Weapon
    { "vr_no_weapon", new List<string>() { "wp71a", "wp72a", "wp73a", "wp74a", "wp75a" } },
    // First Person
    { "vr_first_person", new List<string>() { "sp21a", "sp22a", "sp23a", "sp24a", "sp25a" } },
    // Variety (will trigger Ninja Variety if only 8 is played before menu,
    //   MGS1 variety if 3/6/8 are played, or Pliskin/Tuxedo Variety is 6/8 are played)
    { "vr_variety", new List<string>() { "sp01a", "sp02a", "sp03a", "sp06a", "sp07a", "sp08a" } },
    // Bomb Disposal
    { "vr_bomb_disposal", new List<string>() { "a31a", "a02a", "a41a", "a42a", "a43a", "a01f", "a01a", "a01b", "a01c", "a01d", "a14a", "a15b", "a16a", "a17a", "a18a" } },
    // Elimination
    { "vr_elimination", new List<string>() { "a23b", "a01a", "a19a", "a20a", "a24d", "a24a", "a31a", "a22a", "a42a", "a02a" } },
    // Hold Up
    { "vr_hold_up", new List<string>() { "a15b", "a12a", "a24d", "a13b", "a14a", "a22a", "a01b", "a42a", "a20b", "a31a" } },
    // Photograph
    { "vr_photograph", new List<string>() { "a01a", "a01f", "a00c", "a00a", "a03a" } },
    // Ninja Variety
    { "vr_variety_ninja", new List<string>() { "sp08a" } },
    // Streaking
    { "vr_streaking", new List<string>() { "st01a", "st02a", "st03a", "st04a", "st05a" } },
    // Snake Photograph
    { "vr_photograph_snake", new List<string>() { "a01a", "a24g", "a24a", "a02b", "a41b", "a24f" } },
    // Pliskin/Tuxedo Variety
    { "vr_variety_pliskin", new List<string>() { "sp06a", "sp08a" } },
    // MGS1 Variety (see Variety caveats)
    { "vr_variety_mgs1", new List<string>() { "sp03a", "sp06a", "sp08a" } }
  };
  
  
  // Rooms not considered for immediate splits (mostly cutscenes)
  Dictionary<string, string> OtherRooms = new Dictionary<string, string>() {
    // Menus
    { "init", "init" },
    { "select", "select" },
    { "n_title", "Main Menu" },
    { "mselect", "VR Mission select" },
    { "sselect", "Snake Tales episode select" },
    { "ending", "Results" }, // also for the "not real people honest" message, but eh
    // Tanker
    { "d00t", "George Washington Bridge" }, // intro 1
    { "d01t", "Aft Deck cutscenes" }, // intro 2
    { "d14t", "Marine capture cutscene" },
    { "d12t3", "Tanker ending: explosion" }, // ending 2
    { "d12t4", "Tanker ending: combat" }, // ending 3
    { "d13t", "Tanker ending: outside" }, // ending 4
    // Plant
    { "wmovie", "FMV cutscenes" },
    { "museum", "Plant intro vignette" },
    { "d001p01", "Plant intro" },
    { "d001p02", "Strut A Deep Sea Dock cutscenes" },
    { "d005p01", "Plant overview 1" },
    { "d010p01", "Strut B Transformer Room cutscenes" },
    { "d014p01", "Strut C Dining Hall cutscenes" },
    { "d005p03", "Plant overview 2" },
    { "d036p05", "Shell 1 Core, 1F cutscenes" },
    { "w24c", "Shell 1 Core, B1 Hall (after Ames)" },
    { "w24e", "Shell 1 Core, B1 Hall (eavesdropping)" },
    { "d070p09", "Arsenal Gear launch cutscene" },
    { "d070px9", "Arsenal Gear - Stomach cutscenes" },
    { "d080p06", "Arsenal Gear cutscenes" },
    { "d080p07", "Arsenal Gear entering Manhattan cutscene" },
    { "d080p08", "Federal Hall cutscenes" },
    // External Gazer
    { "ta02a", "Bomb Disposal 2" },
    // VR Missions
    { "vs01a", "Sneaking Mode 1" },
    { "vs02a", "Sneaking Mode 2" },
    { "vs03a", "Sneaking Mode 3" },
    { "vs04a", "Sneaking Mode 4" },
    { "vs05a", "Sneaking Mode 5" },
    { "vs06a", "Sneaking Mode 6" },
    { "vs07a", "Sneaking Mode 7" },
    { "vs08a", "Sneaking Mode 8" },
    { "vs09a", "Sneaking Mode 9" },
    { "vs10a", "Sneaking Mode 10" },
    { "wp01a", "Handgun 1"},
    { "wp02a", "Handgun 2"},
    { "wp03a", "Handgun 3"},
    { "wp04a", "Handgun 4"},
    { "wp05a", "Handgun 5"},
    { "wp11a", "Assault Rifle 1"},
    { "wp12a", "Assault Rifle 2"},
    { "wp13a", "Assault Rifle 3"},
    { "wp14a", "Assault Rifle 4"},
    { "wp15a", "Assault Rifle 5"},
    { "wp21a", "C4 1"},
    { "wp22a", "C4 2"},
    { "wp23a", "C4 3"},
    { "wp24a", "C4 4"},
    { "wp25a", "C4 5"},
    { "wp31a", "Grenade 1"},
    { "wp32a", "Grenade 2"},
    { "wp33a", "Grenade 3"},
    { "wp34a", "Grenade 4"},
    { "wp35a", "Grenade 5"},
    { "wp41a", "Stinger 1"},
    { "wp42a", "Stinger 2"},
    { "wp43a", "Stinger 3"},
    { "wp44a", "Stinger 4"},
    { "wp45a", "Stinger 5"},
    { "wp51a", "Nikita 1"},
    { "wp52a", "Nikita 2"},
    { "wp53a", "Nikita 3"},
    { "wp54a", "Nikita 4"},
    { "wp55a", "Nikita 5"},
    { "wp61a", "HF Blade 1"},
    { "wp62a", "HF Blade 2"},
    { "wp63a", "HF Blade 3"},
    { "wp64a", "HF Blade 4"},
    { "wp65a", "HF Blade 5"},
    { "wp71a", "No Weapon 1"},
    { "wp72a", "No Weapon 2"},
    { "wp73a", "No Weapon 3"},
    { "wp74a", "No Weapon 4"},
    { "wp75a", "No Weapon 5"},
    { "sp21a", "First Person View 1"},
    { "sp22a", "First Person View 2"},
    { "sp23a", "First Person View 3"},
    { "sp24a", "First Person View 4"},
    { "sp25a", "First Person View 5"},
    { "sp01a", "Variety Mode room 1"},
    { "sp02a", "Variety Mode room 2"},
    { "sp03a", "Variety Mode room 3"},
    { "sp06a", "Variety Mode room 6"},
    { "sp07a", "Variety Mode room 7"},
    { "sp08a", "Variety Mode room 8"},
    { "st01a", "Streaking Mode 1" },
    { "st02a", "Streaking Mode 2" },
    { "st03a", "Streaking Mode 3" },
    { "st04a", "Streaking Mode 4" },
    { "st05a", "Streaking Mode 5" }
  };
  
  // Big Boss values
  vars.DifficultyHealth = new Dictionary<int, string> {
    { 200, "Very Easy" },
    { 120, "Easy" },
    { 100, "Normal" },
    { 75, "Hard" },
    { 50, "Extreme" },
    { 30, "European Extreme" }
  };
  
  vars.BestCodeNames = new Dictionary<int, string> {
    { 120, "Hound" },
    { 100, "Doberman" },
    { 75, "Fox" },
    { 50, "Big Boss" },
    { 30, "Big Boss" }
  };
  
  
  /* MAIN CONFIGURATION ENDS */
  
  
  // Special case dictionaries:
  vars.SpecialRoomChange = new Dictionary< string, Dictionary<string, string> >();
  vars.SpecialNewRoom = new Dictionary< string, Dictionary<string, string> >();
  vars.SpecialWatchCallback = new Dictionary<string, Delegate>();
  vars.SpecialRoomChangeCallback = new Dictionary<string, Delegate>();
  vars.SpecialNewRoomCallback = new Dictionary<string, Delegate>();
  vars.DontWatch = false;
  vars.BlockNextRoom = false;
  vars.SplitNextRoom = false;
  vars.ASL_Difficulty = "";
  vars.ASL_BestCodeName = "";
  
  
  // Add main settings
  settings.Add("options", true, "Advanced Options");
  settings.Add("resets", true, "Reset the timer when returning to menu", "options");
  settings.Add("aslvv", true, "ASL Var Viewer Options", "options");
  settings.Add("info_percent", true, "Show numbers as percentages in ASL_Info", "aslvv");
  settings.Add("info_max", true, "Also show the maximum/starting value", "aslvv");
  settings.Add("splits", true, "Split Locations");
  
  
  // Build the old/current room exclusion/inclusion dictionaries
  vars.ExcludeOldRoom = new Dictionary<string, bool>();
  vars.IncludeOldRoom = new Dictionary<string, bool>();
  vars.ExcludeCurrentRoom = new Dictionary<string, bool>();
  vars.IncludeCurrentRoom = new Dictionary<string, bool>();
  foreach (string code in ExcludeOldRoom) {
    vars.ExcludeOldRoom.Add(code, true);
  }
  foreach (string code in IncludeOldRoom) {
    vars.IncludeOldRoom.Add(code, true);
  }
  foreach (string code in ExcludeCurrentRoom) {
    vars.ExcludeCurrentRoom.Add(code, true);
  }
  foreach (string code in IncludeCurrentRoom) {
    vars.IncludeCurrentRoom.Add(code, true);
  }
  
  // Populate the area/room settings
  // vars.Rooms is the format e.g. { "w00a": "Aft Deck", "w00b": "Nav Deck... }
  // i.e. it's a room name lookup table
  vars.Rooms = new Dictionary<string, string>() {
    { "tales", "Snake Tales storyline" }
  };
  // This is a lot of setup, but it's worth it for supafast room lookups
  int alen = Areas.Count();
  for (int i = 0; i < alen; i = i+2) { // for every area...
    string akey = Areas[i];
    string aval = Areas[i + 1];
    settings.Add(akey, true, aval, "splits"); // add area setting
    
    int rlen = Rooms[akey].Count();
    for (int j = 0; j < rlen; j = j+2) { // and for every room in the area...
      string rkey = Rooms[akey][j];
      string rval = Rooms[akey][j + 1];
      vars.Rooms.Add(rkey, rval); // add the room to vars.Rooms
      if (!vars.ExcludeOldRoom.ContainsKey(rkey)) { // and if not already excluded...
        settings.Add(rkey, true, rval, akey); // add room to the settings split list
      }
    }
  }
  string rn = string.Join("\n  ", vars.Rooms);
  vars.Debug("List of rooms: " + "{\n  " + rn + "\n}");
  
  
  // General-purpose room identifier
  Func<string, string> GetRoomName = delegate(string RoomCode) {
    string output = "";
    if (vars.Rooms.TryGetValue(RoomCode, out output)) return output;
    if (OtherRooms.TryGetValue(RoomCode, out output)) return output;
    return "Undefined room";
  };
  vars.GetRoomName = GetRoomName;
  
  
  // Confirm a split
  Func<bool> Split = delegate() {
    vars.DebugTimer = vars.DebugTimerStart;
    vars.PrevDebug = vars.ASL_Debug;
    vars.Debug("Splitting now");
    return true;
  };
  vars.Split = Split;
  
  
  // Insta-split vs bosses, disable regular split mode if this is enabled
  string TempSetting = "boss_insta";
  settings.Add(TempSetting, true, "Split instantly when a boss is defeated", "options");
  
  
  // VR roomset signatures and settings
  vars.VRMissions = false;
  settings.Add("vr", true, "VR Missions", "options");
  settings.Add("vr_variety_ninja", false, "Enable splits for Variety (Ninja)", "vr");
  settings.Add("vr_variety_pliskin", false, "Enable splits for Variety (Pliskin/Tuxedo)", "vr");
  settings.Add("vr_variety_mgs1", false, "Enable splits for Variety (MGS1)", "vr");
  string Tooltip = "The rules for these modes can accidentally trigger Variety splits for other characters. Only enable if you are playing this character.";
  settings.SetToolTip("vr_variety_ninja", Tooltip);
  settings.SetToolTip("vr_variety_pliskin", Tooltip);
  settings.SetToolTip("vr_variety_mgs1", Tooltip);
  // Hash function
  Func< List<string>, string > VRMissionHash = delegate(List<string> roomset) {
    roomset.Sort();
    return String.Join(";", roomset);
  };
  Func< List<string>, int, string > VRMissionHashRange = delegate(List<string> roomset, int range) {
    int length = roomset.Count();
    return VRMissionHash( roomset.GetRange(length - range, range) );
  };
  vars.VRMissionHash = VRMissionHash;
  vars.VRMissionHashRange = VRMissionHashRange;
  // Generate the list of hashes
  vars.VRMissionSignatures = new Dictionary<string, string>();
  vars.VRMissionLengths = new List<int>();
  foreach (KeyValuePair< string, List<string> > roomset in VRMissionRoomSets) {
    string key = roomset.Key;
    List<string> val = roomset.Value;
    string sig = VRMissionHash(val);
    vars.VRMissionSignatures.Add(sig, key);
    int slen = val.Count();
    // Also set the list of possible roomset lengths
    // This will help us match roomset even if the player does dumb stuff
    if (!vars.VRMissionLengths.Contains(slen)) vars.VRMissionLengths.Add(slen);
  }
  vars.VRMissionLengths.Sort();
  vars.VRMissionLengths.Reverse(); // we looking for the longest (and most valid) ones first
    
  
  // Plant: Option to split when meeting Stillman in Strut C
  settings.Add("options_plant", true, "Tanker", "options");
  TempSetting = "d014p01";
  settings.Add(TempSetting, true, "Don't split when meeting Stillman", "options_plant");
  settings.SetToolTip(TempSetting, "You will need two Strut C splits if this is not enabled");
  vars.SpecialNewRoom.Add(TempSetting, new Dictionary<string, string>() {
    { "old", "w16a" },
    { "setting", TempSetting },
    { "no_split", "true" }
  });
  // Never split when meeting Olga in Strut E heliport
  vars.SpecialNewRoom.Add("d021p01", new Dictionary<string, string>() {
    { "old", "w20b" },
    { "no_split", "true" }
  });
  // Option to split when meeting Prez in Shell 2 Core
  TempSetting = "w31a_prez";
  settings.Add(TempSetting, true, "Don't split when meeting Prez", "options_plant");
  settings.SetToolTip(TempSetting, "You will need two Shell 2 Core 1F splits if this is not enabled");
  vars.SpecialRoomChange.Add("w31a", new Dictionary<string, string>() {
    { "current", "wmovie" },
    { "setting_false", TempSetting }
  });
  // Never split when opening the underwater hatch in Shell 2 Core B1
  vars.SpecialNewRoom.Add("d053p01", new Dictionary<string, string>() { // B1 No.1 cutscenes
    { "old", "w31b" },
    { "no_split", "true" }
  });
  /*
  // Option to split when meeting Emma in Shell 2 Core B1
  TempSetting = "w31f_emma";
  settings.Add(TempSetting, true, "Don't split when meeting Emma", "options_plant");
  settings.SetToolTip(TempSetting, "You will need two Shell 2 Core B1 FC2 splits if this is not enabled");
  vars.SpecialRoomChange.Add("w31f", new Dictionary<string, string>() {
    { "current", "d055p01" },
    { "setting", TempSetting },
    { "no_split", "true" }
  });
  */
  
  
  // A Wrongdoing: Option to split when meeting Ames in Strut F
  settings.Add("snaketales_a", true, "A Wrongdoing", "options");
  TempSetting = "snaketales_a_ames";
  settings.Add(TempSetting, true, "Don't split when meeting Ames", "snaketales_a");
  settings.SetToolTip(TempSetting, "You will need two Strut F splits if this is not enabled");
  vars.SpecialRoomChange.Add("a22a", new Dictionary<string, string>() {
    { "current", "tales" },
    { "setting", TempSetting },
    { "no_split", "true" }
  });

  
  // Big Shell Evil: Option to split when accessing the node in Strut B
  settings.Add("snaketales_b", true, "Big Shell Evil", "options");
  TempSetting = "snaketales_b_node";
  settings.Add(TempSetting, true, "Don't split when accessing the node", "snaketales_b");
  settings.SetToolTip(TempSetting, "You will need two Strut B splits if this is not enabled");
  vars.SpecialRoomChange.Add("a14a", new Dictionary<string, string>() {
    { "current", "tales" },
    { "setting", TempSetting },
    { "no_split", "true" }
  });
  
  
  vars.Debug("MGS2 autosplitter ready to roll!"); 
}


update {
  // Callbacks go here - they need access to current and old so startup won't do the job  
  if (!vars.Initialised) {
    vars.Initialised = true;
    int Counter = 0;
    bool BossActive = false;
    int Continues = -1;
    bool BossDefeated = false;
    int BossCounter = 99999;
    int BossHealth = 99999;
    int BossStamina = 99999;
    int BossMaxHealth = 99999;
    int BossMaxStamina = 99999;
    bool BigBossFailed = false;
    int BigBossAlertState = 0;
    
    // Shortened name for the byte[]-to-int converter
    Func<byte[], int> C = (input) => BitConverter.ToInt16(input, 0);
    vars.C = C;
    
    // Check for new continues
    Func<bool> HasContinued = delegate() {
      int NewContinues = C(current.Continues);
      if (NewContinues > Continues) {
        vars.Debug("Detected continue during boss: " + Continues + " > " + NewContinues);
        Continues = NewContinues;
        return true;
      }
      return false;
    };
    
    // Reset Big Boss alert counters
    Action ResetBigBossData = delegate() {
      BigBossFailed = false;
      BigBossAlertState = 0;
    };
    vars.ResetBigBossData = ResetBigBossData;
    
    // Reset counters used to track bosses
    Action ResetBossData = delegate() {
      BossActive = false;
      BossDefeated = false;
      BossCounter = 99999;
      Continues = -1;
      BossHealth = 99999; // normally i'd use -1, but rays can actually go under 0 so have to test <=0
      BossStamina = 99999;
      BossMaxHealth = 99999;
      BossMaxStamina = 99999;
      vars.SplitNextRoom = false;
      vars.BlockNextRoom = false;
    };
    vars.ResetBossData = ResetBossData;
    
    Func<int, int, int> Percent = delegate(int cur, int max) {
      double percentage = (100.0 * cur / max);
      return Convert.ToInt16( Math.Round(percentage) );
    };
    
    Func<int, int, string> ValueFormat = delegate(int cur, int max) {
      if (settings["info_percent"]) return string.Format("{0,2}%", Percent(cur, max));
      
      int MaxLen = (int)Math.Floor(Math.Log10(max) + 1);
      if (settings["info_max"]) return string.Format("{0," + MaxLen + "}/{1," + MaxLen + "}", cur, max);
      return string.Format("{0," + MaxLen + "}", cur);
    };
    vars.ValueFormat = ValueFormat;
    
    // General-purpose boss health watcher - this gets called by the specific bosses below
    Func<string, int, int, int> WatchBoss = delegate(string Name, int CurrentStamina, int CurrentHealth) {
      if (!settings["boss_insta"]) return -1; // stop watching if insta-splits are disabled
      if (Continues == -1) Continues = C(current.Continues);
      else if (HasContinued()) ResetBossData();
      //if ((Counter++ % 300) == 0) vars.Debug("Stamina: " + Convert.ToString(CurrentStamina) + " Health: " + Convert.ToString(CurrentHealth));
      if ( (CurrentStamina != BossStamina) || (CurrentHealth != BossHealth) ) {
        BossStamina = CurrentStamina;
        BossHealth = CurrentHealth;
        vars.ASL_BossStamina = CurrentStamina;
        vars.ASL_BossHealth = CurrentHealth;
        if ( (CurrentStamina <= 0) || (CurrentHealth <= 0) ) {
          if (BossActive) {
            vars.Debug("Boss defeated!");
            vars.BlockNextRoom = true; // Stop the non-insta split that occurs on the next room change
            return 1;
          }
        }
        // necessary for reloading saves after beating a boss already - they'll start at 0 and get a refill
        // so we wait until they've been given some health to start checking properly
        else if (!BossActive) {
          BossActive = true;
          BossMaxStamina = CurrentStamina;
          BossMaxHealth = CurrentHealth;
          vars.Debug("Currently fighting " + Name);
        }
        
        vars.DebugInfo( Name + " | Stamina: " + ValueFormat(CurrentStamina, BossMaxStamina) + " Health: " + ValueFormat(CurrentHealth, BossMaxHealth) );
      }
      return 0;
    };
    

    // BOSSES
    
    // Olga
    // Line below is equiv. to: Func<int> WatchOlga = delegate() { return WatchBoss(current.OlgaStamina, 100); }
    Func<int> WatchOlga = () => WatchBoss("Olga", current.OlgaStamina, 128);
    vars.SpecialWatchCallback.Add("w00b", WatchOlga);

    // Fatman the troublemaker
    Func<int> WatchFatman = delegate() {
      if (!BossDefeated) {
        if (WatchBoss("Fatman", current.FatmanStamina, C(current.FatmanHealth)) == 1) BossDefeated = true;
      }
      if (BossDefeated) {
        if (HasContinued()) {
          ResetBossData();
          return 0;
        }
        if (current.FatmanBombsActive < BossCounter) {
          BossCounter = current.FatmanBombsActive;
          vars.Debug("Bombs remaining: " + Convert.ToString(BossCounter));
        }
        if (current.FatmanBombsActive == 0) return 1; // not necesary to reset boss data as it'll happen in split
      }
      return 0;
    };
    vars.SpecialWatchCallback.Add("w20c", WatchFatman);
    
    // Harrier
    Func<int> WatchHarrier = () => WatchBoss("Harrier", 128, C(current.HarrierHealth));
    vars.SpecialWatchCallback.Add("w25a", WatchHarrier);
    
    // Vamp
    Func<int> WatchVamp = () => WatchBoss("Vamp", C(current.VampStamina), C(current.VampHealth));
    vars.SpecialWatchCallback.Add("w31c", WatchVamp);
    
    // Vamp 2
    Func<int> WatchVamp2 = () => WatchBoss("Vamp", C(current.Vamp2Stamina), C(current.Vamp2Health));
    vars.SpecialWatchCallback.Add("w32b", WatchVamp2);
    
    // Rays
    Func<int> WatchRays = () => WatchBoss("Rays", 128, C(current.RaysHealth));
    vars.SpecialWatchCallback.Add("w46a", WatchRays);
    
    // Solidus
    Func<int> WatchSolidus = () => WatchBoss("Solidus", current.SolidusStamina, current.SolidusHealth);
    vars.SpecialWatchCallback.Add("w61a", WatchSolidus); 
    
    // BOSSES END

    
    // Plant: Filter out the "valid" room change that happens during the torture cutscenes
    bool TortureSkipNextRoomChange = false;
    Func<int> CallTortureCutscene = delegate() {
      // cutscene > jejunum
      if (current.RoomCode == "w42a") {
        vars.Debug("In the torture sequence: skipping the Jejunum > Stomach room change that occurs during it");
        TortureSkipNextRoomChange = true;
      }
      return 0;
    };
    Func<int> CallTortureCutscene2 = delegate() {
      // jejunum > stomach (in cutscene)
      if ( (TortureSkipNextRoomChange) && (current.RoomCode == "w41a") ) {
        TortureSkipNextRoomChange = false;
        return -1;
      }
      return 0;
    };
    vars.SpecialRoomChangeCallback.Add("d070px9", CallTortureCutscene);
    vars.SpecialRoomChangeCallback.Add("w42a", CallTortureCutscene2);
    
    // Plant: Increment the Big Boss alert counters
    Func<int> CallBigBossAlert1 = delegate() {
      BigBossAlertState = 1;
      return 0;
    };
    Func<int> CallBigBossAlert2 = delegate() {
      BigBossAlertState = 2;
      return 0;
    };
    Func<int> CallBigBossAlert3 = delegate() {
      BigBossAlertState = 3;
      return 0;
    };
    vars.SpecialRoomChangeCallback.Add("e32a", CallBigBossAlert1); // sniping
    vars.SpecialRoomChangeCallback.Add("w44a", CallBigBossAlert1); // tengus 1
    vars.SpecialRoomChangeCallback.Add("w45a", CallBigBossAlert1); // tengus 2
    
    
    // Snake Tales in general: Don't split if we're coming from storyline.
    int STCompletionCheck = 99999;
    Func<int> CallSnakeTales = delegate() {
      // Also set up for the results check
      if (current.RoomCode == "sselect") {
        STCompletionCheck = current.STCompletionCheck;
        vars.Debug("Trying to figure out when this tale of snakes has ended.");
      }
      return -1; // don't split after tales
    };
    vars.SpecialRoomChangeCallback.Add("tales", CallSnakeTales);
    // And the results check. I hate this whole thing.
    Func<int> WatchSnakeTalesCredits = delegate() {
      if ( (STCompletionCheck != 99999) && (current.STCompletionCheck != STCompletionCheck) ) {
        STCompletionCheck = 99999;
        vars.Debug("Moved briskly to the Snake Tales result screen!");
        return 1;
      }
      return 0;
    };
    vars.SpecialWatchCallback.Add("sselect", WatchSnakeTalesCredits);
    
    
    // Scary VR Missions stuff
    List<string> VRMissionsCurrentRooms = new List<string>();
    Func<string, bool> VRLogMission = delegate(string RoomCode) {
      // If going to mission select, try to find a completed roomset
      if (RoomCode == "mselect") {
        int CurrentLen = VRMissionsCurrentRooms.Count();
        // Loop through the possible roomset lengths and try to find any match from the latest rooms
        foreach (int VRLength in vars.VRMissionLengths) {
          if (VRLength > CurrentLen) continue; // no point if the roomset is already bigger than our current one
          string Hash = vars.VRMissionHashRange(VRMissionsCurrentRooms, VRLength); // current hash with appropriate length
          string VRCategory = "";
          if (vars.VRMissionSignatures.TryGetValue(Hash, out VRCategory)) {
            if ( (!settings.ContainsKey(VRCategory)) || (settings[VRCategory]) ) {
              vars.Debug("Found completed VR roomset " + VRCategory + " = " + Hash);
              VRMissionsCurrentRooms.Clear();
              return true;
            }
            vars.Debug("Found completed VR roomset " + VRCategory + " = " + Hash + ", but it is disabled in settings");
          }
        }
        return false;
      };
      // Otherwise, add the current room to the list
      if (!VRMissionsCurrentRooms.Contains(RoomCode)) VRMissionsCurrentRooms.Add(RoomCode);
      vars.Debug("Entered [" + RoomCode + "] " + vars.GetRoomName(current.RoomCode) + ", adding to current roomset > " + vars.VRMissionHash(VRMissionsCurrentRooms));
      return false;
    };
    Action VRMissionsEnable = delegate() {
      vars.Debug("VR Missions mode on!");
      vars.VRMissions = true;
      VRMissionsCurrentRooms.Clear();
      VRLogMission(current.RoomCode); // we need to log the first room here
    };
    vars.VRMissionsEnable = VRMissionsEnable;
    vars.VRLogMission = VRLogMission;
    
    // Big Boss status for ASLVarViewer
    Func<int> UpdateBigBoss = delegate() {
      if (BigBossFailed) return -1; // we already doned, so no need to process
      
      // Possible improvement: only do this once at the start of the mission?
      vars.ASL_Difficulty = vars.DifficultyHealth[current.MaxHealth];
      vars.ASL_RadarOn = (current.RadarOn == 32);

      string Message = "";
      bool BigBoss = false; // it's like the null hypothesis...
      
      do {
        if (vars.ASL_Difficulty == "Very Easy") {
          Message = "On Very Easy";
          break;
        }
        
        vars.ASL_BestCodeName = vars.BestCodeNames[current.MaxHealth];
        int DamageLimit = (vars.ASL_Difficulty == "European Extreme") ? 279 : 499; // prob incorrect for easier difficulties
      
        // If radar is on...
        if (vars.ASL_RadarOn) { Message = "Radar is enabled"; break; }
        // If over 3 alerts (only allowing for the mandatory ones when they appear)...
        if (vars.ASL_Alerts > BigBossAlertState) { Message = "Over Alerts limit"; break; }
        // If has continued...
        if (vars.ASL_Continues > 0) { Message = "Over Continues limit"; break; }
        // If has killed...
        if (vars.ASL_Kills > 0) { Message = "Over Kills limit"; break; }
        // If has eaten rations...
        if (vars.ASL_Rations > 0) { Message = "Over Rations limit"; break; }
        // If time is 3h00m01s or more
        if (current.GameTime > ((60/*f*/ * 60/*s*/ * 60/*m*/ * 3/*h*/) + 59)) { Message = "Over Time limit"; break; }
        // If has saved more than 8 times...
        if (vars.ASL_Saves > 8) { Message = "Over Saves limit"; break; }
        // If has taken too much damage...
        if (vars.ASL_DamageTaken > DamageLimit) { Message = "Over Damage Taken limit"; break; }
        // If has shot a decent number of bullets...
        if (vars.ASL_Shots > 700) { Message = "Over Shots Fired limit"; break; }
        BigBoss = true;
      }
      while (false);
      
      if (BigBoss) return 1;

      BigBossFailed = true;
      vars.ASL_BestCodeName = Message;
      return 0;
    };
    vars.UpdateBigBoss = UpdateBigBoss;
    
    // ASLVarViewer values
    int PreviousO2 = 4000;
    int PreviousGrip = 1800;
    Action UpdateASLVars = delegate() {
      if (settings["aslvv"]) {
      
        bool Snake = (C(current.GripMultiplier) == 1800); // Raiden's is 3600 - but this doesn't work
        //vars.Debug(Snake ? "Snake" : "Raiden");
        //vars.Debug(C(current.GripMultiplier).ToString());
        
        vars.ASL_CurrentRoomCode = current.RoomCode;
        vars.ASL_Shots = C(current.Shots);
        vars.ASL_Alerts = C(current.Alerts);
        vars.ASL_Continues = C(current.Continues);
        vars.ASL_Rations = C(current.Rations);
        vars.ASL_Kills = C(current.Kills);
        vars.ASL_DamageTaken = C(current.Damage);
        vars.ASL_Saves = C(current.Saves);
        vars.ASL_MechsDestroyed = C(current.Mechs);
        vars.ASL_Strength = C(Snake ? current.StrengthSnake : current.StrengthRaiden);
        vars.ASL_RoomTimer = current.RoomTimer;
        
        if (vars.DebugTimer > 0) {
          vars.DebugTimer--;
          if (vars.DebugTimer == 0) vars.ASL_Debug = vars.PrevDebug;
        }
        
        if (vars.InfoTimer > 0) {
          vars.InfoTimer--;
          if (vars.InfoTimer == 0) vars.ASL_Info = "";
        }
        
        int CurrentO2 = C(current.CurrentO2);
        int CurrentGrip = (current.CurrentGrip != null) ? C(current.CurrentGrip) : 1800;
        // If we're underwater, update the O2 status in ASL_Info
        if (CurrentO2 != PreviousO2) {
          int MaxO2 = 4000;
          PreviousO2 = CurrentO2;
          int O2Rate = (current.CurrentHealth == current.MaxHealth) ? 60 : 120;
          string O2TimeLeft = string.Format( "{0:0.0}", (decimal)((double)CurrentO2 / O2Rate) );
          vars.ASL_Info = "O2: " + vars.ValueFormat(CurrentO2, MaxO2) + " (" + O2TimeLeft + " left)";
          vars.InfoTimer = 30;
        }
        // If we're hanging, update the grip status
        else if (CurrentGrip != PreviousGrip) {
          PreviousGrip = CurrentGrip;
          int StrengthLevel = (int)Math.Floor((double)vars.ASL_Strength / 100);
          int MaxGrip = ( 1800 * ((Snake ? 1 : 2) + StrengthLevel) );
          int GripRate = (current.CurrentHealth == current.MaxHealth) ? 60 : 120;
          string GripTimeLeft = string.Format( "{0:0.0}", (decimal)((double)CurrentGrip / GripRate) );
          vars.ASL_Info = "Grip: " + vars.ValueFormat(CurrentGrip, MaxGrip) + " (" + GripTimeLeft + " left)";
          vars.InfoTimer = 30;
        }
      }
      
    };
    vars.UpdateASLVars = UpdateASLVars;
    
    
    vars.Debug("Finished initialising script. It's all up to you now.");
  }
  
  vars.UpdateASLVars();
  
  // pausing the game won't help you...
  if (current.GameTime != 0) return true;
}


/*  Split logic! Here's how it goes down...
      "[DictionaryName]" shows the name of the dictionary defined further up in this
        script to store rules and callbacks.
      Callbacks can return 1 to split, -1 to not split, and 0 to make no decision.
      The decision to not split (e.g. return -1) can be overruled if a later step
        explicitly chooses to split (e.g. return 1). The inverse is not true.
    
    * [SpecialWatchCallback] Special cases that watch memory each frame
      These callbacks have the option of returning -1 to stop watching the current room
    * Stop if we haven't changed rooms this frame
    * Log the room change
    * Handle room logging and checking for VR Missions categories
    * [SpecialRoomChange] Basic checks on leaving a particular room
    * [SpecialNewRoom] ^ on entering a particular room
    * [SpecialRoomChangeCallback] Callbacks on leaving a particular room
    * [SpecialNewRoomCallback] Callbacks on entering a particular room
    * [ExcludeOldRoom] Avoid splitting when leaving specific rooms
    * [ExcludeCurrentRoom] ^ when entering specific rooms
    * [IncludeOldRoom] Definitely split when leaving specific rooms
    * [IncludeCurrentRoom] ^ when entering
    * If no decision has been made yet (this is the case for most room changes),
        split only if both the old and new room have defined names (and the old room
        is enabled in settings)
*/
split {
  bool DefinitelySplit = false;
  bool AvoidSplit = false;
  int CallbackResult = 0;
  bool BoolResult = false;
  Dictionary<string, string> SpecialCase = null;
  Func<bool> Split = vars.Split;
  
  // Watching special cases
  if ( (!vars.DontWatch) && (vars.SpecialWatchCallback.ContainsKey(current.RoomCode)) ) {
    CallbackResult = vars.SpecialWatchCallback[current.RoomCode]();
    if (CallbackResult == 1) {
      vars.DontWatch = true;
      return Split();
    }
    else if (CallbackResult == -1) vars.DontWatch = true;
  }
  
  if (current.RoomCode == old.RoomCode) return false; // room is unchanged
  
  vars.ASL_CurrentRoom = vars.GetRoomName(current.RoomCode);
  vars.UpdateBigBoss();
  
  if (vars.BlockNextRoom) {
    vars.BlockNextRoom = false;
    vars.ResetBossData(); // BlockNextRoom will generally be specified by insta-split bosses
    return false; // something requested that we not split this time
  }
  if (vars.SplitNextRoom) {
    vars.SplitNextRoom = false;
    return Split(); // the opposite happened!
  }
  
  if (vars.DontWatch) vars.DontWatch = false; // reset the watch switch on new room
  
  // get the friendly room names for logging
  string CurrentRoomName, OldRoomName;
  if (!vars.Rooms.TryGetValue(current.RoomCode, out CurrentRoomName)) {
    AvoidSplit = true; // Avoid splitting if we're going to an unknown room
    CurrentRoomName = vars.GetRoomName(current.RoomCode);
  }
  if (!vars.Rooms.TryGetValue(old.RoomCode, out OldRoomName)) {
    AvoidSplit = true; // Avoid splitting if we're coming from an unknown room
    OldRoomName = vars.GetRoomName(old.RoomCode);
  }
  vars.Debug("[" + old.RoomCode + "] " + OldRoomName + " > [" + current.RoomCode + "] " + CurrentRoomName);
  
  // If we're in VR Missions, this is the last thing that gets run
  if (vars.VRMissions) return vars.VRLogMission(current.RoomCode);
  
  // Special cases
  do {
    // Parameter-based room change cases
    if (vars.SpecialRoomChange.TryGetValue(old.RoomCode, out SpecialCase)) {
      // Break out if a setting is required but not true (or a false setting required but true)
      if ( (SpecialCase.ContainsKey("setting")) && (!settings[ SpecialCase["setting"] ]) ) break;
      if ( (SpecialCase.ContainsKey("setting_false")) && (settings[ SpecialCase["setting_false"] ]) ) break;
      // ...or if the new room isn't what we want
      if ( (SpecialCase.ContainsKey("current")) && (current.RoomCode != SpecialCase["current"]) ) break;
      // ...and specifically disable the split if required
      if (SpecialCase["no_split"] == "true") {
        AvoidSplit = true;
        break;
      }
      return Split();
    }
  } while (false); // yes, I am in fact using a do-while-false "loop" just so I can use break
  
  do {
    // Parameter-based room change cases (new room)
    if (vars.SpecialNewRoom.TryGetValue(current.RoomCode, out SpecialCase)) {
      // Break out if a setting is required but not true (or a false setting required but true)
      if ( (SpecialCase.ContainsKey("setting")) && (!settings[ SpecialCase["setting"] ]) ) break;
      if ( (SpecialCase.ContainsKey("setting_false")) && (settings[ SpecialCase["setting_false"] ]) ) break;
      // ...or if the new room isn't what we want
      if ( (SpecialCase.ContainsKey("old")) && (old.RoomCode != SpecialCase["old"]) ) break;
      // ...and specifically disable the split if required
      if (SpecialCase["no_split"] == "true") {
        AvoidSplit = true;
        break;
      }
      return Split();
    }
  } while (false);
  
  // Method-based room change cases
  if (vars.SpecialRoomChangeCallback.ContainsKey(old.RoomCode)) {
    CallbackResult = vars.SpecialRoomChangeCallback[old.RoomCode]();
    if (CallbackResult == 1) DefinitelySplit = true;
    else if (CallbackResult == -1) AvoidSplit = true;
  }

  // Method-based room change cases (checking the new room, not the old one)
  // This isn't used anywhere yet - checking the old room is usually more useful
  if (vars.SpecialNewRoomCallback.ContainsKey(current.RoomCode)) {
    CallbackResult = vars.SpecialNewRoomCallback[current.RoomCode]();
    if (CallbackResult == 1) DefinitelySplit = true;
    else if (CallbackResult == -1) AvoidSplit = true;
  }

  // Rooms to exclude (typically cutscenes)
  if (vars.ExcludeOldRoom.TryGetValue(old.RoomCode, out BoolResult)) AvoidSplit = true;
  if (vars.ExcludeCurrentRoom.TryGetValue(current.RoomCode, out BoolResult)) AvoidSplit = true;
  
  // Rooms to include
  if (vars.IncludeOldRoom.TryGetValue(old.RoomCode, out BoolResult)) DefinitelySplit = true;
  if (vars.IncludeCurrentRoom.TryGetValue(current.RoomCode, out BoolResult)) DefinitelySplit = true;
 
  if ( (settings.ContainsKey(old.RoomCode)) && (!settings[old.RoomCode]) ) return false;
  if ( (DefinitelySplit) || (!AvoidSplit) ) return Split();
  
  return false;
}

isLoading {
  return true;
}

gameTime {
  return TimeSpan.FromMilliseconds((current.GameTime) * 1000 / 60);
}