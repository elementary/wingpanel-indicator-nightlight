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
    private Gtk.Switch button_switch;
    private Gtk.Revealer subtitle_revealer;

    public bool active {
        get {
            return button_switch.get_active ();
        } set {
            button_switch.set_active (value);
            subtitle_revealer.reveal_child = value;
            switched ();
        }
    }

    public Switch (string caption, string secondary, bool active = false) {
        button_label = create_label_for_caption (caption);
        button_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
        button_label.valign = Gtk.Align.END;

        var small_label = create_label_for_caption (secondary, true);
        small_label.valign = Gtk.Align.START;
        small_label.sensitive = false;

        button_switch = create_switch (active);
        button_switch.valign = Gtk.Align.CENTER;

        subtitle_revealer = new Gtk.Revealer ();
        subtitle_revealer.add (small_label);

        content_widget.attach (button_label, 0, 0, 1, 1);
        content_widget.attach (subtitle_revealer, 0, 1, 1, 1);
        content_widget.attach (button_switch, 1, 0, 1, 2);

        clicked.connect (() => {
            active = true;
            toggle_switch ();
        });

        button_switch.bind_property ("active", this, "active", GLib.BindingFlags.DEFAULT);
    }

    public Gtk.Switch get_switch () {
        return button_switch;
    }

    public void toggle_switch () {
        button_switch.activate ();
    }

    private Gtk.Label create_label_for_caption (string caption, bool small = false) {
        Gtk.Label label_widget;

        if (small) {
            label_widget = new Gtk.Label ("<small>%s</small>".printf (Markup.escape_text (caption)));
        } else {
            label_widget = new Gtk.Label (Markup.escape_text (caption));
        }

        label_widget.use_markup = true;
        label_widget.halign = Gtk.Align.START;
        label_widget.margin_start = 6;
        label_widget.margin_end = 10;

        return label_widget;
    }

    private Gtk.Switch create_switch (bool active) {
        var switch_widget = new Gtk.Switch ();
        switch_widget.active = active;
        switch_widget.halign = Gtk.Align.END;
        switch_widget.margin_end = 6;
        switch_widget.hexpand = true;

        return switch_widget;
    }
}