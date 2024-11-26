import { APIGatewayProxyHandler } from 'aws-lambda';
import { validateToken } from '/opt/auth';

const { execSync } = require('child_process');

export const handler: APIGatewayProxyHandler = async (event) => {

let combinedOutput = '';

  try {
    const functionContent = '========== function content ==========\n';
    const varTaskLa = execSync('ls -la /var/task').toString();
    const varTaskR = execSync('ls -R /var/task').toString();
    combinedOutput += functionContent;
    combinedOutput += 'Contents of /var/task (ls -la):\n' + varTaskLa + '\n';
    combinedOutput += 'Contents of /var/task (ls -R):\n' + varTaskR + '\n';

    const layerContent = '========== layer content ==========\n';
    const optNodejsLa = execSync('ls -la /opt/nodejs').toString();
    const opNodejstR = execSync('ls -R /opt/nodejs').toString();
    combinedOutput += layerContent;
    combinedOutput += 'Contents of /opt/nodejs (ls -la):\n' + optNodejsLa + '\n';
    combinedOutput += 'Contents of /opt/nodejs (ls -R):\n' + opNodejstR + '\n';

    console.log('\n' + combinedOutput);
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