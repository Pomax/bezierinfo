/*
 * Copyright 2013 The Toolkitchen Authors. All rights reserved.
 * Use of this source code is governed by a BSD-style
 * license that can be found in the LICENSE file.
 */

/**
 * Implements `document.register`
 * @module CustomElements
*/

/**
 * Polyfilled extensions to the `document` object.
 * @class Document
*/

(function() {

/**
 * Registers a custom tag name with the document.
 * 
 * When a registered element is created, a `readyCallback` method is called
 * in the scope of the element. The `readyCallback` method can be specified on 
 * either `inOptions.prototype` or `inOptions.lifecycle` with the latter taking
 * precedence.
 * 
 * @method register
 * @param {String} inName The tag name to register. Must include a dash ('-'), 
 *    for example 'x-component'.
 * @param {Object} inOptions
 *    @param {String} [inOptions.extends]
 *      (_off spec_) Tag name of an element to extend (or blank for a new 
 *      element). This paramter is not part of the specification, but instead 
 *      is a hint for the polyfill because the extendee is difficult to infer.
 *      Remember that the input prototype must chain to the extended element's 
 *      prototype (or HTMLElement.prototype) regardless of the value of 
 *      `extends`.
 *    @param {Object} inOptions.prototype The prototype to use for the new 
 *      element. The prototype must inherit from HTMLElement.
 *    @param {Object} [inOptions.lifecycle]
 *      Callbacks that fire at important phases in the life of the custom 
 *      element.
 *       
 * @example
 *      FancyButton = document.register("fancy-button", {
 *        extends: 'button',
 *        prototype: Object.create(HTMLButtonElement.prototype, {
 *          readyCallback: {
 *            value: function() {
 *              console.log("a fancy-button was created",
 *            }
 *          }
 *        })
 *      });
 * @return {Function} Constructor for the newly registered type.
 */
function register(inName, inOptions) {
  //console.warn('document.register("' + inName + '", ', inOptions, ')');
  // construct a defintion out of options
  // TODO(sjmiles): probably should clone inOptions instead of mutating it
  var definition = inOptions || {};
  // record name
  definition.name = inName;
  // ensure a lifecycle object so we don't have to null test it
  definition.lifecycle = definition.lifecycle || {};
  // must have a prototype, default to an extension of HTMLElement
  // TODO(sjmiles): probably should throw if no prototype, check spec
  definition.prototype = definition.prototype
      || Object.create(HTMLUnknownElement.prototype);
  // build a list of ancestral custom elements (for lifecycle management)
  definition.ancestry = ancestry(definition.extends);
  // extensions of native specializations of HTMLElement require localName
  // to remain native, and use secondary 'is' specifier for extension type
  resolveTagName(definition);
  // some platforms require modifications to the user-supplied prototype
  // chain
  resolvePrototypeChain(definition);
  // 7.1.5: Register the DEFINITION with DOCUMENT
  registerDefinition(inName, definition);
  // 7.1.7. Run custom element constructor generation algorithm with PROTOTYPE
  // 7.1.8. Return the output of the previous step.
  definition.ctor = generateConstructor(definition);
  definition.ctor.prototype = definition.prototype;
  // blanket upgrade (?)
  document.upgradeElements();
  return definition.ctor;
}

function ancestry(inExtends) {
  var extendee = registry[inExtends];
  if (extendee) {
    return ancestry(extendee.extends).concat([extendee]);
  }
  return [];
}

function resolveTagName(inDefinition) {
  // if we are explicitly extending something, that thing is our
  // baseTag, unless it represents a custom component
  var baseTag = inDefinition.extends;
  // if our ancestry includes custom components, we only have a
  // baseTag if one of them does
  for (var i=0, a; (a=inDefinition.ancestry[i]); i++) {
    baseTag = a.is && a.tag;
  }
  // our tag is our baseTag, if it exists, and otherwise just our name
  inDefinition.tag = baseTag || inDefinition.name;
  if (baseTag) {
    // if there is a base tag, use secondary 'is' specifier
    inDefinition.is = inDefinition.name;
  }
}

function resolvePrototypeChain(inDefinition) {
  // TODO(sjmiles): contains ShadowDOM polyfill pollution
  // if we don't support __proto__ we need to locate the native level
  // prototype for precise mixing in
  // we also need native prototype so we can replace it with a wrapper
  // prototype if necessary
  if (window.WrapperElement
        && !(inDefinition.prototype instanceof WrapperElement)
        || !Object.__proto__) {
    if (inDefinition.is) {
      // for non-trivial extensions, work out both prototypes
      var inst = domCreateElement(inDefinition.tag);
      var wrapperNative = Object.getPrototypeOf(inst);
      if (window.WrapperElement) {
        inst = unwrap(inst);
      }
      var native = Object.getPrototypeOf(inst);
    } else {
      // otherwise, use the defaults
      native = HTMLElement.prototype;
      if (window.WrapperElement) {
        wrapperNative = WrapperHTMLUnknownElement.prototype;
      }
    }
  }
  // cache this in case of mixin
  inDefinition.native = native;
  // under ShadowDOM polyfill we need to use Wrapper prototype chain instead
  // of native DOM
  if (window.WrapperElement
        && !(inDefinition.prototype instanceof WrapperElement)) {
    if (Object.__proto__) {
      // search and replace 'native' protoype with 'wrapperNative'
      var p = inDefinition.prototype, pp;
      while (true) {
        pp = Object.getPrototypeOf(p);
        if (pp === native || pp == HTMLUnknownElement.prototype) {
          break;
        }
        p = pp;
      }
      p.__proto__ = wrapperNative;
      //console.log(native, wrapperNative, p);
    } else {
      // TODO(sjmiles): support IE
    }
  }
}

// SECTION 4

function instantiate(inDefinition) {
  // 4.a.1. Create a new object that implements PROTOTYPE
  // 4.a.2. Let ELEMENT by this new object
  //
  // the custom element instantiation algorithm must also ensure that the
  // output is a valid DOM element with the proper wrapper in place.
  //
  return upgrade(domCreateElement(inDefinition.tag), inDefinition);
}

function upgrade(inElement, inDefinition) {
  // make 'element' implement inDefinition.prototype
  implement(inElement, inDefinition);
  // some definitions specify an 'is' attribute
  if (inDefinition.is) {
    inElement.setAttribute('is', inDefinition.is);
  }
  // flag as upgraded
  inElement.__upgraded__ = true;
  // invoke lifecycle.created callbacks
  created(inElement, inDefinition);
  // OUTPUT
  return inElement;
}

function implement(inElement, inDefinition) {
  // prototype swizzling is best
  if (Object.__proto__) {
    inElement.__proto__ = inDefinition.prototype;
  } 
  // TODO(sjmiles): below here is feature detected, but really it's
  // just for IE
  else {
    // where above we can re-acquire inPrototype via
    // getPrototypeOf(Element), we cannot do so when
    // we use mixin, so we install a magic reference
    if (!Object.__proto__) {
      inElement.__proto__ = inDefinition.prototype;
    }
    customMixin(inElement, inDefinition.prototype, inDefinition.native);
  }
}

if (!console.group) {
  console.group = function(m) {console.log("[group] " + m);};
  console.groupEnd = function() {console.log("[end]");};
}

function customMixin(inTarget, inSrc, inNative) {
  //console.group(inTarget.localName);
  // TODO(sjmiles): 'used' allows us to only copy the 'youngest' version of 
  // any property. This set should be precalculated. We also need to 
  // consider this for supporting 'super'.
  var used = {};
  // start with inSrc
  var p = inSrc;
  // sometimes the default is HTMLUnknownElement.prototype instead of 
  // HTMLElement.prototype, so we add a test
  // the idea is to avoid mixing in native prototypes, so adding
  // the second test is WLOG
  while (p !== inNative && p !== HTMLUnknownElement.prototype) {
    //console.group('proto');
    var keys = Object.getOwnPropertyNames(p);
    for (var i=0, k; k=keys[i]; i++) {
      if (!used[k]) {
        //console.log(k);
        Object.defineProperty(inTarget, k, 
            Object.getOwnPropertyDescriptor(p, k));
        used[k] = 1;
      }
    }
    //console.groupEnd();
    p = Object.getPrototypeOf(p);
  }
  //console.groupEnd();
}

function created(inElement, inDefinition) {
  var readyCallback = inDefinition.lifecycle.readyCallback || 
      inElement.readyCallback;
  if (readyCallback) {
    readyCallback.call(inElement);
  }
}

var registry = {};
var registrySlctr = '';

function registerDefinition(inName, inDefinition) {
  registry[inName] = inDefinition;
  registrySlctr += (registrySlctr ? ',' : '');
  if (inDefinition.extends) {
    registrySlctr += inDefinition.tag + '[is=' + inDefinition.is + '],';
  }
  registrySlctr += inName;
}

function generateConstructor(inDefinition) {
  return function() {
    return instantiate(inDefinition);
  };
}

function createElement(inTag) {
  var definition = registry[inTag];
  if (definition) {
    return new definition.ctor();
  }
  return domCreateElement(inTag);
}

/**
 * Upgrade an element to a custom element. Upgrading an element
 * causes the custom prototype to be applied, an `is` attribute to be attached
 * (as needed), and invocation of the `readyCallback`.
 * `upgradeElement` does nothing is the element is already upgraded, or
 * if it matches no registered custom tag name. 
 * 
 * @method ugpradeElement
 * @param {Element} inElement The element to upgrade.
 * @return {Element} The upgraded element.
 */
function upgradeElement(inElement) {
  if (!inElement.__upgraded__) {
    var type = inElement.getAttribute('is') || inElement.localName;
    var definition = registry[type];
    return definition && upgrade(inElement, definition);
  }
}

/**
 * Upgrade all elements under `inRoot` that match selector `inSlctr`.
 * causes the custom prototype to be applied, an `is` attribute to be attached
 * (as needed), and invocation of the `readyCallback`.
 * `upgradeElement` does nothing is the element is already upgraded, or
 * if it matches no registered custom tag name. 
 * 
 * @method ugpradeElements
 * @param {Node} inRoot The root of the DOM subtree in which elements are to 
 *  be upgraded.
 * @param {String} [inSlctr] An optional selector for matching specific 
 * elements, otherwise all register element types are upgraded.
 */
function upgradeElements(inRoot, inSlctr) {
  var slctr = inSlctr || registrySlctr;
  if (slctr) {
    var root = inRoot || document;
    forEach(root.querySelectorAll(slctr), upgradeElement);
  }
}

// utilities

var forEach = Array.prototype.forEach.call.bind(Array.prototype.forEach);

// copy all properties from inProps (et al) to inObj
function mixin(inObj/*, inProps, inMoreProps, ...*/) {
  var obj = inObj || {};
  for (var i = 1; i < arguments.length; i++) {
    var p = arguments[i];
    // TODO(sjmiles): on IE we are using mixin
    // to generate custom element instances, as we have
    // no way to alter element prototypes after creation
    // (nor a way to create an element with a custom prototype)
    // however, prototype sources (inSource) are ultimately
    // chained to a native prototype (HTMLElement or inheritor)
    // and trying to copy HTMLElement properties to itself throwss
    // in IE
    // we don't actually want to copy those properties anyway, but I
    // can't find a way to determine if a prototype is a native
    // or custom inheritor of HTMLElement
    // ad hoc solution is to simply stop at the first exception
    // an alternative exists if we have a tagName hint: then we can
    // work out where the native objects are in the prototype chain
    try {
      for (var n in p) {
        copyProperty(n, p, obj);
      }
    } catch(x) {
      //console.log(x);
    }
  }
  return obj;
}

// copy property inName from inSource object to inTarget object
function copyProperty(inName, inSource, inTarget) {
  var pd = getPropertyDescriptor(inSource, inName);
  Object.defineProperty(inTarget, inName, pd);
}

// get property descriptor for inName on inObject, even if
// inName exists on some link in inObject's prototype chain
function getPropertyDescriptor(inObject, inName) {
  if (inObject) {
    var pd = Object.getOwnPropertyDescriptor(inObject, inName);
    return pd || getPropertyDescriptor(Object.getPrototypeOf(inObject), inName);
  }
}

// capture native createElement before we override it
var domCreateElement = document.createElement.bind(document);

// exports

document.register = register;
document.upgradeElement = upgradeElement;
document.upgradeElements = upgradeElements;
document.createElement = createElement; // override

// TODO(sjmiles): temporary, control scope better
window.mixin = mixin;

})();
