/*
 * Copyright (c) 2017-2021 elementary LLC. (https://elementary.io)
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

    private Granite.SwitchModelButton toggle_switch;
    private Gtk.Grid scale_grid;
    private Gtk.Image image;
    private Gtk.Scale temp_scale;
    private const int TEMP_CHANGE_DELAY_MS = 300;

    public bool automatic_schedule {
        set {
            if (value) {
                toggle_switch.description = _("Disabled until sunrise");
            } else {
                toggle_switch.description = _("Disabled until tomorrow");
            }
        }
    }

    public bool snoozed {
        set {
            scale_grid.sensitive = !value;
            toggle_switch.active = value;

            if (value) {
                image.icon_name = "night-light-disabled-symbolic";
            } else {
                image.icon_name = "night-light-symbolic";
            }
         }
    }

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

        toggle_switch = new Granite.SwitchModelButton (_("Snooze Night Light"));

        var toggle_sep = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            margin_top = 3,
            margin_bottom = 3
        };

        image = new Gtk.Image ();
        image.pixel_size = 48;

        temp_scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 3500, 6000, 10);
        temp_scale.draw_value = false;
        temp_scale.has_origin = false;
        temp_scale.hexpand = true;
        temp_scale.inverted = true;
        temp_scale.width_request = 200;
        temp_scale.get_style_context ().add_class ("warmth");

        scale_grid = new Gtk.Grid ();
        scale_grid.column_spacing = 6;
        scale_grid.margin_start = 6;
        scale_grid.margin_end = 12;
        scale_grid.add (image);
        scale_grid.add (temp_scale);

        var scale_sep = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            margin_top = 3,
            margin_bottom = 3
        };

        var settings_button = new Gtk.ModelButton ();
        settings_button.text = _("Night Light Settings…");
        settings_button.clicked.connect (show_settings);

        add (toggle_switch);
        add (toggle_sep);
        add (scale_grid);
        add (scale_sep);
        add (settings_button);

        snoozed = NightLight.Manager.get_instance ().snoozed;

        toggle_switch.bind_property ("active", NightLight.Manager.get_instance (), "snoozed", GLib.BindingFlags.DEFAULT);
        settings.bind ("night-light-temperature", this, "temperature", GLib.SettingsBindFlags.GET);
        settings.bind ("night-light-schedule-automatic", this, "automatic_schedule", GLib.SettingsBindFlags.GET);

        temp_scale.value_changed.connect (() => {
            schedule_temp_change ();
        });
    }

    private uint temp_change_timeout_id = 0;
    private void schedule_temp_change () {
        if (temp_change_timeout_id != 0) {
            return;
        }

        temp_change_timeout_id = Timeout.add (TEMP_CHANGE_DELAY_MS, () => {
            settings.set_uint ("night-light-temperature", (uint)temp_scale.get_value ());
            temp_change_timeout_id = 0;
            return false;
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
