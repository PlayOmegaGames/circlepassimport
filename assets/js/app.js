// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

document.addEventListener("DOMContentLoaded", function() {

    // Handle Sign-In
    const signInForm = document.querySelector('form[action="/sign_in"]');
    if (signInForm) {
      signInForm.addEventListener("submit", function(event) {
        event.preventDefault();
        submitForm(signInForm, '/sign_in');
      });
    }
  
    // Handle Sign-Up
    const signUpForm = document.querySelector('form[action="/sign_up"]');
    if (signUpForm) {
      signUpForm.addEventListener("submit", function(event) {
        event.preventDefault();
        submitForm(signUpForm, '/sign_up');
      });
    }
});

function submitForm(form, url) {
    fetch(url, {
      method: 'POST',
      body: new FormData(form),
      headers: {
        'X-CSRF-Token': csrfToken
      }
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      // Redirect to homepage or appropriate page on success
      window.location.href = '/';
    })
    .catch(error => {
      console.error('Error:', error);
      displayErrorMessage('An error occurred. Please try again later.');
    });
}


// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

