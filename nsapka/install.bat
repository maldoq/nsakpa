@echo off
echo ========================================
echo   Installation de N'SAPKA
echo ========================================
echo.

echo [1/3] Nettoyage du projet...
flutter clean

echo.
echo [2/3] Installation des dependances...
flutter pub get

echo.
echo [3/3] Verification de l'installation...
flutter doctor

echo.
echo ========================================
echo   Installation terminee !
echo ========================================
echo.
echo Pour lancer l'application :
echo   1. Lancez votre emulateur
echo   2. Executez : flutter run
echo.
pause
