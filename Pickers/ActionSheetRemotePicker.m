//
//Copyright (c) 2011, Tim Cinel
//All rights reserved.
//
//Redistribution and use in source and binary forms, with or without
//modification, are permitted provided that the following conditions are met:
//* Redistributions of source code must retain the above copyright
//notice, this list of conditions and the following disclaimer.
//* Redistributions in binary form must reproduce the above copyright
//notice, this list of conditions and the following disclaimer in the
//documentation and/or other materials provided with the distribution.
//* Neither the name of the <organization> nor the
//names of its contributors may be used to endorse or promote products
//derived from this software without specific prior written permission.
//
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//åLOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "ActionSheetRemotePicker.h"

@implementation ActionSheetRemotePicker
@synthesize onActionSheetDone = _onActionSheetDone;
@synthesize onActionSheetCancel = _onActionSheetCancel;

+ (id)showPickerWithTitle:(NSString *)title remotePicker:(UIPickerView *)remotePicker doneBlock:(ActionRemoteDoneBlock)doneBlock cancelBlock:(ActionRemoteCancelBlock)cancelBlockOrNil origin:(id)origin {
  ActionSheetRemotePicker * picker = [[ActionSheetRemotePicker alloc] initWithTitle:title remotePicker:(UIPickerView *)remotePicker doneBlock:doneBlock cancelBlock:cancelBlockOrNil origin:origin];
  [picker showActionSheetPicker];
  return picker;
}

- (id)initWithTitle:(NSString *)title remotePicker:(UIPickerView *)remotePicker doneBlock:(ActionRemoteDoneBlock)doneBlock cancelBlock:(ActionRemoteCancelBlock)cancelBlockOrNil origin:(id)origin {
  self = [self initWithTitle:title remotePicker:(UIPickerView *)remotePicker target:nil successAction:nil cancelAction:nil origin:origin];
  if (self) {
    self.onActionSheetDone = doneBlock;
    self.onActionSheetCancel = cancelBlockOrNil;
  }
  return self;
}

+ (id)showPickerWithTitle:(NSString *)title remotePicker:(UIPickerView *)remotePicker target:(id)target successAction:(SEL)successAction cancelAction:(SEL)cancelActionOrNil origin:(id)origin {
  ActionSheetRemotePicker *picker = [[[ActionSheetRemotePicker alloc] initWithTitle:title remotePicker:(UIPickerView *)remotePicker target:target successAction:successAction cancelAction:cancelActionOrNil origin:origin] autorelease];
  [picker showActionSheetPicker];
  return picker;
}

- (id)initWithTitle:(NSString *)title remotePicker:(UIPickerView *)remotePicker target:(id)target successAction:(SEL)successAction cancelAction:(SEL)cancelActionOrNil origin:(id)origin {
  self = [self initWithTarget:target successAction:successAction cancelAction:cancelActionOrNil origin:origin];
  if (self) {
    self.title = title;
    self.pickerView = remotePicker;
  }
  return self;
}

- (void)dealloc {  
  Block_release(_onActionSheetDone);
  Block_release(_onActionSheetCancel);
  
  [super dealloc];
}

- (UIView *)configuredPickerView {
  if (!self.pickerView)
    return nil;
  CGRect pickerFrame = CGRectMake(0, 40, self.viewSize.width, 216);
  self.pickerView.frame = pickerFrame;
  self.pickerView.hidden = NO;

  return self.pickerView;
}

- (void)notifyTarget:(id)target didSucceedWithAction:(SEL)successAction origin:(id)origin {    
  if (self.onActionSheetDone) {
    _onActionSheetDone(self, 0, nil);
    return;
  }
  else if (target && [target respondsToSelector:successAction]) {
    return;
  }
  NSLog(@"Invalid target/action ( %s / %s ) combination used for ActionSheetPicker", object_getClassName(target), (char *)successAction);
}

- (void)notifyTarget:(id)target didCancelWithAction:(SEL)cancelAction origin:(id)origin {
  if (self.onActionSheetCancel) {
    _onActionSheetCancel(self);
    return;
  }
  else if (target && cancelAction && [target respondsToSelector:cancelAction])
    [target performSelector:cancelAction withObject:origin];
}

#pragma mark - Block setters

// NOTE: Sometimes see crashes when relying on just the copy property. Using Block_copy ensures correct behavior

- (void)setOnActionSheetDone:(ActionRemoteDoneBlock)onActionSheetDone {
  if (_onActionSheetDone) {
    Block_release(_onActionSheetDone);
    _onActionSheetDone = nil;
  }
  _onActionSheetDone = Block_copy(onActionSheetDone);
}

- (void)setOnActionSheetCancel:(ActionRemoteCancelBlock)onActionSheetCancel {
  if (_onActionSheetCancel) {
    Block_release(_onActionSheetCancel);
    _onActionSheetCancel = nil;
  }
  _onActionSheetCancel = Block_copy(onActionSheetCancel);
}

@end