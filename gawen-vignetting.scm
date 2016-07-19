; Copyright (c) 2016, David Hauweele <david@hauweele.net>
; All rights reserved.
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
;
;  1. Redistributions of source code must retain the above copyright notice, this
;     list of conditions and the following disclaimer.
;  2. Redistributions in binary form must reproduce the above copyright notice,
;     this list of conditions and the following disclaimer in the documentation
;     and/or other materials provided with the distribution.
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
; DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
; ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
; (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
; ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(define (script-fu-gawen-vignetting image layer color border blur opacity flatten)
  (let* ((width  (car (gimp-image-width image)))
         (height (car (gimp-image-height image)))
         (hw (min width height))
         (borderSize (* hw (/ border 100.)))
         (blurSize   (* hw (/ blur   100.)))
         (vignetLayer 0))
    (gimp-image-undo-group-start image)

    (set! vignetLayer (car (gimp-layer-new image
                                           width
                                           height
                                           RGBA-IMAGE
                                           "vignet"
                                           opacity
                                           NORMAL-MODE)))
    (gimp-image-insert-layer image vignetLayer 0 -1)
    (gimp-edit-clear vignetLayer)

    (chris-color-edge image vignetLayer color borderSize)
    (plug-in-gauss-rle TRUE image vignetLayer blurSize TRUE TRUE)

    (if (= flatten TRUE) (gimp-image-merge-down image vignetLayer EXPAND-AS-NECESSARY))

    (gimp-image-undo-group-end image)
    (gimp-displays-flush)))

(define (chris-color-edge image layer color size)
  (gimp-selection-all image)
  (gimp-selection-shrink image size)
  (gimp-selection-invert image)
  (gimp-context-set-background color)
  (gimp-edit-fill layer BACKGROUND-FILL)
  (gimp-selection-none image))

(script-fu-register "script-fu-gawen-vignetting"
                    "<Image>/Script-Fu/Gawen/Vignetting"
                    "Gawen Vignetting"
                    "David Hauweele"
                    "BSD"
                    "18 july 2016"
                    "RGB* GRAY*"
                    SF-IMAGE "Image"             0
                    SF-DRAWABLE "Drawable"       0
                    SF-COLOR "Color"             "black"
                    SF-ADJUSTMENT "Border (%)"   '(2  0 100 0.1 1  1 0)
                    SF-ADJUSTMENT "Blur (%)"     '(40 0 100 1   10 1 0)
                    SF-ADJUSTMENT "Opacity (%)"  '(50 0 100 1   10 1 0)
                    SF-TOGGLE "Flatten image"    FALSE)
