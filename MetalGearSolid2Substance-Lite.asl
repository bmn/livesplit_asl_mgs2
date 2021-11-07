/* Autosplitter-lite for Metal Gear Solid 2: Substance (PC) with V's Fix */

state("mgs2_sse") {
  uint      GameTime: 0xD8AEF8;
  string10  Section: 0xD8C374;
  string10  RoomCode: 0x601F34, 0x2C;
  ushort    ProgressTanker: 0xD8D93C;
  ushort    ProgressPlant: 0xD8D912;
  int       ResultsComplete: 0x65397C;
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
    settings.CurrentDefaultParent = "tanker";
    settings.Add("tanker", true, "Tanker", "splits");
      settings.Add("r_tnk0_24", false, "Reach Olga");
      settings.Add("r_tnk0_26", true, "Olga");
      settings.Add("r_tnk0_31", false, "Reach Guard Rush");
      settings.Add("r_tnk0_33", true, "Guard Rush");
      settings.Add("r_tnk0_56", true, "Results (Tanker Only)");
      settings.SetToolTip("r_tnk0_56", "You can keep this enabled if playing Tanker-Plant. It will not trigger.");
      settings.Add("r_tnk0_58", true, "Tanker (Tanker-Plant)");
    
    settings.CurrentDefaultParent = "plant";
    settings.Add("plant", true, "Plant", "splits");
      settings.Add("r_plt0_63", true, "Reach Stillman");
      settings.Add("r_plt0_109", false, "Reach Fortune");
      settings.Add("r_plt0_115", true, "Fortune");
      settings.Add("r_plt0_117", false, "Reach Fatman");
      settings.Add("r_plt3_119", true, "Fatman");
      settings.Add("r_plt0_153", false, "Reach B1 Hall");
      settings.Add("r_plt0_155", true, "Ames");
      settings.Add("r_plt0_188", false, "Reach Harrier");
      settings.Add("r_plt0_190", true, "Harrier");
      settings.Add("r_plt0_206", true, "Reach Prez");
      settings.Add("r_plt0_246", false, "Reach Vamp 1");
      settings.Add("r_plt0_254", true, "Vamp 1");
      settings.Add("r_plt0_302", false, "Reach Sniping");
      settings.Add("r_plt0_316", false, "Reach Vamp 2");
      settings.Add("r_plt0_318", true, "Vamp 2");
      settings.Add("r_plt0_328", false, "Reach Arsenal Gear");
      settings.Add("r_plt0_382", false, "Reach Snake");
      settings.Add("r_plt0_397", true, "Tengus 1"); // Late split at 400
      settings.Add("r_plt0_404", true, "Tengus 2");
      settings.Add("r_plt0_412", true, "Rays");
      settings.Add("r_plt0_470", true, "Solidus");
      settings.Add("r_plt0_486", true, "Results");
  
  print("Startup complete");
}

update {
  vars.old = old;
  
  if (!vars.Initialised) {
    Func<bool> WatTengus1 = () => ( (current.RoomCode != vars.old.RoomCode) && (current.RoomCode == "w45a") );
    vars.Watch.Add("r_plt0_397", WatTengus1);
    
    uint FrameCounter = 0;
    Func<bool> WatResults = () => ( (current.ResultsComplete != vars.old.ResultsComplete) && ( (current.ResultsComplete & 0x200) == 0x200) );
    vars.Watch.Add("r_tnk0_56", WatResults);
    vars.Watch.Add("r_plt0_486", WatResults);
    
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