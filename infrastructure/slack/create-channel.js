#!/usr/bin/env node
/**
 * Slack Channel Creation Script for Ora Framework
 * Creates dedicated Slack channel for new project instances
 * 
 * Usage: node create-channel.js <project-name>
 * 
 * Environment Variables:
 *   SLACK_BOT_TOKEN - Slack bot token with channels:write scope
 */

const { WebClient } = require('@slack/web-api');
const process = require('process');

// Configuration
const SLACK_BOT_TOKEN = process.env.SLACK_BOT_TOKEN;
const CHANNEL_PREFIX = process.env.SLACK_CHANNEL_PREFIX || 'ora';

// Colors for output
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
};

function printError(message) {
  console.error(`${colors.red}❌ ${message}${colors.reset}`);
}

function printSuccess(message) {
  console.log(`${colors.green}✅ ${message}${colors.reset}`);
}

function printWarning(message) {
  console.log(`${colors.yellow}⚠️  ${message}${colors.reset}`);
}

function printInfo(message) {
  console.log(`${colors.blue}ℹ️  ${message}${colors.reset}`);
}

function validateProjectName(projectName) {
  if (!projectName) {
    return false;
  }
  
  // Lowercase, alphanumeric, hyphens only
  if (!/^[a-z0-9-]+$/.test(projectName)) {
    return false;
  }
  
  // Cannot start/end with hyphen
  if (projectName.startsWith('-') || projectName.endsWith('-')) {
    return false;
  }
  
  // Minimum length
  if (projectName.length < 2) {
    return false;
  }
  
  return true;
}

function getChannelName(projectName) {
  return `${CHANNEL_PREFIX}-${projectName}-agents`;
}

async function channelExists(client, channelName) {
  try {
    const result = await client.conversations.list({
      types: 'public_channel,private_channel',
      exclude_archived: true,
    });
    
    if (result.ok) {
      return result.channels.some(ch => ch.name === channelName);
    }
    return false;
  } catch (error) {
    printWarning(`Could not check channel existence: ${error.message}`);
    return false;
  }
}

async function createChannel(client, channelName, projectName, isPrivate = false) {
  try {
    const result = await client.conversations.create({
      name: channelName,
      is_private: isPrivate,
    });
    
    if (result.ok && result.channel) {
      const channelId = result.channel.id;
      
      // Set channel topic
      await client.conversations.setTopic({
        channel: channelId,
        topic: `Ora Framework - ${projectName} project agents and notifications`,
      });
      
      // Set channel purpose
      await client.conversations.setPurpose({
        channel: channelId,
        purpose: `Autonomous agent coordination and notifications for ${projectName} project. Managed by Ora Framework.`,
      });
      
      return {
        success: true,
        channel: result.channel,
      };
    } else {
      return {
        success: false,
        error: result.error || 'Unknown error',
      };
    }
  } catch (error) {
    return {
      success: false,
      error: error.message,
    };
  }
}

async function main() {
  const projectName = process.argv[2];
  
  // Validate inputs
  if (!projectName) {
    printError('Project name is required');
    console.log('');
    console.log('Usage: node create-channel.js <project-name>');
    console.log('');
    console.log('Example:');
    console.log('  node create-channel.js my-awesome-project');
    console.log('');
    console.log('Environment Variables:');
    console.log('  SLACK_BOT_TOKEN       - Slack bot token (required)');
    console.log('  SLACK_CHANNEL_PREFIX  - Channel prefix (default: ora)');
    process.exit(1);
  }
  
  if (!validateProjectName(projectName)) {
    printError('Invalid project name format');
    console.log('');
    console.log('Project name must be:');
    console.log('  - Lowercase only');
    console.log('  - Alphanumeric and hyphens only');
    console.log('  - Cannot start/end with hyphen');
    console.log('  - Example: "my-project" or "awesome-app"');
    process.exit(1);
  }
  
  if (!SLACK_BOT_TOKEN) {
    printError('SLACK_BOT_TOKEN environment variable not set');
    console.log('');
    console.log('Get a bot token from: https://api.slack.com/apps');
    console.log('Required scopes: channels:write, channels:manage');
    process.exit(1);
  }
  
  const channelName = getChannelName(projectName);
  
  console.log(`${colors.green}${'='.repeat(80)}`);
  console.log('  SLACK CHANNEL CREATION');
  console.log('='.repeat(80));
  console.log(`${colors.reset}`);
  console.log(`Project Name: ${colors.yellow}${projectName}${colors.reset}`);
  console.log(`Channel Name: ${colors.yellow}#${channelName}${colors.reset}`);
  console.log(`${colors.green}${'='.repeat(80)}${colors.reset}`);
  console.log('');
  
  try {
    // Initialize Slack client
    const client = new WebClient(SLACK_BOT_TOKEN);
    
    // Check if channel already exists
    printInfo('Checking if channel exists...');
    const exists = await channelExists(client, channelName);
    
    if (exists) {
      printWarning(`Channel #${channelName} already exists`);
      const response = process.argv.includes('--force') ? 'y' : null;
      
      if (response !== 'y') {
        console.log('');
        console.log('Channel already exists. Use --force to recreate or choose a different project name.');
        process.exit(0);
      }
    }
    
    // Create channel
    printInfo(`Creating channel #${channelName}...`);
    const result = await createChannel(client, channelName, projectName, false);
    
    if (result.success) {
      const channel = result.channel;
      printSuccess('Channel created successfully!');
      console.log('');
      console.log('Channel Details:');
      console.log(`  Name: #${channelName}`);
      console.log(`  ID:   ${channel.id}`);
      console.log(`  URL:  https://slack.com/app_redirect?channel=${channel.id}`);
      console.log('');
      console.log('Next Steps:');
      console.log(`  1. Invite team members to #${channelName}`);
      console.log(`  2. Configure agent notifications to post to #${channelName}`);
      console.log(`  3. Set up channel integrations (GitHub, LangSmith, etc.)`);
      console.log('');
      process.exit(0);
    } else {
      printError(`Failed to create channel: ${result.error}`);
      process.exit(1);
    }
  } catch (error) {
    printError(`Unexpected error: ${error.message}`);
    if (error.data) {
      console.error('Error details:', JSON.stringify(error.data, null, 2));
    }
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  main().catch(error => {
    printError(`Fatal error: ${error.message}`);
    process.exit(1);
  });
}

module.exports = { createChannel, validateProjectName, getChannelName };

