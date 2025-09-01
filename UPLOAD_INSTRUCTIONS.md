# 📤 הוראות העלאה לGitHub

המאגר נוצר בהצלחה ב-GitHub: **https://github.com/mosiko1234/mongo-opsmanager-docker**

## 🔧 בעיית הרשאות

יש בעיית הרשאות בין המשתמש המקומי למשתמש GitHub. להלן מספר דרכים לפתור:

### אפשרות 1: העלאה ידנית דרך GitHub Web

1. גש ל-https://github.com/mosiko1234/mongo-opsmanager-docker
2. לחץ על "uploading an existing file" או "Add file" -> "Upload files"
3. גרור את הקבצים הבאים:
   - `docker-compose.yml`
   - `Makefile`
   - `README.md`
   - `.gitignore`
   - תיקיית `init-scripts/`
   - תיקיית `scripts/`

### אפשרות 2: תיקון הרשאות Git

```bash
# בדיקת הגדרות Git נוכחיות
git config --list | grep user

# עדכון הגדרות למשתמש הנכון
git config user.name "mosiko1234"
git config user.email "your-email@example.com"

# או הגדרה גלובלית
git config --global user.name "mosiko1234"
git config --global user.email "your-email@example.com"
```

### אפשרות 3: SSH Key

```bash
# בדיקה אם יש SSH key
ls -la ~/.ssh/

# יצירת SSH key חדש (אם לא קיים)
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# הוספת ל-GitHub:
# 1. העתק את התוכן של ~/.ssh/id_rsa.pub
# 2. גש ל-GitHub Settings -> SSH and GPG keys
# 3. הוסף SSH key חדש
```

### אפשרות 4: Personal Access Token

```bash
# יצירת token ב-GitHub:
# 1. GitHub Settings -> Developer settings -> Personal access tokens
# 2. יצירת token חדש עם הרשאות repo
# 3. שימוש בtoken במקום סיסמה

git remote set-url origin https://YOUR_TOKEN@github.com/mosiko1234/mongo-opsmanager-docker.git
git push -u origin main
```

## 📁 קבצים להעלאה

הקבצים הבאים מוכנים להעלאה:
- ✅ `docker-compose.yml` - הגדרת התשתית המלאה
- ✅ `Makefile` - פקודות ניהול נוחות
- ✅ `README.md` - דוקומנטציה מלאה
- ✅ `.gitignore` - קבצים להתעלמות
- ✅ `init-scripts/mongodb/01-init-users.js` - אתחול MongoDB
- ✅ `scripts/install-ops-manager-deb.sh` - התקנת Ops Manager

## ⚠️ קובץ לא נכלל

- ❌ `mongodb-mms-8.0.12.500.20250804T2000Z.amd64.deb` (2.1GB - גדול מדי לGit)

המשתמש יצטרך להוריד את הקובץ בנפרד מ-MongoDB Download Center.
