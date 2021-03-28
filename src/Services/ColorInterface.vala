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

[DBus (name="org.gnome.SettingsDaemon.Color")]
public interface NightLight.ColorInterface : GLib.DBusProxy {
    public abstract bool disabled_until_tomorrow { get; set; }
    public abstract bool night_light_active { get; }
}

public class NightLight.Manager : Object {
    private NightLight.ColorInterface interface;

    private bool _snoozed = false;
    public bool snoozed {
        get {
            return _snoozed;
        } set {
            if (interface == null) {
                return;
            }

            if (value != _snoozed) {
                _snoozed = value;
                interface.disabled_until_tomorrow = value;
            }
        }
    }

    public bool active {
        get {
            if (interface == null) {
                return false;
            }

            return interface.night_light_active;
        }
    }

    static NightLight.Manager? instance = null;
    public static Manager get_instance () {
        if (instance == null) {
            instance = new Manager ();
        }

        return instance;
    }

    private Manager () {}

    construct {
        init_interface.begin ();
    }

    private async void init_interface () {
        try {
            interface = yield Bus.get_proxy (BusType.SESSION, "org.gnome.SettingsDaemon.Color", "/org/gnome/SettingsDaemon/Color", DBusProxyFlags.NONE);
            _snoozed = interface.disabled_until_tomorrow;
            notify_property ("active");
            notify_property ("snoozed");

            interface.g_properties_changed.connect ((changed, invalid) => {
                var snooze = changed.lookup_value ("DisabledUntilTomorrow", new VariantType ("b"));

                if (snooze != null && snooze.get_boolean () != _snoozed) {
                    _snoozed = snooze.get_boolean ();
                    notify_property ("snoozed");
                }

                var _active = changed.lookup_value ("NightLightActive", new VariantType ("b"));

                if (_active != null) {
                    notify_property ("active");
                }
            });
        } catch (Error e) {
            warning ("Could not connect to color settings: %s", e.message);
        }
    }

    public void toggle_snooze () {
        snoozed = !snoozed;
    }
}
