import { Option } from './components/Select'

// Color WaveShare frames commented out, since we don't support them yet

export const devices: Option[] = [
  { value: 'web_only', label: 'Web only' },
  { value: 'framebuffer', label: 'HDMI / Framebuffer' },
  { value: 'pimoroni.inky_impression', label: 'Pimoroni Inky Impression e-ink frames' },
  { value: 'pimoroni.hyperpixel2r', label: 'Pimoroni HyperPixel 2.1" Round' },
  { value: 'waveshare.EPD_1in02d', label: 'Waveshare 1.02" (D) 80x80 Black/White' },
  { value: 'waveshare.EPD_1in54_DES', label: 'Waveshare 1.54" (DES) 152x152 Black/White' },
  { value: 'waveshare.EPD_1in54_V2', label: 'Waveshare 1.54" (V2) 200x200 Black/White' },
  { value: 'waveshare.EPD_1in54b', label: 'Waveshare 1.54" (B) 200x200 Black/White/Red' },
  { value: 'waveshare.EPD_1in54c', label: 'Waveshare 1.54" (C) 152x152 Black/White/Red' },
  { value: 'waveshare.EPD_1in54', label: 'Waveshare 1.54" 200x200 Black/White' },
  { value: 'waveshare.EPD_1in54b_V2', label: 'Waveshare 1.54" (B V2) 200x200 Black/White/Red' },
  { value: 'waveshare.EPD_1in64g', label: 'Waveshare 1.64" (G) 168x168 Black/White/Yellow/Red (not implemented)' },
  { value: 'waveshare.EPD_2in13bc', label: 'Waveshare 2.13" (BC) 104x104 Black/White/Red' },
  { value: 'waveshare.EPD_2in13_DES', label: 'Waveshare 2.13" (DES) 104x104 Black/White' },
  { value: 'waveshare.EPD_2in13', label: 'Waveshare 2.13" 122x122 Black/White' },
  { value: 'waveshare.EPD_2in13_V2', label: 'Waveshare 2.13" (V2) 122x122 Black/White' },
  { value: 'waveshare.EPD_2in13_V3', label: 'Waveshare 2.13" (V3) 122x122 Black/White' },
  { value: 'waveshare.EPD_2in13d', label: 'Waveshare 2.13" (D) 104x104 Black/White' },
  { value: 'waveshare.EPD_2in13_V4', label: 'Waveshare 2.13" (V4) 122x122 Black/White' },
  { value: 'waveshare.EPD_2in13g', label: 'Waveshare 2.13" (G) 122x122 Black/White/Yellow/Red (not implemented)' },
  { value: 'waveshare.EPD_2in13b_V3', label: 'Waveshare 2.13" (B V3) 104x104 Black/White/Red' },
  { value: 'waveshare.EPD_2in13b_V4', label: 'Waveshare 2.13" (B V4) 122x122 Black/White/Red' },
  { value: 'waveshare.EPD_2in36g', label: 'Waveshare 2.36" (G) 168x168 Black/White/Yellow/Red (not implemented)' },
  { value: 'waveshare.EPD_2in66', label: 'Waveshare 2.66" 152x152 Black/White' },
  { value: 'waveshare.EPD_2in66b', label: 'Waveshare 2.66" (B) 152x152 Black/White/Red' },
  { value: 'waveshare.EPD_2in66g', label: 'Waveshare 2.66" (G) 184x184 Black/White/Yellow/Red (not implemented)' },
  { value: 'waveshare.EPD_2in7', label: 'Waveshare 2.7" 176x176 4 Grayscale (not implemented!)' },
  { value: 'waveshare.EPD_2in7b', label: 'Waveshare 2.7" (B) 176x176 Black/White/Red' },
  { value: 'waveshare.EPD_2in7b_V2', label: 'Waveshare 2.7" (B V2) 176x176 Black/White/Red' },
  { value: 'waveshare.EPD_2in7_V2', label: 'Waveshare 2.7" (V2) 176x176 4 Grayscale (not implemented!)' },
  { value: 'waveshare.EPD_2in9_DES', label: 'Waveshare 2.9" (DES) 128x128 Black/White' },
  { value: 'waveshare.EPD_2in9_V2', label: 'Waveshare 2.9" (V2) 128x128 4 Grayscale (not implemented!)' },
  { value: 'waveshare.EPD_2in9d', label: 'Waveshare 2.9" (D) 128x128 Black/White' },
  { value: 'waveshare.EPD_2in9bc', label: 'Waveshare 2.9" (BC) 128x128 Black/White/Red' },
  { value: 'waveshare.EPD_2in9b_V3', label: 'Waveshare 2.9" (B V3) 128x128 Black/White/Red' },
  { value: 'waveshare.EPD_2in9', label: 'Waveshare 2.9" 128x128 Black/White' },
  { value: 'waveshare.EPD_2in9b_V4', label: 'Waveshare 2.9" (B V4) 128x128 Black/White/Red' },
  { value: 'waveshare.EPD_3in0g', label: 'Waveshare 3.0" (G) 168x168 Black/White/Yellow/Red (not implemented)' },
  { value: 'waveshare.EPD_3in52', label: 'Waveshare 3.52" 240x240 Black/White' },
  { value: 'waveshare.EPD_3in7', label: 'Waveshare 3.7" 280x280 4 Grayscale (not implemented!)' },
  { value: 'waveshare.EPD_4in01f', label: 'Waveshare 4.01" (F) 640x640 7 Color (not implemented!)' },
  { value: 'waveshare.EPD_4in2bc', label: 'Waveshare 4.2" (BC) 400x400 Black/White/Red' },
  { value: 'waveshare.EPD_4in2_V2', label: 'Waveshare 4.2" (V2) 400x400 4 Grayscale (not implemented!)' },
  { value: 'waveshare.EPD_4in2', label: 'Waveshare 4.2" 400x400 4 Grayscale (not implemented!)' },
  { value: 'waveshare.EPD_4in2b_V2', label: 'Waveshare 4.2" (B V2) 400x400 Black/White/Red' },
  { value: 'waveshare.EPD_4in26', label: 'Waveshare 4.26" 800x800 4 Grayscale (not implemented!)' },
  { value: 'waveshare.EPD_4in37g', label: 'Waveshare 4.37" (G) 512x512 Black/White/Yellow/Red (not implemented)' },
  { value: 'waveshare.EPD_4in37b', label: 'Waveshare 4.37" (B) 176x176 Black/White/Red' },
  { value: 'waveshare.EPD_5in65f', label: 'Waveshare 5.65" (F) 600x600 7 Color (not implemented!)' },
  { value: 'waveshare.EPD_5in83', label: 'Waveshare 5.83" 600x600 Black/White' },
  { value: 'waveshare.EPD_5in83_V2', label: 'Waveshare 5.83" (V2) 648x648 Black/White' },
  { value: 'waveshare.EPD_5in83b_V2', label: 'Waveshare 5.83" (B V2) 648x648 Black/White/Red' },
  { value: 'waveshare.EPD_5in83bc', label: 'Waveshare 5.83" (BC) 600x600 Black/White/Red' },
  { value: 'waveshare.EPD_5in84', label: 'Waveshare 5.84" 768x768 Black/White' },
  { value: 'waveshare.EPD_7in3g', label: 'Waveshare 7.3" (G) 800x800 Black/White/Yellow/Red (not implemented)' },
  { value: 'waveshare.EPD_7in3f', label: 'Waveshare 7.3" (F) 800x800 7 Color (not implemented!)' },
  { value: 'waveshare.EPD_7in5b_V2', label: 'Waveshare 7.5" (B V2) 800x800 Black/White/Red' },
  { value: 'waveshare.EPD_7in5_HD', label: 'Waveshare 7.5" (HD) 880x880 Black/White' },
  { value: 'waveshare.EPD_7in5_V2', label: 'Waveshare 7.5" (V2) 800x800 Black/White' },
  { value: 'waveshare.EPD_7in5_V2_old', label: 'Waveshare 7.5" (V2 OLD) 800x800 Black/White' },
  { value: 'waveshare.EPD_7in5b_HD', label: 'Waveshare 7.5" (B HD) 880x880 Black/White/Red' },
  { value: 'waveshare.EPD_7in5', label: 'Waveshare 7.5" 640x640 Black/White' },
  { value: 'waveshare.EPD_7in5bc', label: 'Waveshare 7.5" (BC) 640x640 Black/White/Red' },
  { value: 'waveshare.EPD_10in2b', label: 'Waveshare 10.2" (B) 960x960 Black/White/Red' },
  { value: 'waveshare.EPD_13in3k', label: 'Waveshare 13.3" (K) 960x960 Black/White' },
]
