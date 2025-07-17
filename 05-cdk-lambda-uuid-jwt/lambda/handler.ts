import { v4 as uuidv4 } from "uuid";
import jwt from "jsonwebtoken";

export const handler = async (event: any) => {
  const id = uuidv4();
  const token = jwt.sign({ id }, "dummy-secret", { expiresIn: "1h" });

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Lambda invoked successfully!",
      id,
      token,
    }),
  };
};
