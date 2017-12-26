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
    private const string ENABLED_ICON_NAME = "night-light-symbolic";
    private const string DISABLED_ICON_NAME = "night-light-disabled-symbolic";

    private Wingpanel.Widgets.OverlayIcon? indicator_icon = null;
    private Nightlight.Widgets.PopoverWidget? popover_widget = null;

    private Settings settings;

    public bool nightlight_state {
        set {
            indicator_icon.set_main_icon_name (value ? ENABLED_ICON_NAME : DISABLED_ICON_NAME);
        }
    }

    public Indicator (Wingpanel.IndicatorManager.ServerType server_type) {
        Object (code_name: "wingpanel-indicator-nightlight",
                display_name: _("Nightlight"),
                description: _("The Nightlight indicator"));

        settings = new GLib.Settings ("org.gnome.settings-daemon.plugins.color");
    }

    public override Gtk.Widget get_display_widget () {
        if (indicator_icon == null) {
            indicator_icon = new Wingpanel.Widgets.OverlayIcon (ENABLED_ICON_NAME);
            indicator_icon.button_press_event.connect ((e) => {
                if (e.button == Gdk.BUTTON_MIDDLE) {
                    NightLight.Manager.get_instance ().toggle_snooze ();
                    return Gdk.EVENT_STOP;
                }

                return Gdk.EVENT_PROPAGATE;
            });

            NightLight.Manager.get_instance ().snooze_changed.connect ((value) => {
                nightlight_state = !value;
                popover_widget.snoozed = value;
            });

            var timer = NightLight.Timer.get_instance ();
            timer.bind_property ("status", this, "visible", GLib.BindingFlags.SYNC_CREATE);

            nightlight_state = !NightLight.Manager.get_instance ().snoozed;
        }

        return indicator_icon;
    }

    public override Gtk.Widget? get_widget () {
        if (popover_widget == null) {
            popover_widget = new Nightlight.Widgets.PopoverWidget (this, settings);
        }

        return popover_widget;
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

    var interface_settings_schema = SettingsSchemaSource.get_default ().lookup ("org.gnome.settings-daemon.plugins.color", false);
    if (interface_settings_schema == null || !interface_settings_schema.has_key ("night-light-enabled")) {
        debug ("No night-light schema found");
        return null;
    }

    var indicator = new Nightlight.Indicator (server_type);
    return indicator;
}
