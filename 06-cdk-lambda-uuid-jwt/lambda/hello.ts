export const handler = async () => {
  console.log("Hello from HelloWorld Lambda!");
  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Hello World!" }),
  };
};
