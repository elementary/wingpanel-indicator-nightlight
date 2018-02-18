/*
 * Copyright (c) 2011-2015 Wingpanel Developers (http://launchpad.net/wingpanel)
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
 * Boston, MA 02110-1301 USA.
 */

public class NightLight.Widgets.Switch : Wingpanel.Widgets.Container {
    public new signal void switched ();

    private Gtk.Label button_label;
    private Gtk.Label small_label;
    private Gtk.Switch button_switch;
    private Gtk.Revealer subtitle_revealer;

    private const string SWITCH_CSS = """
        .compact-switch-labels label {
            padding-bottom: 0;
            padding-top: 0;
        }
    """;

    public bool active {
        get {
            return button_switch.active;
        } set {
            button_switch.active = value;
            subtitle_revealer.reveal_child = value;
            switched ();
        }
    }

    public string secondary_label {
        set {
            small_label.label = "<small>%s</small>".printf (Markup.escape_text (value));
        }
    }

    public Switch (string primary_label, string secondary_label, bool active = false) {
        button_label = new Gtk.Label (primary_label);
        button_label.halign = Gtk.Align.START;
        button_label.valign = Gtk.Align.END;
        button_label.margin_start = 6;
        button_label.margin_end = 6;
        button_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

        small_label = new Gtk.Label ("<small>%s</small>".printf (Markup.escape_text (secondary_label)));
        small_label.use_markup = true;
        small_label.halign = Gtk.Align.START;
        small_label.margin_start = 6;
        small_label.margin_end = 6;
        small_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        button_switch = new Gtk.Switch ();
        button_switch.active = active;
        button_switch.halign = Gtk.Align.END;
        button_switch.hexpand = true;
        button_switch.margin = 3;
        button_switch.margin_end = 6;
        button_switch.valign = Gtk.Align.CENTER;

        subtitle_revealer = new Gtk.Revealer ();
        subtitle_revealer.valign = Gtk.Align.CENTER;
        subtitle_revealer.add (small_label);

        content_widget.attach (button_label, 0, 0, 1, 1);
        content_widget.attach (subtitle_revealer, 0, 1, 1, 1);
        content_widget.attach (button_switch, 1, 0, 1, 2);
        content_widget.get_style_context ().add_class ("compact-switch-labels");

        var provider = new Gtk.CssProvider ();
        try {
            provider.load_from_data (SWITCH_CSS, SWITCH_CSS.length);
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        } catch (Error e) {
            critical (e.message);
        }

        clicked.connect (() => {
            active = true;
            button_switch.activate ();
        });

        button_switch.bind_property ("active", this, "active", GLib.BindingFlags.DEFAULT);
    }

    public Gtk.Switch get_switch () {
        return button_switch;
    }
}
