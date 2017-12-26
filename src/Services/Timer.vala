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

/**
 * This class controls the visibility of the indicator so that it only shows during the scheduled time
 *
 * It also takes care of disabling the snooze after the schedule is over, to allow it to restart on the
 * next cycle.
 *
 * Todo:
 *    - set status with sunrise / sunset as well
 */
public class NightLight.Timer : Object {
    private const uint TIMEOUT = 300000; // 5 minutes
    private static NightLight.Timer? instance = null;

    /**
     * This is the property that describes whether to show or not the indicator
     */
    public bool status { get; set; }

    /**
     * Settings cache of night-light-schedule-from. Do not edit
     */
    public double start {
        get {
            return _start;
        } set {
            _start = value;
            tick ();
        }
    }

    /**
     * Settings cache of night-light-schedule-to. Do not edit
     */
    public double end {
        get {
            return _end;
        } set {
            _end = value;
            tick ();
        }
    }

    /**
     * Settings cache of night-light-enabled". Do not edit
     */
    public bool nightlight_enabled {
        get {
            return _nightlight_enabled;
        } set {
            _nightlight_enabled = value;

            if (value && function_id == null) {
                function_id = Timeout.add (TIMEOUT, tick);
            }

            tick ();
        }
    }

    private double _start;
    private double _end;
    private bool _nightlight_enabled;
    private uint? function_id = null;

    public static NightLight.Timer get_instance () {
        if (instance == null) {
            instance = new NightLight.Timer ();
        }

        return instance;
    }

    private Timer () {}

    GLib.Settings settings;

    construct {
        settings = new GLib.Settings ("org.gnome.settings-daemon.plugins.color");

        settings.bind ("night-light-schedule-from", this, "start", GLib.SettingsBindFlags.GET);
        settings.bind ("night-light-schedule-to", this, "end", GLib.SettingsBindFlags.GET);
        settings.bind ("night-light-enabled", this, "nightlight_enabled", GLib.SettingsBindFlags.GET);
    }

    private bool tick () {
        if (!nightlight_enabled) {
            if (function_id != null) {
                Source.remove (function_id);
                function_id = null;
            }

            status = (false);
            return false;
        }

        var local_time = new GLib.DateTime.now_local ();
        double time = (double) local_time.get_hour () + (double) local_time.get_minute () / 60.0;

        // To calculate with the transitions
        var start = this.start - 1;
        var end = this.end + 1;

        if (start < end) {
            status = (time >= start && time <= end);
        } else {
            status = (time >= start || time <= end);
        }

        return true;
    }
}