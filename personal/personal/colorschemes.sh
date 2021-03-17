
# *** bat ***
if [[ -r ~/.config/bat/themes/Nord/Nord.tmTheme ]]; then
  ( bat --list-themes | grep -q Nord ) || bat cache --build
  export BAT_THEME=Nord
fi
