/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2017-2023 elementary, Inc. (https://elementary.io)
 */

public class Nightlight.Widgets.PopoverWidget : Gtk.Box {
    private Granite.SwitchModelButton toggle_switch;
    private Gtk.Box scale_box;
    private Gtk.Image image;
    private Gtk.Scale temp_scale;
    private Settings settings;
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
        temp_scale.add_css_class ("warmth");

        scale_box = new Gtk.Box (HORIZONTAL, 6) {
            margin_start = 6,
            margin_end = 12
        };
        scale_box.append (image);
        scale_box.append (temp_scale);

        var scale_sep = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            margin_top = 3,
            margin_bottom = 3
        };

        var settings_button = new PopoverMenuitem () {
            text = _("Night Light Settings…")
        };
        settings_button.clicked.connect (show_settings);

        orientation = VERTICAL;
        append (toggle_switch);
        append (toggle_sep);
        append (scale_box);
        append (scale_sep);
        append (settings_button);

        snoozed = NightLight.Manager.get_instance ().snoozed;

        toggle_switch.bind_property ("active", NightLight.Manager.get_instance (), "snoozed", GLib.BindingFlags.DEFAULT);

        settings = new GLib.Settings ("org.gnome.settings-daemon.plugins.color");
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
        var uri_launcher = new Gtk.UriLauncher ("settings://display/night-light");
        uri_launcher.launch.begin ((Gtk.Window) get_root (), null, (obj, res) => {
            try {
                uri_launcher.launch.end (res);
            } catch (Error e) {
                warning ("Failed to open display settings: %s", e.message);
            }
        });
    }

    private class PopoverMenuitem : Gtk.Button {
        public string text {
            set {
                child = new Granite.AccelLabel (value) {
                    action_name = this.action_name
                };

                update_property (Gtk.AccessibleProperty.LABEL, value, -1);
            }
        }

        class construct {
            set_css_name ("modelbutton");
        }

        construct {
            accessible_role = MENU_ITEM;

            clicked.connect (() => {
                var popover = (Gtk.Popover) get_ancestor (typeof (Gtk.Popover));
                if (popover != null) {
                    popover.popdown ();
                }
            });
        }
    }
}
