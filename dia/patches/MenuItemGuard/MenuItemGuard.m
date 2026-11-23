#import "StdPatch/StdPatch.h"

// Dia sometimes adds a menu item that is still in another menu; AppKit asserts and Dia aborts.
// Move the item out of its old menu first, as Dia evidently means to.

extern DPPatch DPMenuItemGuard;

static void DPGuard_insertItem(NSMenu *self, SEL _cmd, NSMenuItem *item, NSInteger index) {
    NSMenu *old = DPMenuItemGuard.on && [item isKindOfClass:NSMenuItem.class] ? item.menu : nil;
    if (old && old != self) {
        [old removeItem:item];
        index = MIN(MAX(index, 0), self.numberOfItems);
    }
    DPCallOriginal(DPGuard_insertItem, self, item, index);
}

static void DPInstallMenuItemGuard(void) {
    DPHookClass(NSMenu.class, @selector(insertItem:atIndex:), (IMP)DPGuard_insertItem);
}

DP_PATCH(DPMenuItemGuard) {
    .key = @"menuItemGuard",
    .defaultOn = YES,
    .order = 286,
    .title = @"Fix Menu Crash",
    .detail = @"Stops Dia quitting when it adds a menu item that is still in another menu: the item moves to the new menu instead.",
    .symbol = @"menubar.rectangle checkmark.shield",
    .tint = @"systemBrownColor",
    .section = @"Window",
    .install = DPInstallMenuItemGuard,
};
