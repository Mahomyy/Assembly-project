;-------------------------------------------------------------------
; 32-bit Keyboard functionality.
;-------------------------------------------------------------------

GLOBAL __keyb_installKeyboardHandler:PROC
GLOBAL __keyb_uninstallKeyboardHandler:PROC
GLOBAL __check_keys:PROC

GLOBAL __keyb_keyboardState:BYTE:128
GLOBAL __keyb_rawScanCode:BYTE
GLOBAL __keyb_keysActive:BYTE
GLOBAL __running:BYTE
GLOBAL booleanFlag:BYTE


;-------------------------------------------------------------------
; Scancodes
;   see: http://www.ee.bgu.ac.il/~microlab/MicroLab/Labs/ScanCodes.htm
;-------------------------------------------------------------------
