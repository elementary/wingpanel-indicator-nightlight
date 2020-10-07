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

    private NightLight.Widgets.Switch night_light_switch;
    private NightLight.Widgets.Switch dark_style_switch;
    private Gtk.Grid scale_grid;
    private Gtk.Image image;
    private Gtk.Scale temp_scale;

    public bool automatic_schedule {
        set {
            if (value) {
                night_light_switch.secondary_label = _("Disabled until sunrise");
            } else {
                night_light_switch.secondary_label = _("Disabled until tomorrow");
            }
        }
    }

    public bool snoozed {
        set {
            scale_grid.sensitive = !value;
            night_light_switch.active = value;

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

        night_light_switch = new NightLight.Widgets.Switch (_("Snooze Night Light"), _("Disabled until tomorrow"));
        dark_style_switch = new NightLight.Widgets.Switch (_("Snooze Dark Style"), _("Disabled until tomorrow"));

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

        var night_light_settings_button = new Gtk.ModelButton ();
        night_light_settings_button.text = _("Night Light Settings…");
        night_light_settings_button.clicked.connect (show_night_light_settings);

        var dark_style_settings_button = new Gtk.ModelButton ();
        dark_style_settings_button.text = _("Dark Style Settings…");
        dark_style_settings_button.clicked.connect (show_dark_style_settings);

        add (night_light_switch);
        add (scale_grid);
        add (new Wingpanel.Widgets.Separator ());
        add (dark_style_switch);
        add (new Wingpanel.Widgets.Separator ());
        add (night_light_settings_button);
        add (dark_style_settings_button);


        snoozed = NightLight.Manager.get_instance ().snoozed;

        night_light_switch.get_switch ().bind_property ("active", NightLight.Manager.get_instance (), "snoozed", GLib.BindingFlags.DEFAULT);
        settings.bind ("night-light-temperature", this, "temperature", GLib.SettingsBindFlags.GET);
        settings.bind ("night-light-schedule-automatic", this, "automatic_schedule", GLib.SettingsBindFlags.GET);

        temp_scale.value_changed.connect (() => {
            settings.set_uint ("night-light-temperature", (uint) temp_scale.get_value ());
        });

        var dark_style_settings = new GLib.Settings ("io.elementary.settings-daemon.prefers-color-scheme");
        dark_style_settings.bind ("snoozed", dark_style_switch.get_switch (), "active", GLib.SettingsBindFlags.DEFAULT);
    }

    private void show_night_light_settings () {
        try {
            AppInfo.launch_default_for_uri ("settings://display/night-light", null);
        } catch (Error e) {
            warning ("Failed to open display settings: %s", e.message);
        }

        indicator.close ();
    }

    private void show_dark_style_settings () {
        try {
            AppInfo.launch_default_for_uri ("settings://desktop/appearance", null);
        } catch (Error e) {
            warning ("Failed to open desktop settings: %s", e.message);
        }

        indicator.close ();
    }
}
