package com.example.demo;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.core.ResponseBytes;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

public class AwsS3Client {

    private static final Logger logger = LoggerFactory.getLogger(AwsS3Client.class);

    private final String accessKeyId;
    private final String secretAccessKey;
    private final String region;
    private final String bucketName;
    private final String accountId;

    public AwsS3Client(String accessKeyId, String secretAccessKey, String region, String bucketName, String accountId) {
        this.accessKeyId = accessKeyId;
        this.secretAccessKey = secretAccessKey;
        this.region = region;
        this.bucketName = bucketName;
        this.accountId = accountId;
    }

    public void downloadFile(String key, String destinationFilePath) {
        logger.info("Starting download of file {} from bucket {} to {}", key, bucketName, destinationFilePath);
        try {
            S3Client s3Client = getS3Client();
            GetObjectRequest getObjectRequest = GetObjectRequest.builder()
                    .bucket(bucketName)
                    .key(key)
                    .build();

            ResponseBytes<GetObjectResponse> objectBytes = s3Client.getObjectAsBytes(getObjectRequest);

            try (OutputStream outputStream = new FileOutputStream(destinationFilePath)) {
                outputStream.write(objectBytes.asByteArray());
            }

            logger.info("Successfully downloaded file {} from bucket {} to {}", key, bucketName, destinationFilePath);
        } catch (IOException | RuntimeException e) {
            logger.error("Error downloading file from S3", e);
            throw new RuntimeException("Error downloading file from S3", e);
        }
    }

    public S3Client getS3Client() {
        logger.info("Creating S3 client for region: {} and bucket {}", region, bucketName);
        S3Client s3Client = S3Client.builder()
                .region(Region.of(region))
                .credentialsProvider(StaticCredentialsProvider.create(AwsBasicCredentials.create(accessKeyId, secretAccessKey)))
                .build();
        return s3Client;
    }
}