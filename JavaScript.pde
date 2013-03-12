/******************************************
 *
 * An HTML+JS 'drop in' for Processing, so
 * that sketches can be given conditional
 * code for interfacing with an on-page
 * JavaScript context without breaking the
 * Processing sketch in either Java/JS mode.
 *
 ******************************************/
 

/**
 * Style object
 */
abstract class StyleObject {
  String display;
}

/**
 * HTML element interface.
 */
abstract class HTMLElement {
  String innerHTML;
  StyleObject style;
  abstract String setAttribute(String name, String value);
  abstract void getAttribute(String name);
}

/**
 * DOM interface.
 */
interface Document {
  HTMLElement querySelector(String s);
  HTMLElement[] querySelectorAll(String s);
}

/**
 * Console object.
 */
abstract class Console {
  abstract void log(String s);
}

/**
 * JavaScript context object.
 */
abstract class JavaScript {
  Console console;
  Document document;
}

/**
 * JS reference.
 */
JavaScript javascript = null;

/**
 * Bind JS reference.
 */
void bindJavaScript(JavaScript js) {
  javascript = js;
}
