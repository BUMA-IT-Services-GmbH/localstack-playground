package com.example.demo;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectReader;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
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

	private void runAwsDownload() {
		log.info("Starting AWS S3 file download...");
		try {
			String accessKeyId = "YOUR_ACCESS_KEY_ID";
			String secretAccessKey = "YOUR_SECRET_ACCESS_KEY";
			String region = "us-east-1";
			String bucketName = "idx-test-bucket";
			String key = "person.json.gz";

			AwsS3Client awsS3Client = new AwsS3Client(accessKeyId, secretAccessKey, region, bucketName);
            awsS3Client.downloadFile(key);
			log.info("AWS S3 file download completed successfully.");
			
			Person person = awsS3Client.mapContent(content -> {
				try {
                    ObjectMapper mapper = new ObjectMapper();
					ObjectReader objectReader = mapper.readerFor(Person.class);
                    return objectReader.readValue(content);
                } catch (IOException e) {
                    throw new RuntimeException("Error mapping content to Person object", e);
                }
			});
			
			log.info("Person: " + person.toString());
			
		} catch (Exception e) {
			log.error("Error during AWS S3 file download: ", e);
		}
	}
	
	public static class Person {
        private String id;
        private String firstName;
        private String lastName;

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        public String getFirstName() {
            return firstName;
        }
        public void setFirstName(String firstName) {
            this.firstName = firstName;
        }

        public String getLastName() {
            return lastName;
        }
        public void setLastName(String lastName) {
            this.lastName = lastName;
        }
		@Override
        public String toString() { return "Person{" + "id='" + id + '\'' + ", firstName='" + firstName + '\'' + ", lastName='" + lastName + '\'' + '}'; }
    }
}