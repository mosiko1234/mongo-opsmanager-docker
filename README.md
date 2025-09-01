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

⚠️ **חשוב**: 
- קובץ ה-.deb גדול מ-2GB ולא נכלל במאגר Git
- ההתקנה משתמשת ב-Docker emulation (amd64 על arm64) - עלול להיות איטי
- דרושים 8GB RAM פנויים עבור Ops Manager

## 🚀 התחלה מהירה

```bash
# הרמת כל השירותים
docker-compose up -d

# מעקב אחר הלוגים
docker-compose logs -f

# בדיקת סטטוס השירותים
docker-compose ps

# או שימוש ב-Makefile (אופציונלי)
make up
make logs-follow
make status
```

## 🔗 גישה לשירותים

| שירות | URL | משתמש | סיסמה |
|--------|-----|-------|--------|
| **Ops Manager** | http://localhost:8080 | יצירת משתמש ראשון | - |
| **MinIO Console** | http://localhost:9001 | minioadmin | minioadmin123 |
| **MongoDB** | localhost:27017 | admin | admin123 |

## 🛠 פקודות שימושיות

### פקודות Docker Compose בסיסיות
```bash
# הפעלת התשתית
docker-compose up -d

# עצירת התשתית  
docker-compose down

# הפעלה מחדש
docker-compose restart

# צפייה בלוגים
docker-compose logs

# מעקב בזמן אמת
docker-compose logs -f

# בדיקת סטטוס
docker-compose ps
```

### פקודות Makefile (נוחות נוספת)
```bash
# הפעלת התשתית עם הודעות צבעוניות
make up

# בדיקת בריאות השירותים
make health

# התחברות ל-MongoDB shell
make mongo-shell

# פתיחת MinIO console
make minio-console

# ניקוי מלא (⚠️ מחיקת כל הנתונים!)
make clean
```

### בדיקות ידניות
```bash
# בדיקת MongoDB
docker exec mongodb mongosh -u admin -p admin123 --authenticationDatabase admin

# בדיקת Ops Manager
curl http://localhost:8080/account/login

# בדיקת MinIO
curl http://localhost:9000/minio/health/live
```

## 📁 מבנה הפרויקט

```
mongo-opsmanager/
├── docker-compose.yml                              # הגדרת השירותים הראשית
├── Makefile                                       # פקודות ניהול נוחות (אופציונלי)
├── README.md                                      # מדריך זה
├── .gitignore                                     # קבצים שלא נכנסים ל-git
├── mongodb-mms-8.0.12.500.20250804T2000Z.amd64.deb # קובץ התקנת Ops Manager (להוריד בנפרד)
├── init-scripts/
│   └── mongodb/
│       └── 01-init-users.js                       # סקריפט אתחול MongoDB
└── scripts/
    └── install-ops-manager-deb.sh                 # סקריפט התקנת Ops Manager
```

### 🔧 רכיבים עיקריים

1. **docker-compose.yml** - הקובץ המרכזי שמגדיר:
   - MongoDB 7.0 עם אימות
   - MinIO לאחסון גיבויים
   - Ubuntu container עם התקנת Ops Manager

2. **קובץ .deb** - MongoDB Ops Manager 8.0.12 (יש להוריד בנפרד)

3. **סקריפטים** - אתחול אוטומטי של כל הרכיבים

## ⚡ שימוש בפועל

### התחלה מהירה (ללא Makefile)
```bash
# שלב 1: הורד קובץ Ops Manager .deb
# שלב 2: הפעל התשתית
docker-compose up -d

# שלב 3: עקוב אחרי ההתקנה
docker-compose logs -f ops-manager

# שלב 4: בדוק סטטוס
docker-compose ps
```

### שימוש עם Makefile (נוח יותר)
```bash
# הפעלה עם הודעות צבעוניות ופתיחת דפדפן
make up

# בדיקה מהירה של כל המערכת
make health

# מידע מלא על המערכת
make info
```

### מה באמת קורה
1. **MongoDB** עולה תוך 30 שניות
2. **MinIO** עולה תוך דקה ויוצר bucket
3. **Ops Manager** לוקח 5-10 דקות להתקנה מלאה (emulation איטי)
4. **Java process** עולה עם 8GB RAM
5. **Web interface** זמין ב-http://localhost:8080

## 🔧 גישה ראשונה ל-Ops Manager

### אחרי ההפעלה
1. לאחר הפעלת השירותים (כ-5-10 דקות), גש ל-http://localhost:8080
2. תועבר אוטומטית ל-`/account/login`  
3. צור משתמש ראשון (First User Registration)
4. הגדר ארגון ופרויקט

### חיבור MongoDB קיים
```
Connection String: mongodb://admin:admin123@mongodb:27017
Database Name: opsmanager (כבר קיים עם קולקציות)
```

## 🐛 פתרון בעיות

### Ops Manager לא עולה
```bash
# בדיקת לוגים מפורטת
docker logs ops-manager -f

# וידוא ש-MongoDB זמין
docker exec mongodb mongosh -u admin -p admin123 --authenticationDatabase admin

# בדיקת תהליכי Java
docker exec ops-manager ps aux | grep java

# בדיקה שקובץ ה-.deb קיים
ls -la mongodb-mms-*.deb
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

## 🔗 Git Repository

הפרויקט זמין ב-GitHub:
```bash
git clone https://github.com/mosiko1234/mongo-opsmanager-docker.git
cd mongo-opsmanager-docker
```

### 🔄 עדכון הפרויקט
```bash
git pull origin main
```

### 🤝 תרומה לפרויקט
```bash
# יצירת branch חדש
git checkout -b feature/my-improvement

# ביצוע שינויים וcommit
git add .
git commit -m "Add new feature"

# העלאת השינויים
git push origin feature/my-improvement
```

## 📞 עזרה

אם נתקלת בבעיות:
1. הרץ `make health` לבדיקת בריאות השירותים
2. בדוק לוגים עם `make logs-follow`
3. נסה איפוס עם `make clean && make up`
4. בדוק את [הדוקומנטציה ב-GitHub](https://github.com/mosiko1234/mongo-opsmanager-docker)

