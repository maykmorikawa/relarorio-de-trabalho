# Rotina diaria: coleta a atividade em C:\xampp\htdocs desde a ultima execucao,
# pede ao Claude para atualizar o index.html e faz commit + push.
# Uso manual:  .\atualizar-relatorio.ps1          (execucao completa)
#              .\atualizar-relatorio.ps1 -Teste   (so mostra a atividade coletada)
param([switch]$Teste)

$ErrorActionPreference = 'Continue'
$Repo      = Split-Path $PSScriptRoot -Parent
$Htdocs    = Split-Path $Repo -Parent
$Estado    = Join-Path $PSScriptRoot 'ultima-execucao.txt'
$Atividade = Join-Path $PSScriptRoot 'atividade-do-dia.md'
$LogDir    = Join-Path $PSScriptRoot 'logs'
$Autor     = 'Mayk'
$Ignorar   = @('xampp', 'webalizer', 'img', 'dashboard', (Split-Path $Repo -Leaf))
$Ruido     = '\\(vendor|node_modules|\.git|tmp|logs|cache)\\'
$MaxArquivos = 30

New-Item -ItemType Directory -Force $LogDir | Out-Null
$agora = Get-Date
$log = Join-Path $LogDir ('{0:yyyy-MM-dd}.log' -f $agora)
function Log($msg) {
    $linha = '{0:HH:mm:ss} {1}' -f (Get-Date), $msg
    Write-Host $linha
    Add-Content -Path $log -Value $linha -Encoding UTF8
}

$desde = if (Test-Path $Estado) { [datetime](Get-Content $Estado -Raw).Trim() } else { $agora.Date }
$desdeIso = $desde.ToString('s')
Log "Coletando atividade desde $desdeIso"

# --- Coleta ---------------------------------------------------------------
$blocos = @()
$totalCommits = 0
foreach ($dir in Get-ChildItem $Htdocs -Directory | Where-Object { $Ignorar -notcontains $_.Name }) {
    $commits = @()
    if (Test-Path (Join-Path $dir.FullName '.git')) {
        $commits = @(git -C $dir.FullName log --all --since=$desdeIso --author=$Autor -i `
            --date=format:'%d/%m %H:%M' --pretty=format:'- %ad  %s' 2>$null | Where-Object { $_ })
    }
    $arquivos = @(Get-ChildItem $dir.FullName -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -gt $desde -and $_.FullName -notmatch $Ruido } |
        Sort-Object LastWriteTime -Descending)

    if ($commits.Count -eq 0 -and $arquivos.Count -eq 0) { continue }
    $totalCommits += $commits.Count

    $b = @("## $($dir.Name)", '')
    if ($commits.Count) { $b += "Commits ($($commits.Count)):"; $b += $commits; $b += '' }
    if ($arquivos.Count) {
        $b += "Arquivos alterados ($($arquivos.Count), mostrando ate $MaxArquivos):"
        $b += $arquivos | Select-Object -First $MaxArquivos |
            ForEach-Object { '- ' + $_.FullName.Substring($dir.FullName.Length + 1) }
        $b += ''
    }
    $blocos += ($b -join "`n")
}

if ($blocos.Count -eq 0) {
    Log 'Nenhuma atividade nova. Nada a fazer.'
    if (-not $Teste) { Set-Content $Estado $agora.ToString('s') }
    exit 0
}

$conteudo = @(
    "# Atividade de $($desde.ToString('dd/MM/yyyy HH:mm')) ate $($agora.ToString('dd/MM/yyyy HH:mm'))",
    '',
    "Data de hoje: $($agora.ToString('dd/MM/yyyy'))",
    "Total de commits novos (autor $Autor): $totalCommits",
    ''
) + $blocos
Set-Content -Path $Atividade -Value ($conteudo -join "`n") -Encoding UTF8
Log "Atividade coletada: $($blocos.Count) projeto(s), $totalCommits commit(s)."

if ($Teste) { Get-Content $Atividade -Encoding UTF8; exit 0 }

# --- Atualizacao pelo Claude ------------------------------------------------
Push-Location $Repo
try {
    Log 'Chamando o Claude...'
    & claude -p 'Leia rotina/instrucoes.md e siga as instrucoes. A atividade nova esta em rotina/atividade-do-dia.md.' `
        --allowedTools 'Read,Edit,Glob,Grep' 2>&1 | ForEach-Object { Log "  claude: $_" }
    if ($LASTEXITCODE -ne 0) {
        Log "Claude falhou (codigo $LASTEXITCODE). Estado mantido para tentar de novo na proxima execucao."
        exit 1
    }
    Set-Content $Estado $agora.ToString('s')

    # --- Git ----------------------------------------------------------------
    if (git status --porcelain -- index.html) {
        git add index.html
        git commit -q -m ("Atualiza relatorio de atividades ({0:dd/MM/yyyy})" -f $agora)
        git push -q origin main 2>&1 | ForEach-Object { Log "  git: $_" }
        if ($LASTEXITCODE -eq 0) { Log 'Commit e push concluidos.' } else { Log 'Push falhou; o commit ficou local.' }
    } else {
        Log 'O Claude nao alterou o index.html.'
    }
} finally {
    Pop-Location
}
