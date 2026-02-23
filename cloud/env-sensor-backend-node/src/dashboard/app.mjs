import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import {
  DynamoDBDocumentClient,
  ScanCommand,
  QueryCommand,
} from '@aws-sdk/lib-dynamodb';
import ejs from 'ejs';
import { readFile } from 'fs/promises';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

const ONE_DAY_AGO = Date.now() - 60 * 60 * 24 * 1000;

// Get unique device IDs from the last 24 hours
async function getDeviceIds() {
  const tableName = process.env.SENSOR_READINGS_TABLE || '';

  const command = new ScanCommand({
    TableName: tableName,
    ProjectionExpression: 'device_id',
    FilterExpression: '#TS > :timestamp',
    ExpressionAttributeNames: { '#TS': 'timestamp' },
    ExpressionAttributeValues: { ':timestamp': ONE_DAY_AGO },
  });

  const response = await docClient.send(command);
  const deviceIds = [...new Set(response.Items.map((item) => item.device_id))];
  return deviceIds;
}

// Get records for a specific device from the last 24 hours
async function getRecordsForDevice(deviceId) {
  const tableName = process.env.SENSOR_READINGS_TABLE || '';

  const command = new QueryCommand({
    TableName: tableName,
    KeyConditionExpression: 'device_id = :device_id AND #TS > :timestamp',
    ExpressionAttributeNames: { '#TS': 'timestamp' },
    ExpressionAttributeValues: {
      ':device_id': deviceId,
      ':timestamp': ONE_DAY_AGO,
    },
  });

  const response = await docClient.send(command);
  return response.Items || [];
}

// Format timestamp to local time string
function formatTime(timestamp) {
  return new Date(timestamp).toLocaleString('ja-JP', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    timeZone: 'Asia/Tokyo',
  });
}

// Format timestamp to time only
function formatTimeOnly(timestamp) {
  return new Date(timestamp).toLocaleTimeString('ja-JP', {
    hour: '2-digit',
    minute: '2-digit',
    timeZone: 'Asia/Tokyo',
  });
}

// Lambda handler
export async function handler(event) {
  try {
    const deviceIds = await getDeviceIds();
    const selectedDeviceId =
      event.queryStringParameters?.device_id || deviceIds[0];

    let records = [];
    let latestRecord = null;

    if (selectedDeviceId && deviceIds.includes(selectedDeviceId)) {
      records = await getRecordsForDevice(selectedDeviceId);
      if (records.length > 0) {
        latestRecord = records.reduce((max, record) =>
          record.timestamp > max.timestamp ? record : max,
        );
      }
    }

    // Read and render EJS template
    const templatePath = join(__dirname, 'index.html.ejs');
    const template = await readFile(templatePath, 'utf-8');

    const html = ejs.render(template, {
      deviceIds,
      deviceId: selectedDeviceId,
      records,
      latestRecord,
      formatTime,
      formatTimeOnly,
    });

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'text/html; charset=utf-8' },
      body: html,
    };
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'text/plain' },
      body: 'Internal Server Error',
    };
  }
}
