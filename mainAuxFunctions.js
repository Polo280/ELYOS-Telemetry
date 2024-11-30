.pragma library
console.log("JS file loaded");

// Format a number of seconds in min:secs
function formatTime(seconds) {
    var minutes = Math.floor(seconds / 60);
    var remainingSeconds = seconds % 60;
    return minutes + ":" + (remainingSeconds < 10 ? "0" : "") + remainingSeconds;
}
