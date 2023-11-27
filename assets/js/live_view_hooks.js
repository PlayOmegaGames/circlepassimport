// Define an empty Hooks object to store our custom hooks
let Hooks = {};

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