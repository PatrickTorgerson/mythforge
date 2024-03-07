const std = @import("std");
const Godot = @import("godot");
const Self = @This();

pub usingnamespace Godot.Control;
godot_object: *Godot.Control, // this makes Self a valid gdextension class

pub fn _enter_tree(self: *Self) void {
    if (Godot.Engine.getSingleton().is_editor_hint()) return;

    var normal_btn = Godot.Button.newButton();
    self.add_child(normal_btn, false, Godot.Node.INTERNAL_MODE_DISABLED);
    normal_btn.set_position(.{ 100, 20 }, false);
    normal_btn.set_size(.{ 100, 50 }, false);
    normal_btn.set_text("Press Me");

    var toggle_btn = Godot.CheckBox.newCheckBox();
    self.add_child(toggle_btn, false, Godot.Node.INTERNAL_MODE_DISABLED);
    toggle_btn.set_position(.{ 320, 20 }, false);
    toggle_btn.set_size(.{ 100, 50 }, false);
    toggle_btn.set_text("Toggle Me");

    Godot.connect(toggle_btn, "toggled", self, "onToggled");
    Godot.connect(normal_btn, "pressed", self, "onPressed");
}

pub fn _exit_tree(self: *Self) void {
    _ = self;
    Godot.Engine.releaseSingleton();
}

pub fn _notification(self: *Self, what: i32) void {
    if (what == Godot.Node.NOTIFICATION_WM_CLOSE_REQUEST) {
        self.get_tree().quit(0);
    }
}

pub fn onPressed(self: *Self) void {
    _ = self;
    std.debug.print("onPressed \n", .{});
}

pub fn onToggled(self: *Self, toggled_on: bool) void {
    _ = self;
    std.debug.print("onToggled {any}\n", .{toggled_on});
}
