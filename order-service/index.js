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


const TOPIC_NAME = 'order-topic';
const SUB_NAME = "order-subscription"

const inventoryServer = axios.create({
  baseURL: process.env.INVENTORY_SERVICE_URL,
  headers :{ 
    get: {
      "Content-Type": 'application/json'
    }
  }
})

app.post('/place-order', async (req, res) => {
  try {
    if (! await inventoryAvailable(req.body.orderItems)) {
      throw 'Incorrect Order Quantity or Item';
    }
    const orderNumber = await createOrderRecord(req.body);
    const topic = pubsub.topic(TOPIC_NAME);

    await subtractFromInventory(req.body.orderItems);
    const callback = (err, messageId) => {
      if (err) {
        console.err("Error publishing to topic")
      }
    };
    
    topic.publishJSON(req.body, callback);
    res.json({orderNumber: orderNumber});
  }
  catch(ex) {
    console.error(ex);
    res.status(500).json({error: ex.toString()});
  }
})

app.delete('/:orderNumber', async (req, res) => {
  try {
    const orderDoc = db.doc(`orders/${req.params.orderNumber}`);
    await orderDoc.delete();
    res.json({status: 'success'});
  }
  catch(ex) {
    console.error(ex);
    res.status(500).json({error: ex.toString()});
  }
})

app.patch('/:orderNumber', async (req, res) => {
  try {
    const orderDoc = db.doc(`orders/${req.params.orderNumber}`);
    await orderDoc.update(req.body);
    res.json({status: 'success'});
  }
  catch(ex) {
    console.error(ex);
    res.status(500).json({error: ex.toString()});
  }
})

async function inventoryAvailable(orderItems) {
  const inventory = await inventoryServer.get("/getAvailableInventory");
  const inventoryDict = {};
  for (item in inventory.data) {
    inventoryDict[parseInt(inventory.data[item].ItemID)] = inventory.data[item].Inventory;
  }
  for (oI in orderItems) {
    var orderItem = orderItems[oI];
    if (!(orderItem.id in inventoryDict) || (inventoryDict[orderItem.id] < orderItem.quantity)) {
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
    name: requestBody.name,
    email : requestBody.email,
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
