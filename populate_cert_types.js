// Script to populate default NDT certification types in Firestore
// Run with: node populate_cert_types.js

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

const certificationTypes = [
  {
    name: 'ASNT Level II - UT',
    description: 'Ultrasonic Testing Level II',
    category: 'NDT',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'ASNT Level II - RT',
    description: 'Radiographic Testing Level II',
    category: 'NDT',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'ASNT Level II - MT',
    description: 'Magnetic Particle Testing Level II',
    category: 'NDT',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'ASNT Level II - PT',
    description: 'Liquid Penetrant Testing Level II',
    category: 'NDT',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'ASNT Level II - VT',
    description: 'Visual Testing Level II',
    category: 'NDT',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'ASNT Level II - ET',
    description: 'Eddy Current Testing Level II',
    category: 'NDT',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'ASNT Level III - UT',
    description: 'Ultrasonic Testing Level III',
    category: 'NDT',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'PCN Level 2',
    description: 'Personnel Certification in Non-Destructive Testing Level 2',
    category: 'NDT',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'CGSB Level 2',
    description: 'Canadian General Standards Board Level 2',
    category: 'NDT',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'AWS CWI',
    description: 'Certified Welding Inspector',
    category: 'Welding',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'API 510',
    description: 'Pressure Vessel Inspector',
    category: 'Inspection',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'API 570',
    description: 'Piping Inspector',
    category: 'Inspection',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'API 653',
    description: 'Aboveground Storage Tank Inspector',
    category: 'Inspection',
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

async function populateCertificationTypes() {
  console.log('Starting to populate certification types...');
  
  const batch = db.batch();
  
  for (const certType of certificationTypes) {
    const docRef = db.collection('certification_types').doc();
    batch.set(docRef, certType);
    console.log(`Adding: ${certType.name}`);
  }
  
  await batch.commit();
  console.log(`\n✓ Successfully added ${certificationTypes.length} certification types!`);
  
  process.exit(0);
}

populateCertificationTypes().catch((error) => {
  console.error('Error populating certification types:', error);
  process.exit(1);
});
