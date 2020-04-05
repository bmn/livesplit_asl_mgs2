state("mgs2_sse") {
  uint      GameTime: 0xD8AEF8;
  string10  RoomCode: 0x601F34, 0x2C;

  byte2     PhotoSubject: 0xD8D93E;
}

startup {
  Action ClearASLVariables = delegate() {
    vars.ASL_Debug = "";
    vars.ASL_Info = "";
  };
  ClearASLVariables();
  
  settings.Add("debug_file", true, "Save debug information to LiveSplit program directory");
  
  vars.Initialised = false;
}

update {
  try {
    vars.old = old; 
    
    // Callbacks go here - they need access to current and old so startup won't do the job  
    if (!vars.Initialised) {
      print("Beginning update initialisation...");
      
      vars.Initialised = true;
      
      var ExceptionCount = new Dictionary<string, int> {
        { "reset", 0 },
        { "start", 0 },
        { "update", 0 },
        { "split", 0 }
      };
      
      var SpecialWatchCallback = new Dictionary<string, Delegate>();
      bool DontWatch = false;
      int DebugTimer = 0;
      int InfoTimer = 0;
      string PrevDebug = "";
      string PrevInfo = "";
      
      // Debug message handler
      string DebugPath = System.IO.Path.GetDirectoryName(Application.ExecutablePath) + "\\mgs2_sse_diag_debug.log";
      Action<string> Debug = delegate(string message) {
        message = "[" + current.GameTime + "] " + message;
        if (settings["debug_file"]) {
          using(System.IO.StreamWriter stream = new System.IO.StreamWriter(DebugPath, true)) {
            stream.WriteLine(message);
            stream.Close();
          }
        }
        print("[MGS2Diag] " + message);
        vars.ASL_Debug = message;
      };
      
      Action<Exception, string> LogException = delegate(Exception e, string source) {
        if (ExceptionCount[source] < 10) { // only log the first 10 of a particular type per run
          ExceptionCount[source] = ExceptionCount[source] + 1;
          Debug("Error in " + source + ":\n" + e.ToString());
          if (ExceptionCount[source] == 10) Debug("Reached error limit for " + source + ", will not log again until next run");
        }
        print(e.ToString());
      };
      vars.LogException = LogException;
      
      Action<string, int> Info = delegate(string message, int frames) {
        vars.ASL_Info = message;
        InfoTimer = frames;
      };
      
      Action<string> DebugInfo = delegate(string message) {
        Debug(message);
        Info(message, 0);
      };
      
      // Shortened name for the byte[]-to-int converter
      Func<byte[], int> C = delegate(byte[] input) {
        if (input == null) return 0;
        return BitConverter.ToInt16(input, 0);
      };
      vars.C = C;
      
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
      
      Action UpdateASLVariables = delegate() {
        if (current.RoomCode != old.RoomCode) DontWatch = false;
        if ( (!DontWatch) && (SpecialWatchCallback.ContainsKey(current.RoomCode)) ) {
          int CallbackResult = SpecialWatchCallback[current.RoomCode]();
          if (CallbackResult == -1) DontWatch = true;
        }
        
        if (DebugTimer > 0) {
          DebugTimer--;
          if (DebugTimer == 0) vars.ASL_Debug = PrevDebug;
        }
        
        if (InfoTimer > 0) {
          InfoTimer--;
          if (InfoTimer == 0) vars.ASL_Info = PrevInfo;
        }
      };
      vars.UpdateASLVariables = UpdateASLVariables;
      
      
      // Hold 3 photo
      var PhotoSubjects = new Dictionary<int, string> {
        { 10, "Front" },
        { 20, "Front-Right" },
        { 30, "Front-Left" },
        { 40, "Marines Logo" },
        { 1000, "No Photo" }
      };
      int PrevIdent = 1000;
      Func<int> WatchHold3Photo = delegate() {
        int Ident = C(current.PhotoSubject);
        if (Ident != PrevIdent) {
          if (Ident != 1000) {
            string Out;
            if (PhotoSubjects.TryGetValue(Ident, out Out))
              Info("Photo: " + Out, 180);
          }
          PrevIdent = Ident;
        }
        return 0;
      };
      SpecialWatchCallback.Add("w04c", WatchHold3Photo);
      
      Debug("Finished initialising script. It's all up to you now.");
    }
  }
  catch (Exception e) {
    vars.LogException(e, "update");
  }
  return true;
}

gameTime {
  vars.UpdateASLVariables();
  return new TimeSpan(0, 0, 4, 20, 690);
}

isLoading {
  return true;
}

reset {
  return false;
}

start {
  return false;
}

split {
  return false;
}