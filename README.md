# Codex Dinger

Codex Dinger plays a sound when your Codex is **completely finished running.** It uses Codex's `Stop` hook, so it'll only beep at you when the task is completely done and control is handed back to you.

Codex Dinger currently supports the Windows Codex Desktop app. It doesn't collect any data, or connect to the internet unless you explicitly tell the plugin to update.

### Wait, why would I want this?
If you're like me, you often like to let your Codex agent run while doing other things. Cook a meal, go watch TV, play a video game (that one is especially important), etc. Codex Dinger is sort of like a microwave timer, in that it lets you know when your task is done so it's not sitting idle.

### But wait, the Windows Codex Desktop App already has a notifications feature!
Right you are! However, oftentimes the notification sound isn't loud enough to hear from another room. Additionally, certain Windows configurations (in particular "Game Mode") tend to suppress notification toasts, which means if you're playing a game, your notification will get completely drowned out!

### OK, what kind of sound can I play with it?
Any sound you want! The default bundled sound is a very simple, custom-created two-tone chime reminiscent of a doorbell. But, you can put any sound you want as your chime tone. A phone ringtone, microwave noise, that one song that plays when your washing machine is finished, a very loud scream, a recording of yourself saying something...anything you want, really. I won't judge.

## Install

Run these in powershell:
```powershell
codex plugin marketplace add Evan-H-Rosenthal/Codex-Dinger
codex plugin add codex-dinger@codex-dinger
```
And then restart Codex. 

Alternatively, if those aren't working you can open a new Codex thread, and tell it:

"Please install the plugin found at https://github.com/Evan-H-Rosenthal/Codex-Dinger.git"

Go to your plugins list, and trust the `Stop` hook. You're ready to start dinging!

## Things you can do:
All of the plugins functions are controlled by NLP, so you can just talk to Codex to adjust them.
Make sure to preface your message by referencing the plugin! You can do this by doing `@Codex Dinger`, it should automatically list the plugin as a valid reference if you've installed it correctly/

### Add a new sound:
Simply drag a sound file into Codex, and ask it:
- "Add the attached sound to my Codex Dinger sound bank."

Alternatively, you can drop new sounds files into the `%LOCALAPPDATA%/CodexDinger/sounds` folder.

### List all available sounds:
- "List my Codex Dinger sounds."

### Set the sound you want to use:
- "Use `my-chime.mp3` for Codex Dinger."

You can also change which sound is used by modifying the settings.json file in `%LOCALAPPDATA%\CodexDinger\settings.json`.

**If the sound you want to use is missing, or you simply entered the name wrong, it'll fall back to the default chime.**

### Adjust the volume:
- "Set Codex Dinger volume to 40 percent."

A volume control value is also in the settings.json file for you to change.

### Enable/Disable the ding:
- "Disable Codex Dinger."

You can also enable/disable by using settings.json.

### Check for updates:
- "Check Codex Dinger for updates."
- "Update Codex Dinger."

You can also manually update by running these Poweshell commands:

```powershell
codex plugin marketplace upgrade codex-dinger
codex plugin add codex-dinger@codex-dinger
```

Make sure to restart Codex after updating. You may need to trust the Stop hook again in order for Dinger to keep working.

If you want, you can watch this repository and get notified when it updates. Codex Dinger is in a completely usable state right now, but I may add extra features like sound randomization, custom sounds for when Codex asks you for clarification/approval, compatibility with other OSes/CLI, and more! So, stay tuned!


## Uninstalling

I'm so sad to see you go! But, I get it. Dinger isn't for everyone. If you'd like to uninstall the plugin, you can run the following Powershell commands:

```powershell
codex plugin remove codex-dinger@codex-dinger
codex plugin marketplace remove codex-dinger
```

Or, you can go into your plugins list, find the installed plugin, click the three dots next to Codex Dinger, and hit Uninstall. I won't hold it against you!

Oh, and uninstalling doesn't delete the local sound bank. Remove `%LOCALAPPDATA%\CodexDinger` manually if you also want to erase preferences and custom sounds.

### Audio licensing

The bundled `default-chime.wav` was created for this project by me. It's under the same MIT license as the code, so you can use it if you decide to open a pull request. However, please don't open a pull request with copyrighted audio!

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md) for validation commands and [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) for release gates.
