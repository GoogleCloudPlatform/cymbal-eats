/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

const express = require('express');
const cors = require('cors');
const app = express();
const axios = require('axios');
app.use(cors());
app.use(express.json());
const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`API listening on port ${port}`);
});
const {Firestore} = require('@google-cloud/firestore');
const {PubSub} = require('@google-cloud/pubsub');
const db = new Firestore();
const pubsub = new PubSub();

const admin = require('firebase-admin');
admin.initializeApp();

const TOPIC_NAME = 'order-topic';

const inventoryServer = axios.create({
  baseURL: process.env.INVENTORY_SERVICE_URL,
  headers: {
    get: {
      "Content-Type": 'application/json'
    }
  }
})

app.get('/order', async (req, res) => {
  try {
    const orderColl = await db.collection(`orders`).get();
    const orders = orderColl.docs.map(d => d.data());
    res.json({status: 'success', data: orders});
  } catch (ex) {
    console.error(ex);
    res.status(500).json({error: ex.toString()});
  }
})

app.get('/orders/customer', async (req, res) => {
  try {
    if (req.headers['authorization'] != null && req.headers['authorization']
        != "undefined") {
      var userId = await getUserIdFromAuthHeader(req.headers['authorization']);
      const orderColl = await db.collection(`orders`).where('userId', '==',
          userId).get();
      const orders = orderColl.docs.map(d => d.data());
      res.json({status: 'success', data: orders});
    } else {
      console.error('Unauthorized');
      res.status(401).json({error: 'Unauthorized'});
    }
  } catch (ex) {
    console.error(ex);
    res.status(500).json({error: ex.toString()});
  }
})

app.get('/order/:orderNumber', async (req, res) => {
  try {
    const orderNumber = req.params.orderNumber;
    const orderDoc = await db.doc(`orders/${orderNumber}`).get();
    if (orderDoc.exists) {
      res.json({status: 'success', data: orderDoc.data()});
    } else {
      res.status(404).json({error: `Order "${orderNumber}" not found`});
    }
  } catch (ex) {
    console.error(ex);
    res.status(500).json({error: ex.toString()});
  }
})

async function getUserIdFromAuthHeader(authHeader) {
  if (authHeader) {
    const token = await admin.auth().verifyIdToken(authHeader);
    return token.uid;
  }
}

app.post('/order', async (req, res) => {
  try {

    var userId = null;
    if (req.headers['authorization'] != null && req.headers['authorization']
        != "undefined") {
      userId = await getUserIdFromAuthHeader(req.headers['authorization']);
    }

    if (!await inventoryAvailable(req.body.orderItems)) {
      throw 'Incorrect Order Quantity or Item';
    }

    if (userId) {
      req.body.userId = userId;
    }
    const orderNumber = await createOrderRecord(req.body);
    await subtractFromInventory(req.body.orderItems);
    res.json({orderNumber: orderNumber});
    const data = req.body;

    if (userId) {
      data.userId = userId;
    }

    data.orderNumber = orderNumber;

    publishMessage(data);
  } catch (ex) {
    console.error(ex);
    res.status(500).json({error: ex.toString()});
  }
})

app.delete('/order/:orderNumber', async (req, res) => {
  try {
    const orderDoc = db.doc(`orders/${req.params.orderNumber}`);
    await orderDoc.delete();
    res.json({status: 'success'});
  } catch (ex) {
    console.error(ex);
    res.status(500).json({error: ex.toString()});
  }
})

app.patch('/order/:orderNumber', async (req, res) => {
  try {
    const orderDoc = db.doc(`orders/${req.params.orderNumber}`);
    await orderDoc.update(req.body);
    res.json({status: 'success'});
  } catch (ex) {
    console.error(ex);
    res.status(500).json({error: ex.toString()});
  }
})

async function inventoryAvailable(orderItems) {
  const inventory = await inventoryServer.get("/getAvailableInventory");
  const inventoryDict = {};
  for (item in inventory.data) {
    inventoryDict[parseInt(
        inventory.data[item].ItemID)] = inventory.data[item].Inventory;
  }
  for (oI in orderItems) {
    var orderItem = orderItems[oI];
    if (!(orderItem.id in inventoryDict) || (inventoryDict[orderItem.id]
        < orderItem.quantity)) {
      return false;
    }
  }
  return true;
}

async function createOrderRecord(requestBody) {
  const orderNumber = getNewOrderNumber();
  const orderDoc = db.doc(`orders/${orderNumber}`);
  await orderDoc.set({
    orderNumber: orderNumber,
    userId: requestBody.userId ? requestBody.userId : '',
    name: requestBody.name,
    email: requestBody.email,
    address: requestBody.address,
    city: requestBody.city,
    state: requestBody.state,
    zip: requestBody.zip,
    orderItems: requestBody.orderItems,
    status: 'New',
    statusUpdatedAt: new Date(),
    placedAt: new Date()
  });
  return orderNumber;
}

async function subtractFromInventory(orderItems) {
  await inventoryServer.post("/updateInventoryItem",
      orderItems.map(x => ({
        itemID: x.id,
        inventoryChange: -x.quantity
      }))
  );
}

function getNewOrderNumber() {
  return Math.round(10000 + Math.random() * 90000);
}

async function publishMessage(data) {
  try {
    const dataBuffer = Buffer.from(JSON.stringify(data))
    const messageId = await pubsub
        .topic(TOPIC_NAME)
        .publishMessage({data: dataBuffer});
    console.log(`Message ${messageId} published.`);
  } catch (error) {
    console.error(`Received error while publishing: ${error.message}`);
  }
}

app.post('/order/points', async (req, res) => {

  try {

    const orderNumber = req.body.message.attributes.orderNumber;
    const rewardPoints = parseInt(req.body.message.attributes.rewardPoints);
    const totalAmount = parseFloat(
        parseFloat(req.body.message.attributes.totalAmount).toFixed(2));

    const updateRec = {
      'rewardPoints': rewardPoints,
      'totalAmount': totalAmount
    };

    const orderDoc = db.doc(`orders/${orderNumber}`);
    if (orderDoc) {
      await orderDoc.update(updateRec);
      res.json({status: 'success'});
    } else {
      console.log("Order not found. orderNumber: ", orderNumber);
    }
  } catch (ex) {
    console.error(ex);
    res.status(500).json({error: ex.toString()});
  }
})
