import * as fs from "fs";
import * as path from "path";
import { v4 as uuidv4 } from "uuid";

const walkDirectory = (dirPath: string, depth = 0): string => {
  let output = "";
  const indent = "  ".repeat(depth);

  try {
    const items = fs.readdirSync(dirPath, { withFileTypes: true });

    for (const item of items) {
      const fullPath = path.join(dirPath, item.name);
      output += `${indent}- ${item.name}\n`;

      if (item.isDirectory()) {
        output += walkDirectory(fullPath, depth + 1);
      }
    }
  } catch (err) {
    const errorMsg = err instanceof Error ? err.message : String(err);
    output += `${indent}- [error reading directory: ${errorMsg}]\n`;
  }

  return output;
};

export const handler = async () => {
  console.log("📂 Lambda Deployment Filesystem (/var/task):");
  const rootTree = walkDirectory("/var/task"); // Standard Lambda code mount
  console.log(rootTree);

  console.log("📁 /opt directory:");
  const optTree = walkDirectory("/opt");
  console.log(optTree);

  console.log("📦 Installed packages in node_modules:");
  const nodeModules = walkDirectory("/var/task/node_modules");
  console.log(nodeModules);

  const id = uuidv4();
  console.log(`Generated UUID: ${id}`);

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Hello World2!",
      id,
    }),
  };
};
