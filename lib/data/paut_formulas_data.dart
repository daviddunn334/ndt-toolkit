import '../models/reference_models.dart';
import 'package:flutter/material.dart';

/// PAUT Cheat Sheet Data
class PAUTFormulasData {
  static final List<CheatSheetSection> sections = [
    CheatSheetSection(
      title: 'Array Geometry',
      description: 'Physical array parameters',
      items: [
        CheatItem(
          label: 'Active Aperture',
          value: 'D = (n - 1) × e + a',
          note: 'n = number of elements, e = pitch, a = element width',
        ),
        CheatItem(
          label: 'Element Width',
          value: 'a = pitch - gap',
          note: 'For arrays with specified gap between elements',
        ),
        CheatItem(
          label: 'Pitch',
          value: 'e = element width + gap',
          note: 'Center-to-center distance between elements',
        ),
      ],
    ),
    CheatSheetSection(
      title: 'Focal Law Calculations',
      description: 'Delay calculations for steering and focusing',
      items: [
        CheatItem(
          label: 'Steering Delay (per element)',
          value: 'Δt = (e × sin(θ)) / V',
          note: 'e = pitch, θ = steering angle, V = wedge velocity',
        ),
        CheatItem(
          label: 'Total Delay (n elements)',
          value: 't_total = (n - 1) × Δt',
          note: 'Maximum delay across aperture for steering',
        ),
        CheatItem(
          label: 'Focusing Delay',
          value: 'Δt_focus = (R_max - R_i) / V',
          note: 'R_max = max distance to focal point, R_i = distance from element i',
        ),
      ],
    ),
    CheatSheetSection(
      title: 'Grating Lobes',
      description: 'Unintended beam formation',
      items: [
        CheatItem(
          label: 'Grating Lobe Angle',
          value: 'sin(θ_g) = sin(θ₀) ± (λ / e)',
          note: 'θ₀ = main lobe angle, λ = wavelength, e = pitch',
        ),
        CheatItem(
          label: 'Pitch Rule (avoid grating)',
          value: 'e < λ / (1 + |sin(θ_max)|)',
          note: 'Maximum pitch to avoid grating lobes',
        ),
        CheatItem(
          label: 'Common Guideline',
          value: 'e ≤ 0.6 × λ',
          note: 'Conservative pitch limit for typical steering',
        ),
      ],
    ),
    CheatSheetSection(
      title: 'Wave Properties (same as UT)',
      description: 'Fundamental formulas apply to PAUT',
      items: [
        CheatItem(
          label: 'Wavelength',
          value: 'λ = V / f',
          note: 'V = velocity in material, f = frequency',
        ),
        CheatItem(
          label: 'Near Field (aperture)',
          value: 'N = (D² × f) / (4 × V)',
          note: 'D = active aperture size',
        ),
        CheatItem(
          label: 'Divergence Half-Angle',
          value: 'α = arcsin(0.61 × λ / D)',
          note: 'D = active aperture',
        ),
      ],
    ),
    CheatSheetSection(
      title: 'Sectorial Scan',
      description: 'Angular scanning parameters',
      items: [
        CheatItem(
          label: 'Angular Step',
          value: 'Δθ = (θ_max - θ_min) / (n_steps - 1)',
          note: 'Resolution of sectorial scan',
        ),
        CheatItem(
          label: 'Typical Angular Resolution',
          value: '0.5° to 2.0°',
          note: 'Common step sizes for sectorial scans',
        ),
      ],
    ),
    CheatSheetSection(
      title: 'Linear Scan (E-scan)',
      description: 'Electronic movement along array',
      items: [
        CheatItem(
          label: 'E-scan Step',
          value: 'step = k × e',
          note: 'k = number of elements to shift (typically 1)',
        ),
        CheatItem(
          label: 'Number of Positions',
          value: 'N_pos = N_total - N_active + 1',
          note: 'N_total = total elements, N_active = elements in aperture',
        ),
      ],
    ),
    CheatSheetSection(
      title: 'Practical Reminders',
      description: 'Field considerations',
      items: [
        CheatItem(
          label: 'Pitch vs Wavelength',
          value: 'e should be < λ to < 0.8λ',
          note: 'Prevents grating lobes in most scenarios',
        ),
        CheatItem(
          label: 'Steering Limits',
          value: 'Practical: ±30° to ±45°',
          note: 'Beyond this, grating lobes and weak signal',
        ),
        CheatItem(
          label: 'Aperture Size',
          value: 'Trade-off: larger = better focus, smaller = more agility',
          note: 'Typical: 8-32 active elements',
        ),
        CheatItem(
          label: 'Wedge Selection',
          value: 'Ensure wedge refracted angle matches target',
          note: 'Use Snell\'s Law to verify',
        ),
      ],
    ),
  ];
}
