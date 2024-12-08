## Self Hosted SMS Microservice 
Self hosted Microservice for sending SMS messages using api and easily extendable.

✨ Feature 

>    Full stack Customizable Microsevice for self hosting SMS gateway.

Secure authentication

🚀 Getting Started

- Prerequisites
- Flutter SDK
- Firebase project
- Django backend server
- Android Studio / VS Code
- Setup Firebase
- Create a new Firebase project
- Add your Android/iOS app
- Download google-services.json and place in android/app
- Enable Cloud Messaging in Firebase Console
- Backend Setup

Clone the repository 
```bash
 git clone https://github.com/yourusername/sms_service.git
```
Install Python dependencies 
```bash
 cd backend pip install -r requirements.txt
```

Configure Django settings 
```bash
 python manage.py migrate python manage.py createsuperuser
```

Start the backend server 
```bash
python manage.py runserver
```
Flutter App Setup
Install Flutter dependencies 
```bash 
flutter pub get
```

Update server URL in app configuration

Run the app 
```bash
 flutter run
```
### 📱 Usage

-    Login with your credentials after creating an account in the backend (you can use the admin pannel to create a user)

-    Grant SMS permissions when prompted

-    Now send sms using the api 



### 🛠️ Technical Stack
-  Flutter

-  Firebase Cloud Messaging

-  Django REST Framework

-  SQLite Database

### 📄 License

This project is licensed under the MIT License - see the LICENSE file for details


### 🤝 Contributing - Contributions are welcome! Please feel free to submit a Pull Request.

-  Fork the Project

-  Create your Feature Branch

-  Commit your Changes

-  Push to the Branch

-  Open a Pull Request