const mqtt = require("mqtt");
const admin = require("firebase-admin");
const path = require("path");

/* ========== FIREBASE ========== */

const serviceAccount = require(
  path.join(__dirname, "../../serviceAccountKey.json")
);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),

  // Realtime Database URL
  databaseURL:
    "https://iot-chong-trom-xe-may-default-rtdb.asia-southeast1.firebasedatabase.app/"
});

const db = admin.firestore(); // Firestore
const rtdb = admin.database(); // Realtime DB


/* ========== MQTT ========== */

const MQTT_BROKER =
  process.env.MQTT_BROKER || "mqtt://10.16.67.125:1883";

const mqttClient = mqtt.connect(MQTT_BROKER, {
  keepalive: 60,
  reconnectPeriod: 2000,
  clean: true
});

let mqttReady = false;


/* ========== MQTT CONNECT ========== */

mqttClient.on("connect", () => {

  mqttReady = true;

  console.log("✅ MQTT Connected");

  // Subscribe GPS
  mqttClient.subscribe("duong/gps/data", { qos: 1 });

  console.log("📡 Subscribed: duong/gps/data");
});


mqttClient.on("error", (err) => {
  console.log("❌ MQTT Error:", err.message);
});


/* ========== FIRESTORE → MQTT (GIỮ NGUYÊN) ========== */

function listenDeviceStatus() {

  console.log("🔥 Listening devices status...");

  db.collection("devices").onSnapshot(snapshot => {

    snapshot.docChanges().forEach(change => {

      if (
        change.type === "added" ||
        change.type === "modified"
      ) {

        const deviceID = change.doc.id;
        const data = change.doc.data();

        const status = data.status || 0;

        console.log("📥 Device:", deviceID);
        console.log(" Status:", status);


        /* ===== SEND TO ESP32 ===== */

        const topic = duong/control/${deviceID};

        const payload = JSON.stringify({
          allowGPS: status === 1
        });


        if (mqttReady) {

          mqttClient.publish(topic, payload, {
            qos: 1,
            retain: true
          });

          console.log("📤 Sent:", topic, payload);

        } else {

          console.log("⚠️ MQTT not ready");

        }
      }
    });
  });
}


/* ========== MQTT GPS → REALTIME DB ========== */

mqttClient.on("message", async (topic, message) => {

  try {

    // Chỉ xử lý GPS
    if (topic !== "duong/gps/data") return;

    const data = JSON.parse(message.toString());


    /*
      ESP gửi ví dụ:
      {
        "deviceID": "abc123",
        "lat": 10.77,
        "lng": 106.68,
        "time": 1700000000
      }
    */

    const {
      deviceID,
      lat,
      lng,
      time
    } = data;


    // Validate
    if (!deviceID || lat == null || lng == null) {

      console.log("❌ Invalid GPS data:", data);
      return;
    }


    console.log("📍 GPS RX:", deviceID, lat, lng);


    /* ===== SAVE TO REALTIME DB ===== */

    const ref = rtdb.ref(locations/${deviceID});

    await ref.update({
      lat: lat,
      lng: lng,
      time: time || Date.now(),
      realtime: true,
      updatedAt: Date.now()
    });


    console.log("✅ Saved to RTDB → locations/" + deviceID);

  }
  catch (err) {

    console.log("❌ GPS Error:", err.message);

  }
});


/* ========== EXPORT ========== */

module.exports = {
  mqttClient,
  listenDeviceStatus
};
