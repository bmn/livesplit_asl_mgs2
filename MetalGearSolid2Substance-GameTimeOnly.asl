/*
  Game Time for Metal Gear Solid 2: Substance (PC)
*/

state("mgs2_sse") {
  uint      GameTime: 0xD8AEF8;
}

gameTime {
  return TimeSpan.FromMilliseconds((current.GameTime) * 1000 / 60);
}