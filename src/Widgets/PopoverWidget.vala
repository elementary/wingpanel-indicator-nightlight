/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2017-2023 elementary, Inc. (https://elementary.io)
 */

public class Nightlight.Widgets.PopoverWidget : Gtk.Box {
    public unowned Nightlight.Indicator indicator { get; construct set; }
    public unowned Settings settings { get; construct set; }

    private Granite.SwitchModelButton toggle_switch;
    private Gtk.Box scale_box;
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
            scale_box.sensitive = !value;
            toggle_switch.active = value;

            if (value) {
                image.icon_name = "indicator-night-light-disabled-symbolic";
            } else {
                image.icon_name = "indicator-night-light-symbolic";
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
        toggle_switch = new Granite.SwitchModelButton (_("Snooze Night Light"));

        var toggle_sep = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            margin_top = 3,
            margin_bottom = 3
        };

        image = new Gtk.Image () {
            pixel_size = 48
        };

        temp_scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 1500, 6000, 10) {
            draw_value = false,
            has_origin = false,
            hexpand = true,
            inverted = true,
            width_request = 200
        };
        temp_scale.get_style_context ().add_class ("warmth");

        scale_box = new Gtk.Box (HORIZONTAL, 6) {
            margin_start = 6,
            margin_end = 12
        };
        scale_box.add (image);
        scale_box.add (temp_scale);

        var scale_sep = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            margin_top = 3,
            margin_bottom = 3
        };

        var settings_button = new Gtk.ModelButton () {
            text = _("Night Light Settings…")
        };
        settings_button.clicked.connect (show_settings);

        orientation = Gtk.Orientation.VERTICAL;
        add (toggle_switch);
        add (toggle_sep);
        add (scale_box);
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
            Gtk.show_uri_on_window (
                (Gtk.Window) get_toplevel (),
                "settings://display/night-light",
                Gtk.get_current_event_time ()
            );
        } catch (Error e) {
            warning ("Failed to open display settings: %s", e.message);
        }

        indicator.close ();
    }
}
