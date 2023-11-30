  // If you want to use Phoenix channels, run `mix help phx.gen.channel`
  // to get started and then uncomment the line below.
  // import "./user_socket.js"

  // You can include dependencies in two ways.
  //
  // The simplest option is to put them in assets/vendor and
  // import them using relative paths:
  //     import "../vendor/some-package.js"
  //
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
  import Hooks from "./hooks"

  // Show progress bar on live navigation and form submits
  topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
  window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
  window.addEventListener("phx:page-loading-stop", _info => topbar.hide())


  function animateProgressBars() {
    document.querySelectorAll('.progress-bar').forEach(barContainer => {
      const progressBar = barContainer.querySelector('.progress, .completed-progress');
      if (!progressBar) return;
  
      const finalWidth = progressBar.style.width; // Get the final width
      progressBar.style.width = '60%'; // Reset width to 0
  
      // Trigger reflow to apply the reset
      void progressBar.offsetWidth;
  
      // Apply the final width with a delay for the transition effect
      setTimeout(() => {
        progressBar.style.width = finalWidth;
  
        // If this is a completed progress bar, add the glow after reaching 100%
        if (progressBar.classList.contains('completed-progress')) {
          setTimeout(() => {
            barContainer.classList.add('completed-progress-bar-glow');
          }, 1900); // Adjust the timeout to match the width transition duration
        }
      }, 100); // Adjust the timeout to control the start of the animation
    });
  }
  
  document.addEventListener('DOMContentLoaded', animateProgressBars);
  
  

  let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
  Hooks.FormSubmit = Hooks.FormSubmit(csrfToken);
  let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks});
  
  liveSocket.connect();
  console.log("LiveSocket connected");

  window.addEventListener("phx:test_event", function(event) {
      console.log("Test event received:", event.detail);
  });
  
  // expose liveSocket on window for web console debug logs and latency simulation:
  liveSocket.enableDebug()
  // >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
  // >> liveSocket.disableLatencySim()
  window.liveSocket = liveSocket

