'user strict';

import St from 'gi://St';

import { BorderSkin } from './borderSkin.js';

const BTN_COUNT = 3;

export const Hook = class {
  _windowSettingFromClass(wm) {
    this._button_count = BTN_COUNT;

    if (this.extension.window_list) {
      let blacklisted = this.extension.window_list.find((i) =>
        i['wm_class'].startsWith(wm)
      );
      this._customWindowSetting = blacklisted;
      if (blacklisted) {
        if (blacklisted['exclude-window']) {
          return true;
        }
      }
    }
    return false;
  }

  attach(window) {
    this._window = window;
    this._window._hook = this;

    // exclude?
    this._wm = window.get_wm_class_instance();
    if (this._wm == '') return;

    if (this._windowSettingFromClass(this._wm)) {
      return;
    }

    this._attached = true;
    this._button_icons = [];

    let border = new St.Widget({ name: 'cwc-border' });
    this._window._parent.add_child(border);
    this._border = border;
    this._border.set_reactive(false);

    this._borderSkin = new BorderSkin();
    this._borderSkin.extension = this.extension;
    this._border.add_child(this._borderSkin);

    global.display.connectObject(
      'notify::focus-window',
      this._onFocusWindow.bind(this),
      'in-fullscreen-changed',
      this._onFullScreen.bind(this),
      this
    );

    window._parent.connectObject('destroy', this.release.bind(this), this);

    this._deferredShow = true;

    this.extension._hiTimer.runOnce(() => {
      if (!window._parent.get_texture()) return;
      window._parent.get_texture().connect('size-changed', () => {
        this._redisplay();
        // do twice.. for wayland
        if (this.extension._hiTimer) {
          this.extension._hiTimer.runOnce(() => {
            this._deferredShow = false;
            this._redisplay();
          }, 10);
        }
      });
    }, 50);

    this._redisplay();

    // ubuntu (gnome 42) .. libadwait seems slow
    if (this.extension._hiTimer) {
      this.extension._hiTimer.runOnce(() => {
        this._deferredShow = false;
        this._redisplay();
      }, 200);
    }
  }

  release() {
    this.extension.focused = null;
    if (!this._attached) {
      return;
    }
    this._attached = false;
    this._window._parent.remove_child(this._border);
    this._window._parent.disconnectObject(this);
    this._window.disconnectObject(this);
  }

  update(force) {
    if (this._attached && this._windowSettingFromClass(this._wm)) {
      this.release();
      return;
    }
    if (!this._attached && !this._windowSettingFromClass(this._wm)) {
      this.attach(this._window);
      return;
    }
  }

  setActive(t) {
    this._border.visible = t;
  }

  _redisplay() {
    let buffer_rect = this._window.get_buffer_rect();
    let frame_rect = this._window.get_frame_rect();

    // console.log(`${this._wm}`);

    let x = frame_rect.x - buffer_rect.x;
    let y = frame_rect.y - buffer_rect.y;

    let focused = this._window.has_focus();

    let bg = focused
      ? this.extension.border_color || [1, 1, 1, 1]
      : this.extension.unfocused_border_color || [1, 1, 1, 1];
    let io = focused
      ? this.extension.inner_outline_color || [0, 0, 0, 1]
      : this.extension.unfocused_inner_outline_color || [0, 0, 0, 1];
    let oo = focused
      ? this.extension.outer_outline_color || [0, 0, 0, 1]
      : this.extension.unfocused_outer_outline_color || [0, 0, 0, 1];
    const THICKNESS = 16;

    this._borderSkin.settings.border_radius = this.extension.border_radius || 0;
    this._borderSkin.settings.color = bg;
    this._borderSkin.settings.inner_outline_color = io;
    this._borderSkin.settings.outer_outline_color = oo;
    this._borderSkin.settings.inner_thickness =
      THICKNESS * this.extension.inner_border_thickness;
    this._borderSkin.settings.outer_thickness =
      THICKNESS * this.extension.outer_border_thickness;

    let thickness =
      this._borderSkin.settings.inner_thickness +
      this._borderSkin.settings.outer_thickness;
    let thickness_padded = thickness + 2;
    if (this._window.xwindow > 0) {
      thickness_padded += 4;
    }

    this._borderSkin.settings.thickness = thickness;
    this._border.set_position(x - thickness_padded, y - thickness_padded);
    this._border.set_size(
      frame_rect.width + thickness_padded * 2,
      frame_rect.height + thickness_padded * 2
    );

    this._borderSkin.set_size(
      frame_rect.width + thickness_padded * 2,
      frame_rect.height + thickness_padded * 2
    );

    if (this._window.is_fullscreen()) {
      this._border.visible = false;
    } else {
      this._border.visible = true;
    }

    this._borderSkin.redraw();
  }

  _onFocusWindow(w, e) {
    this._redisplay();
  }

  _onFullScreen() {
    this._redisplay();
  }
};
