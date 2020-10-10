/*
* Copyright 2020 elementary, Inc. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
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
*
* Authored by: Marius Meisenzahl <mariusmeisenzahl@gmail.com>
*/

[DBus (name="io.elementary.SettingsDaemon.PrefersColorScheme")]
public interface NightLight.PrefersColorSchemeInterface : Object {
    public abstract bool snoozed { get; set; }
}

public class NightLight.SchemeManager : Object {
    public signal void snooze_changed (bool value);

    private NightLight.PrefersColorSchemeInterface interface;

    public bool snoozed {
        get {
            return interface.snoozed;
        } set {
            interface.snoozed = value;
            snooze_changed (value);
        }
    }

    static NightLight.SchemeManager? instance = null;
    public static SchemeManager get_instance () {
        if (instance == null) {
            instance = new SchemeManager ();
        }

        return instance;
    }

    private SchemeManager () {}

    construct {
        try {
            interface = Bus.get_proxy_sync (BusType.SESSION, "io.elementary.settings-daemon", "/io/elementary/settings_daemon", DBusProxyFlags.NONE);

            (interface as DBusProxy).g_properties_changed.connect ((changed, invalid) => {
                var snooze = changed.lookup_value ("snoozed", new VariantType ("b"));

                if (snooze != null) {
                    snoozed = snooze.get_boolean ();
                }
            });
        } catch (Error e) {
            warning ("Could not connect to prefers color scheme settings: %s", e.message);
        }
    }

    public void toggle_snooze () {
        snoozed = !snoozed;
    }
}
