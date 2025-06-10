const functions = require("firebase-functions");
require('dotenv').config();
/* eslint-disable max-len */
const stripeSecretKey = "";
/* eslint-enable max-len */
const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);
const cors = require("cors")({ origin: true });
const jwt = require("jsonwebtoken");
const axios = require("axios");

// DoorDash Drive Credentials
const DEVELOPER_ID = "c83ea729-aa59-42e2-8083-839147dc73ce";
const KEY_ID = "2c5b6eea-be1e-4c0e-9315-c9b49db22ef8";
const SIGNING_SECRET = "gskOrGtqjeI2zkmUDyNiv8JViGlOwXcthSvJ-VIPapM";

function generateDoorDashToken() {
  const payload = {
    aud: "doordash",
    iss: DEVELOPER_ID,
    kid: KEY_ID,
    exp: Math.floor(Date.now() / 1000) + 300,
    iat: Math.floor(Date.now() / 1000),
  };

  const decodedSecret = Buffer.from(SIGNING_SECRET, 'base64url');

  return jwt.sign(payload, decodedSecret, {
    algorithm: "HS256",
    header: {
      kid: KEY_ID,
      "dd-ver": "DD-JWT-V1", // 👈 Required version field
    },
  });
}

exports.createPaymentIntent = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const { amount, currency } = req.body;

      const paymentIntent = await stripe.paymentIntents.create({
        amount: parseInt(amount),
        currency,
        payment_method_types: ["card"],
      });

      res.send({
        client_secret: paymentIntent.client_secret,
        paymentIntentId: paymentIntent.id,
      });
    } catch (err) {
      console.error("Stripe error", err);
      res.status(500).send({ error: err.message });
    }
  });
});

exports.createCheckoutSession = functions.https.onRequest(async (req, res) => {
  const { amount, currency } = req.body;

  try {
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency,
          product_data: {
            name: 'Your Product',
          },
          unit_amount: parseInt(amount), // in cents
        },
        quantity: 1,
      }],
      mode: 'payment',
      success_url: 'http://localhost:5000/payment-success', // ✅ Replace with your local dev success page
      cancel_url: 'http://localhost:5000/payment-cancel',   // ✅ Replace with your local dev cancel page
    });

    res.status(200).json({ checkout_url: session.url, paymentIntentId: session.payment_intent });
  } catch (e) {
    console.error('Stripe Checkout Error:', e);
    res.status(500).send({ error: e.message });
  }
});

exports.refundPayment = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const { paymentIntentId, amount } = req.body;

      const refund = await stripe.refunds.create({
        payment_intent: paymentIntentId,
        amount: amount ? parseInt(amount) : undefined,
      });

      res.send({
        success: true,
        refund,
      });
    } catch (err) {
      console.error("Refund error", err);
      res.status(500).send({ error: err.message });
    }
  });
});


//creating door dash delivery

exports.createDoorDashDelivery = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    const token = generateDoorDashToken();

    const deliveryData = {
      external_delivery_id: `order-${Date.now()}`,
      pickup_address: '901 Market Street 6th Floor San Francisco, CA 94103',
      pickup_business_name: 'Wells Fargo SF Downtown',
      pickup_phone_number: '+16505555555',
      dropoff_address: req.body.dropoffAddress,
      dropoff_phone_number: req.body.customerPhone,
      dropoff_contact_given_name: req.body.customerName,
      dropoff_contact_family_name: "",
      order_value: req.body.orderValue,
    };

    try {
      const response = await axios.post(
        "https://openapi.doordash.com/drive/v2/deliveries",
        deliveryData,
        {
          headers: {
            Authorization: `Bearer ${token}`,
            "Content-Type": "application/json",
          },
        }
      );

      res.status(200).send(response.data);
    } catch (error) {
      console.error("DoorDash API Error:", error.response?.data || error.message);
      res.status(500).send({ error: error.response?.data || error.message });
    }
  });
});



//checking delivery status 

exports.trackDoorDashDelivery = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    const token = generateDoorDashToken();
    const deliveryId = req.body.externalDeliveryId; // should be like 'order-...'

    try {
      const response = await axios.get(
        `https://openapi.doordash.com/drive/v2/deliveries/${deliveryId}`,
        {
          headers: {
            Authorization: `Bearer ${token}`,
            "Content-Type": "application/json",
          },
        }
      );

      res.status(200).send(response.data);
    } catch (error) {
      console.error("Track Delivery Error:", error.response?.data || error.message);
      res.status(500).send({ error: error.response?.data || error.message });
    }
  });
});


//cancel doordash delivery

exports.cancelDoorDashDelivery = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    const token = generateDoorDashToken();
    const deliveryId = req.body.externalDeliveryId;

    try {
      const response = await axios.post(
        `https://openapi.doordash.com/drive/v2/deliveries/${deliveryId}/cancel`,
        {},
        {
          headers: {
            Authorization: `Bearer ${token}`,
            "Content-Type": "application/json",
          },
        }
      );

      res.status(200).send(response.data);
    } catch (error) {
      console.error("Cancel Error:", error.response?.data || error.message);
      res.status(500).send({ error: error.response?.data || error.message });
    }
  });
});


// https://us-central1-genghis-khan-restaurant.cloudfunctions.net/cancelDoorDashDelivery