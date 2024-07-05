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


Hooks.LeafletMap = {
  mounted() {
    console.log("LeafletMap hook mounted");

    try {
      const latitude = parseFloat(this.el.dataset.latitude);
      const longitude = parseFloat(this.el.dataset.longitude);

      if (isNaN(latitude) || isNaN(longitude)) {
        console.error("Invalid coordinates:", { latitude, longitude });
        return;
      }


      const map = L.map(this.el).setView([latitude, longitude], 13);
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
      }).addTo(map);

      const purpleIcon = L.divIcon({
        className: 'custom-div-icon',
        html: "<div style='background-color: rgba(121, 0, 253, 0.5); width: 50px; height: 50px; border: 5px solid purple; border-radius: 50%;'></div>",
        iconSize: [12, 12],
        iconAnchor: [6, 6]
      });

      L.marker([latitude, longitude], { icon: purpleIcon }).addTo(map);
    } catch (error) {
      console.error("Error initializing map:", error);
    }
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
      console.log("Camera component mounted");
      this.handleUserMedia();
    },
  
    handleUserMedia() {
      const video = document.getElementById("videoElement");
  
      const videoConstraints = {
        video: {
          facingMode: 'environment',
          focusMode: 'continuous' // This might not be supported by all browsers
        }
      };
  
      if (navigator.mediaDevices.getUserMedia) {
        navigator.mediaDevices.getUserMedia(videoConstraints)
          .then(stream => {
            video.srcObject = stream;
            video.play();
  
            // Add a timeout to check if the video is playing
            setTimeout(() => {
              if (video.readyState < 3) { // readyState 3 means 'HAVE_FUTURE_DATA' or higher
                this.pushEvent("camera-error", { message: "Camera is not accessible or is blocked" });
              }
            }, 5000); // 5 seconds timeout
  
            video.addEventListener("loadeddata", () => {
              this.scanQRCode(video);
            });
          })
          .catch(error => {
            console.error("Something went wrong with accessing the camera", error);
            this.pushEvent("camera-error", { message: "Camera access denied or not available. Use your app camera instead" });
          });
      } else {
        this.pushEvent("camera-error", { message: "Camera not supported by this browser. Use your app camera instead" });
      }
    },
  
    scanQRCode(video) {
      const canvas = document.createElement('canvas');
      const context = canvas.getContext('2d');
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;
  
      const scanInterval = setInterval(() => {
        if (video.readyState >= 2) { // Ensure video is ready
          context.drawImage(video, 0, 0, canvas.width, canvas.height);
          const imageData = context.getImageData(0, 0, canvas.width, canvas.height);
          const code = jsQR(imageData.data, canvas.width, canvas.height);
          if (code) {
            console.log("QR Code detected:", code.data);
            clearInterval(scanInterval); // Stop scanning once a code is found
            this.pushEvent("qr-code-scanned", { data: code.data });
          }
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
  
  Hooks.SwipeAndIndex = {
    mounted() {
      console.log("SwipeAndIndex hook mounted");
      this.initializeIndex();
      this.handlePan();
    },
    destroyed() {
      if (this.hammerManager) {
        this.hammerManager.destroy();
      }
    },
    initializeIndex() {
      let index = localStorage.getItem("badgeIndex");
      if (index !== null) {
        this.pushEvent("initialize-index", { index: parseInt(index, 10) });
      }
      // Listening for an event to update local storage, assuming you have such an event.
      this.handleEvent("update-local-storage", ({ index }) => {
        console.log("Updating local storage with index:", index);
        localStorage.setItem("badgeIndex", index.toString());
      });
    },
    handlePan() {
      const el = this.el;
      const contentContainer = this.el.querySelector('.quest-bar-content');
      this.hammerManager = new Hammer.Manager(el);
    
      this.hammerManager.add(new Hammer.Pan({ direction: Hammer.DIRECTION_HORIZONTAL, threshold: 0.5 }));
    
      // Track the initial position of the content container
      let initialX = 0;
      let deltaX = 0; // The change in X since the start of the pan
    
      this.hammerManager.on('panstart', (ev) => {
        // Reset deltaX at the start of a pan
        deltaX = 0;
        // Optionally, parse the current transform to get the initial X if you're maintaining the position between pans
        const transformMatrix = window.getComputedStyle(contentContainer).transform;
        if (transformMatrix !== 'none') {
          const matrixValues = transformMatrix.split('(')[1].split(')')[0].split(',');
          initialX = parseFloat(matrixValues[4]); // 4th index in matrix is translateX value
        } else {
          initialX = 0;
        }
      });
    
      this.hammerManager.on('panmove', (ev) => {
        deltaX = ev.deltaX;
        // Apply the ongoing pan translation to the container
        contentContainer.style.transform = `translateX(${initialX + deltaX}px)`;
      });
    
      this.hammerManager.on('panend', (ev) => {
        // Now, panend only decides if we trigger next or previous, but does not move the content itself
        if (ev.velocityX > 0.3) {
          this.pushEvent('previous');
        } else if (ev.velocityX < -0.3) {
          this.pushEvent('next');
        }
        // You could use deltaX to determine if we've moved enough to consider this a next/previous action
        // and reset to initial position if not.
        // Reset the initial position to where we left off, or snap back based on deltaX
        if (Math.abs(deltaX) < 100) { // Example threshold, adjust based on your needs
          // Snap back if the movement wasn't enough to trigger a next/previous
          contentContainer.style.transform = `translateX(${initialX}px)`;
        } else {
          // Update initialX to new position, or handle snapping to next/previous badge
          initialX += deltaX;
        }
      });
    }
  };
  
  Hooks.CountdownTimer = {
    mounted() {
      const startCountdown = (endTime) => {
        const updateCountdown = () => {
          const now = new Date().getTime();
          const distance = endTime - now;
  
          const days = Math.floor(distance / (1000 * 60 * 60 * 24));
          const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
          const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
          const seconds = Math.floor((distance % (1000 * 60)) / 1000);
  
          let display = "";
          if (days > 0) {
            display += days + "d ";
          }
          if (hours > 0 || days > 0) {
            display += hours + "h ";
          }
          if (minutes > 0 || hours > 0 || days > 0) {
            display += minutes + "m ";
          }
          if (seconds > 0 || minutes > 0 || hours > 0 || days > 0) {
            display += seconds + "s ";
          }
  
          this.el.innerHTML = display;
  
          if (distance < 0) {
            clearInterval(countdownInterval);
            this.el.innerHTML = "Ready to scan!";
          }
        };
  
        updateCountdown();
        const countdownInterval = setInterval(updateCountdown, 1000);
      };
  
      const nextScanDate = new Date(this.el.dataset.nextScanDate);
      startCountdown(nextScanDate.getTime());
    }
  };


  Hooks.ExternalRedirect = {
    mounted() {
      console.log("ExternalRedirect hook mounted");
      this.handleEvent("external_redirect", ({url}) => {
        console.log("Redirecting to:", url);
        window.location = url;
      })
    }
  }

  Hooks.ToggleModal = {
    mounted() {
      this.handleEvent("toggle-modal", () => {
        const modal = this.el.querySelector(`#ui-overlay-${this.el.id}`);
        if (modal.classList.contains("hidden")) {
          modal.classList.remove("hidden");
          modal.classList.add("fade-in");
        } else {
          modal.classList.remove("fade-in");
          modal.classList.add("fade-out");
          setTimeout(() => {
            modal.classList.add("hidden");
            modal.classList.remove("fade-out");
          }, 300); // Duration of the fade-out animation
        }
      });
    }
  };
  
export default Hooks;
