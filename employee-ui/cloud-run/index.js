// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

const express = require('express');
const fileUpload = require('express-fileupload');
const {Storage} = require('@google-cloud/storage');
const storage = new Storage();
const path = require('path');
const fs = require('fs');

const ALLOWED_EXTENSIONS = new Set(['jpg', 'jpeg', 'png', 'webp']);

const app = express();
app.use(express.static('public'));
app.use(fileUpload({
  limits: { fileSize: 10 * 1024 * 1024 },
  useTempFiles : true,
  tempFileDir : '/tmp/'
}))

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Started employee-ui-service on port ${PORT}`);
});

app.post('/upload-picture', async (req, res) => {
  if (!req.files || Object.keys(req.files).length === 0 || !req.files.picture) {
    console.log("No file uploaded");
    return res.status(400).send('No file was uploaded.');
  }

  const rawMenuItemId = req.body.menuItemId;
  if (!rawMenuItemId || !/^\d+$/.test(String(rawMenuItemId).trim())) {
    console.log(`Invalid menuItemId rejected: ${rawMenuItemId}`);
    return res.status(400).send('Invalid menuItemId: must be a positive integer.');
  }
  const menuItemId = parseInt(String(rawMenuItemId).trim(), 10);

  const pictureFileExtension = getFileExtension(req.files.picture.name).toLowerCase();
  if (!ALLOWED_EXTENSIONS.has(pictureFileExtension)) {
    console.log(`Invalid file extension rejected: ${pictureFileExtension}`);
    return res.status(400).send('Invalid file type: only JPG, PNG, and WebP images are allowed.');
  }

  console.log(`Receiving picture for menuItemId: ${menuItemId}`);

  const newPictureName = `${menuItemId}.${pictureFileExtension}`;
  const safeFileName = path.basename(newPictureName);
  const newPicture = path.join('/tmp', safeFileName);

  try {
    await req.files.picture.mv(newPicture);
    console.log(`File "${safeFileName}" moved to /tmp`);

    const pictureBucket = storage.bucket(process.env.UPLOAD_BUCKET);
    await pictureBucket.upload(newPicture, { resumable: false });
    console.log(`Uploaded "${safeFileName}" to Cloud Storage bucket "${process.env.UPLOAD_BUCKET}"`);

    res.set('Content-Type', 'text/html');
    res.send('<html>Your menu item is being processed.</html>');
  } finally {
    fs.promises.unlink(newPicture).catch(() => {});
  }
});

function getFileExtension(fileName) {
  return fileName.split('.').pop();
}
