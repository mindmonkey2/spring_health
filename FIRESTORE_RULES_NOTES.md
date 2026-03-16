# Firebase Rules Deployment

To deploy the security rules for Firestore and Storage to the Firebase project, run the following commands from the root directory of this repository:

**Deploy Firestore rules:**
```bash
firebase deploy --only firestore:rules
```

**Deploy Storage rules:**
```bash
firebase deploy --only storage
```
