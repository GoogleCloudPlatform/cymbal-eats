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
const app = express();
app.use(express.json());
const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`API listening on port ${port}`);
});
const {Firestore} = require('@google-cloud/firestore');
const db = new Firestore();

app.get('/', async (req, res) => {
  res.send("Partner registration service: RUNNING")
})

app.get('/partners', async (req, res) => {
  try {
    const partnerCollection = await db.collection('partners').get();
    const partners = partnerCollection.docs.map(d => d.data());
    res.json({status: 'success', data: partners});
  }
  catch(ex) {
    console.error(ex);
    res.status(500).json({error: ex.toString()});
  }
})

app.post('/partner', async (req, res) => {
  try {
    const partnerRecord = await savePartnerRecord(req.body);
    res.json({status: 'success', data: partnerRecord});
  }
  catch(ex) {
    console.error(ex);
    res.status(500).json({error: ex.toString()});
  }
})

async function getPartnerRecord(partnerId) {
  const partnerDoc = await db.doc(`partners/${partnerId}`).get();
  return partnerDoc.data();
}

async function savePartnerRecord(requestBody) {
  const partnerId = getNewPartnerId();
  const partnerDocRef = db.doc(`partners/${partnerId}`);
  await partnerDocRef.set({
    partnerId: partnerId,
    createdAt: new Date(),
    ...requestBody
  });
  return await getPartnerRecord(partnerId);
}

function getNewPartnerId() {
  return Math.round(10000 + Math.random() * 90000);
}
