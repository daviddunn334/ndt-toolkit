/**
 * One-time function to populate default certification types
 * Call this once via HTTP to initialize the certification_types collection
 * DELETE THIS FILE after running to keep codebase clean
 */

import {onRequest} from "firebase-functions/v2/https";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {logger} from "firebase-functions";

export const populateCertificationTypes = onRequest(
  {
    region: "us-central1",
    cors: true,
  },
  async (req, res) => {
    try {
      const db = getFirestore();
      
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

      logger.info("Starting to populate certification types...");
      
      const batch = db.batch();
      
      for (const certType of certificationTypes) {
        const docRef = db.collection('certification_types').doc();
        batch.set(docRef, {
          ...certType,
          createdAt: FieldValue.serverTimestamp(),
        });
        logger.info(`Adding: ${certType.name}`);
      }
      
      await batch.commit();
      
      logger.info(`Successfully added ${certificationTypes.length} certification types`);
      
      res.status(200).json({
        success: true,
        message: `Successfully added ${certificationTypes.length} certification types`,
        count: certificationTypes.length,
      });
    } catch (error) {
      logger.error("Error populating certification types:", error);
      res.status(500).json({
        success: false,
        error: String(error),
      });
    }
  }
);
