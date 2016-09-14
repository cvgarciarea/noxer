/*
Copyright (C) 2016, Cristian García <cristian99garcia@gmail.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

namespace Noxer {

    public class Buffer: Gtk.SourceBuffer {

        public signal void language_changed(string? language);

        public new Gtk.SourceLanguage language = null;

        public Buffer() {
        }

        public void reset_from_file(string file, bool set_text = true) {
            string text;

            try {
                GLib.FileUtils.get_contents(file, out text);
            } catch (GLib.FileError error) {
                print("error\n");
            }

            if (set_text) {
                this.set_text(text);
                this.begin_not_undoable_action();
                this.end_not_undoable_action();
            }

            this.set_language_from_file(file);
            this.set_modified(false);
        }

        private Gtk.SourceLanguage? get_language_from_file(string path) {
            GLib.File file = GLib.File.new_for_path(path);
            string? type;
            try {
                type = file.query_info("*", GLib.FileQueryInfoFlags.NONE).get_content_type();
                if ("x-" in type)
                    type = type.replace("x-", "");

                if ("text/" in type)
                    type = type.replace("text/", "");

                if (type == "shellscript")
                    type = "sh";
            } catch (GLib.Error error) {
                type = null;
            }

            Gtk.SourceLanguageManager language_manager = Gtk.SourceLanguageManager.get_default();
            Gtk.SourceLanguage? language = language_manager.guess_language(path, type);

            return language;
        }

        public string get_all_text() {
            Gtk.TextIter start, end;
            this.get_bounds(out start, out end);
            return this.get_text(start, end, false);
        }

        public void set_language_from_file(string path) {
            Gtk.SourceLanguage? language_from_file = this.get_language_from_file(path);

            if (this.language != null && language_from_file == null) {
                return;
            }

            this.language = language_from_file;

            if (this.language != null) {
                this.set_highlight_syntax(true);
                this.set_language(this.language);
                this.language_changed(this.language.get_id());
            } else {
                this.set_highlight_syntax(false);
                this.language_changed(Noxer.DEFAULT_LANGUAGE);
            }
        }
    }

    public class View: Gtk.SourceView {

        public signal void modified_changed(bool modified);
        
        public new Noxer.Buffer buffer;
        public Gtk.SourceMap preview_map;

        public Noxer.Settings settings;

        public View() {
            this.settings = Noxer.get_settings();
            
            this.set_show_line_numbers(this.settings.show_line_numbers);
            this.override_font(Pango.FontDescription.from_string(this.settings.font_family));

            this.buffer = new Noxer.Buffer();
            this.buffer.modified_changed.connect(this.modified_changed_cb);
            this.set_buffer(this.buffer);

            this.preview_map = new Gtk.SourceMap();
            this.preview_map.set_view(this);
        }

        private void modified_changed_cb(Gtk.TextBuffer buffer) {
            this.modified_changed(buffer.get_modified());
        }

        public void read_file(string file) {
            this.buffer.reset_from_file(file);
        }
    }

    public class SearchBar: Gtk.Box {

        public Gtk.SearchEntry entry;
        public Gtk.Button prev_button;
        public Gtk.Button next_button;

        public SearchBar() {
            this.set_orientation(Gtk.Orientation.HORIZONTAL);
            this.set_border_width(5);

            Gtk.StyleContext context = this.get_style_context();
            context.add_class("linked");

            this.entry = new Gtk.SearchEntry();
            this.entry.set_size_request(200, 1);
            this.pack_start(this.entry, false, false, 0);

            this.prev_button = new Gtk.Button.from_icon_name("go-up-symbolic", Gtk.IconSize.BUTTON);
            this.pack_start(this.prev_button, false, false, 0);

            this.next_button = new Gtk.Button.from_icon_name("go-down-symbolic", Gtk.IconSize.BUTTON);
            this.pack_start(this.next_button, false, false, 0);
        }
    }

    public class EditView: Noxer.BaseView {

        public string? file = null;

        public Gtk.Overlay searchbar_overlay;
        public Gtk.Revealer searchbar_revealer;
        public Noxer.SearchBar searchbar;
        public Gtk.Overlay map_overlay;
        public Gtk.Revealer map_revealer;

        public Noxer.Settings settings;

        public EditView() {
            this.type = Noxer.ViewType.NORMAL;
            this.settings = Noxer.get_settings();

            this.searchbar_overlay = new Gtk.Overlay();
            this.pack_start(this.searchbar_overlay, true, true, 0);

            this.searchbar_revealer = new Gtk.Revealer();
            this.searchbar_revealer.set_halign(Gtk.Align.END);
            this.searchbar_revealer.set_valign(Gtk.Align.START);
            this.searchbar_revealer.set_transition_type(Gtk.RevealerTransitionType.SLIDE_DOWN);
            this.searchbar_overlay.add_overlay(this.searchbar_revealer);

            this.searchbar = new Noxer.SearchBar();
            this.searchbar_revealer.add(this.searchbar);

            this.searchbar_revealer.set_reveal_child(false);

            this.map_overlay = new Gtk.Overlay();
            this.searchbar_overlay.add(this.map_overlay);

            this.remove(this.scroll);
            this.map_overlay.add(this.scroll);

            this.view = new Noxer.View();
            this.view.modified_changed.connect(this.modified_changed_cb);
            this.scroll.add(this.view);

            this.map_revealer = new Gtk.Revealer();
            this.map_revealer.set_halign(Gtk.Align.END);
            this.map_revealer.set_transition_type(Gtk.RevealerTransitionType.SLIDE_LEFT);
            this.map_revealer.add(this.view.preview_map);
            this.map_overlay.add_overlay(this.map_revealer);

            this.map_revealer.set_reveal_child(this.settings.show_map);
        }

        private void modified_changed_cb(Noxer.View view, bool modified) {
            this.tab.set_modified(modified);
        }

        public void set_file(string file) {
            this.file = file;
        }

        public void open(string? file = null) {
            if (file != null) {
                this.set_file(file);
            }

            GLib.File gfile = GLib.File.new_for_path(this.file);

            if (gfile.query_exists()) {
                this.view.read_file(file);
                this.get_tab().set_title(gfile.get_basename());
            }
        }

        public bool save(string? file = null) {
            if (file == null && this.file == null) {
                return false;
            } else if (file != null && this.file == null) {
                this.set_file(file);
            } else if (file == null && this.file != null) {
            } else if (file != null && this.file != null) {
                this.set_file(file);
            }

            string text = this.view.buffer.get_all_text();

            try {
                GLib.FileUtils.set_contents(this.file, text);
                this.view.buffer.reset_from_file(this.file, false);
                return true;
            } catch (GLib.FileError error) {
                return false;  // TODO: Mostrar alerta
            }
        }

        public bool get_modified() {
            return this.view.buffer.get_modified();
        }

        public void toggle_searchbar() {
            if (this.searchbar_revealer.get_reveal_child() && this.searchbar.entry.has_focus) {
                this.hide_searchbar();
            } else {
                this.show_searchbar();
            }
        }

        public void show_searchbar() {
            this.searchbar_revealer.set_reveal_child(true);
            this.searchbar.entry.grab_focus();
        }

        public void hide_searchbar() {
            this.searchbar.entry.set_text("");
            this.searchbar_revealer.set_reveal_child(false);
            this.view.grab_focus();
        }
    }
}