////////////////////////////////////////////////////////////////////////////////
//
//  OpenZoom Nano
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
//  The Original Code is OpenZoom Nano.
//
//  The Initial Developer of the Original Code is Daniel Gasienica.
//  Portions created by the Initial Developer are Copyright (c) 2007-2010
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
package
{

import flash.display.SimpleButton;
import flash.events.MouseEvent;

import org.openzoom.nano.ui.FullScreenButton;
import org.openzoom.nano.ui.ShowAllButton;
import org.openzoom.nano.ui.ZoomInButton;
import org.openzoom.nano.ui.ZoomOutButton;

/**
 * OpenZoom Nano
 * High-resolution image viewer based on the open source OpenZoom SDK.
 */
[SWF(width="960", height="600", frameRate="60", backgroundColor="#000000")]
public class OpenZoomViewer extends BasicOpenZoomViewer
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    private static const DEFAULT_BUTTON_SIZE:Number = 24
    private static const DEFAULT_BUTTON_SPACING:Number = 7
    private static const DEFAULT_BUTTON_MARGIN:Number = 7
    private static const DEFAULT_BUTTON_ALPHA:Number = 0.96

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    public function OpenZoomViewer()
    {
        super()
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var zoomInButton:SimpleButton
    private var zoomOutButton:SimpleButton
    private var showAllButton:SimpleButton
    private var fullScreenButton:FullScreenButton

    //--------------------------------------------------------------------------
    //
    //  Methods: Children
    //
    //--------------------------------------------------------------------------

    override protected function createChildren():void
    {
        super.createChildren()

        if (!zoomInButton)
            createZoomInButton()

        if (!zoomOutButton)
            createZoomOutButton()

        if (!showAllButton)
            createShowAllButton()

        if (!fullScreenButton)
            createFullScreenButton()
    }

    /**
     * @private
     */
    private function createZoomInButton():void
    {
        zoomInButton = new ZoomInButton()
        zoomInButton.alpha = DEFAULT_BUTTON_ALPHA
        zoomInButton.width = zoomInButton.height = DEFAULT_BUTTON_SIZE
        zoomInButton.addEventListener(MouseEvent.MOUSE_DOWN,
                                      zoomInButton_mouseDownHandler,
                                      false, 0, true)
        addChild(zoomInButton)
    }

    /**
     * @private
     */
    private function createZoomOutButton():void
    {
        zoomOutButton = new ZoomOutButton()
        zoomOutButton.alpha = DEFAULT_BUTTON_ALPHA
        zoomOutButton.width = zoomOutButton.height = DEFAULT_BUTTON_SIZE
        zoomOutButton.addEventListener(MouseEvent.MOUSE_DOWN,
                                       zoomOutButton_mouseDownHandler,
                                       false, 0, true)
        addChild(zoomOutButton)
    }

    /**
     * @private
     */
    private function createShowAllButton():void
    {
        showAllButton = new ShowAllButton()
        showAllButton.alpha = DEFAULT_BUTTON_ALPHA
        showAllButton.width = showAllButton.height = DEFAULT_BUTTON_SIZE
        showAllButton.addEventListener(MouseEvent.MOUSE_DOWN,
                                       showAllButton_mouseDownHandler,
                                       false, 0, true)
        addChild(showAllButton)
    }

    /**
     * @private
     */
    private function createFullScreenButton():void
    {
        fullScreenButton = new FullScreenButton()
        fullScreenButton.alpha = DEFAULT_BUTTON_ALPHA
        fullScreenButton.width = fullScreenButton.height = DEFAULT_BUTTON_SIZE
        addChild(fullScreenButton)
    }
	
	//--------------------------------------------------------------------------
	//
	//  Methods: Layout
	//
	//--------------------------------------------------------------------------

    override protected function updateDisplayList(unscaledWidth:Number,
                                         unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight)

        if (fullScreenButton)
        {
            fullScreenButton.x = unscaledWidth
                                    - fullScreenButton.width
                                        - DEFAULT_BUTTON_MARGIN
            fullScreenButton.y = unscaledHeight
                                    - fullScreenButton.height
                                        - DEFAULT_BUTTON_MARGIN
        }

        if (showAllButton)
        {
            showAllButton.x = fullScreenButton.x
                                  - showAllButton.width
                                      - DEFAULT_BUTTON_SPACING
            showAllButton.y = fullScreenButton.y
        }

        if (zoomOutButton)
        {
            zoomOutButton.x = showAllButton.x
                                  - zoomOutButton.width
                                      - DEFAULT_BUTTON_SPACING
            zoomOutButton.y = fullScreenButton.y
        }

        if (zoomInButton)
        {
            zoomInButton.x = zoomOutButton.x
                                 - zoomInButton.width
                                    - DEFAULT_BUTTON_SPACING
            zoomInButton.y = fullScreenButton.y
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function zoomInButton_mouseDownHandler(event:MouseEvent):void
    {
        if (image)
           image.viewport.zoom *= 1.6
    }

    /**
     * @private
     */
    private function zoomOutButton_mouseDownHandler(event:MouseEvent):void
    {
        if (image)
           image.viewport.zoom *= 0.3
    }

    /**
     * @private
     */
    private function showAllButton_mouseDownHandler(event:MouseEvent):void
    {
        if (image)
           image.viewport.showAll()
    }
}

}
