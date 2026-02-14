import '../models/kb_section.dart';

/// PAUT Setup Knowledge Base Content
/// Array basics, steering/focus, coverage, sensitivity, and common pitfalls
final List<KbSection> pautSetupKbData = [
  // 1) Array Fundamentals
  KbSection(
    id: 'array_fundamentals',
    title: 'Array Fundamentals',
    bullets: [
      'Element pitch (e), element width (a), active elements (n)',
      'Active aperture (D): D = (n - 1)·e + a',
      'Wavelength: λ = V / f',
      'Rule-of-thumb: e/λ affects grating lobe risk',
      'Aperture tradeoff: larger D = tighter beam, smaller D = wider beam',
    ],
    actions: [
      KbLinkAction(
        label: 'Open Active Aperture Calculator',
        route: '/tools', // TODO: Update when specific calculator available
      ),
    ],
  ),

  // 2) Steering & Focusing
  KbSection(
    id: 'steering_focusing',
    title: 'Steering & Focusing',
    bullets: [
      'Steering concept: electronic angle control via element delays',
      'Adjacent element delay (steering): Δt = (e·sinθ) / V',
      'Total delay across aperture: (n - 1)·Δt',
      'Focus depth selection relates to near field behavior (don\'t over-focus shallow)',
      'Steering limits depend on pitch vs wavelength (grating lobes)',
    ],
    actions: [
      KbLinkAction(
        label: 'Open Element Time Delay Calculator',
        route: '/tools', // TODO: Update when specific calculator available
      ),
      KbLinkAction(
        label: 'Open Dynamic Near Field Calculator',
        route: '/tools', // TODO: Update when specific calculator available
      ),
    ],
  ),

  // 3) Beam Visualization
  KbSection(
    id: 'beam_visualization',
    title: 'Beam Visualization',
    bullets: [
      'Sectorial scan (S-scan): multiple angles from one probe position',
      'Linear scan (E-scan): aperture moves across the array',
      'Coverage planning: angle range + leg count + thickness',
      'Use beam plots to confirm what your math is doing (legs, skip, etc.)',
    ],
    actions: [
      KbLinkAction(
        label: 'Open Sweep Simulator',
        route: '/sweep_simulator',
      ),
      KbLinkAction(
        label: 'Open Beam Plot Visualizer',
        route: '/beam_plot_visualizer',
      ),
    ],
  ),

  // 4) Sensitivity & Resolution
  KbSection(
    id: 'sensitivity_resolution',
    title: 'Sensitivity & Resolution',
    bullets: [
      'Resolution improves with larger aperture (higher D)',
      'Divergence half-angle estimate: α ≈ asin(0.61·λ/D)',
      'Beam width at depth z: W ≈ 2z·tan(α)',
      'Near field length: N = (D²·f) / (4V)',
      'Gain/TCG affects amplitude, not geometry (keep concepts separate)',
    ],
    actions: [
      KbLinkAction(
        label: 'Open Beam Divergence Calculator',
        route: '/tools', // TODO: Update when specific calculator available
      ),
      KbLinkAction(
        label: 'Open Resolution Aperture Tool',
        route: '/resolution_aperture',
      ),
    ],
  ),

  // 5) Common PAUT Pitfalls
  KbSection(
    id: 'common_pitfalls',
    title: 'Common PAUT Pitfalls',
    bullets: [
      'Over-steering causes grating lobes / confusing indications',
      'Focusing too shallow can mislead (inside early near field)',
      'Wrong velocity values = wrong angle/TOF assumptions',
      'Using too small aperture increases divergence / lowers sensitivity',
      'Poor coupling / wedge wear = unstable signals',
    ],
    actions: [
      KbLinkAction(
        label: 'Open Grating Lobe Predictor',
        route: '/tools', // TODO: Update when specific predictor available
      ),
    ],
  ),
];
