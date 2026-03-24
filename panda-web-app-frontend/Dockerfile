# Version of Vue.js app 
FROM node:20.18 

# Set working directory
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy app source code and build it
COPY . .
RUN npm run build

# Expose port 80 (matches vite.config.js server.port)
EXPOSE 80

# Start Vite development server
CMD ["npm", "run", "dev"]
