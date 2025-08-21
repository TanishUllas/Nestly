# Nestly - Visitor Management System 🏢

A comprehensive visitor management solution for **Ananda Seva Sadana Trust**, built with Flutter and Node.js. Nestly streamlines visitor registration, approval workflows, and security management for residential and institutional facilities.

## 📱 Features

### Core Functionality
- **User Authentication** - Secure login and registration system
- **Visitor Management** - Schedule, approve, and track visitors
- **Pre-Approval System** - Allow residents to pre-approve expected visitors  
- **Real-time Notifications** - Instant alerts for visitor arrivals
- **SOS Emergency System** - Quick emergency assistance feature
- **Guard Communication** - Direct communication with security personnel
- **Profile Management** - User profile and preferences management

### Security Features
- JWT-based authentication
- Encrypted password storage
- Role-based access control
- Secure database connections

## 🏗️ Architecture

### Frontend (Flutter)
- **Framework**: Flutter 3.6.1+
- **State Management**: Provider pattern
- **Navigation**: Named routes with parameter passing
- **Storage**: SharedPreferences for local data persistence
- **HTTP Client**: Built-in http package for API communication

### Backend (Node.js)
- **Runtime**: Node.js with Express.js framework
- **Database**: PostgreSQL with connection pooling
- **Authentication**: JWT tokens with bcryptjs password hashing
- **Email Service**: Nodemailer integration for notifications
- **CORS**: Enabled for cross-origin requests

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.6.1 or higher
- Node.js 16+ and npm
- PostgreSQL database
- Gmail account for email notifications (or configure alternative SMTP)

### Environment Setup

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd nestly
```

2. **Backend Setup**
```bash
cd backend
npm install
```

3. **Create environment file** (`backend/.env`)
```env
DB_HOST=your_postgres_host
DB_USER=your_postgres_user
DB_PASS=your_postgres_password
DB_NAME=your_database_name
DB_PORT=5432
EMAIL_USER=your_gmail@gmail.com
EMAIL_PASS=your_app_password
JWT_SECRET=your_jwt_secret_key
```

4. **Frontend Setup**
```bash
cd frontend
flutter pub get
```

### Running the Application

1. **Start the backend server**
```bash
cd backend
npm run dev  # Development mode with nodemon
# OR
npm start    # Production mode
```

2. **Launch the Flutter app**
```bash
cd frontend
flutter run
```

## 📂 Project Structure

```
nestly/
├── frontend/                 # Flutter mobile application
│   ├── lib/
│   │   ├── main.dart        # App entry point
│   │   └── pages/           # Application screens
│   │       ├── first_page.dart
│   │       ├── login_page.dart
│   │       ├── register_page.dart
│   │       ├── home_dashboard.dart
│   │       ├── sos_page.dart
│   │       ├── call_guard_page.dart
│   │       ├── accept_visitor_page.dart
│   │       ├── profile_page.dart
│   │       ├── pre_approval_page.dart
│   │       ├── my_visitors_page.dart
│   │       ├── schedule_cd_page.dart
│   │       └── schedule_visitor_page.dart
│   └── pubspec.yaml         # Flutter dependencies
│
├── backend/                 # Node.js API server
│   ├── server.js           # Express server setup
│   ├── hash.js             # Password hashing utilities
│   ├── mailer.js           # Email service configuration
│   └── package.json        # Node.js dependencies
│
└── README.md               # This file
```

## 🔧 Configuration

### Database Schema
Ensure your PostgreSQL database includes tables for:
- Users (authentication and profiles)
- Visitors (visitor information and status)
- Approvals (pre-approval records)
- Notifications (system alerts)

### Firebase Integration
The project includes Firebase configuration files:
- `.firebaserc` - Firebase project configuration
- `firebase.json` - Deployment settings
- `apphosting.yaml` - App hosting configuration

## 📱 App Navigation Flow

1. **First Page** → Login/Register options
2. **Authentication** → Login or Register
3. **Home Dashboard** → Central hub with feature access
4. **Feature Pages** → Visitor management, SOS, profiles, etc.

## 🛠️ Development

### Adding New Features
1. Create new page in `frontend/lib/pages/`
2. Add route in `main.dart` 
3. Implement corresponding API endpoints in `backend/server.js`
4. Update navigation from relevant pages

### Testing
```bash
# Frontend testing
cd frontend
flutter test

# Backend testing (when tests are implemented)
cd backend
npm test
```

## 📦 Dependencies

### Frontend Dependencies
- `flutter` - UI framework
- `http` - HTTP client for API calls
- `shared_preferences` - Local data storage
- `url_launcher` - Launch external URLs
- `intl` - Internationalization support
- `cupertino_icons` - iOS-style icons

### Backend Dependencies
- `express` - Web framework
- `pg` - PostgreSQL client
- `bcryptjs` - Password hashing
- `jsonwebtoken` - JWT authentication
- `nodemailer` - Email service
- `cors` - Cross-origin resource sharing
- `dotenv` - Environment variable management

## 🚀 Deployment

### Backend Deployment
The backend can be deployed to platforms like:
- Heroku
- DigitalOcean
- AWS EC2
- Firebase App Hosting (configured)

### Frontend Deployment
- **Android**: `flutter build apk` or `flutter build appbundle`
- **iOS**: `flutter build ios`
- **Web**: `flutter build web`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Support

For support and queries related to Nestly visitor management system:
- Create an issue in this repository
- Contact the development team

## 🎯 Future Enhancements

- [ ] Real-time visitor tracking with GPS
- [ ] QR code generation for visitor passes
- [ ] Integration with access control systems
- [ ] Advanced reporting and analytics
- [ ] Multi-language support
- [ ] Push notifications for mobile devices
- [ ] Visitor photo capture and verification

---

**Built with ❤️ for Ananda Seva Sadana Trust**