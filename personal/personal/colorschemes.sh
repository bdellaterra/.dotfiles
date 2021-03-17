
# *** bat ***
if [[ -r ~/.config/bat/themes/Nord/Gyromantia.tmTheme ]]; then
  ( bat --list-themes | grep -q Gyromantia ) || bat cache --build
  export BAT_THEME=Gyromantia
fi
