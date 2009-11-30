////////////////////////////////////////////////////////////////////////////////
//
//  OpenZoom SDK
//
//  Version: MPL 1.1/GPL 3/LGPL 3
//
//  The contents of this file are subject to the Mozilla Public License Version
//  1.1 (the "License"); you may not use this file except in compliance with
//  the License. You may obtain a copy of the License at
//  http://www.mozilla.org/MPL/
//
//  Software distributed under the License is distributed on an "AS IS" basis,
//  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
//  for the specific language governing rights and limitations under the
//  License.
//
//  The Original Code is the OpenZoom SDK.
//
//  The Initial Developer of the Original Code is Daniel Gasienica.
//  Portions created by the Initial Developer are Copyright (c) 2007-2009
//  the Initial Developer. All Rights Reserved.
//
//  Contributor(s):
//    Daniel Gasienica <daniel@gasienica.ch>
//
//  Alternatively, the contents of this file may be used under the terms of
//  either the GNU General Public License Version 3 or later (the "GPL"), or
//  the GNU Lesser General Public License Version 3 or later (the "LGPL"),
//  in which case the provisions of the GPL or the LGPL are applicable instead
//  of those above. If you wish to allow use of your version of this file only
//  under the terms of either the GPL or the LGPL, and not to allow others to
//  use your version of this file under the terms of the MPL, indicate your
//  decision by deleting the provisions above and replace them with the notice
//  and other provisions required by the GPL or the LGPL. If you do not delete
//  the provisions above, a recipient may use your version of this file under
//  the terms of any one of the MPL, the GPL or the LGPL.
//
////////////////////////////////////////////////////////////////////////////////
package org.openzoom.nano.ui
{

import flash.display.Sprite;
import flash.events.Event;
import flash.events.FullScreenEvent;
import flash.events.MouseEvent;

import org.openzoom.flash.utils.FullScreenUtil;

/**
 * Fullscreen button
 */
public class FullScreenButton extends Sprite
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructor.
     */
	public function FullScreenButton()
	{
        addEventListener(Event.ADDED_TO_STAGE,
                         addedToStageHandler,
                         false, 0, true)
        createChildren()
	}
	
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    private var enterButton:FullScreenEnterButton
    private var exitButton:FullScreenExitButton
	
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    private function createChildren():void
    {
    	if (!enterButton)
    	{
    		enterButton = new FullScreenEnterButton()
    		enterButton.addEventListener(MouseEvent.CLICK,
    		                             enterButton_clickHandler,
    		                             false, 0, true)
            addChild(enterButton)
    		
    		exitButton = new FullScreenExitButton()
    		exitButton.visible = false
            exitButton.addEventListener(MouseEvent.CLICK,
                                        exitButton_clickHandler,
                                        false, 0, true)
            addChild(exitButton)
    	}
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    private function enterButton_clickHandler(event:MouseEvent):void
    {
        FullScreenUtil.toggleFullScreen(stage)
    }
    
    private function exitButton_clickHandler(event:MouseEvent):void
    {
        FullScreenUtil.toggleFullScreen(stage)
    }
    
    private function addedToStageHandler(event:Event):void
    {
        stage.addEventListener(FullScreenEvent.FULL_SCREEN,
                               stage_fullScreenHandler,
                               false, 0, true)
    }
    
    private function stage_fullScreenHandler(event:FullScreenEvent):void
    {
    	if (event.fullScreen)
    	{
            enterButton.visible = false
            exitButton.visible = true   		
    	}
    	else
    	{
            enterButton.visible = true
            exitButton.visible = false  		
    	}
    }
}

}
