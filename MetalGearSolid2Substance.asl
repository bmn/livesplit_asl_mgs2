/*
  Autosplitter for Metal Gear Solid 2: Substance (PC)
  
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
  byte2     Clearings: 0xD8C352;
  byte      SeaLouce: 0x615B1C;
  byte2     Extra: 0x601F34, 0x1596; // & 0x2000 = radar, & 0x20 = sp item
  byte      DogTagsSnake: 0xD8AFEE;
  byte      DogTagsRaiden: 0xD8B13E;
  byte2     StrengthRaiden: 0x3E315E, 0x63;
  byte2     StrengthSnake: 0xD8AEEE;
  
  byte      CurrentHealth: 0x3E315E, 0x2D;
  byte      MaxHealth: 0x3E315E, 0x2F;
  byte2     CurrentChaff: 0xB6DE4C;
  byte2     CurrentO2: 0x3E315E, 0x31;
  byte2     CurrentGrip: 0x618BAC, 0x80;
  byte2     MaxGrip: 0x618BAC, 0x82;
  byte2     CurrentCaution: 0x6160C8;
  byte2     MaxCaution: 0xD8F508; // D8D908 B60000
  byte2     GripMultiplier: 0xD8F500; // This is meant to be 1800 for Snake, 3600 for Raiden, but isn't?
  byte      Difficulty: 0x601F34, 0x10; // 10 = VE, 60 = EEx, increments in 10s
  byte2     Level: 0x601F34, 0x158A; // 0x1800 + 0xD (Tanker), 0xE (Plant), 0xF (T-P)
  
  byte2     STCompletionCheck: 0x13A178C; // This value rises slowly from 0 during credits to about 260, then goes back to 0 at results
  int       PadInput: 0xADAD3C;

  byte      OlgaStamina: 0xAD4F6C, 0x0, 0x1E0, 0x44, 0x1F8, 0x13C;
  byte      OlgaRushStamina: 0xAD4F6C, 0x2C4;
  byte      MerylHealth: 0xB6DEC4, 0x284;

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
  byte2     RaysTalesHealth: 0x652F30, 0x490;
  byte2     ChokeTimer: 0xAD4F6C, 0x40;
  byte      AscendingColonActive: 0xD8E105;
  byte2     AscendingColonTimer: 0xAD4F08, 0x40;
  byte      CartwheelCode: 0xB6095E;
  byte      AmesLocation: 0xD8DF9F; // D8FB9F
}

isLoading {
  return true;
}

gameTime {
  if (settings["aslvv"]) vars.UpdateASLVars();
  return TimeSpan.FromMilliseconds((current.GameTime) * 1000 / 60);
}

reset {
  try {
    string CurrentRoomName, OldRoomName;
    
    if (!settings["resets"]) return false; // resets not enabled anyway!
    
    if (vars.ResetNextFrame) return true;
    
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
    
    vars.ClearASLVariables();
    vars.ResetNextFrame = true;
    return false;
  }
  catch (Exception e) {
    vars.LogException(e, "reset");
    return false;
  }
}

start {
  try {
    int i;
    string CurrentRoomName, OldRoomName;
    
    if ( (old.RoomCode == null) || (old.RoomCode == "") ) return false;
    
    if (current.RoomCode == old.RoomCode) return false; // room is unchanged
      
    // was the old room a menu (or the "this is a fictional story" screen)?
    if ( (!vars.Menus.TryGetValue(old.RoomCode, out OldRoomName)) && (old.RoomCode != "ending") ) return false;
    
    // is the new room NOT a menu (and not that screen)?
    if ( (vars.Menus.TryGetValue(current.RoomCode, out CurrentRoomName)) || (current.RoomCode == "ending") ) return false;
    
    CurrentRoomName = vars.GetRoomName(current.RoomCode);
    if (OldRoomName == "") OldRoomName = vars.GetRoomName(old.RoomCode);
    
    vars.Debug("Menu [" + old.RoomCode + "] " + OldRoomName + " > In-game [" + current.RoomCode + "] " + CurrentRoomName);
    
    // Enable VR Missions mode if coming from the missions menu
    if (old.RoomCode == "mselect") vars.VRMissionsEnable();
    else if (vars.VRMissions) vars.VRMissions = false;
    
    // Enable Boss Rush mode if going into the boss screen (necessary for Olga's different memaddress)
    if (current.RoomCode == "boss") {
      vars.Debug("Starting Boss Rush");
      vars.BossRush = true;
    }
    else if (vars.BossRush) vars.BossRush = false;
    
    // Might as well!
    vars.ResetData(); // resetting on an unbeaten boss can cause some really bad things to happen in insta
    vars.ClearASLVariables();
    
    return true;
  }
  catch (Exception e) {
    vars.LogException(e, "start");
    return false;
  }
} 

startup {
  // Init ASL variables
  Action ClearASLVariables = delegate() {
    vars.ASL_VAR_VIEWER_VARIABLES = "";
    vars.ASL_Alerts = 0;
    vars.ASL_AlertAllowance = 0;
    vars.ASL_AmesLocation = "";
    vars.ASL_Cartwheels = 0;
    vars.ASL_ClearingEscapes = 0;
    vars.ASL_CodeName = "";
    vars.ASL_CodeNameStatus = "";
    vars.ASL_Continues = 0;
    vars.ASL_CurrentRoom = "";
    vars.ASL_CurrentRoomCode = "";
    vars.ASL_DamageTaken = 0;
    vars.ASL_Debug = "";
    vars.ASL_Difficulty = "";
    vars.ASL_DogTags = "";
    vars.ASL_DogTags_Snake = "";
    vars.ASL_DogTags_Raiden = "";
    vars.ASL_Info = "";
    vars.ASL_Kills = 0;
    vars.ASL_LastDamage = 0;
    vars.ASL_Level = "";
    vars.ASL_MechsDestroyed = 0;
    vars.ASL_Minutes = 0;
    vars.ASL_Rations = 0;
    vars.ASL_RoomTimer = 0;
    vars.ASL_Saves = 0;
    vars.ASL_SeaLouce = 0;
    vars.ASL_Shots = 0;
    vars.ASL_SpecialItems = false;
    vars.ASL_Strength = 0;
    vars.INTERNAL_VARIABLES = "";
  };
  ClearASLVariables();
  vars.ClearASLVariables = ClearASLVariables;
  
  vars.Initialised = false;
  print("Beginning startup initialisation...");
  
  /* MAIN CONFIGURATION STARTS */
  
  vars.Menus = new Dictionary<string, string> {
    { "init", "init" }, // TODO define
    { "select", "select" },
    { "n_title", "Main Menu" },
    { "mselect", "VR Mission select" },
    { "sselect", "Snake Tales episode select" }
  };
  
  // Note to self: T[] is preferable over List<T> when not modifying afterwards or doing random access
  var Areas = new string[] {
    "tanker", "Tanker",
    "plant", "Plant",
    "snaketales", "Snake Tales"
  };
  
  
  // The room codes and names are done in this weird way for a mix of performance
  // (after the slower initial load) and ease of editing.
  // The dictionary vars.Rooms will be auto-populated from this
  // and should be used by other parts of the script
  var Rooms = new Dictionary<string, string[]> {
    { "tanker", new[] {
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
    { "plant", new[] {
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
      "w25c", "KL connecting bridge", // "Strut L perimeter" in-game
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
    { "snaketales", new[] {
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
      "a13c", "AB connecting bridge", // EG
      "a14a", "Strut B Transformer Room", // BSE & EG
      "a14b", "Strut B Transformer Room", // AW & DMW
      "a15b", "BC connecting bridge",
      "a16a", "Strut C Dining Hall",
      "a17a", "CD connecting bridge",
      "a18a", "Strut D Sediment Pool",
      "a19a", "DE connecting bridge",
      "a20a", "Strut E Parcel Room, 1F", // AW
      "a20b", "Strut E heliport (BSE)",
      "a20c", "Strut E heliport",
      "a20e", "Strut E Parcel Room, 1F", // BSE
      "a21a", "EF connecting bridge",
      "a22a", "Strut F warehouse", // AM & DMW
      "a22b", "Strut F warehouse", // BSE
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
      "tsp03a", "Gurlugon",
      "tvs03a", "Snake Sneaking Level 3",
      "twp03a", "Snake Handgun Level 3",
      "tvs05a", "Snake Sneaking Level 5",
      "tvs08a", "Snake Sneaking Level 8"
    } }
  };
  
  
  // Old rooms to exclude splitting (typically cutscenes)
  // Even if not necessary (more cutscenes immediately after, for example) this also keeps them out of the settings
  var ExcludeOldRoom = new string[] {
    "d04t", // Deck E
    "d05t", // Post-Olga
    "d10t", // Post-Guard Rush
    "d11t", // Hold 3
    "d12t", // Tanker ending
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
  var ExcludeCurrentRoom = new string[] {
  };
  
  // Old rooms to explicitly include a split at, even when the next room is unknown
  var IncludeOldRoom = new string[] {
  };
  // and new
  var IncludeCurrentRoom = new string[] {
    "museum", // end of tanker in tanker-plant
  };
  
  
  // VR Missions room sets
  // The basic idea: You go to every room in a set, then it splits when you exit to mselect
  var VRMissionRoomSets = new Dictionary< string, List<string> > {
    // Sneaking and Elim All
    { "vr_sneaking", new List<string> { "vs01a", "vs02a", "vs03a", "vs04a", "vs05a", "vs06a", "vs07a", "vs08a", "vs09a", "vs10a" } },
    // Handgun
    { "vr_handgun", new List<string> { "wp01a", "wp02a", "wp03a", "wp04a", "wp05a" } },
    // Rifle
    { "vr_rifle", new List<string> { "wp11a", "wp12a", "wp13a", "wp14a", "wp15a" } },
    // C4
    { "vr_c4", new List<string> { "wp21a", "wp22a", "wp23a", "wp24a", "wp25a" } },
    // Grenade
    { "vr_grenade", new List<string> { "wp31a", "wp32a", "wp33a", "wp34a", "wp35a" } },
    // PSG-1
    { "vr_psg1", new List<string> { "wp41a", "wp42a", "wp43a", "wp44a", "wp45a" } },
    // Stinger
    { "vr_stinger", new List<string> { "wp51a", "wp52a", "wp53a", "wp54a", "wp55a" } },
    // Nikita
    { "vr_nikita", new List<string> { "wp61a", "wp62a", "wp63a", "wp64a", "wp65a" } },
    // HF.Blade/No Weapon
    { "vr_no_weapon", new List<string> { "wp71a", "wp72a", "wp73a", "wp74a", "wp75a" } },
    // First Person
    { "vr_first_person", new List<string> { "sp21a", "sp22a", "sp24a", "sp25a" } },
    // Variety (will trigger Ninja Variety if only 8 is played before menu,
    //   MGS1 variety if 3/6/8 are played, or Pliskin/Tuxedo Variety is 6/8 are played)
    { "vr_variety", new List<string> { "sp01a", "sp02a", "sp03a", "sp06a", "sp07a", "sp08a" } },
    // Bomb Disposal
    { "vr_bomb_disposal", new List<string> { "a31a", "a02a", "a41a", "a42a", "a43a", "a01f", "a01a", "a01b", "a01c", "a01d", "a14a", "a15b", "a16a", "a17a", "a18a" } },
    // Elimination
    { "vr_elimination", new List<string> { "a23b", "a01a", "a19a", "a20a", "a24d", "a24a", "a31a", "a22a", "a42a", "a02a" } },
    // Hold Up
    { "vr_hold_up", new List<string> { "a15b", "a12a", "a24d", "a13b", "a14a", "a22a", "a01b", "a42a", "a20b", "a31a" } },
    // Photograph
    { "vr_photograph", new List<string> { "a01a", "a01f", "a00c", "a00a", "a03a" } },
    // Ninja Variety
    { "vr_variety_ninja", new List<string> { "sp08a" } },
    // Streaking
    { "vr_streaking", new List<string> { "st01a", "st02a", "st03a", "st04a", "st05a" } },
    // Snake Photograph
    { "vr_photograph_snake", new List<string> { "a01a", "a24g", "a24a", "a02b", "a41b", "a24f" } },
    // Pliskin/Tuxedo Variety
    { "vr_variety_pliskin", new List<string> { "sp06a", "sp08a" } },
    // MGS1 Variety (see Variety caveats)
    { "vr_variety_mgs1", new List<string> { "sp03a", "sp06a", "sp08a" } }
  };
  
  
  // Rooms not considered for immediate splits (mostly cutscenes)
  var OtherRooms = new Dictionary<string, string> {
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
    { "w24e", "Shell 1 Core, B1 Hall (with Ames)" },
    { "d070p09", "Arsenal Gear launch cutscene" },
    { "d070px9", "Arsenal Gear - Stomach cutscenes" },
    { "d080p06", "Arsenal Gear cutscenes" },
    { "d080p07", "Arsenal Gear entering Manhattan cutscene" },
    { "d080p08", "Federal Hall cutscenes" },
    // External Gazer
    { "ta02a", "Snake Bomb Disposal 2" },
    { "ta24a", "Snake Elimination Level 6" },
    { "ta31a", "Raiden Bomb Disposal Level 1" },
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
    { "wp21a", "C4/Claymore 1"},
    { "wp22a", "C4/Claymore 2"},
    { "wp23a", "C4/Claymore 3"},
    { "wp24a", "C4/Claymore 4"},
    { "wp25a", "C4/Claymore 5"},
    { "wp31a", "Grenade 1"},
    { "wp32a", "Grenade 2"},
    { "wp33a", "Grenade 3"},
    { "wp34a", "Grenade 4"},
    { "wp35a", "Grenade 5"},
    { "wp41a", "PSG-1 1"},
    { "wp42a", "PSG-1 2"},
    { "wp43a", "PSG-1 3"},
    { "wp44a", "PSG-1 4"},
    { "wp45a", "PSG-1 5"},
    { "wp51a", "Stinger 1"},
    { "wp52a", "Stinger 2"},
    { "wp53a", "Stinger 3"},
    { "wp54a", "Stinger 4"},
    { "wp55a", "Stinger 5"},
    { "wp61a", "Nikita 1"},
    { "wp62a", "Nikita 2"},
    { "wp63a", "Nikita 3"},
    { "wp64a", "Nikita 4"},
    { "wp65a", "Nikita 5"},
    { "wp71a", "HF Blade/No Weapon 1"},
    { "wp72a", "HF Blade/No Weapon 2"},
    { "wp73a", "HF Blade/No Weapon 3"},
    { "wp74a", "HF Blade/No Weapon 4"},
    { "wp75a", "HF Blade/No Weapon 5"},
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
  
  // Dog tag counts
  vars.MaxDogTags = new Dictionary<int, int[]> {
    { 200, new[] { 24, 43, 67 } },
    { 120, new[] { 25, 44, 69 } }, // Nice
    { 100, new[] { 33, 49, 82 } },
    { 75, new[] { 35, 52, 87 } },
    { 50, new[] { 34, 54, 88 } }
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
  vars.SplitRightNow = false;
  
  // Add main settings
  settings.Add("options", true, "Advanced Options");
  
    settings.Add("debug_file", true, "Save debug information to LiveSplit program directory", "options");
    settings.Add("resets", true, "Reset the timer when returning to menu", "options");
    settings.Add("boss_insta", true, "Split instantly when a boss is defeated", "options");
    settings.SetToolTip("boss_insta", "This also enables boss health information in ASL Var Viewer");
    settings.Add("dogtag_insta", false, "Split when a dog tag is collected", "options");
    settings.SetToolTip("dogtag_insta", "The setting \"Enable ASL Var Viewer Integration\" below must also be enabled");
    
    settings.Add("aslvv", true, "Enable ASL Var Viewer integration", "options");
    settings.SetToolTip("aslvv", "Disabling this may slightly improve performance");
      settings.Add("aslvv_info", true, "ASL_Info (contextual information)", "aslvv");
        settings.Add("aslvv_info_vars", true, "Display these values:", "aslvv_info");
          settings.Add("aslvv_info_codename", true, "Codename changes", "aslvv_info_vars");
          settings.Add("aslvv_info_room", false, "Current location", "aslvv_info_vars");
          settings.SetToolTip("aslvv_info_room", "Use ASL_CurrentRoom if you only want the location");
          settings.Add("aslvv_info_tags", true, "Dog tag progress", "aslvv_info_vars");
          settings.SetToolTip("aslvv_info_tags", "Also see the options for ASL_DogTags");   
            settings.Add("aslvv_info_tags_onlycurrent", false, "Show total only for the current character", "aslvv_info_tags");
          settings.Add("aslvv_info_caution", true, "Caution", "aslvv_info_vars");
          settings.Add("aslvv_info_chaff", true, "Chaff", "aslvv_info_vars");
          settings.Add("aslvv_info_grip", true, "Grip", "aslvv_info_vars");
          settings.Add("aslvv_info_o2", true, "O2", "aslvv_info_vars");
            settings.Add("aslvv_info_o2health", false, "Also show the time remaining from Life", "aslvv_info_o2");
          settings.Add("aslvv_info_boss", true, "Boss health", "aslvv_info_vars");
          settings.SetToolTip("aslvv_info_boss", "The setting \"Split instantly when a boss is defeated\" above must also be enabled");
          settings.Add("aslvv_info_choke", true, "Choke torture progress", "aslvv_info_vars");
          settings.Add("aslvv_info_colon", true, "Ascending Colon tutorial progress", "aslvv_info_vars");
        settings.Add("aslvv_info_max", true, "Also show the maximum value for raw values", "aslvv_info");
        settings.Add("aslvv_info_percent", true, "Show percentages instead of raw values", "aslvv_info");
      settings.Add("aslvv_boss", true, "ASL_CodeNameStatus (Perfect Stats attempt tracking)", "aslvv");
        settings.Add("aslvv_boss_specific", true, "Also show the top-rank-specific stats if they are broken", "aslvv_boss");
        settings.SetToolTip("aslvv_boss_specific", "Disable this if you're going for Perfect Stats rather than a top rank such as Big Boss");
        settings.Add("aslvv_boss_short", false, "Show single letters for stats instead of full titles", "aslvv_boss");
        settings.SetToolTip("aslvv_boss_short", "Enable this if the full stat names make the message too long");
      settings.Add("aslvv_tags", true, "ASL_DogTags (dog tag collection stats)", "aslvv");
        settings.Add("aslvv_tags_max", true, "Also show the total number of available dog tags", "aslvv_tags");
    
    settings.Add("options_plant", true, "Plant", "options");
    
    settings.Add("options_snaketales", true, "Snake Tales", "options");  
      settings.Add("snaketales_a", true, "A Wrongdoing", "options_snaketales");
      settings.Add("snaketales_b", true, "Big Shell Evil", "options_snaketales");
      settings.Add("snaketales_c", true, "Confidential Legacy", "options_snaketales");
      settings.Add("snaketales_d", true, "Dead Man Whispers", "options_snaketales");
      settings.Add("snaketales_e", true, "External Gazer", "options_snaketales");
    
    settings.Add("options_vr", true, "VR Missions", "options");    
      settings.Add("vr_variety_ninja", false, "Enable splits for Variety (Ninja)", "options_vr");
      settings.Add("vr_variety_pliskin", false, "Enable splits for Variety (Pliskin/Tuxedo)", "options_vr");
      settings.Add("vr_variety_mgs1", false, "Enable splits for Variety (MGS1)", "options_vr");
      string Tooltip = "The rules for these modes can accidentally trigger Variety splits for other characters. Only enable if you are playing this character.";
      settings.SetToolTip("vr_variety_ninja", Tooltip);
      settings.SetToolTip("vr_variety_pliskin", Tooltip);
      settings.SetToolTip("vr_variety_mgs1", Tooltip);
      
  settings.Add("special", false, "Strategy Testing Mode");
  settings.SetToolTip("special", "Split behaviours suited to route/strategy testing. Ideally use with a large set of unnamed splits, with a layout showing time between splits and without deltas.");
    settings.Add("special_allroomstarts", false, "Split on every screen load", "special");
    settings.SetToolTip("special_allroomstarts", "This will usually split multiple times during cutscenes");
    settings.Add("special_allroomchanges", false, "Split on every area change", "special");
    settings.SetToolTip("special_allroomchanges", "This will usually split multiple times during cutscenes");
    settings.Add("special_startbutton", false, "Split when START is pressed", "special");
    settings.Add("special_r3button", false, "Split when R3 is pressed", "special");
    settings.Add("special_disabledefault", true, "Disable the default autosplitter behaviour", "special");
    
  settings.Add("splits", true, "Split Locations");
  settings.SetToolTip("splits", "Enable or disable splitting when leaving these areas");
  
  
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
  // This is a lot of setup, but it's worth it for O(1) room lookups
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
  
  
  // General-purpose room identifier
  Func<string, string> GetRoomName = delegate(string RoomCode) {
    string output = "";
    if (vars.Rooms.TryGetValue(RoomCode, out output)) return output;
    if (OtherRooms.TryGetValue(RoomCode, out output)) return output;
    return "Undefined room";
  };
  vars.GetRoomName = GetRoomName;
  
  
  // VR roomset signatures and settings
  vars.VRMissions = false;
  // Hash function
  Func< List<string>, string > VRMissionHash = delegate(List<string> roomset) {
    var array = roomset.ToArray();
    Array.Sort(array);
    return String.Join(";", array);
  };
  Func< List<string>, int, string> VRMissionHashRange = delegate(List<string> roomset, int range) {
    int length = roomset.Count();
    List<string> slice = roomset.GetRange(length - range, range).ToArray().ToList();
    return VRMissionHash(slice);
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
  string TempSetting = "d014p01";
  settings.Add(TempSetting, false, "Split when meeting Stillman", "options_plant");
  settings.SetToolTip(TempSetting, "You will need two Strut C splits if this is enabled");
  vars.SpecialNewRoom.Add(TempSetting, new Dictionary<string, string> {
    { "old", "w16a" },
    { "setting", TempSetting }
  });
  // Never split when meeting Olga in Strut E heliport
  vars.SpecialNewRoom.Add("d021p01", new Dictionary<string, string> {
    { "old", "w20b" },
    { "no_split", "true" }
  });
  // Option to split when meeting Prez in Shell 2 Core
  TempSetting = "w31a_prez";
  settings.Add(TempSetting, true, "Split when meeting Prez", "options_plant");
  settings.SetToolTip(TempSetting, "You will need two Shell 2 Core 1F splits if this is enabled");
  vars.SpecialRoomChange.Add("w31a", new Dictionary<string, string> {
    { "current", "wmovie" },
    { "setting", TempSetting }
  });
  // Never split when opening the underwater hatch in Shell 2 Core B1
  TempSetting = "d053p01";
  settings.Add(TempSetting, false, "Split when opening the underwater hatch in Shell 2 Core B1", "options_plant");
  settings.SetToolTip(TempSetting, "You will need two Shell 2 Core B1 splits if this is enabled");
  vars.SpecialNewRoom.Add("d053p01", new Dictionary<string, string> { // B1 No.1 cutscenes
    { "old", "w31b" },
    { "setting_false", TempSetting },
    { "no_split", "true" }
  });
  // Never split immediately when starting Plant on it's own!
  vars.SpecialRoomChange.Add("museum", new Dictionary<string, string> {
    { "old", "ending" },
    { "no_split", "true" }
  });
  /*
  // Option to split when meeting Emma in Shell 2 Core B1
  TempSetting = "w31f_emma";
  settings.Add(TempSetting, true, "Don't split when meeting Emma", "options_plant");
  settings.SetToolTip(TempSetting, "You will need two Shell 2 Core B1 FC2 splits if this is not enabled");
  vars.SpecialRoomChange.Add("w31f", new Dictionary<string, string> {
    { "current", "d055p01" },
    { "setting", TempSetting },
    { "no_split", "true" }
  });
  */
    
  // A Wrongdoing: Option to split when meeting Ames in Strut F
  TempSetting = "snaketales_a_ames";
  settings.Add(TempSetting, false, "Split when meeting Ames", "snaketales_a");
  settings.SetToolTip(TempSetting, "You will need two Strut F splits if this is enabled");
  vars.SpecialRoomChange.Add("a22a", new Dictionary<string, string> {
    { "current", "tales" },
    { "setting_false", TempSetting },
    { "no_split", "true" }
  });

  // Big Shell Evil: Option to split when meeting Emma in Strut C - details in update
  TempSetting = "snaketales_b_pantry";
  settings.Add(TempSetting, false, "Split when meeting Emma in Strut C", "snaketales_b");
  settings.SetToolTip(TempSetting, "You will need a Strut C split before Guard Rush if this is enabled");
  // Option to split when accessing the node in Strut B - again, details in update
  TempSetting = "snaketales_b_node";
  settings.Add(TempSetting, false, "Split when accessing the node", "snaketales_b");
  settings.SetToolTip(TempSetting, "You will need two Strut B splits if this is enabled");
  // Option to split when meeting Emma in Strut F
  TempSetting = "snaketales_b_emma";
  settings.Add(TempSetting, false, "Split when meeting Emma in Strut F", "snaketales_b");
  settings.SetToolTip(TempSetting, "You will need two Strut F splits if this is enabled");
  vars.SpecialRoomChange.Add("a22b", new Dictionary<string, string> {
    { "current", "tales" },
    { "setting_false", TempSetting },
    { "no_split", "true" }
  });
  
  // Confidential Legacy: Never split when meeting Meryl in Deck E
  vars.SpecialRoomChange.Add("a01e", new Dictionary<string, string> {
    { "current", "tales" },
    { "no_split", "true" }
  });
  
  // External Gazer: Option to split after first AB connecting bridge (1st area) - possible???
    
  print("Startup complete");
}

update {
  try {
    // Callbacks go here - they need access to current and old so startup won't do the job  
    if (!vars.Initialised) {
      print("Beginning update initialisation...");
      
      vars.Initialised = true;
      var Vars = (IDictionary<string, object>)vars;
      int MaxVal = 99999;
      int Counter = 0;
      bool BossActive = false;
      bool NoBoss = false;
      int Continues = -1;
      bool BossDefeated = false;
      int BossCounter = MaxVal;
      int BossHealth = MaxVal;
      int BossStamina = MaxVal;
      int BossMaxHealth = -1;
      int BossMaxStamina = -1;
      bool BigBossFailed = false;
      int BigBossAlertState = 0;
      int RoomTrackerInt = 0;
      uint RoomTrackerUint = 0;
      bool RoomTrackerT = false;
      bool RoomTrackerP = false;
      bool RoomTrackerA = false;
      bool RoomTrackerB = false;
      bool RoomTrackerC = false;
      bool RoomTrackerD = false;
      bool RoomTrackerE = false;
      bool Cartwheeling = false;
      vars.PreviousTagsSnake = 0;
      vars.PreviousTagsRaiden = 0;
      vars.PrevInfo = "";
      vars.BossRush = false;
      vars.ResetNextFrame = false;
      vars.AllRoomStartsTimeout = 0;
      
      var ExceptionCount = new Dictionary<string, int> {
        { "reset", 0 },
        { "start", 0 },
        { "update", 0 },
        { "split", 0 }
      };
      
      var ValidMaxHealth = new Dictionary<string, int[]> {
        { "Olga", new[] {128, MaxVal} },
        { "Meryl", new[] {128, MaxVal} },
        { "Fatman", new[] {256, 384, 312} },
        { "Harrier", new[] {2250, 3250, 3500, 4000, 4750, 4750, MaxVal} },
        { "Vamp", new[] {100, 128} },
        { "Rays", new[] {3072, 5120, 7168, 10240, 20480, MaxVal} },
        { "Solidus", new[] {75, 95, 100} }
      };
      
      
      // Input checker
      var Button = new Dictionary<string, int> {
        { "l1", 1 },
        { "r1", 1 << 1 },
        { "l2", 1 << 2 },
        { "r2", 1 << 3 },
        { "triangle", 1 << 4 },
        { "circle", 1 << 5 },
        { "x", 1 << 6 },
        { "square", 1 << 7 },
        { "select", 1 << 8 },
        { "r3", 1 << 10 },
        { "start", 1 << 11 },
        { "up", 1 << 12 },
        { "right", 1 << 13 },
        { "down", 1 << 14 },
        { "left", 1 << 15 },
        { "l3", 0x60000 }
      };
      Func<string, int, int, bool> TestInput = delegate(string ToCheck, int CurrentInput, int PreviousInput) {
        bool cur = ((CurrentInput & Button[ToCheck]) == Button[ToCheck]);
        bool prev = ((PreviousInput & Button[ToCheck]) == Button[ToCheck]);
        return ( (cur) && (cur != prev) );
      };
      vars.TestInput = TestInput;
      
      // Debug message handler
      string DebugPath = System.IO.Path.GetDirectoryName(Application.ExecutablePath) + "\\mgs2_sse_debug.log";
      vars.DebugTimer = 0;
      vars.InfoTimer = 0;
      vars.DebugTimerStart = 120;
      Action<string> Debug = delegate(string message) {
        message = "[" + current.GameTime + "] " + message;
        if (settings["debug_file"]) {
          using(System.IO.StreamWriter stream = new System.IO.StreamWriter(DebugPath, true)) {
            stream.WriteLine(message);
            stream.Close();
          }
        }
        print("[MGS2AS] " + message);
        vars.ASL_Debug = message;
        // also overwrite the previous message if we're already showing the "splitting now" message
        if (vars.DebugTimer != vars.DebugTimerStart) vars.PrevDebug = message;
      };
      vars.Debug = Debug;
      
      Action<Exception, string> LogException = delegate(Exception e, string source) {
        if (ExceptionCount[source] < 10) { // only log the first 10 of a particular type per run
          ExceptionCount[source] = ExceptionCount[source] + 1;
          Debug("Error in " + source + ":\n" + e.ToString());
          if (ExceptionCount[source] == 10) Debug("Reached error limit for " + source + ", will not log again until next run");
        }
        print(e.ToString());
      };
      vars.LogException = LogException;
      
      Action<string> Info = delegate(string message) {
        vars.ASL_Info = message;
      };
      vars.Info = Info;
      
      Action<string> DebugInfo = delegate(string message) {
        Debug(message);
        Info(message);
      };
      vars.DebugInfo = DebugInfo;
      
      // Show debug a list of rooms
      /*
      string RoomNames = string.Join("\n  ", vars.Rooms);
      Debug("List of rooms: " + "{\n  " + RoomNames + "\n}");
      */
      
      // Shortened name for the byte[]-to-int converter
      Func<byte[], int> C = delegate(byte[] input) {
        if (input == null) return 0;
        return BitConverter.ToInt16(input, 0);
      };
      vars.C = C;
      
      // Code for current difficulty (0 = VE, 6 = EuEx)
      Func<int> Difficulty = () => current.Difficulty / 10 - 1;
      vars.Difficulty = Difficulty;
      
      // Name of current difficulty
      var DifficultyTexts = new string[] { "Very Easy", "Easy", "Normal", "Hard", "Extreme", "European Extreme" };
      Func<string> DifficultyText = () => DifficultyTexts[Difficulty()];
      vars.DifficultyText = DifficultyText;
      
      // Code for current level
      Func<int> Level = () => (C(current.Level) & 3) % 3;
      vars.Level = Level;
      
      // Name of current level
      var LevelTexts = new string[] { "Tanker-Plant", "Tanker", "Plant" };
      Func<string> LevelText = () => LevelTexts[Level()];
      
      // Is Radar enabled?
      Func<bool> RadarEnabled = () => ((C(current.Extra) & 0x2000) != 0);
      
      // Has a special item been used?
      Func<bool> SpItemUsed = () => ((C(current.Extra) & 0x20) != 0);
      
      // Confirm a split
      Func<string, bool> Split = delegate(string Reason) {
        vars.DebugTimer = vars.DebugTimerStart;
        vars.PrevDebug = vars.ASL_Debug;
        vars.Debug("Splitting now (" + Reason + ")");
        return true;
      };
      vars.Split = Split;
      
      // Check for new continues
      Func<bool> HasContinued = delegate() {
        int NewContinues = C(current.Continues);
        if (NewContinues > Continues) {
          Debug("Detected continue during boss: " + Continues + " > " + NewContinues);
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
        NoBoss = false;
        BossDefeated = false;
        BossCounter = MaxVal;
        BossMaxHealth = -1;
        BossMaxStamina = -1;
        Continues = -1;
        vars.SplitNextRoom = false;
        vars.BlockNextRoom = false;
        vars.SplitRightNow = false;
      };
      vars.ResetBossData = ResetBossData;
      
      // Reset all counters
      Action ResetData = delegate() {
        RoomTrackerInt = 0;
        RoomTrackerUint = 0;
        RoomTrackerT = false;
        RoomTrackerP = false;
        RoomTrackerA = false;
        RoomTrackerB = false;
        RoomTrackerC = false;
        RoomTrackerD = false;
        RoomTrackerE = false;
        Cartwheeling = false;
        vars.PreviousTagsSnake = 0;
        vars.PreviousTagsRaiden = 0;
        vars.ASL_Cartwheels = 0;
        vars.ASL_AmesLocation = "";
        ExceptionCount = new Dictionary<string, int> {
          { "reset", 0 },
          { "start", 0 },
          { "update", 0 },
          { "split", 0 }
        };
        ResetBigBossData();
        ResetBossData();
        vars.ResetNextFrame = false;
      };
      vars.ResetData = ResetData;
      
      Func<int, int, int, bool> Between = (input, lower, upper) => ( (input <= lower) && (input >= upper) );
      
      Func<int, int, int> Percent = delegate(int cur, int max) {
        double percentage = (100.0 * cur / max);
        return Convert.ToInt16( Math.Round(percentage) );
      };
      
      Func<int, int, string> ValueFormat = delegate(int cur, int max) {
        if (settings["aslvv_info_percent"]) return string.Format("{0,2}%", Percent(cur, max));
        
        int MaxLen = Math.Max((int)Math.Floor(Math.Log10(max) + 1), 1);
        if (settings["aslvv_info_max"]) return string.Format("{0," + MaxLen + "}/{1," + MaxLen + "}", cur, max);
        return string.Format("{0," + MaxLen + "}", cur);
      };
      vars.ValueFormat = ValueFormat;
      
      Func<int, string, string, string> Plural = (Var, Singular, Pluralular) => (Var != 1) ? Pluralular : Singular;
      

      
      // Temporary boss watcher to examine what health values do
      /*
      Func<string, int, int, int> WatchBoss = delegate(string Name, int CurrentStamina, int CurrentHealth) {
        if (Continues == -1) Continues = C(current.Continues);
        else if (HasContinued()) {
          ResetBossData();
          vars.Debug(current.RoomTimer +" | Continued");
        }
        if (CurrentStamina != BossStamina) {
          vars.Debug(current.RoomTimer +" | "+ Name +": Stamina "+ BossStamina +" > "+ CurrentStamina);
          BossStamina = CurrentStamina;
        }
        if (CurrentHealth != BossHealth) {
          vars.Debug(current.RoomTimer +" | "+ Name +": Health "+ BossHealth +" > "+ CurrentHealth);
          BossHealth = CurrentHealth;
        }
        return 0;
      };
      */
      // New snazzy boss watcher
      Func<string, int, int, int> WatchBoss = delegate(string Name, int NewStamina, int NewHealth) {
        if (!settings["boss_insta"]) return -1; // stop watching if insta-splits are disabled
        
        if (Continues == -1) Continues = C(current.Continues);
        
        if (current.RoomTimer > 5) {
          if ( (BossActive) && ( (NewStamina != BossStamina) || (NewHealth != BossHealth) ) ) {
            if (BossMaxStamina <= 0) {
              BossMaxStamina = NewStamina;
              BossMaxHealth = NewHealth;
            }
            
            string DebugDelta = "";
            if ( (BossHealth != MaxVal) && (NewHealth < BossHealth) )
              DebugDelta = "[-" + (BossHealth - NewHealth) + "] ";
            else if ( (BossStamina != MaxVal) && (NewStamina < BossStamina) )
              DebugDelta = "[-" + (BossStamina - NewStamina) + "] ";
            
            BossStamina = NewStamina;
            BossHealth = NewHealth;
                
            string DebugStamina = "";
            string DebugHealth = "";
            if (NewStamina != MaxVal) DebugStamina = " Stamina: " + ValueFormat(NewStamina, BossMaxStamina);
            if (NewHealth != MaxVal) DebugHealth = " Life: " + ValueFormat(NewHealth, BossMaxHealth);
            string DebugString = Name + " |" + DebugStamina + DebugHealth;
            if (settings["aslvv_info_boss"]) {
              DebugInfo(DebugDelta + DebugString);
              vars.InfoTimer = 300;
            }
            else Debug(DebugDelta + DebugString);
            if ( (NewStamina <= 0) || (NewHealth <= 0) ) {
              if (HasContinued()) { // making sure the no-health thing isn't just the game resetting health
                ResetBossData();
                return 0;
              }
              if (settings["aslvv_info_boss"]) {
                vars.PrevInfo = ""; // boss info will be out of fashion once the next message has timed out...
                DebugInfo("Boss defeated!");
              }
              else Debug("Boss defeated!");
              vars.BlockNextRoom = true;
              return 1;
            }
            vars.PrevInfo = DebugString;
          }
          else if ( (!NoBoss) && (!BossActive) && (current.RoomTimer < 60) ) {
            if ( (NewStamina == null) || (!ValidMaxHealth[Name].Contains(NewStamina)) || (NewHealth == null) || (!ValidMaxHealth[Name].Contains(NewHealth)) ) {
              vars.Debug("No boss in this area");
              NoBoss = true;
            }
            else {
              vars.Debug("Boss battle vs " + Name);
              BossActive = true;
            }
          }
        }
        // Reset our data and start again if the room has reloaded
        else if ( (NoBoss) || (BossActive) ) ResetBossData(); 
        
        return 0;
      };
     

      // BOSSES
      
      // Olga
      Func<int> WatchOlga = delegate() {
        int Stamina = (vars.BossRush) ? current.OlgaRushStamina : current.OlgaStamina;
        return WatchBoss("Olga", Stamina, MaxVal);
      };
      vars.SpecialWatchCallback.Add("w00b", WatchOlga);
      
      // Meryl (Confidential Legacy)
      Func<int> WatchMeryl = () => WatchBoss("Meryl", current.OlgaStamina, current.MerylHealth);
      vars.SpecialWatchCallback.Add("a00b", WatchMeryl);

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
          if (current.FatmanBombsActive == 0) {
            if (settings["aslvv_info_boss"]) {
              vars.InfoTimer = 180;
              DebugInfo("Boss completed!");
            }
            else Debug("Boss completed!");
            return 1; // not necesary to reset boss data as it'll happen in split
          }
          if (current.FatmanBombsActive < BossCounter) {
            BossCounter = current.FatmanBombsActive;
            vars.InfoTimer = 0; // deactivate the "boss defeated" timeout
            string DebugString = "Bombs remaining: " + Convert.ToString(BossCounter);
            if (settings["aslvv_info_boss"]) DebugInfo(DebugString);
            else Debug(DebugString);
          }
        }
        return 0;
      };
      vars.SpecialWatchCallback.Add("w20c", WatchFatman); // Sons of Liberty
      vars.SpecialWatchCallback.Add("a20c", WatchFatman); // A Wrongdoing
      
      // Harrier
      Func<int> WatchHarrier = () => WatchBoss("Harrier", MaxVal, C(current.HarrierHealth));
      vars.SpecialWatchCallback.Add("w25a", WatchHarrier); // Sons of Liberty
      vars.SpecialWatchCallback.Add("a25a", WatchHarrier); // Big Shell Evil
      
      // Vamp
      Func<int> WatchVamp = () => WatchBoss("Vamp", C(current.VampStamina), C(current.VampHealth));
      vars.SpecialWatchCallback.Add("w31c", WatchVamp); // Sons of Liberty
      vars.SpecialWatchCallback.Add("a31c", WatchVamp); // Dead Man Whispers
      
      // Vamp 2
      Func<int> WatchVamp2 = () => WatchBoss("Vamp", C(current.Vamp2Stamina), C(current.Vamp2Health));
      vars.SpecialWatchCallback.Add("w32b", WatchVamp2);
      
      // Rays
      Func<int> WatchRays = () => WatchBoss("Rays", MaxVal, C(current.RaysHealth));
      vars.SpecialWatchCallback.Add("w46a", WatchRays); // Sons of Liberty
      Func<int> WatchRaysEG = () => WatchBoss("Rays", MaxVal, C(current.RaysTalesHealth));
      vars.SpecialWatchCallback.Add("a46a", WatchRaysEG); // External Gazer
      
      // Choke Boss (no split)
      Func<int> WatchChoke = delegate() {
        if (!settings["aslvv_info_choke"]) return -1;
        int FramesLeft = C(current.ChokeTimer);
        if ( (FramesLeft < 1) || (FramesLeft > 3000) ) return 0;
        vars.InfoTimer = 10;
        Info("Time left: " + string.Format( "{00:0.0}", (decimal)((double)FramesLeft / 60) ));
        return 0;
      };
      vars.SpecialWatchCallback.Add("w51a", WatchChoke);

      // Solidus
      Func<int> WatchSolidus = () => WatchBoss("Solidus", current.SolidusStamina, current.SolidusHealth);
      vars.SpecialWatchCallback.Add("w61a", WatchSolidus); // Sons of Liberty
      vars.SpecialWatchCallback.Add("a61a", WatchSolidus); // External Gazer
      
      // BOSSES END

      
      // Plant: Log Ames' position... after we've found him, of course
      Func<int> CallAmesLocation = delegate() {
        if (current.RoomCode == "d036p03") {
          vars.ASL_AmesLocation = current.AmesLocation;
        }
        return 0;
      };
      vars.SpecialRoomChangeCallback.Add("w24c", CallAmesLocation);
      
      // Plant: Filter out the "valid" room change that happens during the torture cutscenes
      Func<int> CallTortureCutscene = delegate() {
        // cutscene > jejunum
        if (current.RoomCode == "w42a") {
          Debug("In the torture sequence: skipping the Jejunum > Stomach room change that occurs during it");
          RoomTrackerP = true;
        }
        return 0;
      };
      Func<int> CallTortureCutscene2 = delegate() {
        // jejunum > stomach (in cutscene)
        if ( (RoomTrackerP) && (current.RoomCode == "w41a") ) {
          RoomTrackerP = false;
          return -1;
        }
        return 0;
      };
      vars.SpecialRoomChangeCallback.Add("d070px9", CallTortureCutscene);
      vars.SpecialRoomChangeCallback.Add("w42a", CallTortureCutscene2);
      
      // Plant: Show the 45-second timer for Ascending Colon
      Func<int> WatchAscendingColon = delegate() {
        if (!settings["aslvv_info_colon"]) return -1;
        if (current.AscendingColonActive == 0) return 0;
        int FramesLeft = C(current.AscendingColonTimer);
        if (FramesLeft == 0) return 0;
        vars.InfoTimer = 10;
        Info("Time left: " + string.Format( "{00:0.0}", (decimal)((double)FramesLeft / 60) ));
        return 0;
      };
      vars.SpecialWatchCallback.Add("w43a", WatchAscendingColon);
      
      // Plant: Increment the Big Boss alert counters
      Func<int> CallBigBossAlert1 = delegate() {
        BigBossAlertState = 1;
        Debug("Setting Big Boss alert allowance to 1");
        return 0;
      };
      Func<int> WatchBigBossAlert2 = delegate() {
        // Trigger on the second instance of this room (after cutscene)
        if ( (RoomTrackerInt > 0) && (current.RoomTimer < RoomTrackerInt) ) {
          RoomTrackerInt = 0;
          BigBossAlertState = 2;
          Debug("Setting Big Boss alert allowance to 2");
          return -1;
        }
        if (current.RoomTimer < 30) RoomTrackerInt = current.RoomTimer;
        return 0;
      };
      Func<int> WatchBigBossAlert3 = delegate() {
        // Trigger on the third instance (after initial gameplay and cutscene)
        if ( (RoomTrackerInt > 0) && (current.RoomTimer < RoomTrackerInt) ) {
          if (RoomTrackerP) {
            RoomTrackerP = false;
            RoomTrackerInt = 0;
            BigBossAlertState = 3;
            Debug("Setting Big Boss alert allowance to 3");
            return -1;
          }
          else RoomTrackerP = true;
        }
        if (current.RoomTimer < 30) RoomTrackerInt = current.RoomTimer;
        return 0;
      };
      vars.SpecialNewRoomCallback.Add("w32a", CallBigBossAlert1); // Oil Fence sniping
      vars.SpecialWatchCallback.Add("w44a", WatchBigBossAlert2); // Tengus 1
      vars.SpecialWatchCallback.Add("w45a", WatchBigBossAlert3); // Tengus 2
      
      // Snake Tales in general: Don't split if we're coming from storyline.
      Func<int> CallSnakeTales = delegate() {
        // Also set up for the results check
        if (current.RoomCode == "sselect") {
          RoomTrackerInt = 1;
          Debug("Trying to figure out when this tale of snakes has ended.");
        }
        return -1; // don't split after tales
      };
      vars.SpecialRoomChangeCallback.Add("tales", CallSnakeTales);
      // And the results check.
      Func<int> WatchSnakeTalesCredits = delegate() {
        // it starts at 0, goes up...
        if ( (RoomTrackerInt == 1) && (C(current.STCompletionCheck) != 0) ) RoomTrackerInt = 2;
        // ...then goes back to 0
        else if ( (RoomTrackerInt == 2) && (C(current.STCompletionCheck) == 0) ) {
          Debug("Moved briskly to the Snake Tales result screen!");
          RoomTrackerInt = 0;
          return 1;
        }
        return 0;
      };
      vars.SpecialWatchCallback.Add("sselect", WatchSnakeTalesCredits);
      
      // Big Shell Evil: Option to split when meeting Emma in Strut C
      Func<int> CallBSEStrutC1 = delegate() {
        if (current.RoomCode == "a16a") {
          Debug("[BSE] Entering Strut C from D: will skip pre-Guard Rush split if enabled in settings");
          RoomTrackerB = true;
        }
        return 0;
      };
      Func<int> CallBSEStrutC2 = delegate() {
        if (current.RoomCode == "tales") {
          if (RoomTrackerB) {
            RoomTrackerB = false;
            return (settings["snaketales_b_pantry"]) ? 1 : -1; // pre-Guard Rush, split on setting
          }
          return 1; // post-Guard Rush, always split
        }
        return 0; // defer otherwise
      };
      vars.SpecialRoomChangeCallback.Add("a17a", CallBSEStrutC1);
      vars.SpecialRoomChangeCallback.Add("a16a", CallBSEStrutC2);
      
      // Big Shell Evil: Option to split when accessing the node in Strut B
      // (with some extra stuff to tiptoe around the same sequence in External Gazer - this is a bit awkward
      //  because we can't really tweak the already-awkward Strut C situ in BSE)
      Func<int> CallEGStrutB = delegate() {
        RoomTrackerE = true; // in reverse! set the tracker when we go to EG-only VR
        return 0;
      };
      Func<int> CallBSEStrutB = delegate() {
        if ( (!RoomTrackerE) && (current.RoomCode == "tales") ) {
          RoomTrackerE = false;
          return (settings["snaketales_b_node"]) ? 1 : -1;
        }
        return 0;
      };
      vars.SpecialRoomChangeCallback.Add("ta02a", CallEGStrutB);
      vars.SpecialRoomChangeCallback.Add("a14a", CallBSEStrutB);
      
      // Split at the right time (or at least, a frame or two after the right time - this won't affect IGT) on the results screen
      Func<int> WatchEnding = delegate() {
        if (current.GameTime == RoomTrackerUint) {
          RoomTrackerUint = 0;
          return 1;
        }
        RoomTrackerUint = current.GameTime;
        return 0;
      };
      vars.SpecialWatchCallback.Add("ending", WatchEnding);
      
      
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
            vars.Debug("Checking hash " + Hash);
            string VRCategory = "";
            if (vars.VRMissionSignatures.TryGetValue(Hash, out VRCategory)) {
              if ( (!settings.ContainsKey(VRCategory)) || (settings[VRCategory]) ) {
                Debug("Found completed VR roomset " + VRCategory + " = " + Hash);
                VRMissionsCurrentRooms.Clear();
                return true;
              }
              Debug("Found completed VR roomset " + VRCategory + " = " + Hash + ", but it is disabled in settings");
            }
          }
          return false;
        };
        // Otherwise, add the current room to the list:
        // Do nothing if we just did this room
        int VRCount = VRMissionsCurrentRooms.Count;
        if ( (VRCount > 0) && (VRMissionsCurrentRooms[VRCount - 1] == RoomCode) ) return false; 
        // Remove the duplicate if it's not the most recent
        if (VRMissionsCurrentRooms.Contains(RoomCode)) VRMissionsCurrentRooms.Remove(RoomCode);
        // Add this room as most recent
        VRMissionsCurrentRooms.Add(RoomCode);
        Debug("Entered [" + RoomCode + "] " + vars.GetRoomName(current.RoomCode) + ", adding to current roomset > " + vars.VRMissionHash(VRMissionsCurrentRooms));
        return false;
      };
      Action VRMissionsEnable = delegate() {
        Debug("VR Missions mode on!");
        vars.VRMissions = true;
        VRMissionsCurrentRooms.Clear();
        VRLogMission(current.RoomCode); // we need to log the first room here
      };
      vars.VRMissionsEnable = VRMissionsEnable;
      vars.VRLogMission = VRLogMission;
      


      // New codename functionality
      bool PerfectStatsOnly = false;
      bool TopCodeName = false;
      Func<string> CurrentCodeName = delegate() {
        int Category = -1;
        PerfectStatsOnly = false;
        TopCodeName = false;
        
        int DifficultyCode = Difficulty();
        var DifficultyModifiers = new int[] { 3, 3, 2, 1, 0, 0 };
        int DifficultyModifier = DifficultyModifiers[DifficultyCode];
        vars.ASL_Difficulty = DifficultyText();
        
        int CurrentLevel = Level();
        vars.ASL_Level = LevelText();
        
        var Ranks = new string[] { "", "", "", "" };
        
        // Tanker-Plant only stuff
        if (CurrentLevel == 0) {
          // Top ranks
          // Shared by all top ranks
          if ( (!vars.ASL_SpecialItems) && (vars.ASL_Kills == 0) && (vars.ASL_Continues == 0) ) {
            // Shared by ranks 1/2
            if ( (vars.ASL_Alerts <= BigBossAlertState) && (vars.ASL_Rations == 0) && (vars.ASL_Minutes < 181) ) {
              // Rank 1 only
              int DamageLimit = (11 * current.MaxHealth) - 50;
              if ( (!RadarEnabled()) && (vars.ASL_Saves < 9) && (vars.ASL_Shots < 701) && (vars.ASL_DamageTaken < DamageLimit) ) {
                TopCodeName = true;
                Category = 0;
              }
              // Rank 2
              else if (vars.ASL_Saves < 17) Category = 1;
            }
            else if ( (vars.ASL_Alerts <= (BigBossAlertState + 1)) && (vars.ASL_Rations < 4) && (vars.ASL_Minutes < 195) ) {
              Category = 2;
            }
            else if ( (vars.ASL_Alerts <= (BigBossAlertState + 2)) && (vars.ASL_Minutes < 210) ) {
              Category = 3;
            }
          }
          if (Category != -1) {
            int Result = Category + new int[] { 4, 3, 2, 1, 0, 0 }[DifficultyCode];
            if (Result < 4) return new string[] { "Big Boss", "Fox", "Doberman", "Hound" }[Result];
          }
          // Bottom rank
          else if ( (vars.ASL_Alerts > BigBossAlertState + 246) && (vars.ASL_Kills > 249) && (vars.ASL_Rations > 30) && (vars.ASL_Saves > 99) && (vars.ASL_Continues > 59) && (vars.ASL_Minutes > 1799) ) {
            return new string[] { "Ostrich", "Rabbit", "Mouse", "Chicken" }[DifficultyModifier];
          }
        }
        else PerfectStatsOnly = true;
        
        // Individual stats
        if ( (CurrentLevel != 0) && (current.SeaLouce == 1) ) return "Sea Louce";
        if (vars.ASL_Alerts <= new int[] { BigBossAlertState, 0, BigBossAlertState }[CurrentLevel]) {
          return new string[] { "Night Owl", "Flying Fox", "Bat", "Flying Squirrel" }[DifficultyModifier];
        }
        if (vars.ASL_Kills == 0) return "Pigeon";
        if (vars.ASL_Minutes < new int[] { 181, 19, 166 }[CurrentLevel]) {
          return new string[] { "Eagle", "Hawk", "Falcon", "Swallow" }[DifficultyModifier];
        }
        if (vars.ASL_ClearingEscapes > new int[] { 149, 49, 99 }[CurrentLevel]) return "Gazelle";
        if (vars.ASL_Alerts > new int[] { BigBossAlertState + 246, 49, BigBossAlertState + 196 }[CurrentLevel]) return "Cow";
        if (vars.ASL_Kills > new int[] { 249, 49, 199 }[CurrentLevel]) {
          return new string[] { "Orca", "Jaws", "Shark", "Piranha" }[DifficultyModifier];
        }
        if (vars.ASL_Rations > 30) {
          return new string[] { "Whale", "Mammoth", "Elephant", "Pig" }[DifficultyModifier];
        }
        if (vars.ASL_Minutes > new int[] { 1799, 299, 1499 }[CurrentLevel]) {
          return new string[] { "Giant Panda", "Sloth", "Capybara", "Koala" }[DifficultyModifier];
        }
        if (vars.ASL_Saves > new int[] { 99, 24, 74 }[CurrentLevel]) {
          return new string[] { "Hippopotamus", "Zebra", "Deer", "Cat" }[DifficultyModifier];
        }
        
        // The rest
        string[,,] TheRest = new string[2, 2, 4] {
          { // 0 = <C
            { "Scorpion", "Jaguar", "Jackal", "Iguana" }, // 0 = <K
            { "Tarantula", "Panther", "Tasmanian Devil", "Crocodile" } // 1 = >K
          },
          { // 1 = >C
            { "Centipede", "Leopard", "Mongoose", "Comodo Dragon" }, // 0 = <K
            { "Spider", "Puma", "Hyena", "Alligator" } // 1 = >K
          }
        };
        int TestContinues = (vars.ASL_Continues > new int[] { 40, 10, 30 }[CurrentLevel]) ? 1 : 0;
        int TestKills = (vars.ASL_Kills > new int[] { 70, 15, 60 }[CurrentLevel]) ? 1 : 0;
        return TheRest[TestContinues, TestKills, DifficultyModifier];

      };
      vars.CurrentCodeName = CurrentCodeName;
      
      
      
      // ASL_CodeNameStatus for ASLVarViewer
      Action UpdateCodeNameStatus = delegate() {
        List<string> PerfectStatus = new List<string>();
        List<string> BossStatus = new List<string>();
        string Status = "";
        
        string Prefix = "Still on course for ";

        if (!TopCodeName) {
          // If over 3 alerts (only allowing for the mandatory ones when they appear)...
          if (vars.ASL_Alerts > BigBossAlertState) PerfectStatus.Add(vars.ASL_Alerts + ((settings["aslvv_boss_short"]) ? "A" : Plural(vars.ASL_Alerts, " Alert", " Alerts")) );
          // If has continued...
          if (vars.ASL_Continues > 0) PerfectStatus.Add( vars.ASL_Continues + ((settings["aslvv_boss_short"]) ? "C" : Plural(vars.ASL_Continues, " Continue", " Continues")) );
          // If has killed...
          if (vars.ASL_Kills > 0) PerfectStatus.Add( vars.ASL_Kills + ((settings["aslvv_boss_short"]) ? "K" : Plural(vars.ASL_Kills, " Kill", " Kills")) );
          // If has eaten rations...
          if (vars.ASL_Rations > 0) PerfectStatus.Add( vars.ASL_Rations + ((settings["aslvv_boss_short"]) ? "R" : Plural(vars.ASL_Rations, " Ration", " Rations")) );
          
          if ( (!PerfectStatsOnly) && (settings["aslvv_boss_specific"]) ) {
            // If the radar's enabled...
            if (RadarEnabled()) BossStatus.Add((settings["aslvv_boss_short"]) ? "R!" : "Radar On");
            // If has used special items...
            if (vars.ASL_SpecialItems) BossStatus.Add((settings["aslvv_boss_short"]) ? "S!" : "Special Items");
            // If has saved more than 8 times...
            if (vars.ASL_Saves > 8) BossStatus.Add( vars.ASL_Saves + ((settings["aslvv_boss_short"]) ? "S" : Plural(vars.ASL_Saves, " Save", " Saves")) );
            // If has taken too much damage...
            if (vars.ASL_DamageTaken >= (current.MaxHealth * 11) - 50) BossStatus.Add( vars.ASL_DamageTaken + ((settings["aslvv_boss_short"]) ? "D" : " Damage"));
            // If has shot a decent number of bullets...
            if (vars.ASL_Shots > 700) BossStatus.Add( vars.ASL_Shots + ((settings["aslvv_boss_short"]) ? "B" : Plural(vars.ASL_Shots, " Shot", " Shots")) );
            // If time is 3h00m01s or more
            if (current.GameTime > ((60/*f*/ * 60/*s*/ * 60/*m*/ * 3/*h*/) + 59)) BossStatus.Add((settings["aslvv_boss_short"]) ? ">3h" : "Over 3 Hours");
            
            if (BossStatus.Count > 0) {
              Status = String.Join((settings["aslvv_boss_short"]) ? " " : ", ", BossStatus);
            }
          }
          
          if (PerfectStatus.Count > 0) {
            if (Status != "") Status = ((settings["aslvv_boss_short"]) ? " " : ", ") + Status;
            Status = String.Join((settings["aslvv_boss_short"]) ? " " : ", ", PerfectStatus) + Status;
          }
          
          if (Status != "") Status = Status + " [" + vars.ASL_CodeName + "]";
          else if (PerfectStatsOnly) Status = Prefix + "Perfect Stats";
        }
        
        vars.ASL_CodeNameStatus = (Status == "") ? Prefix + vars.ASL_CodeName : Status; 
      };
      vars.UpdateCodeNameStatus = UpdateCodeNameStatus;
      
      // ASLVarViewer values
      var ListOfStats = new string[] { "Minutes", "Alerts", "Continues", "Shots", "Rations", "Kills", "Saves", "ClearingEscapes", "DamageTaken", "SeaLouce", "SpecialItems" };
      var Previous = new Dictionary<string, int>();
      foreach (string stat in ListOfStats) Previous.Add(stat, MaxVal);

      int PreviousO2 = -1;
      int PreviousGrip = -1;
      int PreviousCaution = -1;
      uint LastCodeNameCheck = 0;
      int WarmUpTimer = 5;
      float ChaffRate = (1024.0f / 30);
      
      vars.ASL_CodeName = "";
      
      Action UpdateASLVars = delegate() {
        vars.ASL_RoomTimer = current.RoomTimer;
        if ( (!Cartwheeling) && (current.CartwheelCode == 16) ) {
          Cartwheeling = true;
          vars.ASL_Cartwheels = vars.ASL_Cartwheels + 1;
        }
        else if ( (Cartwheeling) && (current.CartwheelCode == 0) )
          Cartwheeling = false;

        // Update less-critical values at a lower rate
        if ((current.RoomTimer % 15) == 0) {
          vars.ASL_Alerts = C(current.Alerts);
          vars.ASL_Continues = C(current.Continues);
          vars.ASL_Shots = C(current.Shots);
          vars.ASL_Rations = C(current.Rations);
          vars.ASL_Kills = C(current.Kills);
          vars.ASL_Saves = C(current.Saves);
          vars.ASL_MechsDestroyed = C(current.Mechs);
          vars.ASL_ClearingEscapes = C(current.Clearings);
          vars.ASL_Strength = C(current.StrengthRaiden);
          vars.ASL_AlertAllowance = BigBossAlertState;
          vars.ASL_SeaLouce = current.SeaLouce;
          vars.ASL_SpecialItems = SpItemUsed();
          
          int CurrentDamage = C(current.Damage);
          if (CurrentDamage > vars.ASL_DamageTaken) vars.ASL_LastDamage = (CurrentDamage - vars.ASL_DamageTaken);
          vars.ASL_DamageTaken = CurrentDamage;
         
          // Update the codename if a stat has changed (max once per second)
          if ( (current.GameTime > (LastCodeNameCheck + 60)) || (current.GameTime < LastCodeNameCheck) ) {
            vars.ASL_Minutes = (int)Math.Floor(( ((float)current.GameTime / 60) - 1 ) / 60);
            foreach (string stat in ListOfStats) {
              int statvalue = Convert.ToInt32(Vars["ASL_" + stat]);
              if (statvalue != Previous[stat]) {
                print("Checking for new codename...");
                string NewCodeName = CurrentCodeName();
                if (NewCodeName != vars.ASL_CodeName) {
                  print("New codename: " + NewCodeName);
                  if (settings["aslvv_info_codename"]) {
                    vars.ASL_Info = "Codename changed to " + NewCodeName;
                    vars.InfoTimer = 300;
                  }
                  vars.ASL_CodeName = NewCodeName;
                }
                UpdateCodeNameStatus();
                Previous[stat] = statvalue;
                LastCodeNameCheck = current.GameTime; // Move this out of the foreach if hurting performance
                break;
              }
            }
          }
          
          // Update dog tag counters if we collect one
          if ( (current.MaxHealth != 30) && 
            ((settings["dogtag_insta"]) || ((current.RoomTimer % 15) == 0)) ) {
            bool CollectedTagRaiden = (current.DogTagsRaiden > vars.PreviousTagsRaiden);
            bool CollectedTagSnake = (current.DogTagsSnake > vars.PreviousTagsSnake);
            if (CollectedTagRaiden || CollectedTagSnake) {
              vars.ASL_DogTags_Snake = current.DogTagsSnake + (settings["aslvv_tags_max"] ? "/" + vars.MaxDogTags[current.MaxHealth][0] : "");
              vars.ASL_DogTags_Raiden = current.DogTagsRaiden + (settings["aslvv_tags_max"] ? "/" + vars.MaxDogTags[current.MaxHealth][1] : "");
              vars.ASL_DogTags = current.DogTagsSnake + current.DogTagsRaiden + (settings["aslvv_tags_max"] ? "/" + vars.MaxDogTags[current.MaxHealth][2] : "");
              
              vars.PreviousTagsSnake = current.DogTagsSnake;
              vars.PreviousTagsRaiden = current.DogTagsRaiden;
              
              if (settings["dogtag_insta"]) vars.SplitRightNow = true;
              
              if (settings["aslvv_info_tags"]) {
                string TagStatus = "";
                if (settings["aslvv_info_tags_onlycurrent"])
                  TagStatus = (CollectedTagRaiden) ? vars.ASL_DogTags_Raiden : vars.ASL_DogTags_Snake;
                else TagStatus = vars.ASL_DogTags;
                vars.ASL_Info = "Dog Tags: " + TagStatus;
                vars.InfoTimer = 300;
              }
            }
          }
         
        }

        //bool Snake = (C(current.GripMultiplier) == 1800); // Raiden's is 3600 - but this doesn't work
        //vars.Debug(Snake ? "Snake" : "Raiden");
        //vars.Debug(C(current.GripMultiplier).ToString());
        
        if (vars.DebugTimer > 0) {
          vars.DebugTimer--;
          if (vars.DebugTimer == 0) vars.ASL_Debug = vars.PrevDebug;
        }
        
        if (vars.InfoTimer > 0) {
          vars.InfoTimer--;
          if (vars.InfoTimer == 0) {
            if (vars.PrevInfo != "") vars.ASL_Info = vars.PrevInfo;
            else vars.ASL_Info = (settings["aslvv_info_room"]) ? vars.ASL_CurrentRoom : "";
          }
        }

        int CurrentO2 = C(current.CurrentO2);
        int CurrentGrip = (current.CurrentGrip != null) ? C(current.CurrentGrip) : -1;
        int CurrentChaff = C(current.CurrentChaff);
        int CurrentCaution = C(current.CurrentCaution);

        // If we're underwater, update the O2 status in ASL_Info
        if (
          (settings["aslvv_info_o2"]) && (CurrentO2 != PreviousO2) &&
          (current.RoomCode != "w51a") && (current.RoomCode != "w41a")
        ) {
          PreviousO2 = CurrentO2;
          if (WarmUpTimer == 0) {
            int MaxO2 = (current.MaxHealth == 30) ? 3600 : 4000;
            int O2Rate = (current.CurrentHealth == current.MaxHealth) ? 60 : 120;
            string O2TimeLeft = string.Format( "{00:0.0}", (decimal)((double)CurrentO2 / O2Rate) );
            string HealthTimeLeft = "";
            if (settings["aslvv_info_o2health"]) {
              HealthTimeLeft = " + " + string.Format( "{00:0.0}", (decimal)((double)current.CurrentHealth / 4) );
            }
            vars.ASL_Info = "O2: " + vars.ValueFormat(CurrentO2, MaxO2) + " (" + O2TimeLeft + HealthTimeLeft + " left)";
            vars.InfoTimer = 60;
          }
          else WarmUpTimer = WarmUpTimer - 1;
        }
        // If we're hanging, update the grip status
        else if ( (settings["aslvv_info_grip"]) && (CurrentGrip != -1) && (CurrentGrip != PreviousGrip) ) {
          PreviousGrip = CurrentGrip;
          if (WarmUpTimer == 0) {
            int MaxGrip = C(current.MaxGrip);
            int GripRate = (current.CurrentHealth == current.MaxHealth) ? 60 : 120;
            string GripTimeLeft = string.Format( "{00:0.0}", (decimal)((double)CurrentGrip / GripRate) );
            vars.ASL_Info = "Grip: " + vars.ValueFormat(CurrentGrip, MaxGrip) + " (" + GripTimeLeft + " left)";
            vars.InfoTimer = 60;
          }
          else WarmUpTimer = WarmUpTimer - 1;
        }
        // If there's a chaff grenade active, show that
        else if ( (settings["aslvv_info_chaff"]) && (CurrentChaff > 0) ) {
          int MaxChaff = 1024;
          string ChaffTimeLeft = string.Format( "{00:0.0}", (decimal)((double)CurrentChaff / ChaffRate) );
          vars.ASL_Info = "Chaff: " + vars.ValueFormat(CurrentChaff, MaxChaff) + " (" + ChaffTimeLeft + " left)";
          vars.InfoTimer = 10;
        }
        // If we're in caution, show that
        else if ( (settings["aslvv_info_caution"]) && (CurrentCaution != PreviousCaution) ) {
          PreviousCaution = CurrentCaution;
          string CautionTimeLeft = string.Format( "{00:0.0}", (decimal)((double)CurrentCaution / 60) );
          vars.ASL_Info = "Caution: " + vars.ValueFormat(CurrentCaution, C(current.MaxCaution)) + " (" + CautionTimeLeft + " left)";
          vars.InfoTimer = 10;
        }
        else if (WarmUpTimer < 5) WarmUpTimer = WarmUpTimer + 1;
      };
      vars.UpdateASLVars = UpdateASLVars;
      
      
      Debug("Finished initialising script. It's all up to you now.");
    }
  }
  catch (Exception e) {
    vars.LogException(e, "update");
  }
  return true;
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
  try {
    bool DefinitelySplit = false;
    bool AvoidSplit = false;
    int CallbackResult = 0;
    bool BoolResult = false;
    Dictionary<string, string> SpecialCase = null;
    Func<string, bool> Split = vars.Split;
    
    // Special behaviours
    if (settings["special"]) {
      if ( (settings["special_startbutton"]) && (vars.TestInput("start", current.PadInput, old.PadInput)) )
        return Split("START pressed");
      if ( (settings["special_r3button"]) && (vars.TestInput("r3", current.PadInput, old.PadInput)) )
        return Split("R3 pressed");
      if (vars.AllRoomStartsTimeout > 0) vars.AllRoomStartsTimeout -= 1;
      else if ( (settings["special_allroomstarts"]) && (current.RoomTimer < old.RoomTimer) ) {
        vars.AllRoomStartsTimeout = 6;
        return Split("Room start");
      }
      if ( (settings["special_allroomchanges"]) && (current.RoomCode != old.RoomCode) )
        return Split("Room change");
      if (settings["special_disabledefault"])
        return false;
    }
    
    // Split RIGHT NOW
    if (vars.SplitRightNow) {
      vars.SplitRightNow = false;
      return Split("RIGHT NOW");
    }
    
    // Watching special cases
    if ( (!vars.DontWatch) && (vars.SpecialWatchCallback.ContainsKey(current.RoomCode)) ) {
      CallbackResult = vars.SpecialWatchCallback[current.RoomCode]();
      if (CallbackResult == 1) {
        vars.DontWatch = true;
        return Split("Requested by watch callback");
      }
      else if (CallbackResult == -1) vars.DontWatch = true;
    }
    
    // if (current.RoomTimer == 0) vars.ResetBossData(); // messes up split/blocknextroom
    
    if (current.RoomCode == old.RoomCode) return false; // room is unchanged
    
    vars.ASL_CurrentRoomCode = current.RoomCode;
    vars.ASL_CurrentRoom = vars.GetRoomName(current.RoomCode);
    vars.ASL_Info = (settings["aslvv_info_room"]) ? vars.ASL_CurrentRoom : "";
    
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
    
    // Respect the individual settings for rooms
    if ( (settings.ContainsKey(old.RoomCode)) && (!settings[old.RoomCode]) ) return false;
    
    // Handle block/split requests from watchers
    if (vars.BlockNextRoom) {
      vars.BlockNextRoom = false;
      vars.ResetBossData();
      return false; // something requested that we not split this time
    }
    if (vars.SplitNextRoom) {
      vars.SplitNextRoom = false;
      vars.ResetBossData();
      return Split("SplitNextRoom request"); // the opposite happened!
    }
    vars.ResetBossData();
    
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
        if ( (SpecialCase.ContainsKey("no_split")) && (SpecialCase["no_split"] == "true") ) {
          AvoidSplit = true;
          break;
        }
        return Split("Old-room special case");
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
        if ( (SpecialCase.ContainsKey("no_split")) && (SpecialCase["no_split"] == "true") ) {
          AvoidSplit = true;
          break;
        }
        return Split("New-room special case");
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
    if (vars.ExcludeOldRoom.ContainsKey(old.RoomCode)) AvoidSplit = true;
    if (vars.ExcludeCurrentRoom.ContainsKey(current.RoomCode)) AvoidSplit = true;
    
    // Rooms to include
    if (vars.IncludeOldRoom.ContainsKey(old.RoomCode)) DefinitelySplit = true;
    if (vars.IncludeCurrentRoom.ContainsKey(current.RoomCode)) DefinitelySplit = true;
   
    if ( (DefinitelySplit) || (!AvoidSplit) ) return Split("Normal split");
    
    return false;
  }
  catch (Exception e) {
    vars.LogException(e, "split");
    return false;
  }
}