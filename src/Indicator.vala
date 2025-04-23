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
    private Nightlight.Widgets.PopoverWidget? popover_widget = null;

    public bool nightlight_state {
        set {
            if (value) {
                indicator_icon.remove_css_class ("disabled");
            } else {
                indicator_icon.add_css_class ("disabled");
            }
        }
    }

    public Indicator () {
        GLib.Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        GLib.Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");

        Object (code_name: Wingpanel.Indicator.NIGHT_LIGHT);
    }

    public override Gtk.Widget get_display_widget () {
        if (indicator_icon == null) {
            // Prevent a race that skips automatic resource loading
            // https://github.com/elementary/wingpanel-indicator-bluetooth/issues/203
            weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
            default_theme.add_resource_path ("/org/elementary/wingpanel/icons");

            indicator_icon = new Gtk.Spinner ();

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("io/elementary/wingpanel/nightlight/indicator.css");

            Gtk.StyleContext.add_provider_for_display (
                Gdk.Display.get_default (),
                provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );

            indicator_icon.add_css_class ("night-light-icon");

            var click_gesture = new Gtk.GestureClick () {
                button = Gdk.BUTTON_MIDDLE
            };
            click_gesture.pressed.connect (() => {
                NightLight.Manager.get_instance ().toggle_snooze ();
            });

            indicator_icon.add_controller (click_gesture);

            var nightlight_manager = NightLight.Manager.get_instance ();
            nightlight_manager.notify["snoozed"].connect (() => {
                var snoozed = nightlight_manager.snoozed;
                nightlight_state = !snoozed;
                if (popover_widget != null) {
                    popover_widget.snoozed = snoozed;
                }

                update_tooltip (snoozed);
            });

            nightlight_manager.notify["active"].connect (() => {
                visible = nightlight_manager.active;
            });

            nightlight_state = !nightlight_manager.snoozed;
            visible = nightlight_manager.active;
            update_tooltip (nightlight_manager.snoozed);
        }

        return indicator_icon;
    }

    public override Gtk.Widget? get_widget () {
        if (popover_widget == null) {
            popover_widget = new Nightlight.Widgets.PopoverWidget ();
        }

        return popover_widget;
    }

    public override void opened () {}

    public override void closed () {}

    private void update_tooltip (bool snoozed) {
        string primary_text = _("Night Light is on");
        string secondary_text = _("Middle-click to snooze");

        if (snoozed) {
            primary_text = _("Night Light is snoozed");
            secondary_text = _("Middle-click to enable");
        }

        indicator_icon.tooltip_markup = "%s\n%s".printf (
            primary_text,
            Granite.TOOLTIP_SECONDARY_TEXT_MARKUP.printf (secondary_text)
        );
    }
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
