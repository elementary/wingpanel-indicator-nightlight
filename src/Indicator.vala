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

public class Nightlight.Indicator : Wingpanel.Indicator {
    private Gtk.Spinner? indicator_icon = null;
    private Gtk.StyleContext style_context;
    private Nightlight.Widgets.PopoverWidget? popover_widget = null;

    private NightLight.Manager nightlight_manager;
    private NightLight.SchemeManager scheme_manager;

    public bool nightlight_state {
        set {
            if (value) {
                style_context.remove_class ("disabled");
            } else {
                style_context.add_class ("disabled");
            }
        }
    }

    public Indicator () {
        Object (code_name: "wingpanel-indicator-nightlight");

        nightlight_manager = NightLight.Manager.get_instance ();
        scheme_manager = NightLight.SchemeManager.get_instance ();
    }

    public override Gtk.Widget get_display_widget () {
        if (indicator_icon == null) {
            weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_default ();
            default_theme.add_resource_path ("/io/elementary/wingpanel/nightlight");

            indicator_icon = new Gtk.Spinner ();

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("io/elementary/wingpanel/nightlight/indicator.css");

            style_context = indicator_icon.get_style_context ();
            style_context.add_class ("night-light-icon");
            style_context.add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            indicator_icon.button_press_event.connect ((e) => {
                if (e.button == Gdk.BUTTON_MIDDLE) {
                    NightLight.Manager.get_instance ().toggle_snooze ();
                    return Gdk.EVENT_STOP;
                }

                return Gdk.EVENT_PROPAGATE;
            });

            nightlight_manager.snooze_changed.connect ((value) => {
                nightlight_state = !value;
                popover_widget.nightlight_snoozed = value;
            });

            nightlight_manager.active_changed.connect (update_visible);

            nightlight_state = !nightlight_manager.snoozed;

            scheme_manager.active_changed.connect (update_visible);

            update_visible ();
        }

        return indicator_icon;
    }

    public override Gtk.Widget? get_widget () {
        if (popover_widget == null) {
            var settings = new GLib.Settings ("org.gnome.settings-daemon.plugins.color");
            popover_widget = new Nightlight.Widgets.PopoverWidget (this, settings);
        }

        return popover_widget;
    }

    private void update_visible () {
        visible = nightlight_manager.active || scheme_manager.active;
    }

    public override void opened () {}

    public override void closed () {}
}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating Nightlight Indicator");

    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        debug ("Wingpanel is not in session, not loading nightlight");
        return null;
    }

    var interface_settings_schema = SettingsSchemaSource.get_default ().lookup ("org.gnome.settings-daemon.plugins.color", true);
    if (interface_settings_schema == null || !interface_settings_schema.has_key ("night-light-enabled")) {
        debug ("No night-light schema found");
        return null;
    }

    var indicator = new Nightlight.Indicator ();
    return indicator;
}
