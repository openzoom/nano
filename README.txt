++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
+++ OpenZoom is no longer being maintained nor supported +++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--------------------------------------------------------------------------------

  OpenZoom Nano

--------------------------------------------------------------------------------


  Dependencies
  ------------

  * OpenZoom SDK
    <http://openzoom.org>


--------------------------------------------------------------------------------

  Developed by

  Daniel Gasienica
  <daniel@gasienica.ch>
  <http://gasi.ch/>

  ----------------------------------------------------------------------------

  Powered by OpenZoom <http://openzoom.org/>

--------------------------------------------------------------------------------

  License: MPL 1.1/GPL 3/LGPL 3

--------------------------------------------------------------------------------

  Changelog
  ---------

  0.9.1.1 (2010-03-27)
  --------------------

  * Split viewer into BasicOpenZoomViewer (chromeless) and OpenZoomViewer (UI).  
  * Switched to LicenseUtil for about context menu item.

  0.9.1 (2009-11-29)
  ------------------

  * Added support for setting intial viewport bounds through
    viewportBounds HTML FlashVars, e.g.
    <param name="flashvars" value="source=...&viewportBounds=0.2,0.5,0.5,0.4" />

    Feature suggestion by Samuel Monnier.

  * Fixed bug which prevented OpenZoomViewer from
    being loaded into another SWF:
    http://community.openzoom.org/openzoom/topics/load_openzoom_swf_in_another_flash_file
  
  * Added README.txt


  0.6.1.370 (2009-04-27)
  ----------------------

  * Simple multiscale image viewer for Deep Zoom (DZI), Zoomify
    and OpenZoom images. Specify source through HTML FlashVars, e.g.
    <param name="flashvars" value="source=images/walrus.dzi" />
