/*
    Harmonograph3d: An interactive 3d harmonograph 
    Copyright (C) 2010 Maxime Beauchemin

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
  Class Sound
  Keeping the sound related code in this file. The goal is to generate tones that reflect what is seen on
  the harmonograph. It is highly anoying, though, so it is turned off by default.
*/
import ddf.minim.*;
import ddf.minim.signals.*;

class Sound
{
  Minim minim;
  AudioOutput out;
  SineWave sine;
  
  Sound(PApplet p)
  {
    minim = new Minim(p);
  
    out = minim.getLineOut(Minim.STEREO, 2048);
    
  }
  
  void Freq(int FREQ, float PAN)
  {
    //out.clearSignals();
    sine = new SineWave(FREQ, 0.5, out.sampleRate());
    sine.setPan(PAN);
    out.addSignal(sine);
  }
  void Stop()
  {
    out.close();
    minim.stop();
  }
  void Set3Freq()
  {
    out.clearSignals();
    if(!isMuted)
    {
      int baseFreq = 440;
      Freq(baseFreq,-1);
      int freq = (int)(((float)PeriodY.value / (float)PeriodX.value) * baseFreq);
       
      Freq(freq,1);
      
    }
  }
}
