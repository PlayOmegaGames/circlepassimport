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


  // Show progress bar on live navigation and form submits
  topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
  window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
  window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

  let Hooks = {}; // Ensure Hooks is defined

    // Define a custom hook named PasswordStrength
  Hooks.PasswordStrength = {
    // The mounted function is called once the hook is attached to the DOM
    mounted() {
        // Add an event listener for the input event on the associated DOM element
        this.el.addEventListener('input', event => {

            // Get the value of the password from the event
            const password = event.target.value;
            // Use zxcvbn to estimate the password strength
            const result = zxcvbn(password);
            // Extract the estimated crack time from the zxcvbn result
            const crackTime = result.crack_times_display.offline_slow_hashing_1e4_per_second;
            // Push a password_strength event to the server with the password, strength score, and estimated crack time
            this.pushEvent('password_strength', {
                password: password,
                strength: result.score * 25,
                crack_time: crackTime
            });
        });
    }
  };
  

  let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
  let liveSocket = new LiveSocket("/live", Socket, {
    params: {_csrf_token: csrfToken},
    hooks: Hooks // Include your hooks here
  });

  // connect if there are any LiveViews on the page
  liveSocket.connect()
  console.log("Setting up phx:test_event listener");

  window.addEventListener("phx:test_event", function(event) {
    console.log("Test event received:", event.detail);
  });
  
  window.addEventListener("phx:account_created", function(event) {
    console.log("Account created event received:", event.detail);
    const detail = event.detail;
    if (detail && detail.account_id) {
      fetch("/set_session", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-TOKEN": csrfToken
        },
        body: JSON.stringify({ account_id: detail.account_id })
      }).then(response => {
        if (response.ok) {
          // Redirect to the specified path or default to '/badges'
          window.location.href = detail.redirect_path || "/badges";
        } else {
          // Handle errors, such as displaying a message to the user
        }
      });
    }
  });
  
  // expose liveSocket on window for web console debug logs and latency simulation:
  // >> liveSocket.enableDebug()
  // >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
  // >> liveSocket.disableLatencySim()
  window.liveSocket = liveSocket

