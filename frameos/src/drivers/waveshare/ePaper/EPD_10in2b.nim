{.compile: "EPD_10in2b.c".}
## ***************************************************************************
##  | File      	:   EPD_10in2b.h
##  | Author      :   Waveshare team
##  | Function    :   10.2inch b e-paper test demo
##  | Info        :
## ----------------
##  |	This version:   V1.0
##  | Date        :   2021-01-20
##  | Info        :
##  -----------------------------------------------------------------------------
## #
## # Permission is hereby granted, free of charge, to any person obtaining a copy
## # of this software and associated documnetation files (the "Software"), to deal
## # in the Software without restriction, including without limitation the rights
## # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## # copies of the Software, and to permit persons to  whom the Software is
## # furished to do so, subject to the following conditions:
## #
## # The above copyright notice and this permission notice shall be included in
## # all copies or substantial portions of the Software.
## #
## # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## # FITNESS OR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## # LIABILITY WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
## # THE SOFTWARE.
## #
## ****************************************************************************

import
  DEV_Config

##  Display resolution

const
  EPD_10IN2b_WIDTH* = 960
  EPD_10IN2b_HEIGHT* = 640

proc EPD_10IN2b_Init*() {.importc: "EPD_10IN2b_Init".}
proc EPD_10IN2b_Clear*() {.importc: "EPD_10IN2b_Clear".}
proc EPD_10IN2b_Display*(Image: ptr UBYTE; RedImage: ptr UBYTE) {.
    importc: "EPD_10IN2b_Display".}
proc EPD_10IN2b_Sleep*() {.importc: "EPD_10IN2b_Sleep".}
