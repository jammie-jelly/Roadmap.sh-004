# Use official Node.js image
FROM node:22

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json ./
RUN npm install

# Copy the rest of the application code
COPY . .

# tmole
RUN npm install -g tunnelmole@2.2.14

# Expose port 3000
EXPOSE 3000

# Start both the app and tunnelmole to expose it
CMD ["sh", "-c", "node index.js & tmole 3000"]
