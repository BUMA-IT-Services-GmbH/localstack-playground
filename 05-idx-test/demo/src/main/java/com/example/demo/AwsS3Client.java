// Suggested code may be subject to a license. Learn more: ~LicenseLog:2470603249.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:1034334290.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:430179182.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2072146111.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2515052527.
package com.example.demo;

import lombok.RequiredArgsConstructor;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.stereotype.Component;
import org.apache.commons.compress.utils.IOUtils;
import org.slf4j.Logger;

import org.slf4j.LoggerFactory;
import org.springframework.util.StringUtils;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.core.ResponseBytes;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;

import software.amazon.awssdk.services.s3.model.GetObjectResponse;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.Objects;
import java.util.zip.GZIPInputStream;
import java.nio.charset.StandardCharsets;
import java.util.function.Function;

@Component
@EnableConfigurationProperties
@ConfigurationProperties(prefix = "aws.s3")
@RequiredArgsConstructor
public class AwsS3Client {

    private byte[] fileContent;

    private static final Logger logger = LoggerFactory.getLogger(AwsS3Client.class);

    private final String accessKeyId ;
    private final String secretAccessKey;
    private final String region;
    private final String bucketName;


    public void downloadFile(String s3Url) {
        logger.info("Starting download of file {} ", s3Url);
        String[] parts = s3Url.split("/");
        if (parts.length < 4 || !s3Url.startsWith("s3://")) {
            throw new IllegalArgumentException("Invalid S3 URL format: " + s3Url);
        }

        String bucket = parts[2];
        String key = String.join("/", java.util.Arrays.copyOfRange(parts, 3, parts.length));

        logger.info("Bucket {}  and key {}", bucket, key);

        S3Client s3Client = getS3Client();
        GetObjectRequest getObjectRequest = GetObjectRequest.builder()
                .bucket(bucket)
                .key(key)
                .build();

        ResponseBytes<GetObjectResponse> objectBytes;
        try {
            objectBytes = s3Client.getObjectAsBytes(getObjectRequest);
            
            byte[] fileBytes = objectBytes.asByteArray();
            if (key.endsWith(".gz")) {
                try (GZIPInputStream gzipInputStream = new GZIPInputStream(new ByteArrayInputStream(fileBytes))) {
                    logger.info("Unzipping content of file: {}", key);
                     fileBytes = IOUtils.toByteArray(gzipInputStream);
                } catch (IOException e) {
                    throw new RuntimeException("Error unzipping content from gzipped file " + key, e);
                }
            }
            if (fileBytes != null) {
                this.fileContent = fileBytes;
            }
        } catch (Exception e) {
            logger.error("Error downloading file from S3", e);
            throw new RuntimeException("Error downloading file from S3", e);
        }
        logger.info("Successfully downloaded file {} ", s3Url);
    }


    public <R> R mapContent(Function<String, R> mapper) {

        if (Objects.isNull(this.fileContent) ) {
            throw new IllegalStateException("No content available");
        }
        String fileAsString = new String(this.fileContent, StandardCharsets.UTF_8);
        return mapper.apply(fileAsString);
    }

    public S3Client getS3Client() {
        logger.info("Creating S3 client for region: {} and bucket {}", region, bucketName);
        S3Client s3Client = S3Client.builder()
                .region(Region.of(region))
                .credentialsProvider(StaticCredentialsProvider.create(AwsBasicCredentials.create(accessKeyId, secretAccessKey)))            .build();
        return s3Client;
    }
}