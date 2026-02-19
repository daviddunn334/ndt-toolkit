// Simple script to add certification types using Firebase CLI
// Run with: node add_cert_types.js

const { initializeApp } = require('firebase/app');
const { getFirestore, collection, addDoc, serverTimestamp } = require('firebase/firestore');

// Your Firebase config from firebase_options.dart or Firebase Console
const firebaseConfig = {
  apiKey: "AIzaSyBaoPR8cXSKC8Vxj8r5O_n8NcxKQqjLGHw",
  authDomain: "ndt-toolkit.firebaseapp.com",
  projectId: "ndt-toolkit",
  storageBucket: "ndt-toolkit.firebasestorage.app",
  messagingSenderId: "728027646273",
  appId: "1:728027646273:web:8e8b7f5ef9f2c5e5a1b3c4"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

const certificationTypes = [
  {
    name: 'ASNT Level II - UT',
    description: 'Ultrasonic Testing Level II',
    category: 'NDT',
    isActive: true,
  },
  {
    name: 'ASNT Level II - RT',
    description: 'Radiographic Testing Level II',
    category: 'NDT',
    isActive: true,
  },
  {
    name: 'ASNT Level II - MT',
    description: 'Magnetic Particle Testing Level II',
    category: 'NDT',
    isActive: true,
  },
  {
    name: 'ASNT Level II - PT',
    description: 'Liquid Penetrant Testing Level II',
    category: 'NDT',
    isActive: true,
  },
  {
    name: 'ASNT Level II - VT',
    description: 'Visual Testing Level II',
    category: 'NDT',
    isActive: true,
  },
  {
    name: 'ASNT Level II - ET',
    description: 'Eddy Current Testing Level II',
    category: 'NDT',
    isActive: true,
  },
  {
    name: 'ASNT Level III - UT',
    description: 'Ultrasonic Testing Level III',
    category: 'NDT',
    isActive: true,
  },
  {
    name: 'PCN Level 2',
    description: 'Personnel Certification in Non-Destructive Testing Level 2',
    category: 'NDT',
    isActive: true,
  },
  {
    name: 'CGSB Level 2',
    description: 'Canadian General Standards Board Level 2',
    category: 'NDT',
    isActive: true,
  },
  {
    name: 'AWS CWI',
    description: 'Certified Welding Inspector',
    category: 'Welding',
    isActive: true,
  },
  {
    name: 'API 510',
    description: 'Pressure Vessel Inspector',
    category: 'Inspection',
    isActive: true,
  },
  {
    name: 'API 570',
    description: 'Piping Inspector',
    category: 'Inspection',
    isActive: true,
  },
  {
    name: 'API 653',
    description: 'Aboveground Storage Tank Inspector',
    category: 'Inspection',
    isActive: true,
  },
];

async function addCertificationTypes() {
  console.log('Adding certification types to Firestore...\n');
  
  try {
    for (const certType of certificationTypes) {
      const docData = {
        ...certType,
        createdAt: serverTimestamp(),
      };
      
      await addDoc(collection(db, 'certification_types'), docData);
      console.log(`✓ Added: ${certType.name}`);
    }
    
    console.log(`\n✅ Successfully added ${certificationTypes.length} certification types!`);
    console.log('\nThe "Add New Certification" button should now be enabled in your app.');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error adding certification types:', error);
    process.exit(1);
  }
}

addCertificationTypes();
