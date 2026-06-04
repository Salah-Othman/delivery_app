const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

/**
 * Auto-assign a provider to a pending order.
 * Triggered when a new order document is created.
 */
exports.matchProvider = functions.firestore
  .document("orders/{orderId}")
  .onCreate(async (snap, context) => {
    const order = snap.data();

    const providers = await db
      .collection("providers")
      .where("available", "==", true)
      .where("services", "array-contains", order.serviceType)
      .get();

    if (providers.empty) {
      return null;
    }

    // Simple: assign the provider with fewest orders
    let bestProvider = null;
    let minOrders = Infinity;

    providers.forEach((doc) => {
      const p = doc.data();
      if (p.totalOrders < minOrders) {
        minOrders = p.totalOrders;
        bestProvider = { id: doc.id, ...p };
      }
    });

    if (bestProvider) {
      await snap.ref.update({
        providerId: bestProvider.id,
        status: "accepted",
      });
    }

    return null;
  });

/**
 * Update provider rating when a new review is added.
 */
exports.updateProviderRating = functions.firestore
  .document("reviews/{reviewId}")
  .onCreate(async (snap, context) => {
    const review = snap.data();

    const reviews = await db
      .collection("reviews")
      .where("providerId", "==", review.providerId)
      .get();

    let total = 0;
    reviews.forEach((doc) => {
      if (doc.id !== context.params.reviewId) {
        total += doc.data().rating;
      }
    });
    total += review.rating;
    const avg = total / (reviews.size);

    await db
      .collection("providers")
      .doc(review.providerId)
      .update({ rating: Math.round(avg * 10) / 10 });

    return null;
  });
