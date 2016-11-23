const Elm = require('./Main.elm');

require("./index.html");
require("./static/favicon.ico");
require("./static/apostello-logo.svg");

function handleDOMContentLoaded() {
  // setup elm
  const app = Elm.Main.fullscreen({
    url: document.URL,
  });
  app.ports.event.subscribe(function(e) {
    ga('send', 'event', e.cat, e.act)
  });
}

window.addEventListener('DOMContentLoaded', handleDOMContentLoaded, false);
