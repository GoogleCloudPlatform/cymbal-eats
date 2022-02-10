const express = require('express');
const cors = require('cors');
const app = express();
app.use(cors());
app.use(express.json());
const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`API listening on port ${port}`);
});
const {Firestore} = require('@google-cloud/firestore');
const firestore = new Firestore();

app.post('/place-order', async (req, res) => {
  try {
    const orderNumber = getNewOrderNumber();
    const body = req.body;
    const orderItems = req.body.orderItems;

    const orderDoc = firestore.doc(`orders/${orderNumber}`);
    await orderDoc.set({
      orderNumber: orderNumber,
      name: req.body.name,
      address: req.body.address,
      city: req.body.city,
      state: req.body.state,
      zip: req.body.zip,
      orderItems: req.body.orderItems
    })
    res.json({orderNumber: orderNumber});
  }
  catch(ex) {
    res.status(500).json({error: ex.toString()});
  }
})

function getNewOrderNumber() {
  return Math.round(Math.random() * 100000);
}
