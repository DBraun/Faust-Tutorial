import numpy as np
from scipy.io import wavfile
import matplotlib.pyplot as plt

S = 2048  # the length of the wavecycle files we'll create by hand

ramp = np.arange(S)/S

sine = np.sin(ramp*np.pi*2.)

triangle = (1.-2.*abs(abs(np.mod(ramp*2,1.))-.5))*np.where(ramp>0.5, -1, 1)

square = np.where(ramp>0.5, -1, 1)

pwm = np.where(ramp>0.75, -1, 1)

saw = -1+2*ramp

# plt.title("Wavetables")
# plt.plot(sine, label='sine')
# plt.plot(triangle, label='triangle')
# plt.plot(square, label='square')
# plt.plot(pwm, label='pwm')
# plt.plot(saw, label='saw')
# plt.legend()
# plt.ylabel("Amplitude")
# plt.xlabel("Audio Samples")
# plt.show()

sine = (sine*np.iinfo(np.int16).max).astype(np.int16)
triangle = (triangle*np.iinfo(np.int16).max).astype(np.int16)
square = (square*np.iinfo(np.int16).max).astype(np.int16)
pwm = (pwm*np.iinfo(np.int16).max).astype(np.int16)
saw = (saw*np.iinfo(np.int16).max).astype(np.int16)

# Save them as wav files.
wavfile.write("sine.wav", 44100, sine)
wavfile.write("triangle.wav", 44100, triangle)
wavfile.write("square.wav", 44100, square)
wavfile.write("pwm.wav", 44100, pwm)
wavfile.write("saw.wav", 44100, saw)