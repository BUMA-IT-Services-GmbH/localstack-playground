import { APIGatewayProxyHandler } from 'aws-lambda';
import { validateToken } from '../layers/auth/nodejs';

const { execSync } = require('child_process');

export const handler: APIGatewayProxyHandler = async (event) => {

  try {
    console.log('========== user-login function execution ==========');
    const output = execSync('ls -la /opt/nodejs').toString();
    console.log('Contents of /opt/nodejs:', output);
    const indexts = execSync('cat /opt/nodejs/index.ts').toString();
    console.log('Contents of /opt/nodejs/index.ts:', indexts);
    const nodeModules = execSync('ls -la /opt/nodejs/node_modules').toString();
    console.log('Contents of /opt/nodejs/node_modules:', nodeModules);
  } catch (error) {
    console.error('Error listing /opt/nodejs:', error);
  }

  const { username, password } = JSON.parse(event.body || '{}');
  // Logic to validate user credentials and generate token
  const token = 'generated-token'; // Replace with actual token generation logic
  const isValid = validateToken(token);
  return {
    statusCode: isValid ? 200 : 401,
    body: JSON.stringify({ message: isValid ? 'Login successful' : 'Invalid token' }),
  };
};