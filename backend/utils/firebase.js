const admin = require('firebase-admin');

// Firebase Admin initialization (silently fails if credentials are not provided)
try {
  // If you have a serviceAccountKey.json, require it here and pass to credential
  // const serviceAccount = require('../serviceAccountKey.json');
  /*
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  */
  console.log('Firebase Admin SDK setup skipped. Zəhmət olmasa json faylını yüklədikdən sonra aktivləşdirin.');
} catch (error) {
  console.log('Firebase Admin SDK başlatma xətası (Gözardı edildə bilər):', error.message);
}

const sendPushNotification = async (fcmToken, title, body, data = {}) => {
  if (!fcmToken) return;
  
  // Real implementation will require admin.initializeApp to be uncommented
  try {
    const message = {
      notification: {
        title,
        body
      },
      data,
      token: fcmToken
    };
    
    // Mock the send if not initialized
    if (admin.apps.length > 0) {
      const response = await admin.messaging().send(message);
      console.log('Push notification göndərildi:', response);
      return response;
    } else {
      console.log(`[MOCK PUSH] -> TO: ${fcmToken} | '${title}': ${body}`);
      return { success: true, mock: true };
    }
  } catch (error) {
    console.error('Push notification göndərilmədi:', error.message);
  }
};

module.exports = { sendPushNotification };
