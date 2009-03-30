/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Rendering2D
{
   import flash.display.*;
   import flash.geom.*;
   
   /**
    * Interface for rendering 2D scenes.
    * 
    * Objects can be drawn in Flash using BitmapDatas or DisplayObjects. A
    * rendering component might be implemented using either method (for 
    * instance, an isometric tilemap might composite everything into a 
    * BitmapData while a simpler 2d sprite system might use the DisplayObject
    * hierarchy). However, you may want to introduce a rendering effect that
    * requires the opposite approach.
    * 
    * This API provides a simple way for all these rendering techniques to
    * co-exist. It provides hooks for both DisplayObjects and BitmapData to be
    * drawn.
    * 
    * During rendering, each visible IDrawable2D has its OnDraw method called. 
    * The IDrawable2D can then inspect the state of the IDrawManager2D and call
    * DrawDisplayObject and/or DrawBitmapData one or more times to render itself.
    * 
    * In the case of complex sets of objects - like a tile map or particle system
    * - we assume that they will be grouped into a single IDrawable2D and drawn
    * efficiently in an object-specific way by that object before being submitted
    * to the IDrawManager2D. This manager is more of a compositer than a high
    * performance rendering API.
    * 
    * It additionally provides methods to transform from world space to screen
    * space and back. It supports isometric perspectives by allowing an altitude
    * to be specified when transforming from world to screen space. In an ortho
    * perspective, the altitude is ignored.
    * 
    * You will notice that there is not a way to register normal scene objects
    * with the manager. It is assumed that the manager will use a spatial database
    * to determine what needs to be drawn. There is a way to note "always drawn"
    * items. This functionality exists to support things that should always have
    * the opportunity to draw, for instance a physics debug visualization or a 
    * background layer.
    * 
    * We briefly describe the four rendering possibilities and how to deal with
    * them:
    *    * The scene is drawn into DisplayObjects and the IDrawable2D submits
    *      a DisplayObject. In this case, add it to the end of the display 
    *      hierarchy.
    *    * The scene is drawn into DisplayObjects and the IDrawable2D submits
    *      a BitmapData. In this case, make a Sprite and draw the BitmapData into
    *      its graphics object. Add the sprite normally.
    *    * The scene is drawn into a BitmapData and the IDrawable2D submits a
    *      DisplayObject. All DisplayObjects implement IBitmapDrawable, so draw
    *      the DisplayObject into the BitmapData using BitmapData.draw().
    *    * The scene is drawn into a BitmapData and the IDrawable2D submits a
    *      BitmapData. All BitmapDatas implement IBitmapDrawable, so draw the
    *      BitmapData into the BitmapData using BitmapData.draw(). 
    */
   public interface IDrawManager2D
   {
      /**
       * Add an item that will always receive an opportunity to render.
       */ 
      function AddAlwaysDrawnItem(item:IDrawable2D):void;

      /**
       * Remove an item added by AddAlwaysDrawnItem.
       */ 
      function RemoveAlwaysDrawnItem(item:IDrawable2D):void;
      
      /**
       * Some renderers need to draw in between everything else in order to 
       * sort right, and it isn't possible to manually add IDrawable2Ds at
       * every location. For instance, a particle system in an isometric
       * perspective has to have an opportunity to draw before and after every
       * object in the scene in order to sort correctly. It would be a huge
       * headache to manually place IDrawable2Ds at every particle location.
       * 
       * This registered an "interstitial" drawer with a scene, which is a
       * IDrawable2D which gets called back between every object, as well as
       * at the beginning and ending of rendering. It can use the LastDrawnItem
       * and NextDrawnItem properties to determine what to draw at each call.
       */ 
      function AddInterstitialDrawer(item:IDrawable2D):void;
     
      /**
       * Remove an interstitial drawer previously registered with 
       * AddInterstitialDrawer.
       * 
       * @see AddInterstitialDrawer
       */ 
      function RemoveInterstitialDrawer(item:IDrawable2D):void;

      /**
       * Transform a world position to screen space in pixels. Altitude can be 
       * passed, but is only meaning in non-orthographic projections. The results
       * from this can be passed directly into the x/y properties on a 
       * DisplayObject.
       */ 
      function TransformWorldToScreen(p:Point, altitude:Number = 0):Point;
      
      /**
       * Transform a screen position in pixels into a worldspace coordinate. We
       * currently only support isometric or orthographic projections, so cannot
       * reconstruct a Z coordinate. Results can be assumed to have an altitude
       * of zero.
       */
      function TransformScreenToWorld(p:Point):Point;
   
      /**
       * During drawing, set to the last drawn item or null if there is none (if
       * this is the first rendered object or first interstitial call.
       */ 
      function get LastDrawnItem():IDrawable2D;

      /**
       * During drawing, set to the item that will be drawn next, or null if we
       * are at the end of the draw list.
       */ 
      function get NextDrawnItem():IDrawable2D;
   
      /**
       * Called from IDrawable2D.OnDraw to render a DisplayObject to the screen.
       * 
       * Uses the transform on the DisplayObject for rendering.
       * 
       * May be called multiple times. 
       */ 
      function DrawDisplayObject(object:DisplayObject):void;

      /**
       * Called from IDrawable2D.OnDraw to render a BitmapData to the screen.
       * 
       * The BitmapData is placed via the passed matrix.
       * 
       * May be called multiple times.
       */
      function DrawBitmapData(bd:BitmapData, m:Matrix):void;
   
      /**
       * Get the current results of rendering as a BitmapData. Useful for post
       * processing effects (like glow/blur/motion trails).
       */ 
      function GetBackBuffer():BitmapData;
   }
}