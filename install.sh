#!/bin/bash
set -eo pipefail
#set -x

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$REPO_DIR/src"

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/themes"
else
  DEST_DIR="$HOME/.themes"
fi

SASSC_OPT="-M -t expanded"

THEME_NAME=Orchis
THEME_VARIANTS=('' '-purple' '-pink' '-red' '-orange' '-yellow' '-green' '-grey' '-pop')
COLOR_VARIANTS=('' '-light' '-dark')
SIZE_VARIANTS=('' '-compact')

if [[ "$(command -v gnome-shell)" ]]; then
  SHELL_VERSION="$(gnome-shell --version | cut -d ' ' -f 3 | cut -d . -f -1)"
  if [[ "${SHELL_VERSION:-}" -ge "40" ]]; then
    GS_VERSION="new"
  else
    GS_VERSION="old"
  fi
  else
    echo "'gnome-shell' not found, using styles for last gnome-shell version available."
    GS_VERSION="new"
fi

usage() {
  cat << EOF
Usage: $0 [OPTION]...

OPTIONS:
  -d, --dest DIR          Specify destination directory (Default: $DEST_DIR)
  -n, --name NAME         Specify theme name (Default: $THEME_NAME)
  -t, --theme VARIANT     Specify theme color variant(s) [default|purple|pink|red|orange|yellow|green|grey|all] (Default: blue)
  -c, --color VARIANT...  Specify color variant(s) [standard|light|dark] (Default: All variants)s)
  -s, --size VARIANT      Specify size variant [standard|compact] (Default: All variants)
  --tweaks                Specify versions for tweaks [solid|compact] (solid: no transparency variant, compact: no floating panel)
  --radio-color           Change radio button checked color to default primary color (Default is Green)
  -h, --help              Show help

INSTALLATION EXAMPLES:
Install all theme variants into ~/.themes
  $0 --dest ~/.themes
Install standard theme variant only
  $0 --color standard
Install specific theme variants with different name into ~/.themes
  $0 --dest ~/.themes --name MyTheme --color dark
EOF
}

install() {
  local dest="$1"
  local name="$2"
  local theme="$3"
  local color="$4"
  local size="$5"

  [[ "$color" == '-dark' ]] && local ELSE_DARK="$color"
  [[ "$color" == '-light' ]] && local ELSE_LIGHT="$color"

  local THEME_DIR="$dest/$name$theme$color$size"

  [[ -d "$THEME_DIR" ]] && rm -rf "${THEME_DIR:?}"

  echo "Installing '$THEME_DIR'..."

  mkdir -p                                                                      "$THEME_DIR"
  cp -r "$REPO_DIR/COPYING"                                                     "$THEME_DIR"

  echo "[Desktop Entry]" >>                                                     "$THEME_DIR/index.theme"
  echo "Type=X-GNOME-Metatheme" >>                                              "$THEME_DIR/index.theme"
  echo "Name=$name$theme$color$size" >>                                         "$THEME_DIR/index.theme"
  echo "Comment=An Materia Gtk+ theme based on Elegant Design" >>               "$THEME_DIR/index.theme"
  echo "Encoding=UTF-8" >>                                                      "$THEME_DIR/index.theme"
  echo "" >>                                                                    "$THEME_DIR/index.theme"
  echo "[X-GNOME-Metatheme]" >>                                                 "$THEME_DIR/index.theme"
  echo "GtkTheme=$name$theme$color$size" >>                                     "$THEME_DIR/index.theme"
  echo "MetacityTheme=$name$theme$color$size" >>                                "$THEME_DIR/index.theme"
  echo "IconTheme=Tela-circle${ELSE_DARK:-}" >>                                 "$THEME_DIR/index.theme"
  echo "CursorTheme=Vimix${ELSE_DARK:-}" >>                                     "$THEME_DIR/index.theme"
  echo "ButtonLayout=close,minimize,maximize:menu" >>                           "$THEME_DIR/index.theme"

  mkdir -p                                                                              "$THEME_DIR/gnome-shell"
  cp -r "$SRC_DIR/gnome-shell/pad-osd.css"                                              "$THEME_DIR/gnome-shell"

  if [[ "$panel" == 'compact' || "$opacity" == 'solid' ]]; then
    if [[ "${GS_VERSION:-}" == 'new' ]]; then
      sassc $SASSC_OPT "$SRC_DIR/gnome-shell/shell-40-0/gnome-shell$theme${ELSE_DARK:-}$size.scss" "$THEME_DIR/gnome-shell/gnome-shell.css"
    else
      sassc $SASSC_OPT "$SRC_DIR/gnome-shell/shell-3-28/gnome-shell$theme${ELSE_DARK:-}$size.scss" "$THEME_DIR/gnome-shell/gnome-shell.css"
    fi
  else
    if [[ "${GS_VERSION:-}" == 'new' ]]; then
      cp -r "$SRC_DIR/gnome-shell/shell-40-0/gnome-shell$theme${ELSE_DARK:-}$size.css"    "$THEME_DIR/gnome-shell/gnome-shell.css"
    else
      cp -r "$SRC_DIR/gnome-shell/shell-3-28/gnome-shell$theme${ELSE_DARK:-}$size.css"    "$THEME_DIR/gnome-shell/gnome-shell.css"
    fi
  fi

  cp -r "$SRC_DIR/gnome-shell/common-assets"                                            "$THEME_DIR/gnome-shell/assets"
  cp -r "$SRC_DIR/gnome-shell/assets${ELSE_DARK:-}/"*.svg                               "$THEME_DIR/gnome-shell/assets"
  cp -r "$SRC_DIR/gnome-shell/theme$theme/checkbox${ELSE_DARK:-}.svg"                   "$THEME_DIR/gnome-shell/assets/checkbox.svg"
  cp -r "$SRC_DIR/gnome-shell/theme$theme/more-results${ELSE_DARK:-}.svg"               "$THEME_DIR/gnome-shell/assets/more-results.svg"
  cp -r "$SRC_DIR/gnome-shell/theme$theme/toggle-on${ELSE_DARK:-}.svg"                  "$THEME_DIR/gnome-shell/assets/toggle-on.svg"

  cd "$THEME_DIR/gnome-shell"
  ln -s assets/no-events.svg no-events.svg
  ln -s assets/process-working.svg process-working.svg
  ln -s assets/no-notifications.svg no-notifications.svg

#  mkdir -p                                                                      "$THEME_DIR/gtk-2.0"
#  cp -r "$SRC_DIR/gtk-2.0/common/"{apps.rc,hacks.rc,main.rc}                    "$THEME_DIR/gtk-2.0"
#  cp -r "$SRC_DIR/gtk-2.0/assets-folder/assets$theme${ELSE_DARK:-}"             "$THEME_DIR/gtk-2.0/assets"
#  cp -r "$SRC_DIR/gtk-2.0/gtkrc$theme${ELSE_DARK:-}"                            "$THEME_DIR/gtk-2.0/gtkrc"

  mkdir -p                                                                      "$THEME_DIR/gtk-3.0"
  cp -r "$SRC_DIR/gtk/assets$theme"                                             "$THEME_DIR/gtk-3.0/assets"
  cp -r "$SRC_DIR/gtk/scalable"                                                 "$THEME_DIR/gtk-3.0/assets"
  cp -r "$SRC_DIR/gtk/thumbnail${ELSE_DARK:-}.png"                              "$THEME_DIR/gtk-3.0/thumbnail.png"

  if [[ "$opacity" == 'solid' ]]; then
    sassc $SASSC_OPT "$SRC_DIR/gtk/3.0/gtk$theme$color$size.scss"               "$THEME_DIR/gtk-3.0/gtk.css"
    [[ "$color" != '-dark' ]] && \
    sassc $SASSC_OPT "$SRC_DIR/gtk/3.0/gtk$theme-dark$size.scss"                "$THEME_DIR/gtk-3.0/gtk-dark.css"
  else
    cp -r "$SRC_DIR/gtk/3.0/gtk$theme$color$size.css"                           "$THEME_DIR/gtk-3.0/gtk.css"
    [[ "$color" != '-dark' ]] && \
    cp -r "$SRC_DIR/gtk/3.0/gtk$theme-dark$size.css"                            "$THEME_DIR/gtk-3.0/gtk-dark.css"
  fi

  mkdir -p                                                                      "$THEME_DIR/gtk-4.0"
  cp -r "$SRC_DIR/gtk/assets$theme"                                             "$THEME_DIR/gtk-4.0/assets"
  cp -r "$SRC_DIR/gtk/scalable"                                                 "$THEME_DIR/gtk-4.0/assets"

  if [[ "$opacity" == 'solid' ]]; then
    sassc $SASSC_OPT "$SRC_DIR/gtk/4.0/gtk$theme$color$size.scss"               "$THEME_DIR/gtk-4.0/gtk.css"
    [[ "$color" != '-dark' ]] && \
    sassc $SASSC_OPT "$SRC_DIR/gtk/4.0/gtk$theme-dark$size.scss"                "$THEME_DIR/gtk-4.0/gtk-dark.css"
  else
    cp -r "$SRC_DIR/gtk/4.0/gtk$theme$color$size.css"                           "$THEME_DIR/gtk-4.0/gtk.css"
    [[ "$color" != '-dark' ]] && \
    cp -r "$SRC_DIR/gtk/4.0/gtk$theme-dark$size.css"                            "$THEME_DIR/gtk-4.0/gtk-dark.css"
  fi

  mkdir -p                                                                      "$THEME_DIR/xfwm4"
  cp -r "$SRC_DIR/xfwm4/assets${ELSE_LIGHT:-}/"*.png                            "$THEME_DIR/xfwm4"
  cp -r "$SRC_DIR/xfwm4/themerc${ELSE_LIGHT:-}"                                 "$THEME_DIR/xfwm4/themerc"

  mkdir -p                                                                      "$THEME_DIR/cinnamon"
  cp -r "$SRC_DIR/cinnamon/common-assets"                                       "$THEME_DIR/cinnamon/assets"
  cp -r "$SRC_DIR/cinnamon/assets${ELSE_DARK:-}/"*.svg                          "$THEME_DIR/cinnamon/assets"
  cp -r "$SRC_DIR/cinnamon/cinnamon${ELSE_DARK:-}.css"                          "$THEME_DIR/cinnamon/cinnamon.css"
  cp -r "$SRC_DIR/cinnamon/thumbnail${ELSE_DARK:-}.png"                         "$THEME_DIR/cinnamon/thumbnail.png"

  mkdir -p                                                                      "$THEME_DIR/metacity-1"
  cp -r "$SRC_DIR/metacity-1/metacity-theme-2${color}.xml"                      "$THEME_DIR/metacity-1/metacity-theme-2.xml"
  cp -r "$SRC_DIR/metacity-1/metacity-theme-3.xml"                              "$THEME_DIR/metacity-1"
  cp -r "$SRC_DIR/metacity-1/assets"                                            "$THEME_DIR/metacity-1"
  cp -r "$SRC_DIR/metacity-1/thumbnail${ELSE_DARK:-}.png"                       "$THEME_DIR/metacity-1/thumbnail.png"
  cd "$THEME_DIR/metacity-1" && ln -s metacity-theme-2.xml metacity-theme-1.xml

  mkdir -p                                                                      "$THEME_DIR/plank"
  cp -r "$SRC_DIR/plank/dock.theme"                                             "$THEME_DIR/plank"
}

themes=()
colors=()
sizes=()

while [[ "$#" -gt 0 ]]; do
  case "${1:-}" in
    -d|--dest)
      dest="$2"
      mkdir -p "$dest"
      shift 2
      ;;
    -n|--name)
      _name="$2"
      shift 2
      ;;
    --tweaks)
      shift
      for tweaks in $@; do
        case "$tweaks" in
          solid)
            opacity="solid"
            shift
            ;;
          compact)
            panel="compact"
            shift
            ;;
          -*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized panel variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    --radio-color)
      radio="true"
      shift
      ;;
    -t|--theme)
      accent='true'
      shift
      for variant in "$@"; do
        case "$variant" in
          default)
            themes+=("${THEME_VARIANTS[0]}")
            shift
            ;;
          purple)
            themes+=("${THEME_VARIANTS[1]}")
            shift
            ;;
          pink)
            themes+=("${THEME_VARIANTS[2]}")
            shift
            ;;
          red)
            themes+=("${THEME_VARIANTS[3]}")
            shift
            ;;
          orange)
            themes+=("${THEME_VARIANTS[4]}")
            shift
            ;;
          yellow)
            themes+=("${THEME_VARIANTS[5]}")
            shift
            ;;
          green)
            themes+=("${THEME_VARIANTS[6]}")
            shift
            ;;
          grey)
            themes+=("${THEME_VARIANTS[7]}")
            shift
            ;;
          pop)
            themes+=("${THEME_VARIANTS[8]}")
            shift
            ;;
          all)
            themes+=("${THEME_VARIANTS[@]}")
            shift
            ;;
          -*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized color variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -c|--color)
      shift
      for variant in "$@"; do
        case "$variant" in
          standard)
            colors+=("${COLOR_VARIANTS[0]}")
            shift
            ;;
          light)
            colors+=("${COLOR_VARIANTS[1]}")
            shift
            ;;
          dark)
            colors+=("${COLOR_VARIANTS[2]}")
            shift
            ;;
          -*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized color variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -s|--size)
      shift
      for variant in "$@"; do
        case "$variant" in
          standard)
            sizes+=("${SIZE_VARIANTS[0]}")
            shift
            ;;
          compact)
            sizes+=("${SIZE_VARIANTS[1]}")
            shift
            ;;
          -*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized size variant '${1:-}'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unrecognized installation option '${1:-}'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

parse_sass() {
  cd ${REPO_DIR} && ./parse-sass.sh
}

change_radio_color() {
  if [[ "${radio:-}" == 'true' ]]; then
    cd $SRC_DIR/_sass/gtk
    sed -i.bak "/\$check_radio_primary/s/success/primary/" _common-3.20.scss
    echo "Change radio color ..."
    parse_sass
  fi
}

#  Install needed packages
install_package() {
  if [ ! "$(which sassc 2> /dev/null)" ]; then
    echo sassc needs to be installed to generate the css.
    if has_command zypper; then
      sudo zypper in sassc
    elif has_command apt-get; then
      sudo apt-get install sassc
    elif has_command dnf; then
      sudo dnf install sassc
    elif has_command dnf; then
      sudo dnf install sassc
    elif has_command pacman; then
      sudo pacman -S --noconfirm sassc
    fi
  fi
}

install_compact_panel() {
  cd ${SRC_DIR}/gnome-shell/sass
  cp -an _tweaks.scss _tweaks.scss.bak
  sed -i "/\$panel_style:/s/float/compact/" _tweaks.scss
  echo -e "Install compact panel version ..."
}

install_solid() {
  cd ${SRC_DIR}/gnome-shell/sass
  cp -an _tweaks.scss _tweaks.scss.bak
  sed -i "/\$opacity:/s/default/solid/" _tweaks.scss
  cd ${SRC_DIR}/_sass
  cp -an _tweaks.scss _tweaks.scss.bak
  sed -i "/\$opacity:/s/default/solid/" _tweaks.scss
  echo -e "Install solid version ..."
}

restore_tweaks() {
  cd ${SRC_DIR}/gnome-shell/sass
  [[ -f _tweaks.scss.bak ]] && rm -rf _tweaks.scss && mv _tweaks.scss.bak _tweaks.scss
  cd ${SRC_DIR}/_sass
  [[ -f _tweaks.scss.bak ]] && rm -rf _tweaks.scss && mv _tweaks.scss.bak _tweaks.scss
  echo -e "Restore _tweaks.scss file ..."
}

restore_files() {
  if [[ -f $SRC_DIR/_sass/gtk/_common-3.20.scss.bak ]]; then
    cd $SRC_DIR/_sass/gtk
    rm -rf _common-3.20.scss
    mv -f _common-3.20.scss.bak _common-3.20.scss
    echo "Restore _common-3.20.scss file ..."
    parse_sass
  fi
}

install_theme() {
  for theme in "${themes[@]}"; do
    for color in "${colors[@]}"; do
      for size in "${sizes[@]}"; do
        install "${dest:-$DEST_DIR}" "${_name:-$THEME_NAME}" "$theme" "$color" "$size"
      done
    done
  done
}

if [[ "${#themes[@]}" -eq 0 ]] ; then
  themes=("${THEME_VARIANTS[0]}")
fi

if [[ "${#colors[@]}" -eq 0 ]] ; then
  colors=("${COLOR_VARIANTS[@]}")
fi

if [[ "${#sizes[@]}" -eq 0 ]] ; then
  sizes=("${SIZE_VARIANTS[@]}")
fi

if [[ "$panel" = "compact" ]] ; then
  install_package && install_compact_panel
fi

if [[ "$opacity" = "solid" ]] ; then
  install_package && install_solid
fi

change_radio_color && install_theme && restore_files && restore_tweaks

echo
echo "Done."
