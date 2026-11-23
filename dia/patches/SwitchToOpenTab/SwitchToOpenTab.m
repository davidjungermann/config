#import "StdPatch/StdPatch.h"
#import <objc/runtime.h>

// Return on a suggestion Dia marks "Hold ⌘ to switch" switches to that open tab.
// ⌘-Return there opens a new copy instead. Dia reads ⌘ from the event and from +[NSEvent modifierFlags],
// so both are flipped while the Return is handled.

extern DPPatch DPSwitchToOpenTab;

static NSInteger gFlip;  // 0: leave alone, 1: add ⌘, -1: remove ⌘.

static NSEventModifierFlags DPEvent_classModifierFlags(id self, SEL _cmd) {
    NSEventModifierFlags flags = DPCallOriginal(DPEvent_classModifierFlags, self);
    if (gFlip > 0) return flags | NSEventModifierFlagCommand;
    if (gFlip < 0) return flags & ~NSEventModifierFlagCommand;
    return flags;
}

static NSString *DPTextOf(NSView *view) {
    if ([view isKindOfClass:NSTextField.class]) return ((NSTextField *)view).stringValue;
    if ([view isKindOfClass:NSTextView.class]) return ((NSTextView *)view).string;
    id label = view.accessibilityLabel ?: view.accessibilityValue;
    if ([label isKindOfClass:NSString.class]) return label;
    for (CALayer *layer in view.layer.sublayers)
        if ([layer isKindOfClass:CATextLayer.class]) {
            id s = ((CATextLayer *)layer).string;
            return [s isKindOfClass:NSAttributedString.class] ? [s string] : s;
        }
    return nil;
}

static BOOL DPVisible(NSView *view) {
    for (NSView *v = view; v; v = v.superview)
        if (v.hidden || v.alphaValue < 0.05) return NO;
    return NSWidth(view.frame) > 0 && NSHeight(view.frame) > 0;
}

static NSString *const DPNewCopyHint = @"for a new copy";

static BOOL DPShowsSwitchHint(NSView *root) {
    return DPFindView(root, ^BOOL(NSView *view) {
        NSString *text = DPTextOf(view);
        return [text containsString:@"⌘"] && ([text.lowercaseString containsString:@"switch"] || [text containsString:DPNewCopyHint]) && DPVisible(view);
    }) != nil;
}

// Dia's hint says "Hold ⌘ to switch"; with this on, Return switches, so ⌘ now means a new copy.
static NSRange DPSwitchRange(NSString *text) {
    if (!DPSwitchToOpenTab.on || ![text containsString:@"⌘"]) return NSMakeRange(NSNotFound, 0);
    return [text rangeOfString:@"to switch"];
}

static void DPField_setStringValue(NSTextField *self, SEL _cmd, NSString *value) {
    NSRange r = [value isKindOfClass:NSString.class] ? DPSwitchRange(value) : NSMakeRange(NSNotFound, 0);
    if (r.location != NSNotFound) value = [value stringByReplacingCharactersInRange:r withString:DPNewCopyHint];
    DPCallOriginal(DPField_setStringValue, self, value);
}

static void DPField_setAttributedStringValue(NSTextField *self, SEL _cmd, NSAttributedString *value) {
    NSRange r = [value isKindOfClass:NSAttributedString.class] ? DPSwitchRange(value.string) : NSMakeRange(NSNotFound, 0);
    if (r.location != NSNotFound) {
        NSMutableAttributedString *copy = [value mutableCopy];
        [copy replaceCharactersInRange:r withString:DPNewCopyHint];
        value = copy;
    }
    DPCallOriginal(DPField_setAttributedStringValue, self, value);
}

// The highlighted row, when Dia's table tracks one; else the whole list, where only the highlighted row shows the hint.
static NSView *DPHighlighted(NSView *suggestions) {
    NSTableView *table = (NSTableView *)DPFindView(suggestions, ^BOOL(NSView *view) { return [view isKindOfClass:NSTableView.class]; });
    if (table && table.selectedRow >= 0) return [table rowViewAtRow:table.selectedRow makeIfNecessary:NO] ?: suggestions;
    return suggestions;
}

static BOOL DPOnOpenTabSuggestion(NSEvent *event) {
    if (![NSStringFromClass([event.window.firstResponder class]) hasPrefix:@"_TtCC15BoostCommandBar"]) return NO;
    for (NSView *suggestions in DPFindViews(DPDiaCommandBarSuggestions))
        if (suggestions.window == event.window && DPVisible(suggestions) && DPShowsSwitchHint(DPHighlighted(suggestions))) return YES;
    return NO;
}

static NSEvent *DPSwitchKey(NSEvent *event) {
    if (!DPSwitchToOpenTab.on || gFlip || (event.keyCode != 36 && event.keyCode != 76) || event.isARepeat) return event;
    NSEventModifierFlags mods = event.modifierFlags & (NSEventModifierFlagCommand | NSEventModifierFlagControl | NSEventModifierFlagOption | NSEventModifierFlagShift);
    if (mods != 0 && mods != NSEventModifierFlagCommand) return event;
    if (!DPOnOpenTabSuggestion(event)) return event;
    BOOL add = mods == 0;
    NSEventModifierFlags flags = add ? event.modifierFlags | NSEventModifierFlagCommand : event.modifierFlags & ~NSEventModifierFlagCommand;
    NSEvent *flipped = [NSEvent keyEventWithType:event.type location:event.locationInWindow modifierFlags:flags timestamp:event.timestamp
                                    windowNumber:event.windowNumber context:nil characters:event.characters
                     charactersIgnoringModifiers:event.charactersIgnoringModifiers isARepeat:NO keyCode:event.keyCode];
    if (!flipped) return event;
    gFlip = add ? 1 : -1;
    dispatch_async(dispatch_get_main_queue(), ^{ gFlip = 0; });
    return flipped;
}

static void DPInstallSwitchToOpenTab(void) {
    DPHookClass(object_getClass(NSEvent.class), @selector(modifierFlags), (IMP)DPEvent_classModifierFlags);
    DPHookClass(NSTextField.class, @selector(setStringValue:), (IMP)DPField_setStringValue);
    DPHookClass(NSTextField.class, @selector(setAttributedStringValue:), (IMP)DPField_setAttributedStringValue);
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^NSEvent *(NSEvent *event) { return DPSwitchKey(event); }];
}

DP_PATCH(DPSwitchToOpenTab) {
    .key = @"switchToOpenTab",
    .order = 285,
    .title = @"Switch to Open Tabs",
    .detail = @"Return on a suggestion for a tab you already have open switches to it instead of opening a copy. Hold ⌘ to open a copy instead.",
    .symbol = @"arrow.right.square.fill arrow.right.square",
    .tint = @"systemOrangeColor",
    .section = @"Command Bar",
    .classes = DPClasses(DPDiaCommandBarSuggestions),
    .install = DPInstallSwitchToOpenTab,
};
