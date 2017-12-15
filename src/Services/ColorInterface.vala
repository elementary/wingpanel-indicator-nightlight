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
public interface NightLight.ColorInterface : Object {
    public abstract bool disabled_until_tomorrow { get; set; }
}

public class NightLight.Manager : Object {
    public signal void snooze_changed (bool value);

    private NightLight.ColorInterface adapter;

    public bool snoozed {
        get {
            return adapter.disabled_until_tomorrow;
        } set {
            adapter.disabled_until_tomorrow = value;
            snooze_changed (value);
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
        try {
            adapter = Bus.get_proxy_sync (BusType.SESSION, "org.gnome.SettingsDaemon.Color", "/org/gnome/SettingsDaemon/Color", DBusProxyFlags.NONE);
        } catch (Error e) {
            warning ("Could not connect to color settings: %s", e.message);
        }
    }

    public void toggle_snooze () {
        snoozed = !snoozed;
    }
}