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

import caurina.transitions.Tweener;
import caurina.transitions.properties.DisplayShortcuts;

import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import flash.net.FileReference;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
import flash.ui.Mouse;
import flash.utils.Dictionary;
import flash.utils.Timer;
import flash.utils.setTimeout;

import org.openzoom.flash.components.MemoryMonitor;
import org.openzoom.flash.components.MultiScaleImage;
import org.openzoom.flash.components.Spinner;
import org.openzoom.flash.descriptors.IImageSourceDescriptor;
import org.openzoom.flash.descriptors.IMultiScaleImageDescriptor;
import org.openzoom.flash.utils.ExternalMouseWheel;
import org.openzoom.flash.utils.LicenseUtil;
import org.openzoom.flash.utils.math.clamp;
import org.openzoom.flash.utils.string.format;
import org.openzoom.flash.viewport.constraints.CenterConstraint;
import org.openzoom.flash.viewport.constraints.CompositeConstraint;
import org.openzoom.flash.viewport.constraints.ScaleConstraint;
import org.openzoom.flash.viewport.constraints.VisibilityConstraint;
import org.openzoom.flash.viewport.constraints.ZoomConstraint;
import org.openzoom.flash.viewport.controllers.ContextMenuController;
import org.openzoom.flash.viewport.controllers.KeyboardController;
import org.openzoom.flash.viewport.controllers.MouseController;
import org.openzoom.flash.viewport.transformers.TweenerTransformer;
import org.openzoom.nano.ui.Sad;

/**
 * OpenZoom Nano
 * Basic high-resolution image viewer based on the open source OpenZoom SDK.
 */
[SWF(width="960", height="600", frameRate="30", backgroundColor="#000000")]
public class BasicOpenZoomViewer extends Sprite
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    private static const DEFAULT_LOAD_TIMEOUT:uint = 100
    private static const DEFAULT_MAX_SCALE_FACTOR:Number = 1.0
    private static const DEFAULT_VISIBILITY_RATIO:Number = 0.5
    private static const DEFAULT_CHROME_HIDE_DELAY:Number = 1500 // milliseconds
    private static const DEFAULT_MEMORY_MONITOR_KEY:uint = 77 // M

    private static const VERSION_MAJOR:uint = 0
    private static const VERSION_MINOR:uint = 9
    private static const VERSION_BUGFIX:uint = 3
    private static const VERSION_BUILD:uint = 2
    private static const VERSION:String = format("{0}.{1}.{2}.{3}",
        VERSION_MAJOR, VERSION_MINOR, VERSION_BUGFIX, VERSION_BUILD)
    private static const VERSION_MENU_CAPTION:String = "OpenZoom Nano (" + VERSION + ")"

    private static var DEFAULT_SOURCE:Object = ""
    private static var DEFAULT_VIEWPORT_BOUNDS:String = "0, 0, 1, 1"

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructor.
     */
    public function BasicOpenZoomViewer()
    {
        addEventListener(Event.ADDED_TO_STAGE,
            addedToStageHandler,
            false, 0, true)
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    // UI
    protected var image:MultiScaleImage

    private var sad:Sprite
    private var spinner:Spinner

    private var memoryMonitor:MemoryMonitor

    private var idleTimer:Timer
    private var idle:Boolean = false

    // Context menu
    private var versionMenu:ContextMenuItem

    private var viewImageMenuDescriptors:Dictionary = new Dictionary()
    private var saveAsMenuDescriptors:Dictionary = new Dictionary()

    private var activated:Boolean = false
    private var imageFile:FileReference

    //--------------------------------------------------------------------------
    //
    //  Methods: Initialization
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function initializeStage():void
    {
        if (stage)
        {
            // Enable mouse wheel support for browsers
            // on Mac OS as well as Safari on Windows
            ExternalMouseWheel.initialize(stage)

            // Configure stage
            stage.align = StageAlign.TOP_LEFT
            stage.scaleMode = StageScaleMode.NO_SCALE
            stage.addEventListener(Event.RESIZE,
                stage_resizeHandler,
                false, 0, true)
            stage.addEventListener(KeyboardEvent.KEY_DOWN,
                stage_keyDownHandler,
                false, 0, true)
            stage.addEventListener(MouseEvent.MOUSE_MOVE,
                stage_mouseMoveHandler,
                false, 0, true)
            stage.addEventListener(Event.MOUSE_LEAVE,
                stage_mouseLeaveHandler,
                false, 0, true)
        }
    }

    private function initializeChromeTimer():void
    {
        idleTimer = new Timer(DEFAULT_CHROME_HIDE_DELAY, 1)
        idleTimer.addEventListener(TimerEvent.TIMER_COMPLETE,
            chromeTimer_completeHandler,
            false, 0, true)
        idleTimer.start()
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function loadSource():void
    {
        try
        {
            // Image source
            image.source = getParameter(OpenZoomViewerParameters.SOURCE,
                DEFAULT_SOURCE)
        }
        catch (error:Error) // Security error
        {
            showSad()
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods: Children
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    protected function createChildren():void
    {
        if (!sad)
            createSad()

        if (!image)
            createImage()

        if (!spinner)
            createSpinner()
    }

    /**
     * @private
     */
    private function createSad():void
    {
        sad = new Sad()
        sad.visible = false
        addChild(sad)
    }

    /**
     * @private
     */
    private function createImage():void
    {
        image = new MultiScaleImage()

        configureTransformer(image)
        configureControllers(image)
        configureListeners(image)

        addChild(image)
    }

    /**
     * @private
     */
    private function createSpinner():void
    {
        spinner = new Spinner(12, 4, 0xEEEEEE)
        spinner.visible = false
        spinner.alpha = 0
        spinner.filters = [new GlowFilter(0xFFFFFF, 0.25, 2, 2)]
        addChild(spinner)
    }

    //--------------------------------------------------------------------------
    //
    //  Methods: Image configuration
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function configureTransformer(image:MultiScaleImage):void
    {
        image.transformer = new TweenerTransformer()
    }

    /**
     * @private
     */
    private function configureControllers(image:MultiScaleImage):void
    {
        var keyboardController:KeyboardController = new KeyboardController()
        var mouseController:MouseController = new MouseController()

        var contextMenuController:ContextMenuController
        contextMenuController = new ContextMenuController()

        image.controllers = [mouseController,
            keyboardController,
            contextMenuController]
    }

    /**
     * @private
     */
    private function configureConstraints(image:MultiScaleImage):void
    {
        // Prevent image from zooming out
        var zoomConstraint:ZoomConstraint = new ZoomConstraint()
        zoomConstraint.minZoom = 1

        // Center at minimum zoom level
        var centerConstraint:CenterConstraint = new CenterConstraint()

        // Prevent from zooming in more than the original size of the image
        var scaleConstraint:ScaleConstraint = new ScaleConstraint()

        var imageWidth:Number
        var imageHeight:Number
        var sceneDimension:Number = Math.max(image.sceneWidth,
            image.sceneHeight)

        if (image.source && image.source is IMultiScaleImageDescriptor)
        {
            var descriptor:IMultiScaleImageDescriptor
            descriptor = IMultiScaleImageDescriptor(image.source)
            imageWidth = descriptor.width
            imageHeight = descriptor.height
            var maxScale:Number = Math.max(imageWidth / sceneDimension,
                imageHeight / sceneDimension)
            scaleConstraint.maxScale = DEFAULT_MAX_SCALE_FACTOR * maxScale
        }

        // Prevent image from disappearing from the viewport
        var visibilityConstraint:VisibilityConstraint = new VisibilityConstraint()
        visibilityConstraint.visibilityRatio = DEFAULT_VISIBILITY_RATIO

        // Chain all constraints together
        var compositeContraint:CompositeConstraint = new CompositeConstraint()
        compositeContraint.constraints = [centerConstraint,
            visibilityConstraint,
            zoomConstraint,
            scaleConstraint]
        // Apply constraints
        image.constraint = compositeContraint
    }

    /**
     * @private
     */
    private function configureListeners(image:MultiScaleImage):void
    {
        image.loader.addEventListener(Event.INIT,
            loader_initHandler,
            false, 0, true)
        image.loader.addEventListener(Event.COMPLETE,
            loader_completeHandler,
            false, 0, true)

        image.addEventListener(Event.COMPLETE,
            image_completeHandler,
            false, 0, true)
        image.addEventListener(IOErrorEvent.IO_ERROR,
            image_ioErrorHandler,
            false, 0, true)
        image.addEventListener(SecurityErrorEvent.SECURITY_ERROR,
            image_securityErrorHandler,
            false, 0, true)
    }

    /**
     * @private
     */
    private function configureContextMenu(interactiveObject:InteractiveObject):void
    {
        addVersionMenuItem(interactiveObject)
        LicenseUtil.addAboutMenuItem(interactiveObject)
    }

    /**
     * @private
     */
    private function addVersionMenuItem(interactiveObject:InteractiveObject):void
    {
        if (interactiveObject.contextMenu == null)
            interactiveObject.contextMenu = new ContextMenu()

        var item:ContextMenuItem = new ContextMenuItem(VERSION_MENU_CAPTION,
                                                       true, /* separator */
                                                       false /* enabled */)
        interactiveObject.contextMenu.customItems.push(item)
    }

    /**
     * @private
     */
    private function addSourcesContextMenus(image:MultiScaleImage):void
    {
        var menu:ContextMenu

        if (image.contextMenu && image.contextMenu.customItems)
            menu = image.contextMenu
        else
            menu = new ContextMenu()

        menu.hideBuiltInItems()

        var separator:Boolean = true
        var sources:Array = IMultiScaleImageDescriptor(image.source).sources

        var descriptor:IImageSourceDescriptor
        var name:String
        var caption:String

        for each (descriptor in sources)
        {
            name = getDescriptorName(descriptor)
            caption = ["View Image ", name].join("")

            var viewImageMenu:ContextMenuItem
            viewImageMenu = new ContextMenuItem(caption, separator /* separator */)
            viewImageMenu.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,
                viewImageMenu_menuItemSelectHandler,
                false, 0, true)
            menu.customItems.push(viewImageMenu)
            viewImageMenuDescriptors[caption] = descriptor

            if (separator)
                separator = false
        }

        separator = true

        for each (descriptor in sources)
        {
            var url:String = descriptor.url

            var validDownload:Boolean = url.indexOf("http://") == 0
                validDownload ||= url.indexOf("https://") == 0

            if (!validDownload)
                continue

            name = getDescriptorName(descriptor)
            caption = ["Save Image As... ", name].join("")

            var saveAsMenu:ContextMenuItem
            saveAsMenu = new ContextMenuItem(caption, separator /* Separator */)
            saveAsMenu.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,
                saveAsMenu_menuItemSelectHandler,
                false, 0, true)
            menu.customItems.push(saveAsMenu)
            saveAsMenuDescriptors[caption] = descriptor

            if (separator)
                separator = false
        }
    }

    private function getDescriptorName(descriptor:IImageSourceDescriptor):String
    {
        return format("({0}x{1})", descriptor.width, descriptor.height)
    }

    //--------------------------------------------------------------------------
    //
    //  Methods: Layout
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function layout():void
    {
        updateDisplayList(stage.stageWidth, stage.stageHeight)
    }

    /**
     * @private
     */
    protected function updateDisplayList(unscaledWidth:Number,
                                         unscaledHeight:Number):void
    {
        if (sad)
        {
            sad.width = unscaledWidth / 2
            sad.height = unscaledHeight / 2

            var scale:Number = Math.min(sad.scaleX, sad.scaleY)
            sad.scaleX = sad.scaleY = scale

            sad.x = (unscaledWidth - sad.width)  / 2
            sad.y = (unscaledHeight - sad.height) / 2
        }

        if (spinner)
        {
            // top right
            spinner.x = unscaledWidth - spinner.width - 2
            spinner.y = spinner.height + 2
        }

        if (memoryMonitor)
        {
            memoryMonitor.x = 0
            memoryMonitor.y = unscaledHeight - memoryMonitor.height
        }

        if (image)
            image.setActualSize(unscaledWidth, unscaledHeight)
    }

    //--------------------------------------------------------------------------
    //
    //  Methods: Internal
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function showSad():void
    {
        sad.visible = true
    }

    /**
     * @private
     */
    private function toggleMemoryMonitor():void
    {
        if (!memoryMonitor)
        {
            memoryMonitor = new MemoryMonitor()
            addChild(memoryMonitor)
        }
        else
        {
            removeChild(memoryMonitor)
            memoryMonitor = null
        }

        layout()
    }

    /**
     * @private
     */
    private function hideChrome():void
    {
        idle = true
        Mouse.hide()
    }

    /**
     * @private
     */
    private function showChrome():void
    {
        idle = false
        Mouse.show()

        idleTimer.reset()
        idleTimer.start()
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function addedToStageHandler(event:Event):void
    {
        // Tweener _autoAlpha property
        DisplayShortcuts.init()

        initializeStage()
        initializeChromeTimer()

        createChildren()
        layout()

        if (loaderInfo.url.indexOf("file://") == 0)
            setTimeout(loadSource, DEFAULT_LOAD_TIMEOUT) // Workaround for FF on Mac OS X
        else
            loadSource()
    }

    /**
     * @private
     */
    private function stage_resizeHandler(event:Event):void
    {
        layout()
    }

    /**
     * @private
     */
    private function stage_keyDownHandler(event:KeyboardEvent):void
    {
        if (event.keyCode == DEFAULT_MEMORY_MONITOR_KEY)
            toggleMemoryMonitor()
    }

    /**
     * @private
     */
    private function stage_mouseMoveHandler(event:MouseEvent):void
    {
        if (idle)
            showChrome()
    }

    /**
     * @private
     */
    private function stage_mouseLeaveHandler(event:Event):void
    {
        hideChrome()
    }

    /**
     * @private
     */
    private function chromeTimer_completeHandler(event:TimerEvent):void
    {
        hideChrome()
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers: Loader
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function loader_initHandler(event:Event):void
    {
        Tweener.addTween(spinner, {_autoAlpha: 1, time: 1})
    }

    /**
     * @private
     */
    private function loader_completeHandler(event:Event):void
    {

        Tweener.addTween(spinner, {_autoAlpha: 0, time: 1})
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers: Image
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function image_completeHandler(event:Event):void
    {
        // Viewport bounds
        var bounds:Rectangle = getViewportBoundsParameter()
        image.viewport.fitToBounds(bounds, 1.0, true)

        configureConstraints(image)
        addSourcesContextMenus(image)

        // Important that this happens after attachment
        configureContextMenu(image)
        layout()
    }

    /**
     * @private
     */
    private function image_ioErrorHandler(event:IOErrorEvent):void
    {
        showSad()

        // TODO
//        removeChild(image)
        configureContextMenu(image)

        layout()
    }

    /**
     * @private
     */
    private function image_securityErrorHandler(event:SecurityErrorEvent):void
    {
        showSad()

        // TODO
//        removeChild(image)
        configureContextMenu(image)

        layout()
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers: Context menu
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function viewImageMenu_menuItemSelectHandler(event:ContextMenuEvent):void
    {
        var descriptor:IImageSourceDescriptor
        var key:String = (event.currentTarget as ContextMenuItem).caption
        descriptor = viewImageMenuDescriptors[key] as IImageSourceDescriptor

        if (descriptor)
        {
            var request:URLRequest = new URLRequest(descriptor.url)
            navigateToURL(request, "_blank")
        }
    }

    /**
     * @private
     */
    private function saveAsMenu_menuItemSelectHandler(event:ContextMenuEvent):void
    {
        var descriptor:IImageSourceDescriptor
        var key:String = (event.currentTarget as ContextMenuItem).caption
        descriptor = saveAsMenuDescriptors[key] as IImageSourceDescriptor

        if (descriptor)
        {
            try
            {
                var request:URLRequest = new URLRequest(descriptor.url)
                imageFile = new FileReference()
                var defaultFileName:String = descriptor.url.substring(descriptor.url.lastIndexOf("/") + 1)
                imageFile.download(request, defaultFileName)
            }
            catch(error:Error)
            {
                // Do nothing
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods: Parameters
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function getParameter(name:String, defaultValue:*):*
    {
        if (loaderInfo.parameters.hasOwnProperty(name))
        {
            var value:* = loaderInfo.parameters[name]
            return value
        }

        return defaultValue
    }

    /**
     * @private
     */
    private function getViewportBoundsParameter():Rectangle
    {
        var boundsParameterString:String =
            getParameter(OpenZoomViewerParameters.VIEWPORT_BOUNDS,
                DEFAULT_VIEWPORT_BOUNDS) as String

        var boundsParameter:Array = boundsParameterString.split(",")

        var bounds:Rectangle = new Rectangle()
        bounds.x = clamp(parseFloat(boundsParameter[0]), 0, 1)
        bounds.y = clamp(parseFloat(boundsParameter[1]), 0, 1)
        bounds.width = clamp(parseFloat(boundsParameter[2]), 0, 1)
        bounds.height = clamp(parseFloat(boundsParameter[3]), 0, 1)

        return bounds
    }
}

}
