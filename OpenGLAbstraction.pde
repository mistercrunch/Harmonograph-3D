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
Class OpenGLAbstraction:
The goal is to keep all or most of the OpenGL specific code in this file to avoid abstract
the rest of the program from it all.

The current program uses vertex arrays, and the twisted treatment of all this is implement in this class.
*/

import javax.media.opengl.*;
import javax.media.opengl.glu.*;
import com.sun.opengl.util.*;
import processing.opengl.*;
import java.nio.*;
// Any time I want to draw a square, I use the squareList.
// Should be slightly faster than calling all the vertex calls over and over.


FloatBuffer vbuffer;
FloatBuffer cbuffer;
 
class OpenGLAbstraction
{

  int              numPoints;
  PGraphicsOpenGL  pgl;
  GL               gl;

  OpenGLAbstraction()
  {
    pgl         = (PGraphicsOpenGL) g;
    gl          = pgl.gl;
    //gl.setSwapInterval(1);
    gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);    
  }

  void OpenGLStartDraw(int inNumPoints)
  {
    numPoints=inNumPoints;
    pgl = (PGraphicsOpenGL) g;
    int numPoints = inNumPoints;
    vbuffer = BufferUtil.newFloatBuffer(numPoints * 3);
    cbuffer = BufferUtil.newFloatBuffer(numPoints * 3);
    gl.glDepthMask(false);
    gl.glBlendFunc(GL.GL_SRC_ALPHA,GL.GL_ONE);
    gl.glBlendEquation(GL.GL_FUNC_ADD);	

  } 
  void AddPoint(Vect3d v3d,color c)
  {
    vbuffer.put(v3d.x);
    vbuffer.put(v3d.y);
    vbuffer.put(v3d.z);
    // random r,g,b
    cbuffer.put(red(c));
    cbuffer.put(green(c));
    cbuffer.put(blue(c));
    
    
  }
  void OpenGLEndDraw()
  {
    vbuffer.rewind();
    cbuffer.rewind();
 
    pgl.beginGL();
      if(ColorBlending.value==0)
      {
        gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA);
        gl.glBlendEquation(GL.GL_FUNC_ADD);
      }
      else
      {
        gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);    
      }
      gl.glEnableClientState(GL.GL_VERTEX_ARRAY);
      gl.glVertexPointer(3, GL.GL_FLOAT, 0, vbuffer);
      gl.glEnableClientState(GL.GL_COLOR_ARRAY);
      gl.glColorPointer(3, GL.GL_FLOAT, 0, cbuffer);
      
      gl.glLineWidth(StrokeWeight.value); 
      gl.glEnable (gl.GL_LINE_SMOOTH);
      gl.glPushMatrix();
       
        gl.glDrawArrays(GL.GL_LINE_STRIP, 0, numPoints);
      gl.glPopMatrix();
    pgl.endGL();
  }

};
