// Copyright 2021 Google LLC
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
'use strict';

const imageMagick = require('imagemagick');
const Promise = require("bluebird");
const path = require('path');
const functions = require('@google-cloud/functions-framework');
const vision = require('@google-cloud/vision');
const {Storage} = require('@google-cloud/storage');
const axios = require('axios');
var fs = require('fs');

functions.cloudEvent('process-thumbnails', async (cloudEvent) => {
    console.log(`Event ID: ${cloudEvent.id}`);
    console.log(`Event Type: ${cloudEvent.type}`);

    const file = cloudEvent.data;
    if (!file || !file.name || !file.bucket) {
        console.log('Invalid event data: missing file name or bucket');
        return;
    }

    // Strict validation of the file name format: <integer_id>.<ext>
    const baseName = path.basename(file.name);
    const match = baseName.match(/^(\d+)\.(jpg|jpeg|png|webp)$/i);
    if (!match) {
        console.warn(`Security Warning: Skipping file with invalid filename pattern: "${file.name}"`);
        return;
    }

    const itemID = parseInt(match[1], 10);
    const ext = match[2].toLowerCase();
    const safeFileName = `${itemID}.${ext}`;
    const originalFile = path.join('/tmp/original', safeFileName);
    const thumbFile = path.join('/tmp/thumbnail', safeFileName);

    try {
        console.log(`Received thumbnail request for item ${itemID} (${safeFileName}) from bucket ${file.bucket}`);

        const storage = new Storage();
        const bucket = storage.bucket(file.bucket);
        const thumbBucket = storage.bucket(process.env.BUCKET_THUMBNAILS);

        const client = new vision.ImageAnnotatorClient();
        const visionRequest = {
            image: { source: { imageUri: `gs://${file.bucket}/${file.name}` } },
            features: [
                { type: 'LABEL_DETECTION' },
            ]
        };
        // We launch the vision call first so we can process the thumbnail while we wait for the response.
        const visionPromise = client.annotateImage(visionRequest);

        if (!fs.existsSync("/tmp/original")){
            fs.mkdirSync("/tmp/original", { recursive: true });
        }
        if (!fs.existsSync("/tmp/thumbnail")){
            fs.mkdirSync("/tmp/thumbnail", { recursive: true });
        }

        await bucket.file(file.name).download({
            destination: originalFile
        });

        const originalImageUrl = await bucket.file(file.name).publicUrl()

        console.log(`Downloaded picture into ${originalFile}`);

        const resizeCrop = Promise.promisify(imageMagick.crop);
        await resizeCrop({
            srcPath: originalFile,
            dstPath: thumbFile,
            width: 400,
            height: 400
        });
        console.log(`Created local thumbnail in ${thumbFile}`);

        const thumbnailImage = await thumbBucket.upload(thumbFile);
        const thumbnailImageUrl = thumbnailImage[0].publicUrl();
        console.log(`Uploaded thumbnail to Cloud Storage bucket ${process.env.BUCKET_THUMBNAILS}`);
        const visionResponse = await visionPromise;
        console.log(`Raw vision output for: ${file.name}: ${JSON.stringify(visionResponse[0])}`);
        let status = "Failed"
        let labels = "";
        for (const label of visionResponse[0].labelAnnotations){
            status = label.description == "Food" ? "Ready" : status
            labels = labels.concat(label.description, ", ");
        }
        console.log(`\nVision API labels: ${labels}\n`);
        console.log(`Menu Item status will be set to: ${status}\n`);

        const menuServer = axios.create({
            baseURL: process.env.MENU_SERVICE_URL,
            headers :{
                get: {
                    "Content-Type": 'application/json'
                }
            }
        })
        const item = await menuServer.get(`/menu/${itemID}`);
        // Send update call to menu service
        const request = await menuServer.put(`/menu/${itemID}`, {
            itemImageURL: originalImageUrl,
            itemName: item.data.itemName,
            itemPrice: item.data.itemPrice,
            itemThumbnailURL: thumbnailImageUrl,
            spiceLevel: item.data.spiceLevel,
            status: status,
            tagLine: item.data.tagLine

        })
    } catch (err) {
        console.log(`Error: processing the thumbnail: ${err}`);
    } finally {
        fs.promises.unlink(originalFile).catch(() => {});
        fs.promises.unlink(thumbFile).catch(() => {});
    }
});