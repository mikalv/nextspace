/* All Rights reserved */

#include "ShellPrefs.h"

@implementation ShellPrefs

// <PrefsModule>
+ (NSString *)name
{
  return @"Shell";
}

- init
{
  self = [super init];

  [NSBundle loadNibNamed:@"Shell" owner:self];

  return self;
}

- (void)awakeFromNib
{
  [view retain];

  // Fill in Shell popup button with items from /etc/shells
  // Omit 'nologin' as shell.
  NSString  *shells = [NSString stringWithContentsOfFile:@"/etc/shells"];
  NSString  *lString;
  NSRange   lRange;
  NSUInteger index, stringLength = [shells length];

  [shellPopup removeAllItems];
  for (index=0; index < stringLength;)
    {
      lRange = [shells lineRangeForRange:NSMakeRange(index, 0)];
      lRange.length -= 1; // Do not include new line char
      lString = [shells substringFromRange:lRange];
      if ([lString rangeOfString:@"nologin"].location == NSNotFound)
        {
          [shellPopup addItemWithTitle:lString];
        }
      index = lRange.location + lRange.length + 1;
    }
  [shellPopup addItemWithTitle:@"Command"];
}

// <PrefsModule>
- (NSView *)view
{
  return view;
}

- (void)_updateControls:(Defaults *)defs
{
  NSString  *shellStr;
  NSInteger shellIndex;

  if (defs)
    {
      shellStr = [defs shell];
      shellIndex = [shellPopup indexOfItemWithTitle:shellStr];
  
      if ([shellStr isEqualToString:@"Command"] || shellIndex == -1)
        {
          [shellPopup selectItemWithTitle:@"Command"];
          [commandField setStringValue:shellStr];
        }
      else
        {
          [shellPopup selectItemWithTitle:shellStr];
          [loginShellBtn setState:[defs loginShell]];
        }
    }

  shellStr = [shellPopup titleOfSelectedItem];
  if ([shellStr isEqualToString:@"Command"])
    {
      [loginShellBtn setEnabled:NO];
      [loginShellBtn setState:0];
      
      [commandLabel setEnabled:YES];
      [commandField setEnabled:YES];
    }
  else
    {
      [loginShellBtn setEnabled:YES];
      
      [commandLabel setEnabled:NO];
      [commandField setEnabled:NO];
      [commandField setStringValue:@""];
    }
}
  
- (void)showWindow
{
  [self _updateControls:[[Preferences shared] mainWindowLivePreferences]];
}

// Controls actions

// Write values to UserDefaults
- (void)setDefault:(id)sender
{
  Defaults *defs = [[Preferences shared] mainWindowPreferences];
  NSString *shellStr = [shellPopup titleOfSelectedItem];

  if ([shellStr isEqualToString:@"Command"])
    {
      [defs setShell:[commandField stringValue]];
    }
  else
    {
      [defs setShell:shellStr];
      [defs setLoginShell:[loginShellBtn state]];
    }  
  [defs synchronize];
}
// Reset onscreen controls to values stored in UserDefaults
- (void)showDefault:(id)sender
{
  [self _updateControls:[[Preferences shared] mainWindowPreferences]];
}

- (void)setWindow:(id)sender
{
  // Modify live preferences through notification
}

- (BOOL)       control:(NSControl *)control
  textShouldEndEditing:(NSText *)fieldEditor
{
  return YES;
}

- (void)setShell:(id)sender
{
  [self _updateControls:nil];
}

@end
