import { APIGatewayProxyHandler } from 'aws-lambda';
import { validateToken } from '/opt/nodejs/lambda-layers/auth';

const { execSync } = require('child_process');

export const handler: APIGatewayProxyHandler = async (event) => {

  try {
    const output = execSync('ls -la /opt/nodejs').toString();
    console.log('Contents of /opt/nodejs:', output);
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