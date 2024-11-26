import { exec } from 'child_process';

export const handler = async (event: any = {}): Promise<any> => {
    const commands = ['ls -R /var/task', 'ls -R /opt'];
    for (const cmd of commands) {
        try {
            const res = await execShellCommand(cmd);
            console.log(`Result of ${cmd}:\n${res}`);
        } catch (err) {
            console.log(`error executing command - ${cmd}:`, err);
        }
    }

    function execShellCommand(cmd: any) {
        return new Promise((resolve, reject) => {
            exec(cmd, (error: any, stdout: any, stderr: any) => {
                if (error) {
                    console.warn(error);
                }
                const output = stdout ? stdout : stderr;
                //const formattedOutput = output.split('\n').map((line: any) => `> ${line}`).join('\n');
                const formattedOutput = output.split('\n').join('\n\n');
                resolve(formattedOutput);
            });
        });
    }

    console.log("request:", JSON.stringify(event, undefined, 2));
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: "Hello Mario from Lambda!",
        }),
    };
};