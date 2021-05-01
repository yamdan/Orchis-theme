# Unofficial Pop!_OS flavored Orchis theme

Unofficial Pop!_OS flavored [Orchis](https://github.com/vinceliuice/Orchis-theme) theme.
GTK2 is currently not supported.

Orchis is a [Material Design](https://material.io) theme for GNOME/GTK based desktop environments.
Based on nana-4 --  [materia-theme](https://github.com/nana-4/materia-theme)

## Requirements

- GTK `>=3.20`
- `gnome-themes-extra` (or `gnome-themes-standard`)
- Murrine engine — The package name depends on the distro.
  - `gtk-engine-murrine` on Arch Linux
  - `gtk-murrine-engine` on Fedora
  - `gtk2-engine-murrine` on openSUSE
  - `gtk2-engines-murrine` on Debian, Ubuntu, etc.
- `sassc` — build dependency

## Installation

### Manual Installation

Run the following commands in the terminal:

```sh
./install.sh
```

> Tip: `./install.sh` allows the following options:

```
-d, --dest DIR          Specify destination directory (Default: /usr/share/themes)
-n, --name NAME         Specify theme name (Default: Orchis)
-t, --theme VARIANT...  Specify theme color variant(s) [default|pop|purple|pink|red|orange|yellow|green|grey|all] (Default: blue)
-c, --color VARIANT...  Specify color variant(s) [standard|light|dark] (Default: All variants)
--radio-color           Change radio button checked color to default primary color (Default is Green)
-h, --help              Show help
```

> For more information, run: `./install.sh --help`

> Install different accent color version, run: `./install.sh -t [color name]`

![theme-color](theme-color.png?raw=true)

```
./install.sh -t pop # install Pop!_OS flavored accent color version
```
