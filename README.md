# ReallyStick

**Empower Your Habits, Connect with Others, and Achieve Your Goals Together**

ReallyStick is an open-source, privacy-first app designed to help you build and track habits, create and join challenges, and connect with a community of like-minded individuals. Whether you want to quit smoking, learn a new language, or train for a marathon, ReallyStick provides the tools to stay motivated and accountable—with the added power of social support and end-to-end encrypted messaging.

---

## 🌟 Why ReallyStick?

- **Habit Tracking**: Create, track, and visualize your daily habits.
- **Custom Challenges**: Design your own challenges or join those created by others.
- **Community Threads**: Discuss habits and challenges in public threads.
- **Private Messaging**: Communicate securely with end-to-end encryption.
- **Cross-Platform**: Available on the web at [reallystick.com](https://reallystick.com/), and ready for use on Android and iOS, but not yet deployed on stores.
- **Open Source**: Transparent, community-driven development.

---

## 🛠 Installation & Development

### Prerequisites

- Docker & Docker Compose
- Rust & Cargo
- Flutter SDK
- PostgreSQL

### Setup

1. **Start the database container:**
   ```bash
   docker-compose up -d db
   ```
2. **Start the other containers:**
   ```bash
   docker-compose up -d
   ```

### Backend Commands

| Command                                                            | Description                                 |
| ------------------------------------------------------------------ | ------------------------------------------- |
| `sudo docker-compose up -d --build`                                | Build containers                            |
| `cargo install sqlx-cli --no-default-features --features postgres` | Install SQLx CLI tools (required for setup) |
| `sqlx migrate add name_of_your_migration`                          | Create a new migration file                 |
| `sqlx migrate run`                                                 | Run migrations (required for setup)         |
| `cargo run --bin db_tools populate`                                | Populate your database with initial data    |
| `cargo run --bin db_tools reset`                                   | Reset your database                         |

### Database Management

To **drop and recreate** the database:

```bash
docker exec -it db bash
psql -U reallystick -d postgres
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'reallystick';
DROP DATABASE reallystick;
CREATE DATABASE reallystick;
sqlx migrate run
```

To **drop test databases**:

```bash
docker cp db/delete_other_db.sh db:/
docker exec -it db bash
chmod +x delete_other_db.sh
./delete_other_db.sh
psql -U reallystick -d postgres
vacuum;
```

---

## 📱 Running the App

### Web (Chrome)

1. Select **"Chrome (web-javascript)"** in VSCode (bottom right).
2. Open `frontend/main.dart` and click **"Start debugging"** (top right).

---

### External Device

1. Replace all occurrences of `192.168.` in the code with your local IP.
2. Create `frontend/.env` based on `frontend/.env.template` and update the variables (e.g., `API_BASE_URL`).

---

### Run on Android

**Prerequisite:** Follow the instructions in the [Run locally on an external device](#run-locally-on-an-external-device) section first.

1. **Enable Developer Options and USB Debugging:**

   - Go to **Developer Options**.
   - Select **USB Configuration**.
   - Change the setting from **"File Transfer"** (default) to **"Charging"**.
   - When prompted, confirm that you want to **always allow USB debugging** from this device.

2. **Install Android Studio:**

   - Download and install [Android Studio](https://developer.android.com/studio) from the official website.
   - Create a **dummy project** to complete the initial setup.

3. **Install the Android SDK Command-Line Tools:**

   - Open **Android Studio**.
   - Navigate to:
     **Settings** → **SDK Manager** → **Languages & Frameworks** → **Android SDK** → **SDK Tools**.
   - Check the **Android SDK Command-line Tools** box.
   - Click **Apply**.

4. **Verify the Setup:**

   ```bash
   flutter doctor --verbose
   ```

5. **Build and Install the APK:**
   - To build the APK:
     ```bash
     flutter build apk --flavor dev --release
     ```
   - To install on your device:
     ```bash
     flutter install --flavor dev
     ```
   - To run in debug mode:
     ```bash
     flutter run --flavor dev
     ```

---

## Firebase Setup for Notifications

To enable notifications (WebSocket/Push), you need **two Firebase configuration files**:

1. A **Firebase service account JSON file** (for backend authentication with FCM).
2. A **`google-services.json`** file (for Android apps).

---

### **1. Firebase Service Account (Backend)**

This file is required for backend authentication with Firebase Cloud Messaging (FCM).

#### **Steps to Generate Your Own File:**

1. **Create a Firebase Project**:

   - Go to the [Firebase Console](https://console.firebase.google.com/).
   - Click **"Add Project"** and follow the instructions.

2. **Enable Firebase Cloud Messaging (FCM)**:

   - In your project, go to **Project Settings > Cloud Messaging**.
   - Ensure FCM is enabled.

3. **Generate a Service Account Key**:

   - Go to **Project Settings > Service Accounts**.
   - Click **"Generate New Private Key"** (this downloads a `.json` file).
   - Rename the file to:
     ```
     reallystick-firebase-adminsdk.json
     ```

4. **Place the File**:
   - Copy the `.json` file to the **root of the `backend/notifications/` directory**.

---

### **2. `google-services.json` (Android)**

This file is required for Firebase integration in Android apps.

#### **Steps to Generate and Place the File:**

1. **Register Your Android App in Firebase**:

   - In the [Firebase Console](https://console.firebase.google.com/), go to your project.
   - Click **"Add App"** and select **Android**.
   - Enter the package name `com.reallystick`.
   - Follow the instructions to register your app.

2. **Download `google-services.json`**:
   - After registering, Firebase will prompt you to download `google-services.json`.
   - Save this file in:
     ```
     frontend/android/app/google-services.json
     ```

---

## 🌍 Data Sources

- Countries: [REST Countries API](https://restcountries.com/v3.1/all?fields=name,flags,region)

---

## 🤝 Contributing

ReallyStick is open to contributions! Whether you're a developer, designer, or tester, your help is welcome. Check out our [contribution guidelines](CONTRIBUTING.md) to get started.

---

## 📜 License

ReallyStick is licensed under the [MIT License](LICENSE).

---

**Ready to stick to your goals? Join the ReallyStick community today!**

---
