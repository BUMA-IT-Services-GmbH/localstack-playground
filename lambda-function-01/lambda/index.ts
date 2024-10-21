export const handler = async (event: any = {}): Promise<any> => {
    console.log("request:", JSON.stringify(event, undefined, 2));
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: "Hello Mario from Lambda!",
        }),
    };
};