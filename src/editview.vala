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
        public signal void scroll_to_iter(Gtk.TextIter iter, double margin, bool use_align, double xalign, double yalign);

        public new Gtk.SourceLanguage language = null;
        public Gtk.TextTag search_tag;

        public Buffer() {
            this.make_tags();
        }

        public void make_tags() {
            this.search_tag = this.create_tag("search");
            this.search_tag.foreground = "#DDDDDD";
            this.search_tag.background = "#4E9A06";
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

        public void search(string text, bool force_next, bool backward) {
            Gtk.TextIter start, end, cursor;
            this.get_bounds(out start, out end);
            this.remove_tag(this.search_tag, start, end);

            Gtk.TextMark cursor_mark = this.get_insert();
            this.get_iter_at_mark(out cursor, cursor_mark);

            if (text != "") {
                this.search_and_mark(text, start);
                this.select_text(text, cursor, force_next, backward);
            }
        }

        public void search_and_mark(string text, Gtk.TextIter start) {
            Gtk.TextIter end, match_start, match_end;
            this.get_end_iter(out end);

            bool found = start.forward_search(text, Gtk.TextSearchFlags.VISIBLE_ONLY, out match_start, out match_end, null);
            if (found) {
                this.apply_tag(this.search_tag, match_start, match_end);
                this.search_and_mark(text, match_end);  // Reboot the search from the last iter of the current search
            }
        }

        public void select_text(string text, Gtk.TextIter search_start, bool force_next, bool backward) {
            Gtk.TextIter start, end, match_start, match_end, _start, _end;
            this.get_bounds(out start, out end);

            bool found;
            if (!backward) {
                found = search_start.forward_search(text, Gtk.TextSearchFlags.VISIBLE_ONLY, out match_start, out match_end, null);
            } else {
                found = search_start.backward_search(text, Gtk.TextSearchFlags.VISIBLE_ONLY, out match_start, out match_end, null);
            }
            
            if (found) {
                if (!force_next) {
                    this.select_range(match_start, match_end);
                } else {
                    if (this.get_selection_bounds(out _start, out _end)) {
                        if (match_start.get_offset() == _start.get_offset() && match_end.get_offset() == _end.get_offset()) {
                            if (!backward) {
                                this.select_text(text, _end, true, false);
                            } else {
                                this.select_text(text, _start, true, true);
                            }
                            return;
                        }

                        this.select_range(match_end, match_start);
                    }

                    this.scroll_to_iter(match_end, 0.1, true, 1.0, 1.0);
                }
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

            this.buffer = new Noxer.Buffer();
            this.buffer.modified_changed.connect(this.modified_changed_cb);
            this.buffer.scroll_to_iter.connect(this.scroll_to_iter_cb);
            this.set_buffer(this.buffer);

            this.preview_map = new Gtk.SourceMap();
            this.preview_map.set_view(this);

            this.reload_settings();
        }

        private void modified_changed_cb(Gtk.TextBuffer buffer) {
            this.modified_changed(buffer.get_modified());
        }

        private void scroll_to_iter_cb(Gtk.TextIter iter, double margin, bool align, double xalign, double yalign) {
            this.scroll_to_iter(iter, margin, align, xalign, yalign);
        }

        public void read_file(string file) {
            this.buffer.reset_from_file(file);
        }

        public void reload_settings() {
            this.set_show_line_numbers(this.settings.show_line_numbers);
            this.set_insert_spaces_instead_of_tabs(this.settings.use_spaces);
            this.set_tab_width(this.settings.tab_width);
            this.set_smart_backspace(this.settings.smart_backspace);
            this.set_auto_indent(this.settings.auto_indent);
            this.set_indent_on_tab(this.settings.indent_on_tab);
            this.override_font(Pango.FontDescription.from_string(this.settings.font_family));
        }
    }

    public class SearchBar: Gtk.Box {

        public signal void search(string text, bool force_next, bool backward);

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
            this.entry.changed.connect(() => { this.search(this.entry.get_text(), false, false); });
            this.entry.activate.connect(() => { this.search(this.entry.get_text(), true, false); });
            this.pack_start(this.entry, false, false, 0);

            this.prev_button = new Gtk.Button.from_icon_name("go-up-symbolic", Gtk.IconSize.BUTTON);
            this.prev_button.clicked.connect(() => { this.search(this.entry.get_text(), true, true); });
            this.pack_start(this.prev_button, false, false, 0);

            this.next_button = new Gtk.Button.from_icon_name("go-down-symbolic", Gtk.IconSize.BUTTON);
            this.next_button.clicked.connect(() => { this.search(this.entry.get_text(), true, false); });
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
            this.searchbar.search.connect(this.search_cb);
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

        private void search_cb(Noxer.SearchBar bar, string text, bool force_next, bool backward) {
            this.view.buffer.search(text, force_next, backward);
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