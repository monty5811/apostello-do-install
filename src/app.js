const Elm = require('./Main.elm');

require('./index.html');
require('./static/favicon.ico');
require('./static/apostello-logo.svg');

function handleDOMContentLoaded() {
  // setup elm
  const app = Elm.Main.fullscreen({
    url: document.URL,
  });
  app.ports.gaEvent.subscribe(function(e) {
    gtag('event', e.name, e.params);
  });
}

window.addEventListener('DOMContentLoaded', handleDOMContentLoaded, false);
