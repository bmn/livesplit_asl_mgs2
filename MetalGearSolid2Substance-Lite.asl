/* Autosplitter-lite for Metal Gear Solid 2: Substance (PC) with V's Fix */

state("mgs2_sse") {
  uint      GameTime: 0xD8AEF8;
  string10  Section: 0xD8C374;
  string10  RoomCode: 0x601F34, 0x2C;
  ushort    ProgressTanker: 0xD8D93C;
  ushort    ProgressPlant: 0xD8D912;
  int       ResultsComplete: 0xA5397C;
}

isLoading {
  return true;
}

gameTime {
  return TimeSpan.FromMilliseconds((current.GameTime) * 1000 / 60);
}

reset {
  if (
    (current.RoomCode != old.RoomCode) && (current.RoomCode == "n_title")
  ) return true;
  return false;
}

start {
  if (current.RoomCode == old.RoomCode) return false;
  if (
    ( (old.RoomCode == "ending") && (!vars.Menus.ContainsKey(current.RoomCode)) ) ||
    ( (vars.Menus.ContainsKey(old.RoomCode)) && (current.RoomCode != "ending") )
  ) return true;
  return false;
} 

startup {
  vars.Menus = new Dictionary<string, bool> {
    { "n_title", true },
    { "mselect", true },
    { "sselect", true },
    { "tales", true }
  };
  
  vars.Except = new Dictionary< string, Func<bool> >();
  vars.Watch = new Dictionary< string, Func<bool> >();
  vars.Initialised = false;
  
  settings.Add("splits", true, "Split Points");
    settings.Add("tanker", true, "Tanker", "splits");
      settings.Add("r_tnk0_26", true, "Olga", "tanker");
      settings.Add("r_tnk0_33", true, "Guard Rush", "tanker");
      settings.Add("r_tnk0_56", true, "Results (Tanker Only)", "tanker");
      settings.Add("r_tnk0_58", true, "Plant transition (Tanker-Plant)", "tanker");
    
    settings.Add("plant", true, "Plant", "splits");
      settings.Add("r_plt0_63", true, "Stillman", "plant");
      settings.Add("r_plt0_115", true, "Fortune", "plant");
      settings.Add("r_plt3_119", true, "Fatman", "plant");
      settings.Add("r_plt0_155", true, "Ames", "plant");
      settings.Add("r_plt0_190", true, "Harrier", "plant");
      settings.Add("r_plt0_206", true, "Prez", "plant");
      settings.Add("r_plt0_254", true, "Vamp 1", "plant");
      settings.Add("r_plt0_318", true, "Vamp 2", "plant");
      settings.Add("r_plt0_397", true, "Tengus 1", "plant"); // Late split at 400
      settings.Add("r_plt0_404", true, "Tengus 2", "plant");
      settings.Add("r_plt0_412", true, "Rays", "plant");
      settings.Add("r_plt0_470", true, "Solidus", "plant");
      settings.Add("r_plt0_486", true, "Results", "plant");
  
  print("Startup complete");
}

update {
  vars.old = old;
  
  if (!vars.Initialised) {
    Func<bool> ExcPlantResults = () => (vars.old.ProgressPlant == 487);
    vars.Except.Add("r_plt0_486", ExcPlantResults);
    
    Func<bool> WatTengus1 = () => ( (current.RoomCode != vars.old.RoomCode) && (current.RoomCode == "w45a") );
    vars.Watch.Add("r_plt0_397", WatTengus1);
    
    uint FrameCounter = 0;
    Func<bool> WatResults = () => ( (current.ResultsComplete & 0x200) == 0x200);
    vars.Watch.Add("r_tnk0_56", WatResults);
    
    vars.Initialised = true;
  }
  
  return true;
}

split {
  string Code = current.Section + "_" +
    ( (current.Section == "r_tnk0") ? current.ProgressTanker : current.ProgressPlant);
  
  if (vars.Watch.ContainsKey(Code)) return vars.Watch[Code]();
  
  if (
    (current.Section == old.Section) &&
    (current.ProgressTanker == old.ProgressTanker) &&
    (current.ProgressPlant == old.ProgressPlant)
  ) return false;
  
  if ( (!settings.ContainsKey(Code)) || (!settings[Code]) ) return false;
  if (vars.Except.ContainsKey(Code)) return vars.Except[Code]();
  return true;
}