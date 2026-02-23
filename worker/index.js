/**
 * AWS Lambda Handler for Welcome Email Worker
 * Processes messages from SQS (originally published to SNS)
 */
export const handler = async (event) => {
  console.log(`Processing ${event.Records.length} messages...`);

  for (const record of event.Records) {
    try {
      // 1. SQS message body is a stringified JSON
      const sqsBody = JSON.parse(record.body);

      // 2. Since this comes via SNS -> SQS subscription, 
      // the actual message sent by the backend is in the 'Message' field.
      const userData = JSON.parse(sqsBody.Message);

      const userEmail = userData.email;

      console.log("--------------------------------------------------");
      console.log(`[EMAIL SERVICE] Sending welcome email to: ${userEmail}`);
      console.log(`[MESSAGE] "Welcome to our service! We're glad to have you."`);
      console.log(`[STATUS] Successfully processed at: ${new Date().toISOString()}`);
      console.log("--------------------------------------------------");
      
    } catch (error) {
      console.error("Error processing record:", error);
      console.error("Raw record body:", record.body);
      // In a real scenario, you might want to throw the error to let SQS retry
      // throw error; 
    }
  }

  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Worker processed successfully" }),
  };
};
