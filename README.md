# Wingpanel Nightlight Indicator
[![l10n](https://l10n.elementary.io/widgets/wingpanel/indicator-nightlight/svg-badge.svg)](https://l10n.elementary.io/projects/wingpanel/indicator-nightlight)

![Screenshot](data/screenshot.png?raw=true)

## Building and Installation

It's recommended to create a clean build environment

    mkdir build
    cd build/

Run `cmake` to configure the build environment and then `make` to build

    cmake -DCMAKE_INSTALL_PREFIX=/usr ..
    make

To install, use `make install`

    sudo make install
