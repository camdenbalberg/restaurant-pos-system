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

# Expose the port for the Vite development server
# Typically, Vite runs on port 5173 for development, so exposing 5173
EXPOSE 5173

# Start Vite development server
CMD ["npm", "run", "dev"]
