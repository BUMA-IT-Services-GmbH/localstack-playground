import { APIGatewayProxyHandler } from 'aws-lambda';
import { validateToken } from '/opt/auth';

const { execSync } = require('child_process');

export const handler: APIGatewayProxyHandler = async (event) => {

let combinedOutput = '';

  try {
    console.log('========== function content ==========');
    const varTaskLa = execSync('ls -la /var/task').toString();
    const varTaskR = execSync('ls -R /var/task').toString();
    combinedOutput += 'Contents of /var/task (ls -la):\n' + varTaskLa + '\n';
    combinedOutput += 'Contents of /var/task (ls -R):\n' + varTaskR + '\n';

    console.log('========== layer content ==========');
    const optLa = execSync('ls -la /opt').toString();
    const optR = execSync('ls -R /opt').toString();
    combinedOutput += 'Contents of /opt (ls -la):\n' + optLa + '\n';
    combinedOutput += 'Contents of /opt (ls -R):\n' + optR + '\n';

    console.log(combinedOutput)
  } catch (error) {
    console.error('Error listing directories:', error);
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