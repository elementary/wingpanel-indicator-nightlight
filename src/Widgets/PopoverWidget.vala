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
    public unowned Settings settings { get; construct set; }

    private Wingpanel.Widgets.Switch toggle_switch;
    private Gtk.Scale temp_scale;

    public int temperature {
        set {
            temp_scale.set_value (value);
        }
    }

    public PopoverWidget (Nightlight.Indicator indicator, Settings settings) {
        Object (indicator: indicator, settings: settings);
    }

    construct {
        orientation = Gtk.Orientation.VERTICAL;

        toggle_switch = new Wingpanel.Widgets.Switch (_("Night Light"));
        toggle_switch.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

        var image = new Gtk.Image ();
        image.icon_name = "night-light-symbolic";
        image.pixel_size = 48;

        temp_scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 3500, 6000, 10);
        temp_scale.add_mark (4500, Gtk.PositionType.BOTTOM, null);
        temp_scale.draw_value = false;
        temp_scale.has_origin = false;
        temp_scale.hexpand = true;
        temp_scale.inverted = true;
        temp_scale.width_request = 200;
        temp_scale.get_style_context ().add_class ("warmth");
        temp_scale.set_value (settings.get_uint ("night-light-temperature"));

        var scale_grid = new Gtk.Grid ();
        scale_grid.column_spacing = 6;
        scale_grid.margin_start = 6;
        scale_grid.margin_end = 12;
        scale_grid.add (image);
        scale_grid.add (temp_scale);

        var settings_button = new Wingpanel.Widgets.Button (_("Night Light Settings…"));
        settings_button.clicked.connect (show_settings);

        add (toggle_switch);
        add (new Wingpanel.Widgets.Separator ());
        add (scale_grid);
        add (new Wingpanel.Widgets.Separator ());
        add (settings_button);

        var toggle_switch_switch = toggle_switch.get_switch ();

        settings.bind ("night-light-enabled", toggle_switch.get_switch (), "active", GLib.SettingsBindFlags.DEFAULT);
        settings.bind ("night-light-temperature", this, "temperature", GLib.SettingsBindFlags.GET);
        toggle_switch_switch.bind_property ("active", scale_grid, "sensitive", GLib.BindingFlags.DEFAULT);

        temp_scale.value_changed.connect (() => {
            settings.set_uint ("night-light-temperature", (uint) temp_scale.get_value ());
        });

        toggle_switch_switch.notify["active"].connect (() => {
            if (toggle_switch_switch.active) {
                image.icon_name = "night-light-symbolic";
            } else {
                image.icon_name = "night-light-disabled-symbolic";
            }
        });
    }

    private void show_settings () {
        try {
            AppInfo.launch_default_for_uri ("settings://display/night-light", null);
        } catch (Error e) {
            warning ("Failed to open display settings: %s", e.message);
        }

        indicator.close ();
    }
}
