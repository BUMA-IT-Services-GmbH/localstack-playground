import { APIGatewayProxyHandler } from 'aws-lambda';

const { execSync } = require('child_process');

export const handler: APIGatewayProxyHandler = async (event) => {

  try {
    console.log('========== system log ==========');
    console.log('Contents of /opt directoy is:\r\n', execSync('ls -R /opt').toString());
    console.log('Contents of /var/task directory is:\r\n', execSync('ls -R /var/task').toString());
    //console.log('Contents of /var/task/index.js directory is:\r\n', execSync('cat /var/task/index.js').toString());
    //console.log('========== user-login function execution ==========');
    //console.log('Event:', event);
  } catch (error) {
    console.error('Error listing directories and/or files:', error);
  }

  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'test123' }),
  };
};