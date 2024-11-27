# Step 1: Use the latest Node.js image
FROM node:20-slim

# Install wget to download the certificate
RUN apt-get update && apt-get install -y wget

# Step 2: Set working directory inside the container
WORKDIR /app

# Step 3: Copy package.json and package-lock.json for optimized caching
COPY ../../Simple-MERN-App/package.json ../../Simple-MERN-App/package-lock.json ./

# Step 4: Install dependencies
RUN npm install && npm audit fix

# Step 5: Copy the rest of the business_logiclication
COPY ../../Simple-MERN-App/ ./

# Step 6: Expose the business_logic port
EXPOSE 3000

# Step 7: Use backend script
COPY modules/ecs-backend/backend.sh /usr/local/bin/backend.sh
RUN chmod +x /usr/local/bin/backend.sh

# Step 8: Use the backend script as entrypoint
ENTRYPOINT ["/usr/local/bin/backend.sh"]

CMD ["node", "app.js"]
