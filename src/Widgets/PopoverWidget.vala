/*
 * Copyright (c) 2017 elementary LLC. (https://elementary.io)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 */

public class Nightlight.Widgets.PopoverWidget : Gtk.Grid {
    public unowned Nightlight.Indicator indicator { get; construct set; }

    public PopoverWidget (Nightlight.Indicator indicator) {
        Object (indicator: indicator);
    }

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        var settings = new GLib.Settings ("org.gnome.settings-daemon.plugins.color");

        var toggle_switch = new Wingpanel.Widgets.Switch (_("Warm Display"));
        toggle_switch.get_style_context ().add_class ("h4");

        settings.bind ("night-light-enabled", toggle_switch.get_switch (), "active", GLib.SettingsBindFlags.DEFAULT);

        var settings_button = new Wingpanel.Widgets.Button (_("Night light settings…"));
        settings_button.clicked.connect (show_settings);

        add (toggle_switch);
        add (new Wingpanel.Widgets.Separator ());
        add (settings_button);
    }

    private void show_settings () {
        try {
            AppInfo.launch_default_for_uri ("settings://display", null);
        } catch (Error e) {
            warning ("Failed to open display settings: %s", e.message);
        }

        indicator.close ();
    }
}