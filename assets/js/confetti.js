import confetti from 'canvas-confetti';

  //confetti
  document.addEventListener('DOMContentLoaded', () => {
    // Function to launch a big burst of confetti
    const launchBigBurst = () => {
      confetti({
        startVelocity: 45, // Increased velocity for a more dynamic effect
        spread: 360,
        particleCount: 500, // Increased particle count for a bigger burst
        origin: {
          x: 0.5, // Centralized origin for the burst
          y: 0.5
        }
      });
    };

    // Launch the big burst immediately when the page loads
    launchBigBurst();
  });
