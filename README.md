# MongoDB Ops Manager Local Infrastructure

תשתית מקומית מלאה עם MongoDB, MinIO ו-Ops Manager באמצעות Docker Compose.

## 🎯 מטרה

הקמת סביבת פיתוח מקומית לבחינת MongoDB Ops Manager עם תשתית נקייה ומובנת.

## 📋 דרישות מוקדמות

- Docker & Docker Compose מותקנים
- לפחות 8GB RAM פנויים (עבור Ops Manager)
- פורטים הבאים פנויים: `8080`, `9000`, `9001`, `27017`
- **קובץ MongoDB Ops Manager .deb** (יש להוריד ולהציב בתיקיית הפרויקט)

### 📥 הורדת MongoDB Ops Manager

1. גש ל-[MongoDB Download Center](https://www.mongodb.com/try/download/ops-manager)
2. הורד את הקובץ `.deb` של MongoDB Ops Manager (גרסה 8.0+)
3. הצב את הקובץ בתיקיית הפרויקט עם השם: `mongodb-mms-8.0.12.500.20250804T2000Z.amd64.deb`
   (או עדכן את השם בקובץ `docker-compose.yml`)

⚠️ **הערה**: קובץ ה-.deb גדול מ-2GB ולא נכלל במאגר Git. יש להוריד אותו בנפרד.

## 🚀 התחלה מהירה

```bash
# הרמת כל השירותים
make up

# מעקב אחר הלוגים בזמן אמת
make logs-follow

# בדיקת סטטוס השירותים
make status

# בדיקת בריאות השירותים
make health
```

## 🔗 גישה לשירותים

| שירות | URL | משתמש | סיסמה |
|--------|-----|-------|--------|
| **Ops Manager** | http://localhost:8080 | יצירת משתמש ראשון | - |
| **MinIO Console** | http://localhost:9001 | minioadmin | minioadmin123 |
| **MongoDB** | localhost:27017 | admin | admin123 |

## 🛠 פקודות שימושיות

### פקודות בסיסיות
```bash
# הפעלת התשתית
make up

# עצירת התשתית
make down

# הפעלה מחדש
make restart

# צפייה בלוגים
make logs

# מעקב בזמן אמת
make logs-follow
```

### פקודות בדיקה ותחזוקה
```bash
# בדיקת בריאות השירותים
make health

# בדיקת סטטוס
make status

# וריפיקציה מלאה
make verify
```

### פקודות גישה מהירה
```bash
# התחברות ל-MongoDB shell
make mongo-shell

# פתיחת MinIO console
make minio-console

# פתיחת Ops Manager
make ops-manager
```

### ניקוי ואיפוס
```bash
# ניקוי מלא (⚠️ מחיקת כל הנתונים!)
make clean
```

## 📁 מבנה הפרויקט

```
mongo-opsmanager/
├── docker-compose.yml          # הגדרת השירותים הראשית
├── .env                       # משתני סביבה (נחסם על ידי .gitignore)
├── Makefile                   # פקודות ניהול נוחות
├── README.md                  # מדריך זה
├── .gitignore                 # קבצים שלא נכנסים ל-git
└── init-scripts/
    └── mongodb/
        └── 01-init-users.js   # סקריפט אתחול MongoDB
```

## 🔧 הגדרת Ops Manager

### הגדרה ראשונית
1. לאחר הפעלת השירותים, גש ל-http://localhost:8080
2. צור משתמש ראשון (First User Registration)
3. הגדר ארגון ופרויקט
4. התחבר למסד הנתונים המקומי

### חיבור MongoDB
```
Connection String: mongodb://admin:admin123@mongodb:27017
Database Name: opsmanager
```

## 🐛 פתרון בעיות

### Ops Manager לא עולה
```bash
# בדיקת לוגים מפורטת
docker logs ops-manager -f

# וידוא ש-MongoDB זמין
make mongo-shell
```

### בעיות חיבור MongoDB
```bash
# בדיקת חיבור ישיר
docker exec mongodb mongosh --eval "db.adminCommand('ping')"

# בדיקת משתמשים
docker exec mongodb mongosh -u admin -p admin123 --authenticationDatabase admin --eval "db.getUsers()"
```

### בעיות MinIO
```bash
# בדיקת בריאות MinIO
curl -f http://localhost:9000/minio/health/live

# בדיקת buckets
docker exec minio-setup mc ls myminio/
```

### בעיות רשת
```bash
# בדיקת רשת Docker
docker network ls
docker network inspect mongo-opsmanager_opsmanager-network

# בדיקת פורטים תפוסים
lsof -i :8080
lsof -i :9000
lsof -i :27017
```

### איפוס מלא
```bash
# עצירה וניקוי מלא
make clean

# הפעלה מחדש
make up

# בדיקת תקינות
make verify
```

## 📊 מעקב וניטור

### לוגים חשובים
```bash
# לוגי Ops Manager
docker logs ops-manager --tail=50

# לוגי MongoDB
docker logs mongodb --tail=50

# לוגי MinIO
docker logs minio --tail=50
```

### בדיקת ביצועים
```bash
# שימוש במשאבים
docker stats

# מקום דיסק
docker system df
```

## 🔒 אבטחה

⚠️ **חשוב**: התשתית הזו מיועדת לפיתוח בלבד!
- הסיסמאות הן ברירת מחדל פשוטה
- אין הצפנה ב-transit
- אין הגבלות רשת מתקדמות

## 🤝 תרומה ופיתוח

הקוד מובנה באופן מודולרי:
- כל שירות מופרד בבירור
- Health checks אוטומטיים
- נתונים מתמידים דרך volumes
- רשת מבודדת לתקשורת בטוחה

## 📞 עזרה

אם נתקלת בבעיות:
1. הרץ `make health` לבדיקת בריאות השירותים
2. בדוק לוגים עם `make logs-follow`
3. נסה איפוס עם `make clean && make up`

