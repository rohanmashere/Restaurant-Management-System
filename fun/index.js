/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.database();

// Remove expired bills
const removeExpiredBills = async () => {
    const now = Date.now(); // Current timestamp
    const expirationTime = 30 * 24 * 60 * 60 * 1000; // 30 days in milliseconds

    const billsRef = db.ref('users');

    try {
        const snapshot = await billsRef.once('value');
        const users = snapshot.val();

        if (!users) {
            console.log('No users found.');
            return;
        }

        // Iterate through each user
        for (const userId in users) {
            console.log(`Processing user: ${userId}`);
            const userBills = users[userId].bills;

            if (userBills) {
                for (const billDate in userBills) {
                    console.log(`Processing bills for date: ${billDate}`);
                    const bills = userBills[billDate];

                    const updatedBills = bills.filter((bill) => {
                        const timestamp = bill.timestamp;
                        const isExpired = now - timestamp > expirationTime;
                        console.log(`Bill timestamp: ${timestamp}, isExpired: ${isExpired}`);
                        return now - timestamp <= expirationTime; // Keep only valid bills
                    });

                    if (updatedBills.length === 0) {
                        console.log(`Removing all bills for date: ${billDate}`);
                        await db.ref(`users/${userId}/bills/${billDate}`).remove();
                    } else {
                        console.log(`Updating bills for date: ${billDate}`);
                        await db.ref(`users/${userId}/bills/${billDate}`).set(updatedBills);
                    }
                }
            }
        }

        console.log('Expired bills removed successfully!');
    } catch (error) {
        console.error('Error removing expired bills:', error);
    }
};

// Set up a scheduled function to run every 24 hours
exports.removeExpiredBillsScheduled = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
    await removeExpiredBills();
});
