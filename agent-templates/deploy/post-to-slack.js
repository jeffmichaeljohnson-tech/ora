#!/usr/bin/env node
/**
 * Post message to Slack channel
 * Usage: node post-to-slack.js "#channel-name" "Message content"
 */

const https = require('https');

const SLACK_WEBHOOK = process.env.SLACK_WEBHOOK_URL || '';

if (!SLACK_WEBHOOK) {
    console.error('Error: SLACK_WEBHOOK_URL environment variable not set');
    console.error('Set it with: export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"');
    process.exit(1);
}

const channel = process.argv[2] || '#ora-agents';
const message = process.argv[3] || '';

if (!message) {
    console.error('Usage: node post-to-slack.js "#channel-name" "Message content"');
    process.exit(1);
}

const payload = JSON.stringify({
    text: message,
    channel: channel,
    username: 'Ora Agent System',
    icon_emoji: ':robot_face:'
});

const url = new URL(SLACK_WEBHOOK);
const options = {
    hostname: url.hostname,
    path: url.pathname + url.search,
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload)
    }
};

const req = https.request(options, (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
        if (res.statusCode === 200) {
            console.log('✅ Message posted to Slack');
        } else {
            console.error(`❌ Slack returned ${res.statusCode}: ${data}`);
            process.exit(1);
        }
    });
});

req.on('error', (error) => {
    console.error('❌ Error posting to Slack:', error.message);
    process.exit(1);
});

req.write(payload);
req.end();

