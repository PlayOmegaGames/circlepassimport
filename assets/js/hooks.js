let Hooks = {};

Hooks.PasswordStrength = {
  mounted() {
    this.el.addEventListener('input', event => {
      const password = event.target.value;
      const result = zxcvbn(password);
      const crackTime = result.crack_times_display.offline_slow_hashing_1e4_per_second;
      this.pushEvent('password_strength', {
        password: password,
        strength: result.score * 25,
        crack_time: crackTime
      });
    });
  }
};

Hooks.FormSubmit = function(csrfToken) {
    return {
      mounted() {
        this.el.addEventListener("submit", e => {
          e.preventDefault();
  
          let formData = new FormData(this.el);
          let accountParams = {};
          formData.forEach((value, key) => {
            // Adjust the key to match the expected format
            let adjustedKey = key.replace("user[", "").replace("]", "");
            accountParams[adjustedKey] = value;
          });

        // Read redirect path from the form data-attribute
        const redirectPath = this.el.dataset.redirectPath || "/badges";
  
          fetch("/sign_up", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "X-CSRF-TOKEN": csrfToken
            },
            body: JSON.stringify({ account: accountParams })
          })
  
          .then(response => {
            if (!response.ok && response.status === 409) {
              // Handle email taken error
              return response.json().then(data => {
                alert(data.error); // Display an alert or update the UI with the error message
                throw new Error(data.error); // Stop further processing
              });
            }
            return response.json();
          })
            .then(data => {
            if (data.account && data.account.id) {
              // Account creation successful, set session
              return fetch("/set_session", {
                method: "POST",
                headers: {
                  "Content-Type": "application/json",
                  "X-CSRF-TOKEN": csrfToken
                },
                body: JSON.stringify({ account_id: data.account.id })
              });
            } else {
              // Handle failure, e.g., display error messages
              throw new Error("Signup failed: " + data.error);
            }
          })
          .then(sessionResponse => {
            if (sessionResponse.ok) {
              window.location.href = redirectPath; // Use the redirect path
            } else {
              console.error("Session setup failed");
            }
          })
          .catch(error => {
            console.error(error.message);
          });
        });
      }
    };
  };
  //updates localstorage
  Hooks.UpdateIndex = {
    mounted() {
      let index = localStorage.getItem("badgeIndex");
      if (index !== null) {
        this.pushEvent("initialize-index", { index: parseInt(index) });
      }
      // This is critical: Ensure `handleEvent` is directly within the hook object
      this.handleEvent("update-local-storage", ({ index }) => {
        console.log(index)
        localStorage.setItem("badgeIndex", index.toString()); // Make sure to convert to string
        console.log("LocalStorage updated with index:", index); // For debugging
      });
    }
  };
  
  Hooks.ModalAnimation = {
    updated() {
      let modal = this.el;
      if (this.el.dataset.animationState === "closing") {
        // Listen for the end of the slide out animation
        this.el.addEventListener('animationend', () => {
          this.pushEventTo(modal, "hide_modal", {});
        }, { once: true });
      }
    }
  };
  Hooks.QrScanner = {
    mounted() {
      console.log("test")
      this.handleUserMedia();
    },
  
    handleUserMedia() {
      var video = document.getElementById("videoElement");
  
      if (navigator.mediaDevices.getUserMedia) {
        navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' } })
          .then(stream => {
            video.srcObject = stream;
            video.addEventListener("loadeddata", () => {
              this.scanQRCode(video);
            });
          })
          .catch(error => {
            console.error("Something went wrong with accessing the camera", error);
          });
      }
    },
  
    scanQRCode(video) {
      var canvas = document.createElement('canvas');
      var context = canvas.getContext('2d');
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;
  
      setInterval(() => {
        context.drawImage(video, 0, 0, canvas.width, canvas.height);
        var imageData = context.getImageData(0, 0, canvas.width, canvas.height);
  
        // Assuming you have the jsQR library available
        var code = jsQR(imageData.data, canvas.width, canvas.height);
        if (code) {
          console.log("QR Code detected:", code.data);
          // Here, you'd use `this.pushEvent` to communicate with the server
          this.pushEvent("qr-code-scanned", {data: code.data});
        }
      }, 100);
    }
  };
  
  Hooks.UpdateTab = {
    mounted() {
      this.el.addEventListener("click", e => {
        let target = e.target.closest('[data-tab]'); // Find the closest ancestor with a `data-tab` attribute
        if (target) {
          const tab = target.getAttribute("data-tab");
          this.pushEvent("switch-tab", {tab: tab});
          
          // More dynamic URL update, consider using a data attribute for the URL if different from "/home/"
          const newPath = target.getAttribute("data-url") || ("/home/" + tab);
          history.pushState({}, "", newPath);
          
          e.preventDefault(); // Prevent the default anchor behavior
        }
      });
    }
  }
  
  
  
export default Hooks;
