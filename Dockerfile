# Use a base image for the Vault server
FROM vault:latest

# Set the working directory
WORKDIR /vault

# Copy any additional configuration files if required
COPY config.hcl /vault/config.hcl

# Expose the Vault server port
EXPOSE 8200

# Start the Vault server
CMD ["vault", "server", "-config=/vault/config.hcl"]
