import { APIGatewayProxyHandler } from 'aws-lambda';

export const handler: APIGatewayProxyHandler = async (event) => {
  const { username, password } = JSON.parse(event.body || '{}');
  // Logic to create a user (e.g., store in a database)
    console.log(`User ${username} registered with password ${password}`);
  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'User registered successfully' }),
  };
};