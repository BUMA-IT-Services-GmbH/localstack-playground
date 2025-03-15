package com.example.demo;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {

	private static final Logger log = LoggerFactory.getLogger(DemoApplication.class);

	public static void main(String[] args) {
		log.info("Starting DemoApplication...");
		SpringApplication.run(DemoApplication.class, args);
		DemoApplication demoApplication = new DemoApplication();
		demoApplication.runAwsDownload();
	}

	public void runAwsDownload() {
		log.info("Starting AWS S3 file download...");
		try {
			String accessKeyId = "AKIAIOSFODNN7EXAMPLE";
			String secretAccessKey = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY";
			String region = "us-east-1";
			String bucketName = "idx-test-bucket";
			String accountId = "123456789012";
			String key = "test.txt";
			String destinationFilePath = "/tmp/test.txt";

			AwsS3Client awsS3Client = new AwsS3Client(accessKeyId, secretAccessKey, region, bucketName, accountId);
			awsS3Client.downloadFile(key, destinationFilePath);
			log.info("AWS S3 file download completed successfully.");
		} catch (Exception e) {
			log.error("Error during AWS S3 file download: ", e);
		}
	}
}