import '../models/reference_models.dart';

/// Material Velocities Reference Data
class MaterialVelocitiesData {
  static final List<MaterialVelocity> materials = [
    // Steels
    MaterialVelocity(
      material: 'Carbon Steel (mild)',
      longitudinalVelocity: 5900,
      shearVelocity: 3230,
      density: 7850,
      notes: 'Most common structural steel',
      tags: ['Steel', 'Carbon', 'Structural'],
    ),
    MaterialVelocity(
      material: 'Stainless Steel (austenitic)',
      longitudinalVelocity: 5790,
      shearVelocity: 3100,
      density: 8000,
      notes: '304, 316 grades - note lower velocities than carbon steel',
      tags: ['Steel', 'Stainless', 'Austenitic'],
    ),
    MaterialVelocity(
      material: 'Stainless Steel (ferritic)',
      longitudinalVelocity: 5940,
      shearVelocity: 3230,
      density: 7750,
      notes: '400 series stainless',
      tags: ['Steel', 'Stainless', 'Ferritic'],
    ),
    MaterialVelocity(
      material: 'Cast Iron',
      longitudinalVelocity: 4600,
      shearVelocity: 2500,
      density: 7200,
      notes: 'Significantly lower velocity than steel',
      tags: ['Iron', 'Cast'],
    ),
    
    // Aluminum
    MaterialVelocity(
      material: 'Aluminum (pure)',
      longitudinalVelocity: 6320,
      shearVelocity: 3130,
      density: 2700,
      notes: '99% pure aluminum',
      tags: ['Aluminum', 'Non-ferrous'],
    ),
    MaterialVelocity(
      material: 'Aluminum 2024',
      longitudinalVelocity: 6350,
      shearVelocity: 3130,
      density: 2780,
      notes: 'Aircraft aluminum alloy',
      tags: ['Aluminum', 'Alloy', 'Aircraft'],
    ),
    MaterialVelocity(
      material: 'Aluminum 6061',
      longitudinalVelocity: 6380,
      shearVelocity: 3150,
      density: 2700,
      notes: 'Common structural aluminum',
      tags: ['Aluminum', 'Alloy', 'Structural'],
    ),
    MaterialVelocity(
      material: 'Aluminum 7075',
      longitudinalVelocity: 6420,
      shearVelocity: 3180,
      density: 2810,
      notes: 'High-strength aluminum alloy',
      tags: ['Aluminum', 'Alloy', 'High-strength'],
    ),
    
    // Copper alloys
    MaterialVelocity(
      material: 'Copper',
      longitudinalVelocity: 4700,
      shearVelocity: 2260,
      density: 8960,
      notes: 'Pure copper',
      tags: ['Copper', 'Non-ferrous'],
    ),
    MaterialVelocity(
      material: 'Brass (70/30)',
      longitudinalVelocity: 4430,
      shearVelocity: 2120,
      density: 8520,
      notes: '70% copper, 30% zinc',
      tags: ['Brass', 'Copper', 'Alloy'],
    ),
    MaterialVelocity(
      material: 'Bronze',
      longitudinalVelocity: 3500,
      shearVelocity: 2200,
      density: 8800,
      notes: 'Copper-tin alloy',
      tags: ['Bronze', 'Copper', 'Alloy'],
    ),
    
    // Titanium
    MaterialVelocity(
      material: 'Titanium (commercially pure)',
      longitudinalVelocity: 6070,
      shearVelocity: 3130,
      density: 4500,
      notes: 'Grade 2 titanium',
      tags: ['Titanium', 'Non-ferrous'],
    ),
    MaterialVelocity(
      material: 'Titanium Ti-6Al-4V',
      longitudinalVelocity: 6100,
      shearVelocity: 3120,
      density: 4430,
      notes: 'Most common titanium alloy',
      tags: ['Titanium', 'Alloy', 'Aerospace'],
    ),
    
    // Nickel alloys
    MaterialVelocity(
      material: 'Nickel',
      longitudinalVelocity: 5630,
      shearVelocity: 2990,
      density: 8900,
      notes: 'Pure nickel',
      tags: ['Nickel', 'Non-ferrous'],
    ),
    MaterialVelocity(
      material: 'Inconel 600',
      longitudinalVelocity: 5820,
      shearVelocity: 3020,
      density: 8470,
      notes: 'Nickel-chromium alloy',
      tags: ['Inconel', 'Nickel', 'Alloy', 'High-temp'],
    ),
    MaterialVelocity(
      material: 'Monel 400',
      longitudinalVelocity: 5350,
      shearVelocity: 2720,
      density: 8800,
      notes: 'Nickel-copper alloy',
      tags: ['Monel', 'Nickel', 'Alloy'],
    ),
    
    // Plastics / Wedge materials
    MaterialVelocity(
      material: 'Acrylic (Lucite)',
      longitudinalVelocity: 2730,
      shearVelocity: 1430,
      density: 1180,
      notes: 'Common wedge material',
      tags: ['Plastic', 'Wedge', 'Acrylic'],
    ),
    MaterialVelocity(
      material: 'Rexolite',
      longitudinalVelocity: 2337,
      shearVelocity: 1105,
      density: 1050,
      notes: 'Popular wedge material for PAUT',
      tags: ['Plastic', 'Wedge', 'Rexolite'],
    ),
    MaterialVelocity(
      material: 'Polystyrene',
      longitudinalVelocity: 2340,
      shearVelocity: 1150,
      density: 1060,
      notes: 'Wedge material',
      tags: ['Plastic', 'Wedge'],
    ),
    
    // Other materials
    MaterialVelocity(
      material: 'Glass (typical)',
      longitudinalVelocity: 5570,
      shearVelocity: 3430,
      density: 2500,
      notes: 'Common soda-lime glass',
      tags: ['Glass', 'Ceramic'],
    ),
    MaterialVelocity(
      material: 'Concrete',
      longitudinalVelocity: 4000,
      shearVelocity: 2000,
      density: 2400,
      notes: 'Typical values - varies significantly',
      tags: ['Concrete', 'Construction'],
    ),
    MaterialVelocity(
      material: 'Water (20°C)',
      longitudinalVelocity: 1483,
      shearVelocity: 0,
      density: 1000,
      notes: 'Shear waves do not propagate in liquids',
      tags: ['Water', 'Liquid', 'Couplant'],
    ),
    MaterialVelocity(
      material: 'Glycerin',
      longitudinalVelocity: 1920,
      shearVelocity: 0,
      density: 1260,
      notes: 'Used as high-viscosity couplant',
      tags: ['Glycerin', 'Liquid', 'Couplant'],
    ),
  ];

  // Preset material pairs for critical angle calculations
  static final List<MaterialPair> presetPairs = [
    MaterialPair(
      name: 'Rexolite → Carbon Steel (L)',
      medium1: 'Rexolite',
      medium2: 'Carbon Steel',
      v1: 2337,
      vL2: 5900,
      vS2: 3230,
    ),
    MaterialPair(
      name: 'Acrylic → Carbon Steel (L)',
      medium1: 'Acrylic',
      medium2: 'Carbon Steel',
      v1: 2730,
      vL2: 5900,
      vS2: 3230,
    ),
    MaterialPair(
      name: 'Rexolite → Stainless Steel (L)',
      medium1: 'Rexolite',
      medium2: 'Stainless Steel (austenitic)',
      v1: 2337,
      vL2: 5790,
      vS2: 3100,
    ),
    MaterialPair(
      name: 'Acrylic → Aluminum (L)',
      medium1: 'Acrylic',
      medium2: 'Aluminum 6061',
      v1: 2730,
      vL2: 6380,
      vS2: 3150,
    ),
    MaterialPair(
      name: 'Water → Carbon Steel (L)',
      medium1: 'Water',
      medium2: 'Carbon Steel',
      v1: 1483,
      vL2: 5900,
      vS2: 3230,
    ),
  ];
}
