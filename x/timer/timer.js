function byid(id) {
    return document.getElementById(id);
}

paused = true;
timer_id = false;

max_minutes = "15";
max_seconds = "00";

function tick()
{
    minutes = byid("minutes").innerText;
    seconds = byid("seconds").innerText;
    if (seconds == 0) {
        seconds = 59;
        minutes -= 1;
        if (minutes < 10) {
            minutes = "0" + minutes;
        }
    }
    else {
        seconds -= 1;
        if (seconds < 10) {
            seconds = "0" + seconds;
        }
    }
    byid("minutes").innerText = minutes;
    byid("seconds").innerText = seconds;
    byid("title").innerText = minutes + ":" + seconds;
    if ((minutes == 0) && (seconds == 0) && !paused) {
        pause_unpause();
    }
}

function reset()
{
    if (!paused) {
        pause_unpause();
    }
    byid("minutes").innerText = max_minutes;
    byid("seconds").innerText = max_seconds;
}

function pause_unpause()
{
    paused = !paused;
    if (paused) {
        byid("pause").innerHTML = "<b>s</b>tart";
        byid("title").innerText = "Timer";
        byid("controls").style.color = "#777";
        document.body.style.cursor = "default";
        if (timer_id !== false) {
            clearInterval(timer_id);
        }
    }
    else {
        byid("pause").innerHTML = "<b>p</b>ause";
        byid("controls").style.color = "#222";
        document.body.style.cursor = "none";
        timer_id = setInterval(tick, 1000);
        if ((minutes == 0) && (seconds == 0)) {
            reset();
        }
    }
    minutes = byid("minutes").innerText;
    seconds = byid("seconds").innerText;
}

function get_formatted_integer(message, default_value)
{
    new_value = parseInt(prompt(message, default_value));
    if (isNaN(new_value)) {
        new_value = default_value;
    }
    else if (new_value < 0) {
        new_value = "00";
    }
    else if (new_value < 10) {
        new_value = "0" + new_value;
    }
    return new_value;
}

function adjust()
{
    max_minutes = get_formatted_integer("Minutes:", max_minutes);
    max_seconds = get_formatted_integer("Seconds:", max_seconds);
    if ((max_minutes == 0) && (max_seconds == 0)) {
        max_minutes = "00";
        max_seconds = "01";
    }
    byid("minutes").innerText = max_minutes;
    byid("seconds").innerText = max_seconds;
}

document.onkeypress = function(e)
{
    if ((e.code == "Space") || (e.code == "KeyS") || (e.code == "KeyP")) {
        pause_unpause();
    }
    else if (e.code == "KeyA") {
        adjust();
    }
    else if (e.code == "KeyR") {
        reset();
    }
}
