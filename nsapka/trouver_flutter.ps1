# Script pour trouver et configurer Flutter sur Windows

Write-Host "Recherche de Flutter sur votre système..." -ForegroundColor Cyan

# Emplacements communs où Flutter peut être installé
$emplacements = @(
    "C:\src\flutter",
    "$env:USERPROFILE\flutter",
    "$env:USERPROFILE\AppData\Local\flutter",
    "C:\flutter",
    "C:\Program Files\flutter",
    "C:\Program Files (x86)\flutter",
    "$env:LOCALAPPDATA\flutter"
)

$flutterTrouve = $null

foreach ($emplacement in $emplacements) {
    $flutterBat = Join-Path $emplacement "bin\flutter.bat"
    if (Test-Path $flutterBat) {
        $flutterTrouve = $emplacement
        Write-Host "✓ Flutter trouvé à : $flutterTrouve" -ForegroundColor Green
        break
    }
}

if (-not $flutterTrouve) {
    Write-Host "✗ Flutter n'a pas été trouvé dans les emplacements standards." -ForegroundColor Red
    Write-Host ""
    Write-Host "Recherche dans tous les disques (cela peut prendre du temps)..." -ForegroundColor Yellow
    
    # Recherche plus approfondie
    $disques = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -like "C:\*" -or $_.Root -like "D:\*" }
    foreach ($disque in $disques) {
        try {
            $resultat = Get-ChildItem -Path $disque.Root -Filter "flutter.bat" -Recurse -ErrorAction SilentlyContinue -Depth 3 | Select-Object -First 1
            if ($resultat) {
                $flutterTrouve = $resultat.Directory.Parent.FullName
                Write-Host "✓ Flutter trouvé à : $flutterTrouve" -ForegroundColor Green
                break
            }
        } catch {
            # Ignorer les erreurs d'accès
        }
    }
}

if ($flutterTrouve) {
    $binPath = Join-Path $flutterTrouve "bin"
    Write-Host ""
    Write-Host "Chemin du dossier bin : $binPath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Pour ajouter Flutter au PATH de manière permanente :" -ForegroundColor Yellow
    Write-Host "1. Appuyez sur Windows + R" -ForegroundColor White
    Write-Host "2. Tapez : sysdm.cpl et appuyez sur Entrée" -ForegroundColor White
    Write-Host "3. Allez dans l'onglet 'Avancé'" -ForegroundColor White
    Write-Host "4. Cliquez sur 'Variables d'environnement'" -ForegroundColor White
    Write-Host "5. Dans 'Variables système', trouvez 'Path' et cliquez sur 'Modifier'" -ForegroundColor White
    Write-Host "6. Cliquez sur 'Nouveau' et ajoutez : $binPath" -ForegroundColor White
    Write-Host "7. Cliquez sur 'OK' pour fermer toutes les fenêtres" -ForegroundColor White
    Write-Host "8. Redémarrez votre terminal/PowerShell" -ForegroundColor White
    Write-Host ""
    Write-Host "OU exécutez cette commande dans PowerShell (en tant qu'administrateur) :" -ForegroundColor Yellow
    $commande = "[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'User') + ';$binPath', 'User')"
    Write-Host $commande -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Pour tester maintenant (temporaire pour cette session) :" -ForegroundColor Yellow
    Write-Host "`$env:Path += ';$binPath'" -ForegroundColor Cyan
    Write-Host "flutter --version" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "Flutter n'a pas été trouvé sur votre système." -ForegroundColor Red
    Write-Host ""
    Write-Host "Pour installer Flutter :" -ForegroundColor Yellow
    Write-Host "1. Téléchargez Flutter depuis : https://docs.flutter.dev/get-started/install/windows" -ForegroundColor White
    Write-Host "2. Extrayez l'archive dans C:\src\flutter (ou un autre emplacement)" -ForegroundColor White
    Write-Host "3. Ajoutez le chemin bin au PATH comme indiqué ci-dessus" -ForegroundColor White
    Write-Host ""
    Write-Host "OU utilisez Git pour cloner Flutter :" -ForegroundColor Yellow
    Write-Host "git clone https://github.com/flutter/flutter.git -b stable C:\src\flutter" -ForegroundColor Cyan
}

