local obs = require("obslua")
local ffi = require("ffi")
local bit = require("bit")
local winmm = ffi.load("winmm")

local SOUND_FILE = ""
local SND_FILENAME = 0x00020000
local SND_ASYNC = 0x00000001
local SND_NODEFAULT = 0x00000002

ffi.cdef [[
    int PlaySoundA(const char *pszSound, void *hmod, uint32_t fdwSound);
]]

function script_description()
    return "Plays a sound when a replay is saved (Windows only)."
end

function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_path(props, "SOUND_FILE", "Sound File", obs.OBS_PATH_FILE, "Wav Files (*.wav)", nil)

    return props
end

function script_defaults(settings)
    obs.obs_data_set_default_string(settings, "SOUND_FILE", "C:\\Windows\\Media\\notify.wav")
end

function script_update(settings)
    SOUND_FILE = obs.obs_data_get_string(settings, "SOUND_FILE")
    obs.script_log(obs.LOG_INFO, "Replay sound set to " .. (SOUND_FILE ~= "" and SOUND_FILE or "None"))
end

function script_load(settings)
    obs.obs_frontend_add_event_callback(on_event)
end

function on_event(event)
    if event == obs.OBS_FRONTEND_EVENT_REPLAY_BUFFER_SAVED then
        obs.script_log(obs.LOG_INFO, "Replay saved! Playing " .. SOUND_FILE)

        -- WinMM seems pretty dated, but it's the only method I found that isn't slow.
        -- Normally I'd like to use FFplay, but os.execute(cmd) takes upwards of 10s?
        -- This should be revisited later.
        winmm.PlaySoundA(SOUND_FILE, nil, bit.bor(SND_FILENAME, SND_ASYNC, SND_NODEFAULT))
    end
end
