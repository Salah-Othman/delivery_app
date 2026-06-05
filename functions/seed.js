const admin = require("firebase-admin");

const serviceAccount = require("../service-account.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function seed() {
  console.log("Seeding data...");

  // 1. Categories
  const categories = [
    { id: "plumbing", name: "سباكة", icon: "🔧", order: 1 },
    { id: "electricity", name: "كهرباء", icon: "⚡", order: 2 },
    { id: "ac", name: "تكييف", icon: "❄️", order: 3 },
    { id: "delivery", name: "توصيل", icon: "📦", order: 4 },
    { id: "carpentry", name: "نجارة", icon: "🪚", order: 5 },
    { id: "painting", name: "دهان", icon: "🎨", order: 6 },
  ];

  for (const cat of categories) {
    await db.collection("categories").doc(cat.id).set(cat);
    console.log(`  ✓ Category: ${cat.name}`);
  }

  // 2. Test provider
  const provider = {
    name: "أحمد محمد",
    phone: "+201234567890",
    services: ["plumbing", "electricity", "ac"],
    available: true,
    totalOrders: 0,
    rating: 4.5,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  const providerRef = await db.collection("providers").add(provider);
  console.log(`  ✓ Provider: ${provider.name} (${providerRef.id})`);

  // 3. Sample pending order
  const order = {
    userId: "test-user-id",
    serviceType: "plumbing",
    description: "تسريب مياه في الحمام",
    address: "أبو قرقاص، مركز المنيا",
    proposedPrice: 150,
    paymentMethod: "cash",
    status: "pending",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  const orderRef = await db.collection("orders").add(order);
  console.log(`  ✓ Sample order: ${orderRef.id}`);

  console.log("\n✅ Seeding complete!");
  process.exit(0);
}

seed().catch((err) => {
  console.error("❌ Seeding failed:", err);
  process.exit(1);
});
