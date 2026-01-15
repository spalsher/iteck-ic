# WebRTC Chat Backend

Node.js backend server for WebRTC chat application with Express and Socket.io.

## Features

- User authentication with JWT
- WebRTC signaling server
- Media file upload/download
- Contact management
- QR code generation
- Real-time user status updates

## Prerequisites

- Node.js 18.x or 20.x LTS
- MongoDB 6.0+
- npm 9.x or higher

## Installation

1. Install dependencies:
```bash
npm install
```

2. Create `.env` file in the backend root directory:
```env
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb://localhost:27017/webrtc_chat
JWT_SECRET=your_super_secret_jwt_key_change_in_production
JWT_EXPIRE=7d
MAX_FILE_SIZE=10485760
ALLOWED_FILE_TYPES=image/jpeg,image/png,image/gif,video/mp4,video/webm
CORS_ORIGIN=*
RATE_LIMIT_WINDOW=15
RATE_LIMIT_MAX=100
```

3. Make sure MongoDB is running:
```bash
# Local MongoDB
mongod

# Or use MongoDB Atlas (cloud)
```

## Running the Server

Development mode with auto-reload:
```bash
npm run dev
```

Production mode:
```bash
npm start
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/refresh` - Refresh JWT token (protected)

### Users
- `GET /api/users/me` - Get current user (protected)
- `GET /api/users/:id` - Get user by ID (protected)
- `GET /api/users/search?username=xxx` - Search users (protected)
- `GET /api/users/:id/qr` - Get user QR code (protected)
- `POST /api/users/contacts/:userId` - Add contact (protected)
- `DELETE /api/users/contacts/:userId` - Remove contact (protected)

### Media
- `POST /api/media/upload` - Upload media file (protected)
- `GET /api/media/:filename` - Get media file
- `DELETE /api/media/:filename` - Delete media file (protected)

### Health Check
- `GET /api/health` - Server health check

## Socket.io Events

### Client to Server
- `call-request` - Initiate a call
- `call-accept` - Accept incoming call
- `call-reject` - Reject incoming call
- `call-end` - End active call
- `offer` - Send WebRTC offer
- `answer` - Send WebRTC answer
- `ice-candidate` - Send ICE candidate
- `message` - Send text message
- `typing` - User is typing
- `stop-typing` - User stopped typing

### Server to Client
- `call-request` - Incoming call request
- `call-accept` - Call accepted
- `call-reject` - Call rejected
- `call-end` - Call ended
- `call-failed` - Call failed
- `offer` - WebRTC offer received
- `answer` - WebRTC answer received
- `ice-candidate` - ICE candidate received
- `message` - Message received
- `typing` - Contact is typing
- `stop-typing` - Contact stopped typing
- `user-online` - User came online
- `user-offline` - User went offline

## Project Structure

```
backend/
├── src/
│   ├── controllers/      # Request handlers
│   ├── middleware/       # Express middleware
│   ├── models/          # Mongoose models
│   ├── routes/          # API routes
│   ├── socket/          # Socket.io handlers
│   ├── utils/           # Utility functions
│   └── server.js        # Main server file
├── uploads/             # Media file storage
├── .env                 # Environment variables
├── .gitignore
├── package.json
└── README.md
```

## Testing

Run tests:
```bash
npm test
```

## Security

- Helmet for security headers
- Rate limiting on API endpoints
- JWT authentication
- Password hashing with bcrypt
- File type validation
- CORS configuration

## License

MIT
