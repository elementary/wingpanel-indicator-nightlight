# Wingpanel Nightlight Indicator
[![Translation status](https://l10n.elementary.io/widgets/wingpanel/-/indicator-nightlight/svg-badge.svg)](https://l10n.elementary.io/engage/wingpanel/?utm_source=widget)

![Screenshot](data/screenshot.png?raw=true)

## Building and Installation

You'll need the following dependencies:

    libglib2.0-dev
    libgranite-dev
    libgtk-3-dev
    libwingpanel-2.0-dev
    meson
    valac

Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`

    sudo ninja install
