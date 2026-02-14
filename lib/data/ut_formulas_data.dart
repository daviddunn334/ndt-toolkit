import '../models/reference_models.dart';
import 'package:flutter/material.dart';

/// UT Level II Formula Sheet Data
class UTFormulasData {
  static final List<CheatSheetSection> sections = [
    CheatSheetSection(
      title: 'Snell\'s Law & Refraction',
      description: 'Wave refraction at material interfaces',
      items: [
        CheatItem(
          label: 'Snell\'s Law',
          value: 'sin(θ₁) / V₁ = sin(θ₂) / V₂',
          note: 'Relates incident and refracted angles to velocities',
        ),
        CheatItem(
          label: 'Critical Angle',
          value: 'θ_crit = arcsin(V₁ / V₂)',
          note: 'Angle at which refracted wave travels parallel to interface (V₁ < V₂)',
        ),
        CheatItem(
          label: 'Refracted Angle',
          value: 'θ₂ = arcsin((V₂ / V₁) × sin(θ₁))',
          note: 'Calculate refracted angle from incident angle and velocities',
        ),
      ],
    ),
    CheatSheetSection(
      title: 'Wave Properties',
      description: 'Fundamental wave characteristics',
      items: [
        CheatItem(
          label: 'Wavelength',
          value: 'λ = V / f',
          note: 'V = velocity (m/s), f = frequency (Hz)',
        ),
        CheatItem(
          label: 'Frequency',
          value: 'f = V / λ',
          note: 'Frequency in Hz (cycles per second)',
        ),
        CheatItem(
          label: 'Velocity Relationship',
          value: 'V = λ × f',
          note: 'Basic wave equation: velocity = wavelength × frequency',
        ),
      ],
    ),
    CheatSheetSection(
      title: 'Near Field & Beam Spread',
      description: 'Beam characteristics and divergence',
      items: [
        CheatItem(
          label: 'Near Field Length',
          value: 'N = (D² × f) / (4 × V)',
          note: 'D = crystal diameter, f = frequency, V = material velocity',
        ),
        CheatItem(
          label: 'Near Field (alternate)',
          value: 'N = D² / (4 × λ)',
          note: 'Using wavelength instead of frequency',
        ),
        CheatItem(
          label: 'Half-Angle Divergence',
          value: 'α = arcsin(0.61 × λ / D)',
          note: 'Half-angle of beam spread in far field',
        ),
        CheatItem(
          label: 'Beam Width at Depth',
          value: 'W = 2 × z × tan(α)',
          note: 'z = depth from transducer, α = divergence half-angle',
        ),
      ],
    ),
    CheatSheetSection(
      title: 'Amplitude & Decibels',
      description: 'Signal amplitude calculations',
      items: [
        CheatItem(
          label: 'dB from Amplitudes',
          value: 'dB = 20 × log₁₀(A₂ / A₁)',
          note: 'A₂ = new amplitude, A₁ = reference amplitude',
        ),
        CheatItem(
          label: 'Amplitude Ratio from dB',
          value: 'A₂ / A₁ = 10^(dB / 20)',
          note: 'Calculate amplitude ratio from dB change',
        ),
        CheatItem(
          label: 'dB from %DAC',
          value: 'dB = 20 × log₁₀(%DAC / 100)',
          note: 'Convert percent DAC to decibels',
        ),
        CheatItem(
          label: '%DAC from dB',
          value: '%DAC = 100 × 10^(dB / 20)',
          note: 'Convert decibels to percent DAC',
        ),
      ],
    ),
    CheatSheetSection(
      title: 'Common dB Reference Values',
      description: 'Quick reference for common dB changes',
      items: [
        CheatItem(
          label: '2:1 amplitude ratio',
          value: '+6 dB',
          note: 'Doubling amplitude = +6 dB',
        ),
        CheatItem(
          label: '4:1 amplitude ratio',
          value: '+12 dB',
          note: 'Quadrupling amplitude = +12 dB',
        ),
        CheatItem(
          label: '10:1 amplitude ratio',
          value: '+20 dB',
          note: '10× amplitude = +20 dB',
        ),
        CheatItem(
          label: '1:2 amplitude ratio',
          value: '-6 dB',
          note: 'Halving amplitude = -6 dB',
        ),
      ],
    ),
    CheatSheetSection(
      title: 'Angle Beam Geometry',
      description: 'Skip distance and sound path calculations',
      items: [
        CheatItem(
          label: 'Half Skip Distance',
          value: 'HS = T × tan(θ)',
          note: 'T = thickness, θ = refracted angle',
        ),
        CheatItem(
          label: 'Full Skip Distance',
          value: 'FS = 2 × T × tan(θ)',
          note: 'Distance for one complete V-path',
        ),
        CheatItem(
          label: 'Sound Path',
          value: 'S = depth / cos(θ)',
          note: 'Actual distance traveled by sound',
        ),
        CheatItem(
          label: 'Surface Distance',
          value: 'SD = depth × tan(θ)',
          note: 'Horizontal distance from probe index',
        ),
      ],
    ),
    CheatSheetSection(
      title: 'Attenuation',
      description: 'Signal loss over distance',
      items: [
        CheatItem(
          label: 'Attenuation',
          value: 'dB_loss = α × distance',
          note: 'α = attenuation coefficient (dB/unit length)',
        ),
        CheatItem(
          label: 'Distance Amplitude Correction',
          value: 'dB_DAC = 20 × log₁₀(r₂ / r₁)',
          note: 'Compensate for distance differences (r₂, r₁ = ranges)',
        ),
      ],
    ),
    CheatSheetSection(
      title: 'Resolution',
      description: 'Axial resolution limits',
      items: [
        CheatItem(
          label: 'Axial Resolution',
          value: 'R = λ / 2',
          note: 'Minimum detectable separation between reflectors',
        ),
        CheatItem(
          label: 'Pulse Length',
          value: 'PL = n × λ',
          note: 'n = number of cycles in pulse',
        ),
      ],
    ),
  ];
}
